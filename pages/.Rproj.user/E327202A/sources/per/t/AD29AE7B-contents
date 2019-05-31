trainTestDataset = function(data,category = "Abbreviation",ntree=200, metric = "Kappa", clN = 7, noiseLevels = c("clean","noise10","noise50","noise100"),path=NULL,
                            preProcTypes = c("raw",
                                             "norm",
                                             "sg",
                                             "d1",
                                             "d2",
                                             "sg.d1",
                                             "sg.d2",
                                             "sg.norm",
                                             "d1.norm",
                                             "d2.norm",
                                             "sg.d1.norm",
                                             "sg.d2.norm"),...){
  #noiseLevels = noiseLevels
  #preProcTypes = preProcTypes
  variables = data.frame(var = 1:20,imp = 1:20)
  for (level in 1:length(noiseLevels)){
    levelData = data[[level]]
    for (type in 1:length(preProcTypes)){
      trainingData = levelData[[type]]
      trCnt = trainCt = trainControl(method = "LOOCV", classProbs = TRUE)
      trainingData[,category] = as.factor(trainingData[,category])
      
      cl = parallel::makeCluster(clN)
      doParallel::registerDoParallel(cl)
      rfModel = train(x = trainingData[,1:ncol(trainingData)-1], y = trainingData[,category], method = "rf", trControl = trCnt, metric = metric, ntree = ntree)
      parallel::stopCluster(cl)
      saveRDS(rfModel, file = paste0(path,"rfmodel_",noiseLevels[level],"_",preProcTypes[type],".rds"))
      imp = varImp(rfModel)
      
      variables$var = attributes(imp$importance)$row.names[which(imp$importance$Overall %in% sort(imp$importance$Overall, decreasing = T)[1:20])]
      variables$imp = imp$importance$Overall[which(imp$importance$Overall %in% sort(imp$importance$Overall, decreasing = T)[1:20])]
      accuracy = rfModel$results[which(rfModel$results$Kappa == max(rfModel$results$Kappa)),]
      print(paste0("Level: ",noiseLevels[level]," Type: ",preProcTypes[type]))
      print(accuracy)
      predictive = rfModel$pred
      conf = rfModel$finalModel$confusion
      results = list(variables,accuracy,predictive,conf)
      saveRDS(results,file = paste0(path,"results_",noiseLevels[level],"_",preProcTypes[type],".rds"))
      
    }
  } 
}
