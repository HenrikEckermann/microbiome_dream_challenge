###### README

# nonIBD = 0, CD = 1, UC = 2
# to convert tax or pathway ids to descriptive string use taxa_id_info
# or path_id_info after loading tax_abundances.RDS or pathway_abundances.RDS


###### Libraries

library(tidyverse)
library(glue)
library(here)
library(randomForest)
library(xgboost)



###### load datasets

load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")


###### automated workflow
# helper
factor_as_binary <- function(tgt) {
  as.numeric(levels(tgt)[tgt])
}


 


# task: classification task (IBD_vs_nonIBD, UC_vs_CD etc.)
# feature_name: which feature to use (species, genus, etc,  all_taxa, pathway)
# classifier: currently randomForest or XGBoost 
# k: number of CV folds 
# p: percentage training set 
# seed: to standardize CV 
# n_features: top_n features to keep for each model before using intersection
# if n_features = NA, no feature selection will be applied


fit_and_predict <- function(
  task, 
  feature_name, 
  classifier, 
  k = 10, 
  p = 0.8, 
  seed = 4,
  n_features = 50) {
        
    ########## Select taxonomic level or pathway 

    if (feature_name %in% names(taxa_by_level)) {
      df <- taxa_by_level[[feature_name]] %>%
        select(-sampleID)
      } else if (feature_name == "pathway") {
      df <- path_abu %>%
        select(-sampleID)
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
          by = "sampleID") %>%
        select(-sampleID)
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

  
    ########## k-fold Cross validation with p% of data as train
    
    set.seed(seed)
    train_index <- caret::createDataPartition(df$group, times = k, p = p)
    
    
    ######### Model fitting for feature selection
    
    
    # fit models
    if (classifier == "randomForest") {
      # fit RF model for k folds. store in list unless models was fit already
      if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))) {
        models <- map(train_index, function(ti) {
          train <- df[ti, ]
          test <- df[-ti, ]
          model <- randomForest(
            x = select(train, -group),
            y = train$group,
            ntree = 5000,
            importance = TRUE
          )
        })
      }
     } else if (classifier == "XGBoost") {
      # fit XGBoost model for k folds. store in list unless models was fit already
      if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))) {
        models <- map(train_index, function(ti) { # xgboost uses multicore
          train <- df[ti, ]
          test <- df[-ti, ]
          # prepare xgb data matrix object
          labels_train <- train$group %>% as.numeric() -1 # one-hot-coding
          labels_test <- test$group %>% as.numeric() -1
          train_xgb <- select(train, -group) %>% as.matrix()
          test_xgb <- select(test, -group) %>% as.matrix()
          train_xgb <- xgb.DMatrix(data = train_xgb, label = labels_train)
          test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)
    
          # set model parameters (this should be default parameters)
          params <- list(
            booster = "gbtree",
            objective = "binary:logistic",
            eta = 0.3,
            gamma = 0,
            max_depth = 6,
            min_child_weight = 1,
            subsample = 1,
            colsample_bytree = 1
          )
          # nrounds parameter has been tuned using whole dataset
          nrounds <- ifelse(
            feature_name == "pathway", 10, 8)
    
          model <- xgb.train(
            params = params,
            data = train_xgb, 
            nrounds = nrounds,
            watchlist = list(val = test_xgb, train = train_xgb),
            print_every_n = 10, 
            early_stop_round = 10,
            maximize = FALSE,
            eval_metric = "logloss"
          )
        })
      }
    }
    
    
  # save models incl the used train/test ids
  if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))) {
    save(
      models, 
      train_index, 
      file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
    }
  
  if (!is.na(n_features)) {
    ########## Extract top n_features features from models based on RF perm imp

    if (file.exists(glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))) {
      top_predictors <- load(glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))
     } else {
     load(file = here(glue("data/models/{task}_{feature_name}_randomForest.Rds")))
     id_name <- ifelse(
       feature_name %in% names(taxa_by_level), 
       "TaxID", "PathID")
       
     top_predictors <- map(models, function(model) {
       top_predictors <- importance(
         model, 
         type = 1, 
         scale = F) %>%
        as.data.frame() %>%
        rownames_to_column(id_name) %>%
        arrange(desc(MeanDecreaseAccuracy)) %>%
        select(id_name) %>%
        head(n_features)
        })
    selected_features <- Reduce(intersect, top_predictors)
    save(
      selected_features, 
      file = glue(here("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))
    }
    
    
    
    ###### fit model with selected features 
    n_features_final <- dim(selected_features)[1]
    print(glue("For {task}, {feature_name}, {classifier} found {n_features_final} features"))
    id_name <- ifelse(
      feature_name %in% names(taxa_by_level), 
      "TaxID", "PathID")
    df <- select(df, group, selected_features[, id_name])
      
    # fit models
    if (classifier == "randomForest") {
      # fit RF model for k folds. store in list unless models was fit already
      if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))) {
        models <- map(train_index, function(ti) {
          train <- df[ti, ]
          test <- df[-ti, ]
          model <- randomForest(
            x = select(train, -group),
            y = train$group,
            ntree = 5000,
            importance = TRUE
          )
        })
      } else {
          if (!is.na(n_features)) {
            load(file = here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))
          } else {
            load(file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
          }
      }
      predictions <- map2(train_index, models, function(ti, model) {
        train <- df[ti, ]
        test <- df[-ti, ]
        # predictons 
        model_pred_tr <- predict(model)
        model_pred_prob_tr <- predict(model, type="prob")[, 2] # probabilities of class 1
        model_pred_ts <- predict(model, newdata = test)
        model_pred_prob_ts <- predict(model, newdata = test, type="prob")[,2] # probabilities of class 1
        model_pred_num <- factor_as_binary(model_pred_ts)
        list(
          "model_name" = glue("{task}_{feature_name}_{classifier}_top_{n_features}_features"),
          "model_tr_preds" = model_pred_tr,
          "model_pred_prob_tr" = model_pred_prob_tr,
          "model_tst_preds" = model_pred_ts,
          "model_pred_prob_ts" = model_pred_prob_ts,
          "data" = df, 
          "tr_inds" = ti)
        })
      
    } else if (classifier == "XGBoost") {
      # fit XGBoost model for k folds. store in list unless models was fit already
      if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))) {
        models <- map(train_index, function(ti) { # xgboost uses multicore
          train <- df[ti, ]
          test <- df[-ti, ]
          # prepare xgb data matrix object
          labels_train <- train$group %>% as.numeric() -1 # one-hot-coding
          labels_test <- test$group %>% as.numeric() -1
          train_xgb <- select(train, -group) %>% as.matrix()
          test_xgb <- select(test, -group) %>% as.matrix()
          train_xgb <- xgb.DMatrix(data = train_xgb, label = labels_train)
          test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)
    
          # set model parameters (this should be default parameters)
          params <- list(
            booster = "gbtree",
            objective = "binary:logistic",
            eta = 0.3,
            gamma = 0,
            max_depth = 6,
            min_child_weight = 1,
            subsample = 1,
            colsample_bytree = 1
          )
          # nrounds parameter has been tuned using whole dataset
          nrounds <- ifelse(
            feature_name == "pathway", 10, 8)
    
          model <- xgb.train(
            params = params,
            data = train_xgb, 
            nrounds = nrounds,
            watchlist = list(val = test_xgb, train = train_xgb),
            print_every_n = 10, 
            early_stop_round = 10,
            maximize = FALSE,
            eval_metric = "logloss"
          )
        })
      } else {
          if (!is.na(n_features)) {
            load(file = here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))
          } else {
            load(file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
          }
      }
      predictions <- map2(train_index, models, function(ti, model) {
        train <- df[ti, ]
        test <- df[-ti, ]
        # prepare xgb data matrix object
        labels_train <- train$group %>% as.numeric() -1 # one-hot-coding
        labels_test <- test$group %>% as.numeric() -1
        train_xgb <- select(train, -group) %>% as.matrix()
        test_xgb <- select(test, -group) %>% as.matrix()
        train_xgb <- xgb.DMatrix(data = train_xgb, label = labels_train)
        test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)
        # predictons 
        model_pred_tr <- predict(model, newdata = train_xgb)
        model_pred_prob_tr <- predict(model, newdata = train_xgb) # probabilities of class 1
        model_pred_ts <- predict(model, newdata = test_xgb)
        model_pred_prob_ts <- predict(model, newdata = test_xgb) # probabilities of class 1
        model_pred_num <- factor_as_binary(model_pred_ts)
        list(
          "model_name" = glue("{task}_{feature_name}_{classifier}_top_{n_features}_features"),
          "model_tr_preds" = model_pred_tr,
          "model_pred_prob_tr" = model_pred_prob_tr,
          "model_tst_preds" = model_pred_ts,
          "model_pred_prob_ts" = model_pred_prob_ts,
          "data" = df, 
          "tr_inds" = ti)
        })
    }
    
    
    # save models incl the used train/test ids
    if (!file.exists(here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))) {
      save(
        models, 
        train_index, 
        file = here(glue("data/models/{task}_{feature_name}_{classifier}_top_{n_features}_features.Rds")))
      }
  }
  predictions
  
}


# test

tasks <- list("IBD_vs_nonIBD")
feature_list <- list("species", "genus")
classifier_list <- list("randomForest", "XGBoost")
# store all models to compare 
predictions_all <- map(tasks, function(task) {
  map(feature_list, function(feature_name) {
    map(classifier_list, function(classifier) {
      fit_and_predict(task, feature_name, classifier, n_features = 50)
    })
  })
})

test <- fit_and_predict(
  task = "IBD_vs_nonIBD",
  feature_name = "genus",
  classifier = "randomForest",
  n_features = 100
)
test2 <- fit_and_predict(
  task = "IBD_vs_nonIBD",
  feature_name = "pathway",
  classifier = "XGBoost",
  n_features = 875
)
test3 <- fit_and_predict(
  task = "IBD_vs_nonIBD",
  feature_name = "species",
  classifier = "randomForest",
  n_features = 125
)





# perform ensemble method 
source(here("R/ensemble_functions.R"))



set.seed(4)
model_names <- map(ensemble_models, ~.x$Resample01$model_name)
model_names
ens_fit <- logistic_glmnet_ensemble_only_model_predictions_with_ia(
  target = df$group,
  tr_inds = train_index[[1]],
  model_names = model_names,
  model_tr_preds = list(
    ensemble_models[[1]][["Resample01"]]$model_pred_prob_tr,
    ensemble_models[[2]][["Resample01"]]$model_pred_prob_tr,
    ensemble_models[[3]][["Resample01"]]$model_pred_prob_tr
  ),
  model_tst_preds = list(
    ensemble_models[[1]][["Resample01"]]$model_pred_prob_ts,
    ensemble_models[[2]][["Resample01"]]$model_pred_prob_ts,
    ensemble_models[[3]][["Resample01"]]$model_pred_prob_ts
  ),
  s = "lambda.min"
)

#ens_res$ensemble_preds
log_l <- MLmetrics::LogLoss(ens_res$ensemble_preds, as.numeric(test$Resample01$data$group[-test$Resample01$tr_inds]) - 1)

log_l



source(here("R/ensemble_functions.R"))
###### specify models that we selected for the ensemble
task <- "IBD_vs_nonIBD"
model_specs <- list(
  "model1" = list(
    task = task,
    feature_name = "genus",
    classifier = "randomForest",
    n_features = 100
  ),
  "model2" = list(
    task = task,
    feature_name = "genus",
    classifier = "randomForest",
    n_features = 1448
  ),
  "model3" = list(
    task = task,
    feature_name = "species",
    classifier = "randomForest",
    n_features = 125
  ),
  "model4" = list(
    task = task,
    feature_name = "species",
    classifier = "XGBoost",
    n_features = 575
  )
)



###### for each model: for each k fold: fit model, store predictions and train index 

seed <- 4

ensemble_models <- map(model_specs, function(model_spec) {
  task <- model_spec$task 
  feature_name <- model_spec$feature_name 
  classifier <- model_spec$classifier 
  n_features <- model_spec$n_features
  fit_and_predict(
    task = task,
    feature_name = feature_name,
    classifier = classifier,
    n_features = n_features
  )
})
###### for each k fold, fit the ensemble models


# we create a df with all taxonomic levels 
load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")

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
    by = "sampleID") %>%
  select(-sampleID)


# Select data accordings to task

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


# use same seed as for the models we use 
set.seed(seed)
k <- 10
p <- 0.8
# since the df is equal as long as the task is equal
train_index <- caret::createDataPartition(df$group, times = k, p = p)


model_names <- map(ensemble_models, ~.x$Resample01$model_name)
model_names
# fit ensembles
fold_names <- names(train_index)
target <- df$group
data_ens <- select(df, -group)
ensemble_predictions <- map2(fold_names, train_index, function(fold_name, tr_inds) { 
  ens_fit <- logistic_glmnet_ensemble_predictions(
    data = data_ens,
    target = df$group,
    tr_inds = tr_inds,
    model_names = model_names,
    model_tr_preds = list(
      ensemble_models[[1]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[2]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[3]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[4]][[fold_name]]$model_pred_prob_tr
    ),
    model_tst_preds = list(
      ensemble_models[[1]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[2]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[3]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[4]][[fold_name]]$model_pred_prob_ts
    ),
    s = "lambda.min",
    lambda=2^seq(1, -15, -0.05)
  )
})


source(here("R/ensemble_functions.R"))
ensemble_predictions_rf <- map2(fold_names, train_index, function(fold_name, tr_inds) { 
  ens_fit <- randomforest_ensemble_meta2_predictions(
    data = data_ens,
    target = df$group,
    tr_inds = tr_inds,
    model_names = model_names,
    model_tr_preds = list(
      ensemble_models[[1]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[2]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[3]][[fold_name]]$model_pred_prob_tr,
      ensemble_models[[4]][[fold_name]]$model_pred_prob_tr
    ),
    model_tst_preds = list(
      ensemble_models[[1]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[2]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[3]][[fold_name]]$model_pred_prob_ts,
      ensemble_models[[4]][[fold_name]]$model_pred_prob_ts
    ),
    type = "prob"
  )
})


37ensemble_predictions_rf[[1]]$ensemble_preds[, 2]

###### evaluate ensemble 
logl_ens <- map2_dbl(ensemble_predictions_rf, train_index, function(predictions, tr_inds) {
  test <- df[-tr_inds, ]
  log_l <- MLmetrics::LogLoss(
    predictions$ensemble_preds[, 2], 
    as.numeric(test$group) - 1)
})

logl_ens
mean(logl_ens)
sd(logl_ens)



git pull origin master

