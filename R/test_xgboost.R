library(tidyverse)
library(glue)
library(here)
library(mlr)
library(xgboost)

########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
# use "pathway" for pathway abundances
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
  num_class = 3, 
  objective = "multi:softprob",
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
  metrics = "mlogloss",
  nrounds = 100, 
  nfold = 10, 
  showsd = TRUE, 
  stratified = TRUE, 
  print_every_n = 10, 
  early_stop_round = 20, 
  maximize = F)
nrounds <- filter(
  xgbcv$evaluation_log, 
  test_mlogloss_mean == min(xgbcv$evaluation_log$test_mlogloss_mean))$iter
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
  eval_metric = "mlogloss"
)

# get multilogloss
row_n <- dim(model$evaluation_log)[1]
mll <- model$evaluation_log$val_mlogloss[row_n]

pred <- predict(model, test_xgb)
pred <- matrix(pred, ncol = 3) %>% as_tibble()
colnames(pred) <- c(0, 1, 2)

pred
labels_test
pred_prob <- predict(model, test, type = "prob")
mlm <- MLmetrics::MultiLogLoss(pred, labels_test)

labels_test
mlm
model$evaluation_log
