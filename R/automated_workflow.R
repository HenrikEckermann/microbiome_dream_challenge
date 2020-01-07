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



fit_and_evaluate <- function(
  task, 
  feature_name, 
  classifier, 
  k = 10, 
  p = 0.8, 
  seed = 4) {
  
  
  

  ########## Select taxonomic level or pathway 

  if (feature_name %in% names(taxa_by_level)) {
    df <- taxa_by_level[[feature_name]] %>%
      select(-sampleID)
    } else if (feature_name == "pathway") {
    df <- path_abu %>%
      select(-sampleID)
  } else if (feature_name == "all") {
    df <- left_join(
        taxa_by_level[["species"]],
        select(taxa_by_level[["genus"]], - group),
        by = "sampleID") %>%
        left_join(
        select(path_abu, -group),
        by = "sampleID"
       ) %>%
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
   } else if (task == "CD_vs_UC") {
       df <- df %>%
           filter(group %in% c(1, 2)) %>%
           mutate(group = ifelse(group == 1, 1, 0))
       df$group <- as.factor(df$group)
  }

  
  ########## k-fold Cross validation with p% of data as train
  
  set.seed(seed)
  train_index <- caret::createDataPartition(df$group, times = k, p = p)
  
  
  ######### Model fitting 
  
  
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
  
  
  ########## Model evaluation
  
  load(file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
  
  # logloss
  log_l <- map2_df(models, train_index, function(model, ti) {
    test <- df[-ti, ]
    if (classifier == "XGBoost") { # XGBoost requires different data structure
      row_n <- dim(model$evaluation_log)[1]
      log_l <- model$evaluation_log$val_logloss[row_n]
    } else {
      pred_prob <- predict(model, test, type = "prob")
      log_l <- MLmetrics::LogLoss(pred_prob[, 2], as.numeric(test$group) - 1)
    }
  
  })
  
  # log_l plot
  log_l_plot <- log_l %>% 
    as_tibble() %>% 
    gather() %>%
    ggplot(aes(x = "10 fold CV logloss", y = value)) +
    geom_boxplot() +
    geom_jitter(width = 0.05, color = "red", size = 3)
  
  # summarise multilogloss over k fold
  log_l <- log_l %>% 
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
      cfm_df <- caret::confusionMatrix(pred, as.factor(test$group), positive = "1")$table %>%
      as.data.frame()
      # manipulate df according to task
      if (task == "IBD_vs_nonIBD") {
        cfm_df <- cfm_df %>%
            mutate(Prediction = ifelse(Prediction == 1, "IBD", "nonIBD"),
                   Reference = ifelse(Reference == 1, "IBD", "nonIBD")
          )
       } else if (task == "UC_vs_nonIBD") {
           cfm_df <- cfm_df %>%
               mutate(Prediction = ifelse(Prediction == 1, "UC", "nonIBD"),
                      Reference = ifelse(Reference == 1, "UC", "nonIBD")
             )
       } else if (task == "CD_vs_nonIBD") {
           cfm_df <- cfm_df %>%
               mutate(Prediction = ifelse(Prediction == 1, "CD", "nonIBD"),
                      Reference = ifelse(Reference == 1, "CD", "nonIBD")
             )
       } else if (task == "CD_vs_UC") {
           cfm_df <- cfm_df %>%
               mutate(Prediction = ifelse(Prediction == 1, "CD", "UC"),
                      Reference = ifelse(Reference == 1, "CD", "UC")
             )
      }
  })
    
  list(
    "models" = models,
    "logloss" = log_l,
    "logloss_plot" = log_l_plot,
    "confusion_matrix" = cfm
  )  
  
}


  

###### test function 

rf_model <- fit_and_evaluate(
  task = "IBD_vs_nonIBD", 
  feature_name = "species", 
  classifier = "randomForest",
  k = 10,
  p = 0.8, 
  seed = 4
)

xgb_model <- fit_and_evaluate(
  task = "IBD_vs_nonIBD", 
  feature_name = "species", 
  classifier = "XGBoost",
  k = 10,
  p = 0.8, 
  seed = 4
)
  
  
rf_model$logloss
xgb_model$logloss


# # create documents for all tasks, features and classifiers considered so far
# 
# tasks <- list("UC_nonIBD", "CD_nonIBD", "UC_CD")
# feature_list <- list("species", "genus", "pathway")
# classifier_list <- list("randomForest", "XGBoost")
# map(tasks, function(task) {
#   map(feature_list, function(feature_name) {
#     map(classifier_list, function(classifier) {
#       fit_and_evaluate(task, feature_name, classifier)
#     })
#   })
# })



# source(here("R/create_report.R"))
# create_pred_files(test$models$Resample01, "CD_vs_UC", "species")



# #########################
####### Binary ##########
#########################

###### The following stats/findings are based on basic RF models 
###### (no feature selection)
# species: mean: 0.9183, sd: 0.0507
# genus:   mean: 0.4592, sd: 0.0945
# pathway: mean: 1.0880, sd: 0.0668
# all:     mean: 0.3498, sd: 0.0634

###### The following stats/findings are based on basic RF models 
###### (no feature selection)
# species: mean: 0.4537, sd: 0.1254
# genus:   mean: 0.4592, sd: 0.0945
# pathway: mean: 0.3093, sd: 0.0865
# all:     mean: 0.3498, sd: 0.0634

#########################
# Output for submission #
#########################

# once we found the best model, we need to create a specific output file that 
# includes the prediction for both class labels for each classification task 
# optionally, we need to include feature importance scores from e.g. RF models 

load(file = here("data/processed/testdataset.RDS"))

create_pred_files <- function(
  best_model, 
  task, 
  feature_name, 
  classifier = "XGBoost") {
      
    # select testdata according to feature_name 
    if (feature_name %in% names(test_taxa_by_level)) {
      testdata <- test_taxa_by_level[[feature_name]]
    } else {
      testdata <- testpath
    }
    
    # make predictions 
    if (classifier == "XGBoost") { # XGBoost requires different data structure
      testdata_xgb <- as.matrix(select(testdata, -sampleID))
      testdata_xgb <- xgb.DMatrix(data = testdata_xgb)
      pred_prob <- predict(best_model, testdata_xgb) %>%
        as.data.frame() %>%
        select("1" = ".") %>%
        mutate("0" = 1 - `1`)
     } else {
      pred_prob <- predict(best_model, testdata, type = "prob")
     }
    prediction <- pred_prob %>%
      bind_cols(select(testdata, sampleID)) %>%
      select(sampleID, "1", "0")

    # adapt colnames according to tasks
    if (task == "IBD_vs_nonIBD") {
      c_names <- c("IBD", "nonIBD")
     } else if (task == "CD_vs_nonIBD") {
      c_names <- c("CD", "nonIBD")
     } else if (task == "UC_vs_nonIBD") {
      c_names <- c("UC", "nonIBD")
     } else {
      c_names <- c("CD", "UC")
    }
    
    colnames(prediction) <- c(
      "sampleID", 
      glue("Confidence_Value_{c_names[1]}"), 
      glue("Confidence_Value_{c_names[2]}")
    )
    
      # filenames according to features
      feature_name_file <- ifelse(
        feature_name %in% names(taxa_by_level), "Taxonomy", "Pathways")
        
    write.table(
      prediction, 
      file = here(glue("data/output/SC2-Processed_{feature_name_file}_{task}_Prediction.txt")),
      sep = "\t",
      col.names = TRUE,
      row.names = FALSE,
      quote = FALSE
    )


  
}

df <- path_abu %>%
  select(-sampleID) %>%
  mutate(group = ifelse(group %in% c(1,2), 1, 0))
df$group <- as.factor(df$group)
set.seed(4)
train_index <- caret::createDataPartition(df$group, times = 10, p = 0.8)
test <- df[-train_index$Resample01, ]
pred_prob <- predict(rf_model$models$Resample01, test, type = "prob") 
log_l <- MLmetrics::LogLoss(pred_prob[, 2], as.numeric(test$group) - 1)
log_l


