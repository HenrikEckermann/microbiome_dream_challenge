library(tidyverse)
library(caret)
library(glue)
library(here)
library(randomForest)



########## Select data 

load(here("data/processed/tax_abundances.RDS"))
# select taxonomic level for features
tax_level = "species"
df <- taxa_by_level[[tax_level]] %>%
  select(-sampleID)
head(taxa_id_info)
 
 
 
########## k-fold Cross validation with p% of data as train

k = 10
p <- 0.8
set.seed(4)
train_index <- createDataPartition(df$group, times = k, p = p)



########## Model fitting 

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
# save models
if (!file.exists(here(glue("data/models/{tax_level}_rf_models.Rds")))) {
  save(
    rf_models, 
    train_index, 
    file = here(glue("data/models/{tax_level}_rf_models.Rds")))
  }



########## Model evaluation

# calculate multilogloss from stored models and test data 
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