###### Libraries

library(tidyverse)
library(glue)
library(here)
library(randomForest)
library(xgboost)



###### load datasets

load(here("data/processed/tax_abundances.RDS"))
load("data/processed/pathway_abundances.RDS")


source(here("R/ensemble_functions.R"))
# data: original n (points) x d (n of features) matrix / df. e.g taxonomy matrix
#		(if one wants to include them in the final ensemble)
# target: a single class output target, n x 1 binary (0,1) vector
# tr_inds: indexes of rows in data used for training
# model_names: list of k character names, names of models in model_*_preds
# model_tr_preds: list of k vectors. each vector is of length n_training,
#				  contains predictions of kth model on train data
# model_tst_preds: same as above, but for training set


# helper
factor_as_binary <- function(tgt) {
  as.numeric(levels(tgt)[tgt])
}


# train test split 





tr_inds <- which(runif(rnd_n) > 0.5)

data_tmp_tr <- cbind(rnd_data[tr_inds,], target=rnd_target[tr_inds])
data_tmp_tst <- cbind(rnd_data[-tr_inds,], target=rnd_target[-tr_inds])

data_tmp_tr

# tow toy rf fits. intentionally small ntree to get "weak" results
rf1 <- randomForest(formula = target ~ . , data=data_tmp_tr, ntree=10)
rf1_trpreds <- predict(rf1) # prediction on train set
rf1_trpreds_prob <- predict(rf1, type="prob")[,2] # probabilities of class 1

rf1_preds <- predict(rf1, newdata = data_tmp_tst)
rf1_preds_prob <- predict(rf1, newdata = data_tmp_tst, type="prob")[,2] # probabilities of class 1
rf1_preds_num <- factor_as_binary(rf1_preds)


# misclasification error
sum(rf1_preds != data_tmp_tst$target) / nrow(data_tmp_tst)
# MSE
sum((rf1_preds_prob - factor_as_binary(data_tmp_tst$target))^2)/nrow(data_tmp_tst)

rf2 <- randomForest(formula = target ~ . , data=data_tmp_tr, ntree=5)
rf2_trpreds <- predict(rf2)
rf2_trpreds_prob <- predict(rf2, type="prob")[,2] # probabilities of class 1
rf2_preds <- predict(rf2, newdata = data_tmp_tst)
rf2_preds_prob <- predict(rf2, newdata = data_tmp_tst, type="prob")[,2] # probabilities of class 1
rf2_preds_num <- factor_as_binary(rf2_preds)
sum(rf2_preds != data_tmp_tst$target) / nrow(data_tmp_tst)
# MSE
sum((rf2_preds_prob - factor_as_binary(data_tmp_tst$target))^2)/nrow(data_tmp_tst)

# make an ensemble with glm logistic
tr_inds

source(here("R/ensemble_functions.R"))

ens_res <- logistic_glm_ensemble_predictions(rnd_data, rnd_target, tr_inds, c("rf1", "rf2"),
                                             list(rf1_trpreds, rf2_trpreds),
                                             list(rf1_preds, rf2_preds))


ens_res$ensemble_fit
# misclassification
sum(as.numeric(ens_res$ensemble_preds > 0.5) != data_tmp_tst$target)/nrow(data_tmp_tst)
# MSE error
sum((ens_res$ensemble_preds - factor_as_binary(data_tmp_tst$target))^2)/nrow(data_tmp_tst)

# similar ensemble with GLMnet. notice that target is factor but predictions are numeric probabilities!
ens_glmnet <- logistic_glmnet_ensemble_predictions(rnd_data, rnd_target, tr_inds, c("rf1", "rf2"),
                                                   list(rf1_trpreds_prob, rf2_trpreds_prob),
                                                   list(rf1_preds_prob, rf2_preds_prob), s="lambda.1se")

# misclassification
sum(as.numeric(ens_glmnet$ensemble_preds > 0.5) != data_tmp_tst$target)/nrow(data_tmp_tst)
# MSE error
sum((ens_glmnet$ensemble_preds - factor_as_binary(data_tmp_tst$target))^2)/nrow(data_tmp_tst)

# similar ensemble with GLMnet. notice that target is factor but predictions are numeric probabilities!
ens_glmnet2 <- logistic_glmnet_ensemble_predictions(rnd_data, rnd_target, tr_inds, c("rf1", "rf2"),
                                                   list(rf1_trpreds_prob, rf2_trpreds_prob),
                                                   list(rf1_preds_prob, rf2_preds_prob), s="lambda.min")

# misclassification
sum(as.numeric(ens_glmnet2$ensemble_preds > 0.5) != data_tmp_tst$target)/nrow(data_tmp_tst)
# MSE error
sum((ens_glmnet2$ensemble_preds - factor_as_binary(data_tmp_tst$target))^2)/nrow(data_tmp_tst)
ens_glmnet$ensemble_fit