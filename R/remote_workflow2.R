###### README

# nonIBD = 0, CD = 1, UC = 2
# to convert tax or pathway ids to descriptive string use taxa_id_info
# or path_id_info after loading tax_abundances.RDS or pathway_abundances.RDS


###### LOAD LIBRARIES AND HELPER FUNCTIONS

library(tidyverse)
library(glue)
library(randomForest)
library(xgboost)
library(ranger)
library(tuneRanger)
library(mlr)

source(here::here("R/ml_helper.R"))


###### LOAD DATASETS

load(here::here("data/processed/tax_abundances.RDS"))
load(here::here("data/processed/pathway_abundances.RDS"))


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
    
    ###### SELECT DATA ACCORDING TO TAXONOMIC LEVEL (OR PATHWAY) and TASK
    df <- prepare_data(task, feature_name)
  
  }
  
  
  # specify features if not provided (if custom_df = FALSE, features should be
  # provided)
  if (is.na(features)) {
    features <- colnames(select(df, -group))
  }

  
  ###### FEATURE SELECTION 
  
  if (!is.na(n_features)) {
    # skip if performed already for given task
    if (file.exists(glue(here::here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))) {
      top_predictors <- load(glue(here::here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))
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
         file = glue(here::here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds"))
       )
     }
   }
   
    # specify features if feature selection was enabled and inform
    if (!is.na(n_features)) {
      id_name <- ifelse(
        feature_name %in% names(taxa_by_level), 
        "TaxID", "PathID")
      # inform about number of retained features in case of feat sel
      n_features_final <- dim(selected_features)[1]
      print(glue("\nSelected {n_features_final} features for {task},  {feature_name}, {classifier}"))
      features <- selected_features[, id_name]
    }
   
   ###### TUNE RF MODEL 
   if (classifier == "tuneRanger") {
     if (!file.exists(here::here(glue("data/tuneRanger/pars_{task}_{feature_name}_{n_features}_{classifier}.Rds")))) {
         tune_task <- makeClassifTask(
           data = select(df, features, y),
           target = y
         )
         estimateTimeTuneRanger(tune_task)
         res <- tuneRanger(
           tune_task,
           parameters = list(
             replace = FALSE, 
             respect.unordered.factors = "order"),
           tune.parameters = c(
             "mtry", 
             "min.node.size",
             "sample.fraction"),
           num.trees = ntree,
           num.threads = 8, iters = 70
         )
         pars <- res$recommended.pars
         save(pars, 
           file = here::here(glue("data/tuneRanger/pars_{task}_{feature_name}_{n_features}_{classifier}.Rds"))
         )
     } else {
       load(here::here(glue("data/tuneRanger/pars_{task}_{feature_name}_{n_features}_{classifier}.Rds")))
     }
     print(glue("\nmtry: {pars[1, 1]}\nnode.size: {pars[1, 2]}\nsample.fraction: {pars[1, 3]}"))
   }
   
   
   
   ###### FIT FINAL MODELS
  
   models_and_data <- fit_cv(
     data = df,
     features = features,
     y = "group",
     p = p,
     k = k,
     model_type = classifier,
     ntree = ntree,
     sample.fraction = ifelse(
       classifier == "tuneRanger", 
       pars$sample.fraction, NA),
     min.node.size = ifelse(
       classifier == "tuneRanger", 
       pars$min.node.size, NA),
     mtry = ifelse(
       classifier == "tuneRanger", 
       pars$mtry, NA)     
   )


   
   ###### MODEL EVALUATION 
   
   summarize_metrics(models_and_data, y = y, model_type = classifier, features = features)

}





###### CREATE TABLE OF ALL TASKS, FEATURES AND SOME N_FEATURES 
# there are 12650, 5061 and 1450 features for path, spec and gen respectively
# find the optimal n_features per task/feature 
n_features_list <- as.list(c(seq(800, 1000, 25), NA))
tasks <- list("IBD_vs_nonIBD", "CD_vs_nonIBD", "UC_vs_nonIBD", "UC_vs_CD")
feature_list <- list("species", "genus", "pathway")
classifier_list <- list(
  "tuneRanger"
)
# evaluate all non custom models  
metrics_all <- map_dfr(n_features_list, function(n_features) {
    map_dfr(tasks, function(task) {
      map_dfr(feature_list, function(feature_name) {
        map_dfr(classifier_list, function(classifier) {
          df <- fit_and_evaluate(
            custom_df = FALSE, 
            task = task, 
            feature_name = feature_name,
            features = NA, 
            y = "group",
            classifier = classifier, 
            k = 10, 
            p = 0.8, 
            seed = 4,
            ntree = 5000,
            n_features = n_features)

          df <- df %>% mutate(
              "task" = task, 
              "feature_name" = feature_name,
              "classifier" = classifier,
              "n_features" = n_features
          )
          df
        })
      })
    })
})


