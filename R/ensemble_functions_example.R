library(xgboost)
library(randomForest)
### example with random data. only single 0.5 train / test split

#### random data generation, details not important
rnd_n <- 500
rnd_c <- 10
rnd_data <- as.data.frame(matrix(runif(rnd_n*rnd_c), ncol=rnd_c))
rnd_target_tmp <- 3*rnd_data$V1 + 0.8*rnd_data$V2 + 0.2*rnd_data$V3 + 0.1*rnd_data$V4 + runif(rnd_n, min=-0.4, max=0.4)
rnd_target_raw <- as.numeric(2^scale(rnd_target_tmp) / (2^scale(rnd_target_tmp) + 1))
rnd_target <- as.factor(as.numeric(rnd_target_raw > 0.5))

## helper

factor_as_binary <- function(tgt) {
  as.numeric(levels(tgt)[tgt])
}

#### fit rf on random data

tr_inds <- which(runif(rnd_n) > 0.5)

data_tmp_tr <- cbind(rnd_data[tr_inds,], target=rnd_target[tr_inds])
data_tmp_tst <- cbind(rnd_data[-tr_inds,], target=rnd_target[-tr_inds])

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

ens_res <- logistic_glm_ensemble_predictions(rnd_data, rnd_target, tr_inds, c("rf1", "rf2"),
                                             list(rf1_trpreds, rf2_trpreds),
                                             list(rf1_preds, rf2_preds))

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
