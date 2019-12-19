library(tidyverse)
library(caret)
library(glue)
library(here)
library(randomForest)



########## Select taxonomic level or pathway 

load(here("data/processed/tax_abundances.RDS"))
# use "pathway" for pathway abundances
features <- "pathway"

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
train_index <- createDataPartition(df$group, times = k, p = p)



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

###### The following stats/findings are based on basic RF models (no feature selection)
# species: mean: 0.6889, sd: 0.0608
# genus:   mean: 0.6959, sd: 0.0551
# path:    mean: 0.4921, sd: 0.0669
# we cannot classify UC at all with tax abu and weakly with pathway abu
