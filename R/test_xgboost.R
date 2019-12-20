library(tidyverse)
library(glue)
library(here)

########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
# use "pathway" for pathway abundances
features <- "species"

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




library(mlr)
library(xgboost)

# 0 = nonIBD, 1 = CD, 2 = UC
df_xgb <- df %>% mutate(
  group_num = ifelse(
    group == "nonIBD", 0, ifelse(
      group == "CD", 1, 2))) %>%
  select(-group)

# prepare xgb data matrix object
train <- df_xgb[train_index$Resample01, ]
test <- df_xgb[-train_index$Resample01, ]
labels_train <- train$group_num
labels_test <- test$group_num
train <- select(train, -group_num) %>% as.matrix()
test <- select(test, -group_num) %>% as.matrix()
train_xgb <- xgb.DMatrix(data = train, label = labels_train)
test_xgb <- xgb.DMatrix(data = test, label = labels_test)

# default parameters
params <- list(
  booster = "gbtree",
  num_class = 3, 
  objective = "multi:softmax",
  eta = 0.3,
  gamma = 0,
  max_depth = 6,
  min_child_weight = 1,
  subsample = 1,
  colsample_bytree = 1
)
# estimate test error using CV
xgbcv <- xgb.cv(
  params = params, 
  data = train_xgb,
  metrics = "mlogloss",
  nrounds = 100, 
  nfold = 5, 
  showsd = TRUE, 
  stratified = TRUE, 
  print_every_n = 10, 
  early_stop_round = 20, 
  maximize = F)

filter(
  xgbcv$evaluation_log, 
  test_mlogloss_mean == min(xgbcv$evaluation_log$test_mlogloss_mean))
# mlogloss 0.6779 sd = 0.0336


# filter(
#   xgbcv$evaluation_log, 
#   test_merror_mean == min(xgbcv$evaluation_log$test_merror_mean))
# xgbcv$evaluation_log$test_merror_mean %>% mean()

# calculate test error 
xgb1 <- xgb.train(
  params = params,
  data = train_xgb, 
  nrounds = 10,
  watchlist = list(val = test_xgb, train = train_xgb),
  print_every_n = 10, 
  early_stop_round = 10,
  maximize = FALSE,
  eval_metric = "mlogloss"
)
xgb1$evaluation_log
xgb_pred <- predict(xgb1, test_xgb)
conf_matrix <- caret::confusionMatrix(
  xgb_pred %>% as.factor(), 
  labels_test%>% as.factor()) 

conf_matrix$byClass
