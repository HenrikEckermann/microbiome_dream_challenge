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



########## Set features, classifier and classification task 

load(here("data/processed/tax_abundances.RDS"))
# choose pathway, species, genus etc...
feature_name <- "species"
classifier <- "randomForest"
task = "IBD_nonIBD"


###### Structure data accordings above selection

# features 
if (feature_name %in% names(taxa_by_level)) {
  df <- taxa_by_level[[feature_name]] %>%
    select(-sampleID)
  } else if (feature_name == "pathway") {
  df <- path_abu %>%
    select(-sampleID)
 } else if (feature_name == "all") {
  df <- left_join(
    taxa_by_level[["species"]],
    taxa_by_level[["genus"]] %>% select(-group),
    by = "sampleID"
  ) %>%
  left_join(
    path_abu %>% select(-group),
    by = "sampleID"
   ) %>%
  select(-sampleID)
}


# task
if (task == "IBD_nonIBD") {
  df <- df %>%
      mutate(group = ifelse(group %in% c(1,2), 1, 0))
  df$group <- as.factor(df$group)
 } else if (task == "UC_nonIBD") {
     df <- df %>%
         filter(group %in% c(0, 2)) %>%
         mutate(group = ifelse(group == 2, 1, 0))
     df$group <- as.factor(df$group)
 } else if (task == "CD_nonIBD") {
     df <- df %>%
         filter(group %in% c(0, 1))
     df$group <- droplevels(df$group)
 } else if (task == "UC_CD") {
     df <- df %>%
         filter(group %in% c(1, 2)) %>%
         mutate(group = ifelse(group == 1, 0, 1))
     df$group <- as.factor(df$group)
}




########## k-fold Cross validation with p% of data as train

k = 10
p <- 0.8
set.seed(4)
train_index <- caret::createDataPartition(df$group, times = k, p = p)



########## Model fitting 


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



########## Model evaluation

load(file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
log_l <- map2_df(models, train_index, function(model, ti) {
  test <- df[-ti, ]
  if (classifier == "XGBoost") { # XGBoost requires different data structure
    row_n <- dim(model$evaluation_log)[1]
    log_l <- model$evaluation_log$val_logloss[row_n]
  } else {
    pred_prob <- predict(model, test, type = "prob")
    log_l <- MLmetrics::LogLoss(pred_prob, as.numeric(test$group) -1)
  }
})

# summarise multilogloss over k fold
log_l %>% 
  as_tibble() %>% 
  gather() %>% 
  summarise(mean = mean(value), sd = sd(value))
  
  # confusion matrix
cfm <- map2(models, train_index, function(model, ti) {
  test <- df[-ti, ]
  if (classifier == "XGBoost") { # XGBoost requires different data structure
    labels_test <- test$group %>% as.numeric() -1
    test_xgb <- select(test, -group) %>% as.matrix()
    test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)
    pred_prob <- predict(model, test_xgb)
    pred <- ifelse(pred_prob >= 0.5, 1, 0)
  } else {
    pred_prob <- predict(model, test, type = "prob")
    pred <- ifelse(pred_prob[, 2] >= 0.5, 1, 0)
  }
    pred <- as.factor(pred)
    caret::confusionMatrix(pred, as.factor(test$group), positive = "1")$table %>%
    as.data.frame()
})

cfm

log_l %>% 
  as_tibble() %>% 
  gather() %>%
  ggplot(aes(x = "10 fold CV logloss", y = value)) +
  geom_boxplot() +
  geom_jitter(width = 0.05, color = "red", size = 3) 



log_l
###### The following stats/findings are based on basic RF models
###### (no feature selection)
# species: mean: 0.6990, sd: 0.0906
# genus:   mean: 0.7106, sd: 0.0943
# path:    mean: 0.4883, sd: 0.0635


###### The following stats/findings are based on basic XGB models 
###### (no feature selection)
# species: mean: 0.6945, sd: 0.1284
# genus:   mean: 0.6985, sd: 0.1262
# pathway: mean; 0.5382, sd: 0.1440

# all: mean: 0.5921, sd: 0.1266

classifier
