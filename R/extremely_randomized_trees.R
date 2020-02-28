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



custom_df = FALSE 
task = "IBD_vs_nonIBD" 
feature_name = "species"
features = NA 
y = "group"
classifier = "tuneRanger" 
k = 10 
p = 0.8 
seed = 4
ntree = 5000
n_features = 50
    
  
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

features <- selected_features[, 1]
features

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
}



model_and_data <- fit_cv(
  data = df,
  features = features,
  y = "group",
  p = p,
  k = k,
  model_type = classifier,
  ntree = ntree  
)

model_type = classifier 
model_eval(model_and_data[[1]][[1]], model_and_data[[1]][[2]], features, y)
model <- model_and_data[[1]][[1]]
testdata <- model_and_data[[1]][[2]]


y_true <- as.numeric(testdata[[y]]) -1 





if (model_type == "extremely_randomized_trees") {
  y_pred_prob <- predict(model, testdata)$predictions[, 2]
  y_pred_resp <- ifelse(y_pred_prob > 0.5, 1, 0)
}


library(tuneRanger)
library(mlr)

# A mlr task has to be created in order to use the package
data(iris)
head(iris)
iris.task = makeClassifTask(data = iris, target = "Species")
 
# Estimate runtime
estimateTimeTuneRanger(iris.task)
# Tuning
res = tuneRanger(iris.task, measure = list(multiclass.brier), num.trees = 5000, 
  num.threads = 8, iters = 70, save.file.path = NULL)
  
# Mean of best 5 % of the results
res$recommended.pars
# Model with the new tuned hyperparameters
res$model
# Prediction
predict(res$model, newdata = iris[1:10,])
# }