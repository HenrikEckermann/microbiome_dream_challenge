library(tidyverse)
library(glue)
library(here)
library(randomForest)
library(xgboost)

source(here("R/ml_helper.R"))
#source("https://raw.githubusercontent.com/HenrikEckermann/in_use/master/mb_helper.R")



# import data 
load(here("data/processed/tax_abundances.RDS"))
load(here("data/processed/pathway_abundances.RDS"))

task <- "IBD_vs_nonIBD"
# for shannon_df and pcx object we need to select feature
feature_name <- "species"
classifier <- "XGBoost"


# create a complete df of all features
df_all <- map_dfc(c(names(taxa_by_level), "pathway"), function(feature_name) {
  load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
  # we only need sampleID once
  if (feature_name == "species") {
    df
  } else {
    select(df, -sampleID)
  }
})


# get PCs from species PCA
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_sp <- pcx$x %>% 
 as.data.frame() %>% 
 rownames_to_column("sampleID") 
colnames(pcs_sp) <- glue("{colnames(pcs_sp)}_sp")
pcs_sp <- select(pcs_sp, sampleID = sampleID_sp, everything())

# get PCs from genus PCA
feature_name <- "genus"
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_gn <- pcx$x %>% 
 as.data.frame() %>% 
 rownames_to_column("sampleID") 
colnames(pcs_gn) <- glue("{colnames(pcs_gn)}_gn")
pcs_gn <- select(pcs_gn, sampleID = sampleID_gn, everything())

# get PCs from pathway PCA
feature_name <- "pathway"
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_pw <- pcx$x %>% 
  as.data.frame() %>% 
  rownames_to_column("sampleID")
colnames(pcs_pw) <- glue("{colnames(pcs_pw)}_pw")
pcs_pw <- select(pcs_pw, sampleID = sampleID_pw, everything())
 


df_all <-  df_all %>%
  left_join(pcs_sp, by = "sampleID") %>%
  left_join(pcs_gn, by = "sampleID") %>%
  left_join(pcs_pw, by = "sampleID") %>%
  left_join(select(shannon_df, -group), by = "sampleID") %>%
  left_join(labels, by = "sampleID")

# model_pc <- randomForest(
#   y = pcs$group,
#   x = select(pcs, -sampleID, -group, PC1, PC2, PC3, PC4),
#   ntree = 1e4,
#   importance = TRUE
# ) 
# 
# model <- randomForest(
#   y = labels$group,
#   x = select(df, -sampleID),
#   ntree = 1e4,
#   importance = TRUE
# )



features <- c(
  # Species 
  "Bifidobacteriumbifidum", # lit
  "Bifidobacteriumlongum",  # lit
  "Roseburiahominis",
  "Clostridiumbolteae", 
  # Genus
  "Akkermansia", # lit
  "Shigella", # lit
  "Enterobacteriaceae", # lit
  "Escherichia",
  "Bacteroides",
  "Klebsiella",
  "Lachnoclostridium",
  "Veillonella",
  "Fusobacterium",
  "Parabacteroides",
  "Dialister",
  "Roseburia",
  "Anaerostipes",
  "Ruminococcus",
  "Eubacterium",
  "Bifidobacterium",
  "CandidatusCloacimonas",
  "Faecalibacterium",
  # Family
  "Coriobacteriaceae",
  "Christensenellaceae",
  
  # Phylum 
  "Tenericutes", # lit
  "Lentisphaerae", # lit
  "Actinobacteria", # lit
  "Firmicutes", # lit
  "Proteobacteria", # lit 
  "Eubacteriumrectale", # lit
  # pathways
  "UNINTEGRATEDgEscherichiasEscherichiacoli",
  "UNINTEGRATED",
  "UNINTEGRATEDgKlebsiellasKlebsiellapneumoniae",
  "UNINTEGRATEDgBlautiasRuminococcusgnavus",
  "UNINTEGRATEDgClostridiumsClostridiumsymbiosum",
  "UNINTEGRATEDgBacteroidessBacteroidescoprocola",
  "UNINTEGRATEDgBacteroidessBacteroidesstercoris",
  "UNINTEGRATEDgPrevotellasPrevotellacopri",
  "UNINTEGRATEDgBacteroidessBacteroidesplebeius",
  "UNINTEGRATEDgRoseburiasRoseburiainulinivorans",
  "UNINTEGRATEDgEubacteriumsEubacteriumrectale",
  "UNINTEGRATEDgBacteroidessBacteroidesuniformis",
  "UNMAPPED",
  "UNINTEGRATEDgFaecalibacteriumsFaecalibacteriumprausnitzii",
  "UNINTEGRATEDunclassified",
  # other 
  "shannon",
  "PC1_sp",
  "PC2_sp",
  "PC3_sp",
  "PC4_sp",
  # "PC1_gn",
  # "PC2_gn",
  # "PC3_gn",
  # "PC4_gn",
  "PC1_pw",
  "PC2_pw",
  "PC3_pw",
  "PC4_pw"
)

# next: try to add species etc. mentioned by literature...







set.seed(6)
models_and_data1 <- fit_cv(
  df_all, 
  features, 
  y = "group", 
  p = 0.8,
  k = 10,
  model_type = classifier, 
  ntree = 5000
)




summarize_metrics(models_and_data1, y = "group", model_type = classifier, features = features) %>% 
  mutate(task = task, feature_name = "custom", classifier = classifier, n_features = length(features)) %>%
  select(metric, task, feature_name, classifier, n_features, mean, sd)

sel_feat <- select_features(models_and_data1) 

########## Extract top n_features features from models based on RF perm imp
set.seed(6)
models_and_data2 <- fit_cv(
  df_all, 
  sel_feat$id, 
  y = "group", 
  p = 0.8,
  k = 10,
  model_type = "randomForest", 
  ntree = 5000
)


summarize_metrics(models_and_data2, y = "group") %>% 
  mutate(task = task, feature_name = "custom", classifier = classifier, n_features = length(features)) %>%
  select(metric, task, feature_name, classifier, n_features, mean, sd)

sel_feat <- select_features(models_and_data2) 

########## Extract top n_features features from models based on RF perm imp
set.seed(6)
models_and_data3 <- fit_cv(
  df_all, 
  sel_feat$id, 
  y = "group", 
  p = 0.8,
  k = 10,
  model_type = "randomForest", 
  ntree = 5000
)


summarize_metrics(models_and_data3, y = "group") %>% 
  mutate(task = task, feature_name = "custom", classifier = classifier, n_features = length(features)) %>%
  select(metric, task, feature_name, classifier, n_features, mean, sd)
  
  
  
  
models_and_data1[[1]]