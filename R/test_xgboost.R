library(tidyverse)
library(glue)
library(here)
library(mlr)
library(xgboost)

########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
# use "pathway" for pathway abundances
features <- "species"
# select classification task 
task = "IBD_nonIBD"

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


###### Select data according to task

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
                                                                                                                                    
                                                                                                             