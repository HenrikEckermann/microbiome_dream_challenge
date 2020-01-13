library(tidyverse)
library(glue)
library(here)
library(mlr)
library(xgboost)
library(mlrMBO)

# set settings for xgboost example model
feature_name <- "species"
task <- "IBD_vs_nonIBD"
classifier <- "XGBoost"
k <- 10
p <- 0.8
seed <- 4

########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
 

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
 } else if (task == "UC_vs_CD") {
     df <- df %>%
         filter(group %in% c(1, 2)) %>%
         mutate(group = ifelse(group == 1, 1, 0))
     df$group <- as.factor(df$group)
}

########## k-fold Cross validation with p% of data as train

k = 10
p <- 0.8
set.seed(4)
train_index <- caret::createDataPartition(df$group, times = k, p = p)






obj.fun <- smoof::makeSingleObjectiveFunction(
  name = "xgb_cv_bayes",
  fn = function(x) {
    train_mbo <- dtrain_class[cv_folds[[as.numeric(x["fold"])]],]
    test_idx <- setdiff(c(1:dim(dtrain_class)[1]), cv_folds[[as.numeric(x["fold"])]])
    test_mbo <- dtrain_class[test_idx,]
    watchlist <- list(train=train_mbo, test=test_mbo)
    set.seed(42)
    cv <- xgb.train(data = train_mbo,
      watchlist = watchlist,
      params = list(
      booster          = "gbtree",
      eta              = x["eta"],
      max_depth        = x["max_depth"],
      min_child_weight = x["min_child_weight"],
      gamma            = x["gamma"],
      subsample        = x["subsample"],
      colsample_bytree = x["colsample_bytree"],
      objective        = "binary:logistic", 
      eval_metric      = "logloss"),
      nrounds          = x["nrounds"],
      showsd = TRUE,
      verbose = FALSE)
    as.numeric(cv$evaluation_log[max(iter),3])
  },
    par.set = makeParamSet(
      makeNumericParam("eta",              lower = 0.001,  upper = 0.3),
      makeNumericParam("gamma",            lower = 0.1,   upper = 5),
      makeIntegerParam("max_depth",        lower = 2,     upper = 8),
      makeIntegerParam("min_child_weight", lower = 1,     upper = 10),
      makeNumericParam("subsample",        lower = 0.2,   upper = 0.8), #set maximum to 80%
      makeNumericParam("colsample_bytree", lower = 0.2,   upper = 0.9),  #set maximum to 90%
      makeIntegerParam("nrounds",          lower = 50,    upper = 5000),
      makeIntegerParam("fold",             lower = 1,     upper = 6, tunable = FALSE)
    ),
  minimize = TRUE
)




































# prepare xgb data matrix object
train <- df[train_index$Resample01, ]
test <- df[-train_index$Resample01, ]
d_complete <- df
labels_train <- train$group %>% as.numeric() -1
labels_test <- test$group %>% as.numeric() -1
labels_complete <- d_complete$group %>% as.numeric() -1
train <- select(train, -group) %>% as.matrix()
test <- select(test, -group) %>% as.matrix()
d_complete <- select(d_complete, -group) %>% as.matrix()
train_xgb <- xgb.DMatrix(data = train, label = labels_train)
test_xgb <- xgb.DMatrix(data = test, label = labels_test)
complete_xgb <- xgb.DMatrix(data = d_complete, label = labels_complete)

# default parameters
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

# find parameter nrounds (in classification this is number of
# trees to grow) using CV; might later tune other parameters
xgbcv <- xgb.cv(
  params = params, 
  data = complete_xgb,
  metrics = "logloss",
  nrounds = 100, 
  nfold = 10, 
  showsd = TRUE, 
  stratified = TRUE, 
  print_every_n = 10, 
  early_stop_round = 20, 
  maximize = F)
nrounds <- filter(
  xgbcv$evaluation_log, 
  test_logloss_mean == min(xgbcv$evaluation_log$test_logloss_mean))$iter
print(glue('Parameter "nrounds" is set to {nrounds}'))

xgbcv$evaluation_log

# nrounds tuning:
# species: 8
# pathways: 10 

# train model using nrounds
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

# get logloss
row_n <- dim(model$evaluation_log)[1]
log_ <- model$evaluation_log$val_logloss[row_n]

pred <- predict(model, test_xgb)
pred %>% length()
pred
pred <- ifelse(pred >= 0.5, 1, 0)
pred <- as.factor(pred)
test_cf <- caret::confusionMatrix(pred, as.factor(labels_test), positive = "1")
test_cf$table %>% as.data.frame()
test_cf
                                                                                                                                    
                                                                                                             