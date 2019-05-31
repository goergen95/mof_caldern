#' function to train specific modells to classify FTIR spectra
#'
#'@description

#' This function is used within to apply specific modelling function to the FTIR database.
#' It is used within the TrainTestDataset function to be able to apply various models to the TestDataSet. It heavily realies on 
#' funtionality of the caret package. The user only can choose the model type while the cross-validation technique is held fixed as
#' a leave-one-out-cross-validation (LOOCV). 

#'@author Darius Görgen

#'@param data an object of type DataFrame which numeric variables represent the FTIR spectrum of various samples.

#'@param category  string which is equal to one of the names in data and relates to the classes of the samples.

#'@param clN number of clusters to be used for parallel computing. Default is 4.

#'@param savG list containing the parameters to be used in the Savitzkiy-Golay filtering of the spectra. Default is p =3 and w=11

#'@param path string indicating the directory where the models of the current run should be saved

#'

#'@value returns a list element of the same length as indicated by the noise vector, the first element containing all the pre-process steps 

#' at the first noise level. The order within each noise level is: raw data, normalized data, SG-filter data, 1st derivative, 2nd derivative, SG-filter of 1st derivative
#' SG-filter of 2nd derivative, SG-filter of normalized data, SG-filter of normalized 1st derivative, SG-filter of normalized 2nd derivative,
#' SG-filter of normalized 1st derivative, SG-filter of normalized 2nd derivative,
#' 
#' 

trainModel = function(data, method = "rf", category = category, clN = 4, path = NULL){
  if (method == "rf"){
    cl = parallel::makeCluster(clN)
    doParallel::registerDoParallel(cl)
    mod = train(x = data[,1:ncol(data)-1], y = data[,category], method = "rf", trControl = trCnt, metric = metric, ntree = ntree)
    parallel::stopCluster(cl)
    saveRDS(mod, file = paste0(path,"rfmodel_",levels[level],"_",types[type],".rds"))
    imp = varImp(mod)
  }
  if (method == "plsr"){
    trCnt = trainCt = trainControl(method = "cv", classProbs = TRUE, number = 5 ) 
    cl = parallel::makeCluster(clN)
    doParallel::registerDoParallel(cl)
    mod = train(x = data[,1:ncol(data)-1], y = data[,category], method = "gpls", trControl = trCnt, metric = "Accuracy", ncomp = 60)
    parallel::stopCluster(cl)
    saveRDS(mod, file = paste0(path,"plsrmodel_",levels[level],"_",types[type],".rds"))
    imp = varImp(mod) 
  }
  if (method == "mlp"){
    trCnt = trainCt = trainControl(method = "cv", classProbs = TRUE, number = 5 ) 
    cl = parallel::makeCluster(clN)
    doParallel::registerDoParallel(cl)
    mod = train(x = data[,1:ncol(data)-1], y = data[,category], method = "mlp", trControl = trCnt, metric = "Accuracy", tuneLength = 20)
    parallel::stopCluster(cl)
    saveRDS(mod, file = paste0(path,"mlpmodel_",levels[level],"_",types[type],".rds"))
    imp = varImp(mod) 
  }
  if (method == "svm"){
    trCnt = trainCt = trainControl(method = "cv", classProbs = F, number = 5 ) 
    cl = parallel::makeCluster(clN)
    doParallel::registerDoParallel(cl)
    mod = train(x = data[,1:ncol(data)-1], y = data[,category], method = "lssvmRadial", trControl = trCnt, metric = "Accuracy")
    parallel::stopCluster(cl)
    saveRDS(mod, file = paste0(path,"svmrmodel_",levels[level],"_",types[type],".rds"))
    imp = varImp(mod) 
  }
}
