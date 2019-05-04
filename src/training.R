setwd("/media/marius/Verbatim/mpg-envinsys-plygrnd/")
library(caret)
library(snow)
library(CAST)
library(rgdal)
library(doParallel)
library(parallel)
# read in training data
data = readRDS("data/training/training_data_ben.rds")
data = readRDS("data/training/training_data.rds")
#read in shapefile with section info
shape = readOGR("data/training/species_poly.shp")
shape = readOGR("data/data_mof/training.shp")


# prepare joining species information to data frame
#shape$id = as.numeric(shape$id)
shape$id = 1:length(shape$id)
spectral_data = data[,1:44]
id = 1:length(shape$id)

# actually joind the information with for-loop
for (i in id){
  spectral_data$species[spectral_data$ID== i] = as.character(shape@data$SP_type)[shape$id==i]
  print(i)
}

# coerce to factor              
spectral_data$species  = as.factor(spectral_data$species)             


# splitting the data
smp = lapply(id, function(i){
  set.seed(15834982)
  smp_rows = sample(nrow(spectral_data[spectral_data$ID ==i,]), 10)
  tmp = spectral_data[spectral_data$ID ==i,][smp_rows,]
  return(tmp)
})
smp = do.call("rbind", smp)

index = CAST::CreateSpacetimeFolds(smp,spacevar = "ID", k = 5)



# train control for rf model - with LAO-CV based on forest sections
tC = caret::trainControl(method = "cv", number =  5,  classProbs = TRUE, index = index$index, indexOut = index$indexOut )


# training the model
cl =  parallel::makeCluster(6)
doParallel::registerDoParallel(cl)
rfModel = CAST::ffs(smp[,2:44], smp$species, method = "parRF", withinSE = FALSE,importance = TRUE, trainControl = tC, metric = "Kappa")
stopCluster(cl)
saveRDS(rfModel, file = "/media/marius/Verbatim/mpg-envinsys-plygrnd/data/training/rfModel.rds")
# validate accuarcies (confusion matrix)

rfModel = readRDS("D:/Ben/goergen/data/training/rfModel.rds")
rfModel
