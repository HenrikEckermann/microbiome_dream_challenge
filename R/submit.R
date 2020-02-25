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

load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")
load(file = here("data/processed/testdataset.RDS"))

create_pred_files <- function(
  best_model, 
  task, 
  feature_name, 
  classifier = "XGBoost") {
      
    # select testdata according to feature_name 
    if (feature_name %in% names(test_taxa_by_level)) {
      testdata <- test_taxa_by_level[[feature_name]]
    } else {
      testdata <- testpath
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
      pred_prob <- predict(best_model, testdata, type = "prob")
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
      "sampleID", 
      glue("Confidence_Value_{c_names[1]}"), 
      glue("Confidence_Value_{c_names[2]}")
    )
    
      # filenames according to features
      feature_name_file <- ifelse(
        feature_name %in% names(taxa_by_level), "Taxonomy", "Pathways")
        
    write.table(
      prediction, 
      file = here(glue("data/output/SC2-Processed_{feature_name_file}_{task}_Prediction.txt")),
      sep = "\t",
      col.names = TRUE,
      row.names = FALSE,
      quote = FALSE
    )

}