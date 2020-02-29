#########################
# Output for submission #
#########################

# once we found the best model, we need to create a specific output file that 
# includes the prediction for both class labels for each classification task. 
# optionally, we need to include feature importance scores from e.g. RF models 



library(tidyverse)
library(glue)
library(here)
library(randomForest)
library(xgboost)

source(here("R/ml_helper.R"))


###### LOAD DATASETS

load(here::here("data/processed/tax_abundances.RDS"))
load(here::here("data/processed/pathway_abundances.RDS"))
load(file = here::here("data/processed/testdataset.RDS"))


###### FUNCTION THAT PRODUCES OUTPUT FILES 

create_pred_files <- function(
  best_model, 
  task, 
  feature_name, 
  classifier = "randomForest") {
      
    # select testdata according to feature_name 
    if (feature_name %in% names(test_taxa_by_level)) {
      testdata <- test_taxa_by_level[[feature_name]]
    } else {
      testdata <- test_path
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
      pred_prob <- predict(best_model, testdata, type = "prob") %>%
        as.data.frame()
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
      "SampleID", 
      glue("Confidence_Value_{c_names[1]}"), 
      glue("Confidence_Value_{c_names[2]}")
    )
    
      # filenames according to features
      feature_name_file <- ifelse(
        feature_name %in% names(taxa_by_level), "Taxonomy", "Pathways")
        
    
    # optional importance scores:
    if (classifier == "randomForest") {
      var_imp <- extract_importance(best_model, regression = FALSE)
      if (feature_name == "pathway") {
        var_imp <- var_imp %>%
          rename(PathwayID = feature, Importance_Optional = MDA) %>% 
          left_join(path_id_info, by = "PathID") %>%
          select(TaxonomyID, Importance_Optional, Description = Pathway)
      } else {
        var_imp <- var_imp %>%
          rename(TaxonomyID = feature, Importance_Optional = MDA) %>% 
          left_join(taxa_id_info, by = "TaxID") %>%
          select(TaxonomyID, Importance_Optional, Description = Taxon)
      }
      write.table(
        var_imp, 
        file = here(glue("data/output/SC2-Processed_{feature_name_file}_{task}_Features.txt")),
        sep = "\t",
        col.names = TRUE,
        row.names = FALSE,
        quote = FALSE
      )
    }
        
    write.table(
      prediction, 
      file = here(glue("data/output/SC2-Processed_{feature_name_file}_{task}_Prediction.txt")),
      sep = "\t",
      col.names = TRUE,
      row.names = FALSE,
      quote = FALSE
    )

}





###### BEST MODELS PER TASK (must be one pathway, one feature) 


### IBD_vs_nonIBD

# F1  pathway  randomForest  250 
# ll  pathway  XGBoost       875 

task <- "IBD_vs_nonIBD"
feature_name <- "pathway"
classifier <- "randomForest"
n_features <- 250
# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)

# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)

# F1  species  randomForest  950
# ll  species  randomForest  100


feature_name <- "species"
classifier <- "randomForest"
n_features <- 100
# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)

# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)

### CD_vs_nonIBD

# F1  pathway  randomForest  175 
# ll  pathway  randomForest  150

task <- "CD_vs_nonIBD"
feature_name <- "pathway"
classifier <- "randomForest"
n_features <- 150

# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)


# F1  species  randomForest  325 
# ll  species  randomForest  525

feature_name <- "species"
classifier <- "randomForest"
n_features <- 325
# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)




### UC_vs_nonIBD

# F1  pathway  randomForest  99999
# ll  pathway  randomForest  50

task <- "UC_vs_nonIBD"
feature_name <- "pathway"
classifier <- "randomForest"
n_features <- 50

# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)
best_model

# F1  species  randomForest  50
# ll  species  randomForest  50


feature_name <- "species"
classifier <- "randomForest"
n_features <- 50

# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)
best_model




### UC_vs_CD

# ll  pathway  extremely_randomized_trees  975

task <- "UC_vs_CD"
feature_name <- "pathway"
classifier <- "extremely_randomized_trees"
n_features <- 975

# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_randomForest_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)
best_model


# ll  species  randomForest  75


feature_name <- "species"
classifier <- "randomForest"
n_features <- 75

# obtain stored top predictors 
load(here(glue("data/top_predictors/{task}_{feature_name}_{classifier}_top{n_features}_predictors.Rds")))

df <- prepare_data(task, feature_name)


x <- df %>% select(selected_features[, 1])
y <- df$group
best_model <- randomForest(
  x = x,
  y = y,
  ntree = 1e4,
  importance = TRUE
)
# double check
df %>% group_by(group) %>% summarise(n())
create_pred_files(best_model, task, feature_name, classifier)
best_model



