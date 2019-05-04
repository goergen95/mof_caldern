predictors = brick("pred_small.tif")
names = readRDS("names_predictors.rds")
names(predictors) = names[c(1:18,21:44)]

#read in shapefile with section info
shape = readOGR("species_poly.shp")

#extract data
ext = extent(predictors)
shape_ras = gdalUtils::gdal_rasterize(src_datasource = "species_poly.shp", 
                                      dst_filename = "shape_ras.tif",
                                      a = "id", 
                                      l  = "species_poly",
                                      tr = c(xres(predictors),yres(predictors)),
                                      te = c(ext[1],ext[3],ext[2],ext[4]),
                                      output_Raster = T)

shape_ras = raster("shape_ras.tif")
segID = values(shape_ras)
index0 = which(segID == 0)
segID = segID[-index0]


trainingVals = lapply(seq(nlayers(predictors)), function(i){
  layerVals = values(predictors[[i]])[-index0]
  #layer = predictors[[i]]
  #layerVals = values(layer)[-index0]
  return(layerVals)
  print(i)
})
saveRDS(trainingVals, "trainingVals.rds")

extractVals = do.call("cbind", trainingVals)
extractVals = as.data.frame(extractVals)
names(extractVals) = names(predictors)
id = unique(segID)
extractVals$species = 1
for(i in 1:length(id)){
  extractVals$species[segID==id[i]] = shape@data$Baumart[which(shape@data$id==id[i])]
  print(i)
}
extractVals$polID = segID
extractVals = na.omit(extractVals)




# splitting the data
smp = lapply(id, function(i){
  set.seed(1234)
  smp_rows = sample(nrow(extractVals[extractVals$polID ==i,]), 20)
  tmp = extractVals[extractVals$polID ==i,][smp_rows,]
  return(tmp)
})
smp = do.call("rbind", smp)
smp$species = as.factor(smp$species)
index = CAST::CreateSpacetimeFolds(smp,spacevar = "polID", k = 5)
smp$species = as.factor(smp$species)
smp$species = as.character(smp$species)
smp$species[smp$species=="1"] = "Beech"
smp$species[smp$species=="2"] = "Dgl"
smp$species[smp$species=="3"] = "Oak"
smp$species[smp$species=="4"] = "Spruce"

# train control for rf model - with LAO-CV based on forest sections
tC = caret::trainControl(method = "cv", number =  5,  classProbs = TRUE, index = index$index, indexOut = index$indexOut )


# training the model
cl =  parallel::makeCluster(7)
doParallel::registerDoParallel(cl)
rfModel = CAST::ffs(smp[,1:42], smp$species, method = "rf", withinSE = FALSE,importance = TRUE, trControl = tC, metric = "Kappa")
stopCluster(cl)
saveRDS(rfModel, file = "rfModel.rds")
# validate accuarcies (confusion matrix)
rfModel


test = lapply(id, function(i){
  set.seed(1234)
  test_rows = sample(nrow(extractVals[extractVals$polID ==i,]), 20)
  tmp = extractVals[extractVals$polID ==i,][-test_rows,]
  return(tmp)
})
test = do.call("rbind", test)


test$species = as.character(test$species)
test$species[test$species=="1"] = "Beech"
test$species[test$species=="2"] = "Dgl"
test$species[test$species=="3"] = "Oak"
test$species[test$species=="4"] = "Spruce"
test$species = as.factor(test$species)


pred = predict(rfModel, test)
confMat = caret::confusionMatrix(test$species,pred)
saveRDS(confMat, "confMat.rds")


cl =  parallel::makeCluster(7)
doParallel::registerDoParallel(cl)
predRas = raster::predict(predictors,rfModel)
stopCluster(cl)
writeRaster(predRas, "predicted_species.tif")



nam = c("red + CIVE",rfModel$selectedvars[3:13])


org = par(no.readonly = TRUE)
png("plots/ffs_vars.png")
par(las=2) # make label text perpendicular to axis
par(mar=c(5,8,4,2))
b =barplot(rfModel$selectedvars_perf, horiz = TRUE, names.arg = nam, col = "lightblue", xlab = "Kappa Score", cex.names = 0.8)
par(org)
print(b)
dev.off()


plotCM <- function(cm){
  cmdf <- as.data.frame(cm[["table"]])
  cmdf[["color"]] <- ifelse(cmdf[[1]] == cmdf[[2]], "green", "red")
  
  alluvial::alluvial(cmdf[,1:2]
                     , freq = cmdf$Freq
                     , col = cmdf[["color"]]
                     , alpha = 0.5
                     , hide  = cmdf$Freq == 0
  )
}
attributes(confMat$table)$dimnames$Prediction = c("Beech","Dgl. Spruce","Oak","Spruce")
attributes(confMat$table)$dimnames$Reference = c("Beech","Dgl. Spruce","Oak","Spruce")
png("plots/cf_alluvial.png")
b = plotCM(confMat)
print(b)
dev.off()