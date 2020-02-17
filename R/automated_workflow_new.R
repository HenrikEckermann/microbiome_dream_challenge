###### README

# nonIBD = 0, CD = 1, UC = 2
# to convert tax or pathway ids to descriptive string use taxa_id_info
# or path_id_info after loading tax_abundances.RDS or pathway_abundances.RDS


###### LOAD LIBRARIES AND HELPER FUNCTIONS

library(tidyverse)
library(glue)
library(here)
library(randomForest)
library(xgboost)

source(here("R/ml_helper.R"))


###### LOAD DATASETS

load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")


###### AUTOMATED WORKFLOW FUNCTION

# task: classification task (IBD_vs_nonIBD, UC_vs_CD etc.)
# feature_name: which feature to use (species, genus, etc,  all_taxa, pathway)
# classifier: currently randomForest or XGBoost 
# k: number of CV folds 
# p: percentage training set 
# seed: to standardize CV 
# n_features: top_n features to keep for each model before using intersection
# if n_features = NA, no feature selection will be applied
# ntree is only used for the RF models (incl the feat sel models)
# if features are provided, then these are used for model fitting (incl feat 
# sel models if that is enabled)
# to disable seed set to NA


fit_and_evaluate <- function(
  custom_df = FALSE, 
  task = "IBD_vs_nonIBD", 
  feature_name = "species",
  features = NA, 
  y = "group",
  classifier = "randomForest", 
  k = 10, 
  p = 0.8, 
  seed = 4,
  ntree = 5000,
  n_features = 50) {
    
  
  if (!is.na(seed)) {
    set.seed(seed)
  } 
      
  # create df if not provided
  if (!custom_df) {
    
    ###### SELECT DATA ACCORDING TO TAXONOMIC LEVEL OR PATHWAY 

    if (feature_name %in% names(taxa_by_level)) {
      df <- taxa_by_level[[feature_name]] %>%
        select(-sampleID)
      } else if (feature_name == "pathway") {
      df <- path_abu %>%
        select(-sampleID)
    } else if (feature_name == "all_taxa") {
      df <- left_join(
          taxa_by_level[["species"]],
          select(taxa_by_level[["genus"]], -group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["family"]], -group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["order"]], -group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["class"]], -group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["phylum"]], -group),
          by = "sampleID") %>%
          left_join(
          select(taxa_by_level[["superkingdom"]], -group),
          by = "sampleID") %>%
        select(-sampleID)
    }
    
    
    ###### SELECT DATA ACCORDING TO TASK
    
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
  }
    
  
  # specify features if not provided (if custom_df = FALSE, features should be
  # provided)
  if (is.na(features)) {
    
  }

  
  ###### FEATURE SELECTION 
  
  if (!is.na(n_features)) {
    # skip if performed already for given task
    if (file.exists(glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))) {
      top_predictors <- load(glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))
     } else {
       
       # fit k RF models 
       models_and_data <- fit_cv(
         df, 
         features = features, 
         y = "group", 
         p = p,
         k = k,
         model_type = "randomForest", 
         ntree = ntree
       )
       
       # colname needed to select features below
       id_name <- ifelse(
         feature_name %in% names(taxa_by_level), "TaxID", "PathID")
         
       # perform selection
       select_features(models_and_data, id_name, n_features)
       
       # store selected features in file
       save(
         selected_features, 
         file = glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds"))
       )
     }
   }
   
   ###### FIT FINAL MODEL
   
   # specify features if feature selection was enabled and inform
   if (!is.na(n_features)) {
     id_name <- ifelse(
       feature_name %in% names(taxa_by_level), 
       "TaxID", "PathID")
     # inform about number of retained features in case of feat sel
     n_features_final <- dim(selected_features)[1]
     print(glue("Selected {n_features_final} features for {task},  {feature_name}, {classifier}"))
     features <- selected_features[, id_name]
   }
   
   
   # fit final models
    models_and_data <- fit_cv(
      data = df,
      features = features,
      y = "group",
      p = p,
      k = k,
      model_type = classifier,
      ntree = ntree
    )
    
    
    
   ###### MODEL EVALUATION 

   summarize_metrics(models_and_data, y = y, model_type = classifier, features = features)
}


test <- fit_and_evaluate(
  custom_df = FALSE, 
  task = "CD_vs_nonIBD", 
  feature_name = "species",
  features = NA, 
  y = "group",
  classifier = "randomForest", 
  k = 10, 
  p = 0.8, 
  seed = 4,
  ntree = 5000,
  n_features = 50)


test    
