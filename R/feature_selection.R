# here I adapt the method from Matti for my setting 
# this code will be integrated in the automated workflow

library(mlr)
library(tidyverse)
library(glue)
library(here)
library(randomForest)


###### load datasets

load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")



feature_name <- "species"
task <- "IBD_vs_nonIBD"
classifier <- "randomForest"
k <- 10
p <- 0.8
seed <- 4

########## Extract top 50 features from models based on perm imp

if (file.exists(glue(here("data/top_predictors/{task}_{feature_name}_{classifier}_top_predictors.Rds")))) {
  top_predictors <- load(glue(here("data/top_predictors/{task}_{feature_name}_{classifier}_top_predictors.Rds")))
 } else {
   
   load(file = here(glue("data/models/{task}_{feature_name}_{classifier}.Rds")))
   id_name <- ifelse(
     feature_name %in% names(taxa_by_level), 
     "TaxID", "PathID")
     
     top_predictors <- map(models, function(model) {
       top_predictors <- importance(
         model, 
         type = 1, 
         scale = F) %>%
        as.data.frame() %>%
        rownames_to_column(id_name) %>%
        arrange(desc(MeanDecreaseAccuracy)) %>%
        select(id_name) %>%
        head(50)
        })
    selected_features <- Reduce(intersect, top_predictors)
    save(
      selected_features, 
      file = glue(here("data/top_predictors/{task}_{feature_name}_{classifier}_top_predictors.Rds")))
}




# top_predictors$TaxID <- factor(top_predictors$TaxID, level = top_predictors$TaxID)
# top_predictors[1:50, ] %>%
#   ggplot(aes(TaxID, MeanDecreaseAccuracy)) +
#     geom_bar(stat = "identity")





