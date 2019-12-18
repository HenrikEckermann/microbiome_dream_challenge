library(tidyverse)
library(caret)
library(glue)
library(here)

load(here("data/tax_abundances.RDS"))
# superkingdom, phylum, class, order etc. can be loaded.
# change tax_level as required. 
# For pathway analyses load pathway_abundances.RDS like this
# load("data/pathway_abundances.RDS")
# df <- path_abu
# head(path_id_info)

tax_level = "species"
df <- taxa_by_level[[tax_level]] %>%
  select(-sampleID)
head(taxa_id_info)
 

########## 1. Perform k fold CV using p percentage of data as train 
########## 2. For each fold, perform RF model and calculate MultiLogLoss


# k-fold CV
k = 10
# % data training 
p <- 0.8
set.seed(4)
train_index <- createDataPartition(df$group, times = k, p = p)
# fit rf models for k folds and store in list unless model exists already
if (!file.exists(here(glue("data/models/{tax_level}_rf_models.Rds")))) {
  rf_models <- map(train_index, function(ti) {
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

if (!file.exists(here(glue("data/models/{tax_level}_rf_models.Rds")))) {
  save(
    rf_models, 
    train_index, 
    file = here(glue("data/models/{tax_level}_rf_models.Rds")))
  }


# calculate evaluation metric from stored models and test data 
load(file = here(glue("data/models/{tax_level}_rf_models.Rds")))
class_error_oob <- map2_df(rf_models, train_index, function(model, ti) {
  test <- df[-ti, ] 
  class_error_oob <- model$confusion %>% 
    as.data.frame() %>%
    rownames_to_column("group")
})

# average oob class error over k fold 
class_error_oob %>% 
  group_by(group) %>% 
  summarise(
    mean = mean(class.error), 
    sd = sd(class.error))

multi_ll <- map2_df(rf_models, train_index, function(model, ti) {
  test <- df[-ti, ] 
  pred_prob <- predict(model, test, type = "prob")
  mlm <- MLmetrics::MultiLogLoss(pred_prob, test$group)
})

# summarise multilogloss over k fold
multi_ll %>% 
  as_tibble() %>% 
  gather() %>% 
  summarise(mean = mean(value), sd = sd(value))


########## The RF model cannot classify UC at all. I will try the extremely  
########## randomized trees algorithm as described by Geurts in a next step 


# fit models for k folds and store in list unless model exists already
library(ranger)
if (!file.exists(here(glue("data/models/{tax_level}_ert_models.Rds")))) {
  ert_models <- map(train_index, function(ti) {
    train <- df[ti, ]
    test <- df[-ti, ]
    model <- ranger(
      formula = group ~ .,
      data = train,
      splitrule = "extratrees",
      num.trees = 5000,
      replace = FALSE,
      sample.fraction = 1,
      importance = 'impurity',
      write.forest = TRUE,
      probability = TRUE
    )
  })
}

save(
  ert_models, 
  train_index, 
  file = here(glue("data/models/{tax_level}_ert_models.Rds")))

# calculate evaluation metric from stored models and test data 
load(file = here(glue("data/models/{tax_level}_ert_models.Rds")))
ert_class_error <- map2_df(ert_models, train_index, function(model, ti) {
  test <- df[-ti, ]
  tespred <- predict(model, test)
  # calculate error rate per class 
  testpred$predictions %>%
    as_tibble() %>%
    mutate(id = c(1:length(test$group))) %>% # need index to transpose next
    gather(group_pred, prob, -id) %>% # gather and spread to transpose 
    spread(id, prob) %>%
    mutate_if(is.numeric, function(prob) { # only keep the max prob as pred
      ifelse(prob == max(prob), 1, 0)
    }) %>%
    gather(id, pred, -group_pred) %>%
    filter(pred == 1) %>%
    bind_cols(test %>% select(group)) %>% # compare to test set 
    select(group, group_pred) %>%
    mutate(correct = group == group_pred) %>%
    group_by(group) %>%
    summarise(class_error = 1- mean(correct))
})

# summarise class error over k fold 
ert_class_error %>%
  group_by(group) %>%
  summarise(mean = mean(class_error), sd = sd(class_error))


multi_ll <- map2_df(ert_models, train_index, function(model, ti) {
  test <- df[-ti, ] 
  # multilogloss
  pred_prob <- predict(model, test)$predictions
  mlm <- MLmetrics::MultiLogLoss(pred_prob, test$group)
})

# summarise multilogloss over k fold
multi_ll %>% 
  as_tibble() %>% 
  gather() %>% 
  summarise(mean = mean(value), sd = sd(value))
