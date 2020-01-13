# try out the simple ensemble method provided here: 
# https://machinelearningmastery.com/machine-learning-ensembles-with-r/


library(tidyverse)
library(here)
library(caret)
library(caretEnsemble)


load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS") 

seed <- 4

# combine all taxonomic levels to one df
df <- left_join(
    taxa_by_level[["species"]],
    select(taxa_by_level[["genus"]], - group),
    by = "sampleID") %>%
    left_join(
    select(taxa_by_level[["family"]], - group),
    by = "sampleID") %>%
    left_join(
    select(taxa_by_level[["order"]], - group),
    by = "sampleID") %>%
    left_join(
    select(taxa_by_level[["class"]], - group),
    by = "sampleID") %>%
    left_join(
    select(taxa_by_level[["phylum"]], - group),
    by = "sampleID") %>%
    left_join(
    select(taxa_by_level[["superkingdom"]], - group),
    by = "sampleID") %>%
  select(-sampleID)
  
  
task <- "IBD_vs_nonIBD"
###### Select data accordings to task

if (task == "IBD_vs_nonIBD") {
  df <- df %>%
      mutate(group = ifelse(group %in% c(1,2), 1, 0))
  df$group <- as.factor(df$group)
 } else if (task == "UC_vs_nonIBD") {
     df <- df %>%
         filter(group %in% c(0, 2)) %>%
         mutate(group = ifelse(group == 2, 1, 0))
     df$group <- as.factor(df$group)
 } else if (task == "CD_vs_nonIBD") {
     df <- df %>%
         filter(group %in% c(0, 1))
     df$group <- droplevels(df$group)
 } else if (task == "UC_vs_CD") {
     df <- df %>%
         filter(group %in% c(1, 2)) %>%
         mutate(group = ifelse(group == 1, 1, 0))
     df$group <- as.factor(df$group)
}


control <- trainControl(method="repeatedcv", number=5, repeats=3, savePredictions=TRUE, classProbs=TRUE)
algorithmList <- c("rf", "svmRadial", "elm")
set.seed(seed)
models <- caretList(group~., data=df, trControl=control, methodList=algorithmList)
results <- resamples(models)
summary(results)
dotplot(results)

df %>% colnames()
levels(df$group)

