library(tidyverse)
library(here)
library(microbiome)
library(vegan)
library(brms)
library(tidybayes)
library(phyloseq)


options(repr.plot.width=15, repr.plot.height=15)
# import data 
load(here("data/processed/tax_abundances.RDS"))
load(here("data/processed/pathway_abundances.RDS"))
source("https://raw.githubusercontent.com/HenrikEckermann/in_use/master/mb_helper.R")
source(here("R/ensemble_functions.R"))



# # to download raw data of samples 
# samples <- select(taxa_by_level[[1]], sampleID)
# stor_dir <- "/Volumes/chicken_t5/medic_challenge"
# stor_dir <-here("data/raw")
# 
# url_list <- map(samples, function(sample) {
#   noquote(glue("https://ibdmdb.org/tunnel/static/HMP2/WGS/1818/{sample}.tar"))
# })
# 
# write.table(url_list$sampleID, here("data/raw/url_list.txt"), quote = FALSE, row.names = FALSE, col.names = FALSE)

compare_groups <- function(
  task = "UC_vs_CD",
  feature_name = "species") {
    
    # select data according to feature name      
    if (feature_name %in% names(taxa_by_level)) {
      df <- taxa_by_level[[feature_name]] 
      } else if (feature_name == "pathway") {
      df <- path_abu
     } else if (feature_name == "all_taxa") {
      df <- left_join(
          taxa_by_level[["species"]],
          select(taxa_by_level[["genus"]], - group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["family"]], - group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["order"]], - group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["class"]], - group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["phylum"]], - group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["superkingdom"]], - group),
          by = "sampleID") 
    }


    ###### Select data according to task
    if (task == "IBD_vs_nonIBD") {
        df <- df %>%
            mutate(group = ifelse(group %in% c(1,2), 1, 0))
        df$group <- as.factor(df$group)
     } else if (task == "UC_vs_nonIBD") {
         df <- df %>%
             filter(group %in% c(0, 2)) %>%
             mutate(group = ifelse(group == 2, 1, 0))
         df$group <- as.factor(df$group)
     } else if (task == "CD_vs_nonIBD") {
         df <- df %>%
             filter(group %in% c(0, 1))
         df$group <- droplevels(df$group)
     } else if (task == "UC_vs_CD") {
         df <- df %>%
             filter(group %in% c(1, 2)) %>%
             mutate(group = ifelse(group == 1, 1, 0))
         df$group <- as.factor(df$group)
    }
  
    
    # keep labels separate
    labels <- select(df, group, sampleID)
    
    # prepare dataframe for further analysis/pseq construction
    if (feature_name != "pathway") {
      df <- df %>%
          gather(TaxID, abundance, -sampleID, -group) %>%
          select(-group) %>%
          spread(sampleID, abundance) %>%
          mutate_if(is.numeric, function(x) x/100) %>%
          left_join(taxa_id_info, by = "TaxID") %>%
          select(-TaxID, -Rank) %>% 
          select(Taxon, everything()) %>%
          gather(sampleID, abundance, -Taxon) %>%
          spread(Taxon, abundance)
     } else {
      df <- df %>%
          gather(PathID, abundance, -sampleID, -group) %>%
          select(-group) %>%
          spread(sampleID, abundance) %>%
          mutate_if(is.numeric, function(x) x/100) %>%
          left_join(path_id_info, by = "PathID") %>%
          select(-PathID) %>% 
          select(Pathway, everything()) %>%
          gather(sampleID, abundance, -Pathway) %>%
          spread(Pathway, abundance)
    }
    colnames(df) <- clean_otu_names(colnames(df))
    

    # otus matrix for pseq object
    otu <- df %>% 
      gather(tax_level, value, -sampleID) %>%
      spread(sampleID, value) %>%
      mutate_if(is.numeric, function(abundance) abundance/100) %>%
      arrange(tax_level) %>%
      column_to_rownames("tax_level")  
    otu <- otu_table(otu, taxa_are_rows = TRUE)  
  
    # tax table for pseq object
    if (feature_name %in% names(taxa_by_level)) {
      tax_t <- taxa_id_info %>% 
        filter(TaxID %in% colnames(taxa_by_level[[feature_name]])) %>%
        select(tax_level = Taxon) %>%
        mutate(tax_level = clean_otu_names(tax_level)) %>% 
        arrange(tax_level) %>%
        mutate(rownames = tax_level) %>%
        column_to_rownames("rownames")  %>%
        as.matrix()
    } else {
      tax_t <- path_id_info %>% 
        filter(PathID %in% colnames(path_abu)) %>%
        select(tax_level = Pathway) %>% # pathway now named tax level for conv
        mutate(tax_level = clean_otu_names(tax_level)) %>% 
        arrange(tax_level) %>%
        mutate(rownames = tax_level) %>%
        column_to_rownames("rownames")  %>%
        as.matrix()
    }

    colnames(tax_t) <- c(feature_name)
    tax_t <- tax_table(tax_t)
  
    # sample data object for pseq object
    sample_d <- labels %>%
      mutate(group_backup = ifelse(group == 0, 0, ifelse(group == 1, 1, 2))) %>%
      column_to_rownames("sampleID") %>%
      sample_data()
    sample_d$group_backup <- as.factor(sample_d$group_backup)
  
    # create pseq object
    pseq <- phyloseq(otu, tax_t, sample_d)
    pseq_clr <- transform(pseq, "clr")
  
  
  
    scaling_factor <- ifelse(feature_name == "pathway", 1000, ifelse(feature_name == "species", 400, ifelse(feature_name == "family", 50, ifelse(feature_name == "order", 25, ifelse(feature_name == "class", 12, ifelse(feature_name == "Phylum", 6, ifelse(feature_name == "superkingdom", 3, 100)))))))
    # PCA Biplots (Aitchison)
    pca_plot <- biplot(
      pseq_clr, 
      color = "group", 
      scaling_factor = scaling_factor, 
      loading = ifelse(feature_name == "pathway", 0.06, ifelse(feature_name == "species", 0.08, 0.1)),
      text_size = 6,
      point_size = 6,
      otu_text_size = 6)  
  
    pca_plot1 <- pca_plot[[1]]
    pca_plot2 <- pca_plot[[2]]
  
  
    # # PCoA
    # ord <- ordinate(pseq, "MDS", "bray")
    # plot_ordination(pseq, ord, color = "group") +
    #                 geom_point(size = 5)
  
  
    # PCA 
    pcx <- pseq_clr %>% 
        otu_to_df() %>%
        column_to_rownames("sample_id") %>%
        prcomp()
    
    # extract loadings 
    pcx_rot <- pcx$rotation %>%
      as_tibble() %>%
      add_column(taxa = rownames(pcx$rotation))
    
    pcs <- pcx$x %>% as.data.frame() %>%
      rownames_to_column("sampleID") 
    
    df_pc <- pcs %>% left_join(
      labels,
      by = "sampleID") 
    # 
    # #pcx$sdev^2/sum(pcx$sdev^2)
    # var_exp <- map(seq(1, 170), function(pc) {
    #   round(pcx$sdev[pc]^2/sum(pcx$sdev^2), 3)
    # })
    # 
    # 
    # pca_plot1 <- ggplot(df_pc, aes(PC1, PC2, color = group)) +
    #   geom_point(size = 5) +
    #   theme_bw(base_size = 30) +            
    #   xlab(glue("PC1: [{var_exp[[1]]*100}%]")) +  ylab(glue("PC2: [{var_exp[[2]]*100}%]")) +
    #   ggtitle(glue("{task}_{feature_name}_PCA"))
    # 
    # pca_plot2 <- ggplot(df_pc, aes(PC3, PC4, color = group)) +
    #   geom_point(size = 5) +
    #   theme_bw(base_size = 30) +
    #   xlab(glue("PC1: [{var_exp[[3]]*100}%]")) +  ylab(glue("PC2: [{var_exp[[4]]*100}%]")) +
    #   ggtitle(glue("{task}_{feature_name}_PCA"))
  
  
  
  
    # PCoA
    bray_dist <- df %>% 
      column_to_rownames("sampleID") %>% 
      dist(method = "manhattan") * 0.5
  
  
    pcoax <- cmdscale(bray_dist, eig = T, x.ret = T, k =4)
    data_and_pc <- pcoax$points %>% as.data.frame() %>%
      select(PC1 = V1, PC2 = V2, PC3 = V3, PC4 = V4) %>%
      rownames_to_column("sampleID") %>%
      left_join(labels, by = "sampleID")
  
  
    var_exp <- pcoax$eig/sum(pcoax$eig)
    var_exp <- round(var_exp, 2)
  
  
    pcoa_plot1 <- ggplot(data_and_pc, aes(PC1, PC2, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      xlab(glue("PC1: [{var_exp[[1]]*100}%]")) +  ylab(glue("PC2: [{var_exp[[2]]*100}%]")) +
      ggtitle(glue("{task}_{feature_name}_PCoA"))
  
    pcoa_plot2 <- ggplot(data_and_pc, aes(PC3, PC4, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      xlab(glue("PC3: [{var_exp[[3]]*100}%]")) +  ylab(glue("PC4: [{var_exp[[4]]*100}%]")) +
      ggtitle(glue("{task}_{feature_name}_PCoA"))
  
  
  
    otu <- column_to_rownames(df, "sampleID")
    group <- labels$group
    pm <- adonis(otu ~ group)
    pm_aov <- pm$aov.tab
  
    coefs <- pm$coefficient %>% as.data.frame() %>%
      rownames_to_column("group")
  
    coefs <- coefs %>%
      gather_(key_col = feature_name, value_col = "coef", gather_cols = c(colnames(coefs)[-1])) %>%
      spread(group, coef) 
    head(coefs)
  
  
    if (task == "IBD_vs_nonIBD") {
      coef_v <- "group1"
      coef_title <- "IBD"
     } else if (task == "UC_vs_nonIBD") {
         coef_v <- "group1"
         coef_title <- "UC"
     } else if (task == "CD_vs_nonIBD") {
         coef_v <- "group1"
         coef_title <- "CD"
     } else if (task == "UC_vs_CD") {
         coef_v <- "group1"
         coef_title <- "UC"
    }
  
  
    pmps <- map2(coef_v, coef_title, function(.x, .y) {
        coef <- pm$coefficients[.x,] 
        # make plot that I can manipulate better for apa6th in case
        coef_top <- 
            coef[rev(order(abs(coef)))[1:15]] %>%
            as.data.frame() %>%
            rownames_to_column("top_features") 
        colnames(coef_top) <- c("top_features", "coef_top")
  
    coef_top <- coef_top %>% arrange(desc(coef_top)) %>%
                mutate(top_features = factor(top_features, levels = top_features))
  
        if (feature_name == "pathway") {
  
           p <- ggplot(coef_top, aes(top_features, coef_top)) +
                  geom_bar(stat="identity", fill = "#404040") +
                  xlab("") + ylab(.y) +
                  ggtitle(glue::glue("{task}_{feature_name}_Coefficient: {.x}")) +
                  coord_flip() +
                  theme_bw(base_size = 30)
        } else {
           p <- ggplot(coef_top, aes(top_features, coef_top)) +
                  geom_bar(stat="identity", fill = "#404040") +
                  ylim(-0.1, 0.1) +
                  xlab("") + ylab(.y) +
                  ggtitle(glue::glue("{task}_{feature_name}_Coefficient: {.x}")) +
                  coord_flip() +
                  theme_bw(base_size = 30)
        }
  
  
        top_features <- coef_top$top_features
        list(p, top_features)
    })
  
    # add labels back
    plot_df <- df %>% left_join(
      labels, 
      by = "sampleID")
  
    # plot difference in abundance
  
    colnames(plot_df) <- clean_otu_names(colnames(plot_df)) 
    features_names <- pmps[[1]][[2]] %>% clean_otu_names()
  
  
  
  
  
    dif_ab_plots <- map(features_names, function(feat_name) {
      ggplot(plot_df, aes_string(x = "group", y = feat_name)) +
          geom_boxplot() +
          ggtitle(glue("{task}_{feature_name}_{feat_name}")) +
          theme_bw(base_size = 30)
    })
  
  
  
    ### Bayesian Linear Regression regression shannon on groups
    shannon <- df %>% select(-sampleID) %>%
      compute_shannon()
    shannon_df <- df %>% select(sampleID) %>%
      add_column(shannon = shannon) %>%
      left_join(labels, by = "sampleID")
  
    fit <- brm(
      data = shannon_df,
      family = gaussian(),
      formula = bf(shannon ~ 1 + group, sigma ~ 1 + group),
      file = here(glue("data/models/shannon_brms_{task}_{feature_name}"))
    )
  
    shannon_coef <- posterior_samples(fit) %>%
      select(b_group1, b_sigma_group1) %>% 
      gather(parameter, value) %>%  
      group_by(parameter) %>%
        group_by(parameter) %>%
        do(data.frame(
          median = median(.$value),
          sd = sd(.$value),
          lower = quantile(.$value, 0.025),
          upper = quantile(.$value, 0.975)
        )) %>%
        as_tibble() %>%
        mutate(parameter = ifelse(parameter == "b_sigma_group1", "sigma_difference", "mu_difference")) %>%
        ggplot(aes(x = median, y = parameter)) +
          geom_pointintervalh(aes(xmin = lower, xmax = upper), size = 8) +
          geom_vline(aes(xintercept = 0), linetype = "dashed") +
          theme_bw(base_size = 30)
  
  
<<<<<<< HEAD
  # save task files for later
  if(!file.exists(here(glue("data/processed/{task}_{feature_name}_data.rds")))) {
    save(
      pcx,
      pseq_clr,
      df,
      labels,
      shannon_df,
      file = here(glue("data/processed/{task}_{feature_name}_data.rds"))
    )
  }
=======
  
>>>>>>> faca951ecf80c7906a558749a6115faeeec69a27
  
  list(
    pca_plot1,
    pca_plot2,
    pcoa_plot1,
    pcoa_plot2,
    pm_aov,
    pmps[[1]][[1]],
    dif_ab_plots,
    shannon_coef,
    pcx
  )


}
























# output <- compare_groups(task = "IBD_vs_nonIBD")
# output[[9]]$rot %>% as.data.frame() %>%
#   rownames_to_column("taxa") %>%
#   arrange(desc(abs(PC1))) %>%
#   head(15)
# 
# 
# # IBD_vs_nonIBD
# - PCA with clr/euclidean shows clustering along either PC1 or combination of PC1 and PC2 at several phylogenetic levels
# - Collinsella aerofaciens, Bifidobacterium pseudocatenulatum, Faecalibacterium Prausnitzii and others load highest on PC1
# - E.coli and F.Prausnitzii as most discriminative species according to Bray curtis PERMANOVA 
# - lower shannon diversity in IBD
# - similar findings at genus level 
# 
# 
# output2 <- compare_groups(task = "UC_vs_CD")
# output2[[9]]$rot %>% as.data.frame() %>%
#   rownames_to_column("taxa") %>%
#   select(taxa, PC1) %>%
#   arrange(desc(abs(PC1))) %>%
#   head(15)
# 
# # UC_vs_CD
# - not clustering in PCA. Some samples of CD are clustered along PC1/PC2 but the other cloud is mixed of CD and UC (the same observation along PC4 and also PCoA with bray curtis)
# - E.coli seems most different but also again F. Prausnitzii: E.C. is higher in UC and F.P. is even lower in CD compared to UC.
# - no difference in Shannon diversity between UC and CD
# - similar findings at genus level whereas Bacteroides also show as important Differences
# - at family level PC4 seems highly discriminatice between UC and CD. E.C. and F.P. load not only relatively high on PC1 but also PC4. But there are other higher loadings for PC4.
# 
# 
# 
# 
# output3 <- compare_groups(task = "UC_vs_nonIBD")
# output3[[9]]$rot %>% as.data.frame() %>%
#   rownames_to_column("taxa") %>%
#   select(taxa, PC1) %>%
#   arrange(desc(abs(PC1))) %>%
#   head(15)
# 
# 
# # UC_vs_nonIBD
# - no clustering visible in PCA/PCoA 
# - mainly Bacteroides and F.P. drive difference according to PERMANOVA
# - lower Shannon diversity in UC
# - at genus level Bacteroides and Bifidobacterium as main difference (also according to literature)
# - at order level: PCoA can discriminate a cloud of nonIBD from UC but the other cloud is mixed UC and nonIBD
# - Pathway: combination of PC1 and PC2 can separate cloud of nonIBD from datapoints that are dominantly UC (same for PCoA along PC1 and PC3)
# 
# 
# 
# output4 <- compare_groups(task = "CD_vs_nonIBD")
# output4[[9]]$rot %>% as.data.frame() %>%
#   rownames_to_column("taxa") %>%
#   select(taxa, PC1) %>%
#   arrange(desc(abs(PC1))) %>%
#   head(15)
# 
# 
# # CD_vs_nonIBD
# - main findings of IBD_vs_nonIBD apply 
# - alpha diversity difference highest 
# - proteobacteria vs firmicutes at phylum level
<<<<<<< HEAD


=======
>>>>>>> faca951ecf80c7906a558749a6115faeeec69a27
