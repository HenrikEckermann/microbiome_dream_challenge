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


library(mlr)
library(xgboost)
df %>% head()

train_indeces <- caret::createDataPartition(df[[y]], p = p, times = k)
train <- df[train_indeces$Resample01, ]
test <- df[-train_indeces$Resample01, ]

train_task <- makeClassifTask(data = train, target = y, positive = 1)
test_task <- makeClassifTask(data = test, target = y, positive = 1)
set.seed(seed)
xgb_learner <- makeLearner(
  "classif.xgboost",
  predict.type = "response",
  par.vals = list(
    objective = "binary:logistic",
    eval_metric = "error",
    nrounds = 200
  )
)
xgb_model <- train(xgb_learner, task = train_task )
result <- predict(xgb_model, test_task)

xgb_params <- makeParamSet(
  makeIntegerParam("nrounds", lower = 1, upper = 1000),
  makeIntegerParam("max_depth", lower = 1, upper = 10),
  makeNumericParam("eta", lower = 0.1, upper = 0.5),
  makeNumericParam("lambda", lower = -1, upper = 0, trafo = function(x) 10^x)
)

control <- makeTuneControlRandom()
resample_desc <- makeResampleDesc("CV", iters = 5)
tuned_params <- tuneParams(
  learner = xgb_learner,
  task = train_task,
  resampling = resample_desc,
  par.set = xgb_params,
  control = control
)
