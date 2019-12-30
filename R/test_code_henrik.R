library(tidyverse)
library(glue)
library(here)
library(randomForest)



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



########## Model fitting 

# select classifier
classifier <- "randomForest"

# fit models
if (classifier == "randomForest") {
  # fit RF model for k folds and store in list unless model exists already
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
   #### XGBoost ####
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
# calculate multilogloss 
multi_ll <- map2_df(models, train_index, function(model, ti) {
  test <- df[-ti, ]
  pred_prob <- predict(model, test, type = "prob")
  mlm <- MLmetrics::MultiLogLoss(pred_prob, test$group)
})
# summarise multilogloss over k fold
multi_ll %>% 
  as_tibble() %>% 
  gather() %>% 
  summarise(mean = mean(value), sd = sd(value))







# calculate evaluation metric from stored models and test data 
class_error_oob <- map2_df(models, train_index, function(model, ti) {
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


########## The RF model cannot classify UC at all. I will try the extremely  
########## randomized trees algorithm as described by Geurts in a next step 


# fit models for k folds and store in list unless model exists already
library(ranger)
if (!file.exists(here(glue("data/models/{features}_ert_models.Rds")))) {
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
  file = here(glue("data/models/{features}_ert_models.Rds")))

# calculate evaluation metric from stored models and test data 
load(file = here(glue("data/models/{features}_ert_models.Rds")))
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
