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



########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
# choose pathway, species, genus etc...
features <- "genus"


if (features %in% names(taxa_by_level)) {
  df <- taxa_by_level[[features]] %>%
    select(-sampleID)
    } else {
  load("data/processed/pathway_abundances.RDS")
  df <- path_abu %>%
    select(-sampleID)
}

# pathway df cannot be printed (too many cols)
if (features != "pathway") {
  head(df)
}



########## k-fold Cross validation with p% of data as train

k = 10
p <- 0.8
set.seed(4)
train_index <- caret::createDataPartition(df$group, times = k, p = p)



########## Model fitting 

# select classifier
classifier <- "XGBoost"

# fit models
if (classifier == "randomForest") {
  # fit RF model for k folds. store in list unless models was fit already
  if (!file.exists(here(glue("data/models/{features}_{classifier}.Rds")))) {
    models <- map(train_index, function(ti) {
      train <- df[ti, ]
      test <- df[-ti, ]
      model <- randomForest(
        formula = group ~ .,
        data = train,
        ntree = 5000,
        importance = TRUE
      )
    })
  }
 } else if (classifier == "XGBoost") {
  # fit XGBoost model for k folds. store in list unless models was fit already
  if (!file.exists(here(glue("data/models/{features}_{classifier}.Rds")))) {
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
        num_class = 3, 
        objective = "multi:softprob",
        eta = 0.3,
        gamma = 0,
        max_depth = 6,
        min_child_weight = 1,
        subsample = 1,
        colsample_bytree = 1
      )
      # nrounds parameter has been tuned using whole dataset
      nrounds <- ifelse(
        features == "pathway", 10, 8)

      model <- xgb.train(
        params = params,
        data = train_xgb, 
        nrounds = nrounds,
        watchlist = list(val = test_xgb, train = train_xgb),
        print_every_n = 10, 
        early_stop_round = 10,
        maximize = FALSE,
        eval_metric = "mlogloss"
      )
    })
  }
}




# save models incl the used train/test ids
if (!file.exists(here(glue("data/models/{features}_{classifier}.Rds")))) {
  save(
    models, 
    train_index, 
    file = here(glue("data/models/{features}_{classifier}.Rds")))
  }



########## Model evaluation

load(file = here(glue("data/models/{features}_{classifier}.Rds")))
multi_ll <- map2_df(models, train_index, function(model, ti) {
  test <- df[-ti, ]
  if (classifier == "XGBoost") { # XGBoost requires different data structure
    # labels_test <- test$group %>% as.numeric() -1
    # test <- select(test, -group)
    # test <- xgb.DMatrix(data = as.matrix(test), label = labels_test)
    # get multilogloss
    row_n <- dim(model$evaluation_log)[1]
    mll <- model$evaluation_log$val_mlogloss[row_n]
  } else {
    pred_prob <- predict(model, test, type = "prob")
    mll <- MLmetrics::MultiLogLoss(pred_prob, test$group)
  }
  
})


# summarise multilogloss over k fold
multi_ll %>% 
  as_tibble() %>% 
  gather() %>% 
  summarise(mean = mean(value), sd = sd(value))


###### The following stats/findings are based on basic RF models
###### (no feature selection)
# species: mean: 0.6889, sd: 0.0608
# genus:   mean: 0.6959, sd: 0.0551
# path:    mean: 0.4921, sd: 0.0669
# we cannot classify UC at all with tax abu and weakly with pathway abu

###### The following stats/findings are based on basic XGB models 
###### (no feature selection and nrounds fixed)
# species: mean: 0.6945, sd: 0.1284
# genus:   mean: 0.6985, sd: 0.1262
# pathway: mean; 0.5382, sd: 0.1440
