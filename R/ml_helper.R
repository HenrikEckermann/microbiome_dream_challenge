
library(tidyverse)
library(randomForest)
library(xgboost)




#########################
###     ML General    ### --------------------------------------
#########################

# returns df of our eval metrics (logloss and F1)
model_eval <- function(
  model, 
  testdata, 
  features,
  y,  
  model_type = "randomForest", 
  classification = TRUE) {
    
    if (classification) {
      
      # what we need for all classfication models
      y_true <- as.numeric(testdata[[y]]) -1
      
      # for most models we can get predictions like this
      if (model_type == "randomForest") {
        y_pred_resp <- predict(model, testdata, type = "response")
        y_pred_resp <- as.numeric(y_pred_resp) -1
        y_pred_prob <- predict(model, testdata, type = "prob")[, 2]
        
      # for xgb models we need a xgb.DMatrix
      } else if (model_type == "XGBoost") {
        testdata_xgb <- select(testdata, features) %>% as.matrix()
        testdata_xgb <- xgb.DMatrix(data = testdata_xgb, label = y_true)
        y_pred_prob <- predict(model, testdata_xgb)
        y_pred_resp <- ifelse(y_pred_prob == 0.5, 
          rbinom(n = 1, size = 1, p = 0.5), ifelse(y_pred_prob > 0.5,
            1, 0))
      }
      # logloss 
      log_l <- MLmetrics::LogLoss(y_pred_prob, y_true)
      
      # F1 scores
      f_one <- MLmetrics::F1_Score(
        factor(y_true, levels = c("0", "1")), 
        factor(y_pred_resp, levels = c("0", "1"))
      )
    }
    
    metric <- tibble(logloss = log_l, F1 = f_one)
    return(metric)
}


# returns a list of lists where each list has a fitted model and the
# corresponding testdata as items 
fit_cv <- function(
  data, 
  features,
  y,
  p = 0.8, 
  k = 10,
  model_type = "randomForest",
  ...
  ) {
    
    dots <- list(...)
    
    # generate k datasets
    train_indeces <- caret::createDataPartition(
      data[[y]], 
      p = p, 
      times = k)
    
    # this will return a list of lists that each contain a fitted model and 
    # the corresponding test dataset 
    models_and_testdata <- map(train_indeces, function(ind) {
      train <- data[ind, ]
      test <- data[-ind, ]
    
      # fit randomForest 
      if (model_type == "randomForest") {
        model <- randomForest::randomForest(
          y = train[[y]],
          x = select(train, features),
          ntree = dots$ntree,
          importance = TRUE
        )
      } else if (model_type == "XGBoost") {
    
        # prepare xgb data matrix object
        labels_train <- train[[y]] %>% as.numeric() -1 # one-hot-coding
        labels_test <- test[[y]] %>% as.numeric() -1
        train_xgb <- select(train, features) %>% as.matrix()
        test_xgb <- select(test, features) %>% as.matrix()
        train_xgb <- xgb.DMatrix(data = train_xgb, label = labels_train)
        test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)
    
        # set model parameters (this should be put in ... at some point)
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
    
        # fit model 
        model <- xgb.train(
          params = params,
          data = train_xgb, 
          nrounds = 10,
          watchlist = list(val = test_xgb, train = train_xgb),
          print_every_n = 10, 
          early_stop_round = 10,
          maximize = FALSE,
          eval_metric = "logloss",
          verbose = 0
        )
      }
      # return fitted model and corresponding test data set
      list(model, test)
    })
    return(models_and_testdata)
}



# summarises eval metrics 
summarize_metrics <- function(models_and_data, y, model_type = "randomForest", features = features) {
  map_dfr(models_and_data, function(model_and_data) {
    model <- model_and_data[[1]]
    testdata <- model_and_data[[2]]
    model_eval(model, testdata, features = features, y = y, model_type = model_type) 
  }) %>%
    gather(metric, value) %>%
    group_by(metric) %>%
    summarise(mean = mean(value), sd = sd(value)) %>%
    mutate_if(is.numeric, round, 2)
}

# plot permutation importance 
plot_importance <- function(model, regression = T, top_n = NULL) {
  
  var_imp <- importance(model, type = 1, scale = F) %>% 
    as.data.frame() %>%
    rownames_to_column("feature")
  if (regression) {
    var_imp <- var_imp %>%
      select(feature, inc_mse = `%IncMSE`) %>%
      arrange(inc_mse) 
    score <- "inc_mse"
    } else {
      var_imp <- var_imp %>%
        select(feature, MDA = MeanDecreaseAccuracy) %>%
        arrange(MDA)
      score <- "MDA"
    }
    
    var_imp <- var_imp %>% 
      mutate(feature = factor(feature, level = feature))
    if (!is.null(top_n)) {
      var_imp <- tail(var_imp, top_n)
    }

    ggplot(var_imp, aes_string("feature", score)) +
      geom_col() +
      coord_flip() 
}

# extract permutation based importance
extract_importance <- function(model, top_n = NULL) {
  
  var_imp <- importance(model, type = 1, scale = F) %>% 
    as.data.frame() %>%
    rownames_to_column("feature")
  if (regression) {
    var_imp <- var_imp %>%
      select(feature, inc_mse = `%IncMSE`) %>%
      arrange(inc_mse) 
    } else {
      var_imp <- var_imp %>%
        select(feature, MDA = MeanDecreaseAccuracy) %>%
        arrange(MDA)
    }
    
    var_imp <- var_imp %>% 
      mutate(feature = factor(feature, level = feature))
    if (!is.null(top_n)) {
      var_imp <- tail(var_imp, top_n)
    }
    
    return(var_imp)    
}




#########################
### Feature Selection ### --------------------------------------
#########################


# Feature selection based on RF importance scores.
# models_and_data is a list of list where each list contains a model object [1]
# and the corresponding testdata [2] According to workflow in this script
select_features <- function(models_and_data, id_name = "id", n_features = 50) {
  top_predictors <- map(models_and_data, function(model_and_data) {
    model <- model_and_data[[1]]
  
    top_predictors <- importance(model, type = 1, scale = F) %>%
      as.data.frame() %>%
      rownames_to_column(id_name) %>%
      arrange(desc(MeanDecreaseAccuracy)) %>%
      select(id_name) %>%
      head(n_features)
    }
  )
  
  # only intersection of all k model is used
  selected_features <- Reduce(intersect, top_predictors)
  return(selected_features)
}


# plot top_n predictors 
plot_importance <- function(model, regression = T, top_n = NULL) {
  if (regression) {
    var_imp <- importance(model, type = 1, scale = F)
    var_imp <- var_imp %>% as.data.frame() %>%
    rownames_to_column("feature") %>%
    select(variable, inc_mse = `%IncMSE`) %>%
    arrange(inc_mse) %>%
    mutate(variable = factor(feature, level = feature))
    if (!is.null(top_n)) {
      var_imp <- tail(var_imp, top_n)
    }
    ggplot(var_imp, aes(feature, inc_mse)) +
      geom_col() +
      coord_flip() 
  } else {
    var_imp <- importance(model, type = 1, scale = F)
    var_imp <- var_imp %>% as.data.frame() %>%
      rownames_to_column("feature") %>%
      select(feature, MDA = MeanDecreaseAccuracy) %>%
      arrange(MDA) %>%
      mutate(feature = factor(feature, level = feature))
    if (!is.null(top_n)) {
      var_imp <- tail(var_imp, top_n)
    }
    ggplot(var_imp, aes(feature, MDA)) +
      geom_col() +
      coord_flip() 
  }
}

# return df of top n predictors 
extract_importance <- function(model, n = NULL, regression = T) {
  if (regression) {
    var_imp <- importance(model, type = 1, scale = F)
    var_imp <- var_imp %>% as.data.frame() %>%
      rownames_to_column("feature") %>%
      select(feature, inc_mse = `%IncMSE`) %>%
      arrange(desc(inc_mse)) %>%
      mutate(feature = factor(feature, level = feature))
  } else {
    var_imp <- importance(model, type = 1, scale = F)
    var_imp <- var_imp %>% as.data.frame() %>%
      rownames_to_column("feature") %>%
      select(feature, MDA = MeanDecreaseAccuracy) %>%
      arrange(desc(MDA)) %>%
      mutate(feature = factor(feature, level = feature))
  }
  if (!is.null(n)) {
    var_imp <- tail(var_imp, n)
  }
  return(var_imp)
}





#########################
## Challenge specific  ## --------------------------------------
#########################

prepare_data <- function(task, feature_name) {
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
  return(df)
}

