source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

shape = readOGR(dsn = paste0(envrmt$path_data_validatio,"/seg_val_den2.shp"), layer = "seg_val_den2")
#chm = raster(paste0(envrmt$path_data_validatio,"/chm.tif"))
#shape = spTransform(shape, crs(chm))
#writeOGR(shape, dsn = paste0(envrmt$path_data_validatio,"/seg_val_den2.shp"), layer = "seg_val_den2", overwrite_layer = TRUE,
#         driver = "ESRI Shapefile")

#chm1 = crop(chm,shape[shape@data$sectionID==1,])
#chm2 = crop(chm,shape[shape@data$sectionID==2,])
#chm3 = crop(chm,shape[shape@data$sectionID==3,])
#chm4 = crop(chm,shape[shape@data$sectionID==4,])
#chm5 = crop(chm,shape[shape@data$sectionID==5,])
#writeRaster(chm1, filename = paste0(envrmt$path_data_validatio,"/chm1.tif"))
#writeRaster(chm2, filename = paste0(envrmt$path_data_validatio,"/chm2.tif"))
#writeRaster(chm3, filename = paste0(envrmt$path_data_validatio,"/chm3.tif"))
#writeRaster(chm4, filename = paste0(envrmt$path_data_validatio,"/chm4.tif"))
#writeRaster(chm5, filename = paste0(envrmt$path_data_validatio,"/chm5.tif"))
chmLS = list.files(path = envrmt$path_data_validatio, pattern = "tif", full.names = TRUE)
kernel = matrix(1,3,3)
#winFun = function(pixel) {m*pixel+b}



valTressSeg = function(chmList, shape, minHeight = 8, m = c(0.1), b = 0.5, valIndex = 1,kernel = matrix(1,3,3)){
  
  results = NULL
  for(i in 1:length(m)){
    
    for(j in 1:length(b)){
      winFun = function(x) {m[i]*x+b[j]}
      #values = 1:5
      #values = values[-which(values==valIndex)]
      #chms = lapply(chmList[-valIndex], raster)
      chm = raster(chmList[valIndex])
      chm =raster::focal(chm, w = kernel, fun = mean)
      #val = raster(chmList[valIndex])
      valPoints = shape[shape@data$sectionID==valIndex,]
      treePos = ForestTools::vwf(chm, winFun = winFun, minHeight=minHeight)
      crowns = ForestTools::mcws(treePos, chm, minHeight = minHeight, format = "polygons",verbose = TRUE)
      valValues = segValues(crowns, valPoints)
      if(is.null(results)){
        #results = do.call(rbind,valValues)
        results = valValues
        results$m = m[i]
        results$b = b[j]
      }else{
        #results2 = do.call(rbind,valValues)
        results2 = valValues
        results2$m = m[i]
        results2$b = b[j]
        results = rbind(results,results2)
      }
    }
  }
  
  return(results)
}

test = valTressSeg(chmLS, shape,valIndex = 5, m = c( 0.1,0.2))

firstTry = valTressSeg(chmList = chmLS, shape = shape, minHeight = 8, m = c(0.1,0.11,0.12,0.13,0.14,0.15,0.16,0.17,0.18,0.19,0.2), b = c(0.9,1,1.1,1.2,1.3,1.4), valIndex = 1)



saveRDS(firstTry,file = paste0(envrmt$path_data_validatio,"/firstTry.rds"))
firstTry = readRDS(paste0(envrmt$path_data_validatio,"/firstTry.rds"))

boxplot(firstTry$hitratio~firstTry$m)
boxplot(firstTry$underratio~firstTry$m)
boxplot(firstTry$overratio~firstTry$m)
boxplot(firstTry$hitratio~firstTry$b)
boxplot(firstTry$underratio~firstTry$b)
boxplot(firstTry$overratio~firstTry$b)

secondTry = valTressSeg(chmList = chmLS, shape = shape, minHeight = 8, m = c(0.1), b = c(1.2), valIndex = 5)
saveRDS(secondTry,file = paste0(envrmt$path_data_validatio,"/secondTry.rds"))
boxplot(secondTry$hitratio~secondTry$m)
boxplot(secondTry$underratio~secondTry$m)
boxplot(secondTry$overratio~secondTry$m)
boxplot(secondTry$hitratio~secondTry$b)
boxplot(secondTry$underratio~secondTry$b)
boxplot(secondTry$overratio~secondTry$b)

thirdTry = valTressSeg(chmList = chmLS, shape = shape, minHeight = 8, m = c(0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.1,0.12,0.13,0.14,0.15,0.155,0.16,0.17,0.18,0.19,0.2), b = c(1.2), valIndex = 5)
saveRDS(thirdTry,file = paste0(envrmt$path_data_validatio,"/thirdTry.rds"))
boxplot(thirdTry$hitratio~thirdTry$m)
boxplot(thirdTry$underratio~thirdTry$m)
boxplot(thirdTry$overratio~thirdTry$m)
boxplot(thirdTry$hitratio~thirdTry$b)
boxplot(thirdTry$underratio~thirdTry$b)
boxplot(thirdTry$overratio~thirdTry$b)

fourthTry = valTressSeg(chmList = chmLS, shape = shape, minHeight = 8, m = c(0.05), b = c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,1.4), valIndex = 3)
saveRDS(fourthTry,file = paste0(envrmt$path_data_validatio,"/fourthTry.rds"))
boxplot(fourthTry$hitratio~fourthTry$m)
boxplot(fourthTry$underratio~fourthTry$m)
boxplot(fourthTry$overratio~fourthTry$m)
boxplot(fourthTry$hitratio~fourthTry$b)
boxplot(fourthTry$underratio~fourthTry$b)
boxplot(fourthTry$overratio~fourthTry$b)


Tpos5=ForestTools::vwf(raster(chmList[5]),winFun=function(x) {0.1*x+1.2},minHeight = 8)
crowns5=ForestTools::mcws(Tpos5,minHeight = 8,CHM = raster(chmList[5]),format = "polygons",verbose = TRUE)
pal = mapview::mapviewPalette("mapviewTopoColors")
raster::plot(raster(chmList[5]),col=pal(32))
plot(crowns5, add = T)
plot(shape5,pch=20, add = T)

Tpos5=ForestTools::vwf(raster(chmList[1]),winFun=function(x) {0.08*x+1.2},minHeight = 8)
crowns5=ForestTools::mcws(Tpos5,minHeight = 8,CHM = raster(chmList[1]),format = "polygons",verbose = TRUE)
plot(raster(chmList[1]))
plot(crowns5, add = T)
  
shape1= crop(shape, shape[shape@data$sectionID==1,])
shape3= crop(shape, shape[shape@data$sectionID==3,])
shape5= crop(shape, shape[shape@data$sectionID==5,])