
library(glmnet)

### simplistic logistic regression stacking ensemble

# helper function 

my_data_combined <- function(data_s, model_s_preds, model_names, target_s=NULL) {
	data_s_preds <- do.call(cbind, c(model_s_preds))
	colnames(data_s_preds) <- model_names

	data_s_combd <- cbind(data_s, data_s_preds)
	if (!is.null(target_s)) {
		data_s_combd <- cbind(data_s_combd, target=target_s)
	}
	data_s_combd
}

# a. logistic regression GLM

# data: original n (points) x d (n of features) matrix / df. e.g taxonomy matrix
#		(if one wants to include them in the final ensemble)
# target: a single class output target, n x 1 binary (0,1) vector
# tr_inds: indexes of rows in data used for training
# model_names: list of k character names, names of models in model_*_preds
# model_tr_preds: list of k vectors. each vector is of length n_training,
#				  contains predictions of kth model on train data
# model_tst_preds: same as above, but for training set

logistic_glm_ensemble_predictions <- function(data, target, tr_inds, model_names, model_tr_preds, model_tst_preds) {
	# data_tr
	data_tr_combd <- my_data_combined(data[tr_inds,], model_tr_preds, model_names, target[tr_inds])

	# fit
	ensemble_fit <- glm(target ~ ., data=data_tr_combd, family=binomial())

	# data_tst
	data_tst_combd <- my_data_combined(data[-tr_inds,], model_tst_preds, model_names, target[-tr_inds])


	ensemble_preds <- predict(ensemble_fit, newdata=data_tst_combd, type="response")

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}


# b. penalized GLM (ElasticNet-LASSO, glmnet)


row_impute <- function (data_m) {
  rmeans <- rowMeans(data_m, na.rm=TRUE)
  data_m_tmp <- sapply(1:nrow(data_m),
                              function (ri) {
                                r <- data_m[ri,]
                                r[is.na(r)] <- rmeans[ri]
                                r
                              })
  as.data.frame(t(data_m_tmp))
}



logistic_glmnet_ensemble_predictions <- function(data, target, tr_inds, model_names, model_tr_preds,
                                                 model_tst_preds, s=c("lambda.min", "lambda.1se"),
                                                 lambda=NULL) {
	# data_tr
	data_tr_combd <- my_data_combined(data[tr_inds,], model_tr_preds, model_names)
	# scale predictors, and impute any NAs in input as rowmeans
	data_tr_combd <- row_impute(scale(data_tr_combd))
	# set any remaining NAs to 0
	data_tr_combd[is.na(data_tr_combd)] <- 0
	
	# fit
	ensemble_fit <- cv.glmnet(as.matrix(data_tr_combd), target[tr_inds], family="binomial", type.measure="class",
							  lambda=lambda)

	# data_tst
	data_tst_combd <- my_data_combined(data[-tr_inds,], model_tst_preds, model_names)
	data_tst_combd <- row_impute(scale(data_tst_combd))


	ensemble_preds <- predict(ensemble_fit, newx=as.matrix(data_tst_combd), s=s, type="response")

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}

# note, this version does not take original data (e.g. taxa or pathways) as input
# it fits glmnet to data only via lower level models (if glmnet is one of them)
logistic_glmnet_ensemble_only_model_predictions <- function(target, tr_inds, model_names, model_tr_preds,
                                                 model_tst_preds, s=c("lambda.min", "lambda.1se"),
                                                 lambda=NULL) {
	# data_tr
	data_tr_combd <- do.call(cbind, c(model_tr_preds))
	colnames(data_tr_combd) <- model_names


	# scale predictors, and impute any NAs in input as rowmeans
	data_tr_combd <- row_impute(scale(data_tr_combd))
		# set any remaining NAs to 0
	data_tr_combd[is.na(data_tr_combd)] <- 0
	


	# fit
	ensemble_fit <- cv.glmnet(as.matrix(data_tr_combd), target[tr_inds], family="binomial", type.measure="class",
							  lambda=lambda)

	# data_tst
	data_tst_combd <- do.call(cbind, c(model_tst_preds))
	colnames(data_tst_combd) <- model_names
	data_tst_combd <- row_impute(scale(data_tst_combd))


	ensemble_preds <- predict(ensemble_fit, newx=as.matrix(data_tst_combd), s=s, type="response")

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}



# note, this version does not take original data (e.g. taxa or pathways) as input
# AND also add between-models-interactions
logistic_glmnet_ensemble_only_model_predictions_with_ia <- function(target, tr_inds, model_names, model_tr_preds,
                                                 model_tst_preds, s=c("lambda.min", "lambda.1se"),
                                                 lambda=NULL) {
	# data_tr
	data_tr_combd <- do.call(cbind, c(model_tr_preds))
	colnames(data_tr_combd) <- model_names


	# scale predictors, and impute any NAs in input as rowmeans
	data_tr_combd <- row_impute(scale(data_tr_combd))
	# set any remaining NAs to 0
	data_tr_combd[is.na(data_tr_combd)] <- 0
	
	# add interactions to model matrix
	# (https://stackoverflow.com/questions/27580267/how-to-make-all-interactions-before-using-glmnet)
	f <- as.formula(~ .*.)

	data_tr_combd <- model.matrix(f, data_tr_combd)[, -1] # remove intercept with -1

	# fit
	ensemble_fit <- cv.glmnet(as.matrix(data_tr_combd), target[tr_inds], family="binomial", type.measure="class",
							  lambda=lambda)
	# data_tst
	data_tst_combd <- do.call(cbind, c(model_tst_preds))
	colnames(data_tst_combd) <- model_names
	data_tst_combd <- row_impute(scale(data_tst_combd))
	data_tst_combd <- model.matrix(f, data_tst_combd)[, -1]


	ensemble_preds <- predict(ensemble_fit, newx=as.matrix(data_tst_combd), s=s, type="response")

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}


# random forest ensemble
# NB. we have conjectured that it is best that if the data has been feature selected.

randomforest_ensemble_predictions <- function(data, target, tr_inds, model_names, model_tr_preds,
                                                 model_tst_preds,
                                                 ntree=5000, importance=TRUE, type="response", ...) {

	# data_tr
	data_tr_combd <- my_data_combined(data[tr_inds,], model_tr_preds, model_names)
	# scale predictors, and impute any NAs in input as rowmeans
	data_tr_combd <- row_impute(scale(data_tr_combd))
	# set any remaining NAs to 0
	data_tr_combd[is.na(data_tr_combd)] <- 0
	
	if(!is.factor(target)) {
		cat("\n NB target is not a factor! \n")
	}

	# fit
	ensemble_fit <- randomForest(x=data_tr_combd, y=target, ntree=ntree, importance=importance)

	# data_tst
	data_tst_combd <- my_data_combined(data[-tr_inds,], model_tst_preds, model_names)
	data_tst_combd <- row_impute(scale(data_tst_combd))


	ensemble_preds <- predict(ensemble_fit, newdata=data_tst_combd, type=type)

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}




# notice that this ensemble takes into account both so called *metafeatures* and model predictions
# metafeature_df is n x K matrix where n is number of data points and K is number of metafeatures
# metafeature_df[tr_inds,] would correspond to data points used in training of models
# colnames of metafeature_df should be legible variable names
# WARNING not testes / finished
logistic_glmnet_ensemble_metafeat_model_predictions_with_ia <- function(target, tr_inds, model_names, model_tr_preds,
                                                 model_tst_preds, metafeature_df, s=c("lambda.min", "lambda.1se"),
                                             	 lambda=NULL) {
	# data_tr
	data_tr_combd <- do.call(cbind, c(model_tr_preds))
	colnames(data_tr_combd) <- model_names

	# scale predictors, and impute any NAs in input as rowmeans
	data_tr_combd <- row_impute(scale(data_tr_combd))
	# set any remaining NAs to 0
	data_tr_combd[is.na(data_tr_combd)] <- 0

	# add metafeatures
	data_tr_combd <- cbind(metafeature_df[tr_inds,], data_tr_combd)

	
	# add POSSIBLE interactions to model matrix
	# (https://stackoverflow.com/questions/27580267/how-to-make-all-interactions-before-using-glmnet)
	f <- as.formula(~ .*.)

	data_tr_combd <- model.matrix(f, data_tr_combd)[, -1] # remove intercept with -1

	# fit
	ensemble_fit <- cv.glmnet(as.matrix(data_tr_combd), target[tr_inds], family="binomial", type.measure="class",
							  lambda=lambda)
	# data_tst
	data_tst_combd <- do.call(cbind, c(model_tst_preds))
	colnames(data_tst_combd) <- model_names
	data_tst_combd <- row_impute(scale(data_tst_combd))

	# add metafeatures
	data_tst_combd <- cbind(metafeature_df[-tr_inds,], data_tst_combd)


	data_tst_combd <- model.matrix(f, data_tst_combd)[, -1]


	ensemble_preds <- predict(ensemble_fit, newx=as.matrix(data_tst_combd), s=s, type="response")

	return(list(ensemble_preds=ensemble_preds, ensemble_fit=ensemble_fit))
}

