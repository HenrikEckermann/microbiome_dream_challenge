library(tidyverse)
library(here)
library(microbiome)
library(vegan)

# import data 
load(here("data/processed/tax_abundances.RDS"))
load(here("data/processed/pathway_abundances.RDS"))
source("https://raw.githubusercontent.com/HenrikEckermann/in_use/master/mb_helper.R")



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


    ###### Select data accordings to task

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

    labels <- select(df, group, sampleID)
    
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


    # PCA 
    pcx <- df %>%
      column_to_rownames("sampleID") %>%
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

    #pcx$sdev^2/sum(pcx$sdev^2)
    var_exp <- map(seq(1, 170), function(pc) {
      round(pcx$sdev[pc]^2/sum(pcx$sdev^2), 3)
    })


    pca_plot1 <- ggplot(df_pc, aes(PC1, PC2, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      ggtitle(glue("{task}_{feature_name}_PCA"))

    pca_plot2 <- ggplot(df_pc, aes(PC3, PC4, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      ggtitle(glue("{task}_{feature_name}_PCA"))
    bray_dist <- df %>% 
      column_to_rownames("sampleID") %>% 
      dist(method = "manhattan") * 0.5


    pcoax <- cmdscale(bray_dist, eig = T, x.ret = T, k =4)
    data_and_pc <- pcoax$points %>% as.data.frame() %>%
      select(PC1 = V1, PC2 = V2, PC3 = V3, PC4 = V4) %>%
      rownames_to_column("sampleID") %>%
      left_join(labels, by = "sampleID")


    var_exp <- pcoax$eig/sum(pcoax$eig)

    options(repr.plot.width=15, repr.plot.height=15)
    pcoa_plot1 <- ggplot(data_and_pc, aes(PC1, PC2, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      ggtitle(glue("{task}_{feature_name}_PCoA"))
      
    pcoa_plot2 <- ggplot(data_and_pc, aes(PC3, PC4, color = group)) +
      geom_point(size = 5) +
      theme_bw(base_size = 30) +
      ggtitle(glue("{task}_{feature_name}_PCoA"))
      

    
    otu <- column_to_rownames(df, "sampleID")
    labels <- labels$group
    pm <- adonis(otu ~ labels)
    pm_aov <- pm$aov.tab

    coefs <- pm$coefficient %>% as.data.frame() %>%
      rownames_to_column("group")

    coefs <- coefs %>%
      gather_(key_col = feature_name, value_col = "coef", gather_cols = c(colnames(coefs)[-1])) %>%
      spread(group, coef) 
    head(coefs)


    if (task == "IBD_vs_nonIBD") {
      coef_v <- "labels1"
      coef_title <- "IBD"
     } else if (task == "UC_vs_nonIBD") {
         coef_v <- "labels1"
         coef_title <- "UC"
     } else if (task == "CD_vs_nonIBD") {
         coef_v <- "labels1"
         coef_title <- "CD"
     } else if (task == "UC_vs_CD") {
         coef_v <- "labels1"
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
                    mutate(top_taxa = factor(top_features, levels = top_features))
        
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
      select(taxa_by_level[["species"]], sampleID, group), 
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




  list(
    pca_plot1,
    pca_plot2,
    pcoa_plot1,
    pcoa_plot2,
    pm_aov,
    pmps[[1]][[1]],
    dif_ab_plots
  )


}


