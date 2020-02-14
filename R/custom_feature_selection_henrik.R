library(tidyverse)
library(glue)
library(here)
library(randomForest)

source(here("R/ml_helper.R"))
source("https://raw.githubusercontent.com/HenrikEckermann/in_use/master/mb_helper.R")



# import data 
load(here("data/processed/tax_abundances.RDS"))
load(here("data/processed/pathway_abundances.RDS"))

task <- "CD_vs_nonIBD"
# for shannon_df and pcx object we need to select feature
feature_name <- "species"

# create a complete df of all features
df_all <- map_dfc(c(names(taxa_by_level), "pathway"), function(feature_name) {
  load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
  # we only need sampleID once
  if (feature_name == "species") {
    df
  } else {
    select(df, -sampleID)
  }
})


# get PCs from species PCA
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_sp <- pcx$x %>% 
 as.data.frame() %>% 
 rownames_to_column("sampleID") 
colnames(pcs_sp) <- glue("{colnames(pcs_sp)}_sp")
pcs_sp <- select(pcs_sp, sampleID = sampleID_sp, everything())

# get PCs from genus PCA
feature_name <- "genus"
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_gn <- pcx$x %>% 
 as.data.frame() %>% 
 rownames_to_column("sampleID") 
colnames(pcs_gn) <- glue("{colnames(pcs_gn)}_gn")
pcs_gn <- select(pcs_gn, sampleID = sampleID_gn, everything())

# get PCs from pathway PCA
feature_name <- "pathway"
load(here(glue("data/processed/{task}_{feature_name}_data.rds")))
pcs_pw <- pcx$x %>% 
  as.data.frame() %>% 
  rownames_to_column("sampleID")
colnames(pcs_pw) <- glue("{colnames(pcs_pw)}_pw")
pcs_pw <- select(pcs_pw, sampleID = sampleID_pw, everything())
 


df_all <-  df_all %>%
  left_join(pcs_sp, by = "sampleID") %>%
  left_join(pcs_gn, by = "sampleID") %>%
  left_join(pcs_pw, by = "sampleID") %>%
  left_join(select(shannon_df, -group), by = "sampleID") %>%
  left_join(labels, by = "sampleID")

# model_pc <- randomForest(
#   y = pcs$group,
#   x = select(pcs, -sampleID, -group, PC1, PC2, PC3, PC4),
#   ntree = 1e4,
#   importance = TRUE
# ) 
# 
# model <- randomForest(
#   y = labels$group,
#   x = select(df, -sampleID),
#   ntree = 1e4,
#   importance = TRUE
# )


feat_spc <- c(
    "Escherichiacoli",
    "Klebsiellapneumoniae",
    "Faecalibacteriumprausnitzii",
    "Eubacteriumrectale",
    "Ruminococcusbicirculans",
    "Anaerostipeshadrus",
    "LachnospiraceaebacteriumGAM79",
    "DialisterspMarseilleP5638",
    "Eubacteriumeligens",
    "Roseburiahominis",
    "Veillonellaparvula",
    "Bacteroidesfragilis",
    "Clostridiumbolteae",
    "Bacteroidesthetaiotaomicron",
    "Bacteroidesovatus",
    "shannon", 
    "PC1"
)
features <- c(
  # Species 
  "Bifidobacteriumbifidum", # lit
  "Bifidobacteriumlongum",  # lit
  "Roseburiahominis",
  "Clostridiumbolteae", 
  # Genus
  "Akkermansia", # lit
  "Shigella", # lit
  "Enterobacteriaceae", # lit
  "Escherichia",
  "Bacteroides",
  "Klebsiella",
  "Lachnoclostridium",
  "Veillonella",
  "Fusobacterium",
  "Parabacteroides",
  "Dialister",
  "Roseburia",
  "Anaerostipes",
  "Ruminococcus",
  "Eubacterium",
  "Bifidobacterium",
  "CandidatusCloacimonas",
  "Faecalibacterium",
  # Family
  "Coriobacteriaceae",
  "Christensenellaceae",
  
  # Phylum 
  "Tenericutes", # lit
  "Lentisphaerae", # lit
  "Actinobacteria", # lit
  "Firmicutes", # lit
  "Proteobacteria", # lit 
  "Eubacteriumrectale", # lit
  # pathways
  "UNINTEGRATEDgEscherichiasEscherichiacoli",
  "UNINTEGRATED",
  "UNINTEGRATEDgKlebsiellasKlebsiellapneumoniae",
  "UNINTEGRATEDgBlautiasRuminococcusgnavus",
  "UNINTEGRATEDgClostridiumsClostridiumsymbiosum",
  "UNINTEGRATEDgBacteroidessBacteroidescoprocola",
  "UNINTEGRATEDgBacteroidessBacteroidesstercoris",
  "UNINTEGRATEDgPrevotellasPrevotellacopri",
  "UNINTEGRATEDgBacteroidessBacteroidesplebeius",
  "UNINTEGRATEDgRoseburiasRoseburiainulinivorans",
  "UNINTEGRATEDgEubacteriumsEubacteriumrectale",
  "UNINTEGRATEDgBacteroidessBacteroidesuniformis",
  "UNMAPPED",
  "UNINTEGRATEDgFaecalibacteriumsFaecalibacteriumprausnitzii",
  "UNINTEGRATEDunclassified",
  # other 
  "shannon",
  "PC1_sp",
  "PC2_sp",
  "PC3_sp",
  "PC4_sp",
  # "PC1_gn",
  # "PC2_gn",
  # "PC3_gn",
  # "PC4_gn",
  "PC1_pw",
  "PC2_pw",
  "PC3_pw",
  "PC4_pw"
)

# next: try to add species etc. mentioned by literature...

df_all %>% dim()

custom_rf <- rf_summary(
  df_all, 
  features,
  outcome = "group",
  regression = FALSE
)



custom_rf


# # tune rf algorithm
# library(caret)
# fit_control <- trainControl(## 5-fold CV
#                            method = "repeatedcv",
#                            number = 10,
#                            ## repeated 5 times
#                            repeats = 1)
# 
# mtry <- c(143, seq(1, 20364, 200))
# hg_ef <- expand.grid(
#   .mtry = mtry,
#   .splitrule = "extratrees",
#   .min.node.size = c(1, 5, 10, 15)
# )
# fit_ef <- train(
#   y = df_all[["group"]],
#   x = df_all %>% select(features),
#   method = "ranger",
#   tuneGrid = hg_ef,
#   num.trees = 1000,
#   replace = FALSE
# )


### code eval metrics 
y <- "group"
train_index <- caret::createDataPartition(df_all$group, times = 10, p = 0.8)
train <- df_all[train_index$Resample01, c(features, y)]
test <- df_all[-train_index$Resample01, c(features, y)]

model <- randomForest(
  x = train[, features],
  y = train[[y]],
  ntree = 5000
)


model_eval(model, test, features, y)


y_true <- test[[y]]
y_pred <- predict(model, test)
MLmetrics::F1_Score(y_true, y_pred)


library(xgboost)
# prepare xgb data matrix object
labels_train <- train$group %>% as.numeric() -1 # one-hot-coding
labels_test <- test$group %>% as.numeric() -1
train_xgb <- select(train, features) %>% as.matrix()
test_xgb <- select(test, features) %>% as.matrix()
train_xgb <- xgb.DMatrix(data = train_xgb, label = labels_train)
test_xgb <- xgb.DMatrix(data = test_xgb, label = labels_test)

# set model parameters (this should be default parameters)
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


model <- xgb.train(
  params = params,
  data = train_xgb, 
  nrounds = 10,
  watchlist = list(val = test_xgb, train = train_xgb),
  print_every_n = 10, 
  early_stop_round = 10,
  maximize = FALSE,
  eval_metric = "logloss"
)

y_true <- test[[y]]
y_pred <- predict(model, test_xgb)
#y_pred <- ifelse(y_pred > 0.5, 1, 0)
MLmetrics::F1_Score(y_true, y_pred)
MLmetrics::LogLoss(y_pred, as.numeric(y_true)-1)




models_and_data <- fit_cv(
  df_all, 
  features, 
  y, 
  p = 0.8,
  k = 10,
  model_type = "randomForest", 
  ntree = 1000
)

test <- map(models_and_data, function(model_and_data) {
  model <- model_and_data[[1]]
  testdata <- model_and_data[[2]]
  model_eval(model, testdata, features, y)
})

test

