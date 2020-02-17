
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