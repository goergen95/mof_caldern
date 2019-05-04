#Setup Environment
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

##Read in Data
#Shapefile
shp <- readOGR(dsn=paste0(envrmt$path_data_data_mo,"/uwcWaldorte_AOI.shp"), layer = "uwcWaldorte_AOI") 
#List of aerial images (.tif)
listImages <- list.files(envrmt$path_data_aerial_org, pattern =".tif*",full.names = TRUE)


## Use user defined function to check the projectons of shape and raster
checkProj(listImages)
# check equal extent of rasters and do some cleaning when rasters overlap
checkExt(listImages, path = paste0(envrmt$path_data,"aerial/"))
 


#exclude merged tifs from list
ls <- list.files(path = paste0(envrmt$path_data,"aerial"),pattern="merge")
for (i in 1:length(ls)){
  listImages <- listImages[-which(grepl(substr(ls[i],7,20),listImages))]
}

listImages <- append(listImages,list.files(path = paste0(envrmt$path_data,"aerial"),full.names = TRUE, pattern ="merge")) 


# create function to check if some tifs do not overlap with AOI shapefile
checkExtshp <- function (x,y){
  ext <- extent(x)
  ext2 <- extent(y)
  return(is.null(intersect(ext,ext2)))
}

# apply function
index <- c()
for (i in 1:length(listImages)){
  index[i] <- checkExtshp(raster(listImages[i]),shp)
}

# get rid of not overlapping tifs
listImages <- listImages[-which(index)]


# define function to create on raster file for the AOI
mosaicLists <- function (x,y){
   rls <- lapply(x,brick)
   for (i in 1:length(x)){
   rls[[i]] <- crop(rls[[i]],y)
   }
   tmp <- do.call(merge,rls)
return(tmp)
}

# apply function
mof <- mosaicLists(listImages,shp) 


# write out created images
saveRDS(mof,file=paste0(envrmt$path_data,"aerial/mosaic_mof.rds"))
writeRaster(mof,filename=paste0(envrmt$path_data,"aerial/mosaic_mof.tif"), datatype= "INT1U", overwrite=TRUE)

# clean the workspace
rm(mof, listImages, ls, index, shp)
gc()
  