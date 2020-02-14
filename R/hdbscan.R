library(dbscan)
library(tidyverse)
library(here)
library(microbiome)
library(phyloseq)

load(here("data/processed/tax_abundances.RDS"))
load(here("data/processed/pathway_abundances.RDS"))
source("https://raw.githubusercontent.com/HenrikEckermann/in_use/master/mb_helper.R")


data(moons)
plot(moons, pch = 20)
cl <- hdbscan(moons, minPts = 5)
plot(moons, col = cl$cluster + 1, pch = 20)



task = "IBD_vs_nonIBD"
feature_name = "species"

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

otu_clr <- otu_to_df(pseq_clr) %>% select(-sample_id)


cl <- hdbscan(otu_clr, minPts = 2)
cl
biplot(
  pseq_clr, 
  color = "group", 
  scaling_factor = 10, 
  loading = ifelse(feature_name == "pathway", 0.06, ifelse(feature_name == "species", 0.08, 0.1)),
  text_size = 6,
  point_size = 6,
  otu_text_size = 6)  
