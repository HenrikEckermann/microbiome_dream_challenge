# this is the code I got from Matti 


#Find the optimal predictors by random forest permutation importance in mlr and hyperparameters through Bayesian optimization (adapted from https://www.simoncoulombe.com/2019/01/bayesian/)
obj.fun <- smoof::makeSingleObjectiveFunction(
  name = "xgb_cv_bayes",
  fn = function(x) {
    train_mbo <- dtrain[cv_folds[[as.numeric(x["fold"])]],]
    test_idx <- setdiff(c(1:dim(dtrain)[1]), cv_folds[[as.numeric(x["fold"])]])
    test_mbo <- dtrain[test_idx,]
    watchlist <- list(train=train_mbo, test=test_mbo)
    set.seed(42)
    cv <- xgb.train(data = train_mbo,
      watchlist = watchlist,
      params = list(
      booster          = "gbtree",
      eta              = x["eta"],
      max_depth        = x["max_depth"],
      min_child_weight = x["min_child_weight"],
      gamma            = x["gamma"],
      subsample        = x["subsample"],
      colsample_bytree = x["colsample_bytree"],
      objective        = "reg:squarederror", 
      eval_metric      = "rmse"),
      nrounds          = x["nrounds"],
      showsd = TRUE,
      verbose = FALSE)
    as.numeric(cv$evaluation_log[max(iter),3])
  },
  par.set = makeParamSet(
    makeNumericParam("eta",              lower = 0.001,  upper = 0.3),
    makeNumericParam("gamma",            lower = 0.1,   upper = 5),
    makeIntegerParam("max_depth",        lower = 2,     upper = 8
    makeIntegerParam("min_child_weight", lower = 1,     upper = 10),
    makeNumericParam("subsample",        lower = 0.2,   upper = 0.8), #set maximum to 80%
    makeNumericParam("colsample_bytree", lower = 0.2,   upper = 0.9),  #set maximum to 90%
    makeIntegerParam("nrounds",          lower = 50,    upper = 5000),
    makeIntegerParam("fold",             lower = 1,     upper = 6, tunable = FALSE)
  ),
  minimize = TRUE
)


obj.fun_class <- smoof::makeSingleObjectiveFunction(
  name = "xgb_cv_bayes",
  fn = function(x) {
    train_mbo <- dtrain_class[cv_folds[[as.numeric(x["fold"])]],]
    test_idx <- setdiff(c(1:dim(dtrain_class)[1]), cv_folds[[as.numeric(x["fold"])]])
    test_mbo <- dtrain_class[test_idx,]
    watchlist <- list(train=train_mbo, test=test_mbo)
    set.seed(42)
    cv <- xgb.train(data = train_mbo,
      watchlist = watchlist,
      params = list(
      booster          = "gbtree",
      eta              = x["eta"],
      max_depth        = x["max_depth"],
      min_child_weight = x["min_child_weight"],
      gamma            = x["gamma"],
      subsample        = x["subsample"],
      colsample_bytree = x["colsample_bytree"],
      objective        = "binary:logistic", 
      eval_metric      = "auc"),
      nrounds          = x["nrounds"],
      showsd = TRUE,
      verbose = FALSE)
    as.numeric(cv$evaluation_log[max(iter),3])
  },
  par.set = getParamSet(obj.fun),
  minimize = FALSE
)
#Generate random sets of the parameter space
set.seed(42)
des <- generateDesign(n=30, par.set = getParamSet(obj.fun), fun = lhs::randomLHS)
#Gather a set of consensus most important features present in all models: intersect of top 50 predictors (ranger permutation importance) in all folds
if (file.exists("/homes/mruuskan/Liver_analysis_antibiotics/top_predictors.RDs") && file.exists("/homes/mruuskan/Liver_analysis_antibiotics/top_predictors_class.RDs")) {
  top_predictors <- readRDS("/homes/mruuskan/Liver_analysis_antibiotics/top_predictors.RDs")
  top_predictors_class <- readRDS("/homes/mruuskan/Liver_analysis_antibiotics/top_predictors_class.RDs")
} else {
  #top_predictors <- list(NULL)
  top_predictors_class <- list(NULL)
  for (fold in 1:length(cv_folds)) {
	#First do feature selection for regression
	fold_regr_task <- makeRegrTask(data = as.data.frame(train_data[cv_folds[[fold]],]), target = "FLI")
	set.seed(42)
	fv <- generateFilterValuesData(fold_regr_task, method = "ranger_permutation")
	fold_predictors <- data.frame(fv$data[order(-fv$data$value),])[1:50,]
  top_predictors[[fold]] <- fold_predictors$name
  #Then for classification
	class_fold_data <- as.data.frame(train_data[cv_folds[[fold]],])
	class_fold_data$FLI <- as.factor(ifelse(class_fold_data$FLI >= 60, 1, 0))
	fold_class_task <- makeClassifTask(data = class_fold_data, target = "FLI", positive = "1")
	set.seed(42)
	fv_class <- generateFilterValuesData(fold_class_task, method = "ranger_permutation")
	fold_predictors_class <- data.frame(fv_class$data[order(-fv_class$data$value),])[1:50,]
  top_predictors_class[[fold]] <- fold_predictors_class$name
  }
  print(top_predictors)
  saveRDS(top_predictors, "/homes/mruuskan/Liver_analysis_antibiotics/top_predictors.RDs")
  print(top_predictors_class)
  saveRDS(top_predictors_class, "/homes/mruuskan/Liver_analysis_antibiotics/top_predictors_class.RDs")
}
top_predictors <- Reduce(intersect, top_predictors)
top_predictors_class <- Reduce(intersect, top_predictors_class)
#Subset features in the data based on results of the feature selection
train_data_subset <- as.matrix(FLI_ML_train[,colnames(FLI_ML_train) %in% c("FLI", top_predictors)])
dtrain <- xgb.DMatrix(data = train_data_subset[,-1], label = train_data_subset[,1])
train_data_subset_class <- as.matrix(FLI_ML_train[,colnames(FLI_ML_train) %in% c("FLI", top_predictors_class)])
dtrain_class <- xgb.DMatrix(data = train_data_subset_class[,-1], label = ifelse(train_data_subset_class[,1] >= 60, 1, 0))
#Run hyperparameter optimization with the feature selected models
if (file.exists("/homes/mruuskan/Liver_analysis_antibiotics/xgboost_parameters.RDs")) {
  run <- readRDS("/homes/mruuskan/Liver_analysis_antibiotics/xgboost_parameters.RDs")
  run_class <- readRDS("/homes/mruuskan/Liver_analysis_antibiotics/xgboost_parameters_class.RDs")
} else {
  control <- makeMBOControl()
  control <- setMBOControlTermination(control, iters = 100)
  run <- mbo(fun = obj.fun, design = des[21:50,], control = control, show.info = TRUE)
  saveRDS(run, "/homes/mruuskan/Liver_analysis_antibiotics/xgboost_parameters.RDs")
  run_class <- mbo(fun = obj.fun_class, design = des[21:50,], control = control, show.info = TRUE)
  saveRDS(run_class, "/homes/mruuskan/Liver_analysis_antibiotics/xgboost_parameters_class.RDs")
}


