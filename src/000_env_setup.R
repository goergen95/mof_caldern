source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_fun.R")
libs = c("rgdal", 
         "raster", 
         "link2GI",
         "mapview",
         "uavRst",
         "lidR",
         "rlas",
         "sp",
         "stringr",
         "RStoolbox",
         "smoothie",
         "FactoMineR", 
         "factoextra",
         "corrplot",
         "rgeos",
         "ggplot2",
         "vegan",
         "magrittr",
         "gdalUtils")

lapply(libs, require, character.only = TRUE)


if(Sys.info()["sysname"] == "Windows"){
  projRootDir = "~/edu/mpg-envinsys-plygrnd"
} else {
  projRootDir = "~/edu/mpg-envinsys-plygrnd"
}

# Set project specific subfolders
project_folders = c("data/", 
                    "data/aerial/org/", "data/aerial/VI/","data/aerial/focal/","data/aerial/pca/","data/lidar/org/","data/lidar/prc/","data/lidar/focal/", "data/grass/", 
                    "data/data_mof/", "data/tmp/","data/validation",
                    "run/", "log/", "mpg-envinfosys-teams-2018-rs_18_axmideda/",
                    "/data/training")

envrmt = initProj(projRootDir = projRootDir, GRASSlocation = "data/grass/",
                  projFolders = project_folders, path_prefix = "path_", 
                  global = FALSE)


#set tmp-dir for raster package
rasterOptions(tmpdir = envrmt$path_data_tmp)

# Link GIS software ------------------------------------------------------------
print("Now linking GIS Software.")
# Find GRASS installations
if (length(list.files(envrmt$path_data, pattern = "grass.rds"))==0){
grass = findGRASS()
saveRDS(grass,file = paste0(envrmt$path_data,"grass.rds"))
}else{
  grass <- readRDS(paste0(envrmt$path_data,"grass.rds"))
}

# Find SAGA installations
if (length(list.files(envrmt$path_data, pattern = "saga.rds"))==0){
saga = findSAGA()
saveRDS(saga, paste0(envrmt$path_data,"saga.rds"))
}else{
  saga <- readRDS(paste0(envrmt$path_data,"saga.rds"))
}



# Find OTB installations
if (length(list.files(envrmt$path_data, pattern = "otb.rds"))==0){
otb = findOTB()
saveRDS(otb, file = paste0(envrmt$path_data,"otb.rds"))
}else{
  otb <- readRDS(paste0(envrmt$path_data,"otb.rds"))
}

#linking SAGA
if(length(saga[,1])==1){
  saga <- linkSAGA(saga, returnPaths = TRUE,
                   searchLocation = saga$binDir[which(saga$installation_type=="qgisSAGA")],
                   quiet = FALSE)
}else{
  saga <- linkSAGA(default_SAGA = saga,
                   returnPaths = TRUE, 
                   searchLocation =saga$binDir[which(saga$installation_type=="soloSAGA")],
                   quiet = FALSE)
}


if (saga$exist) {
  require(RSAGA)
  RSAGA::rsaga.env(path = saga$installed$binDir[1],
                   modules = saga$installed$moduleDir[1])
}

#linking OTB - still searching to long (cause using findOTB again, need to revise that part)

root_dir <<- otb$baseDir
installDir <<- otb$baseDir
otb <- linkOTB(bin_OTB = otb$binDir, 
               root_OTB = otb$baseDir, 
               type_OTB = otb$installation_type,
               searchLocation = otb$baseDir, 
               quiet = FALSE, 
               returnPaths = TRUE)
rm(root_dir)
rm(installDir)

#link grass for aoi


if(length(list.files(envrmt$path_data_grass, pattern ="caldern"))==0){
  r <- raster(paste0(envrmt$path_data,"aerial/mosaic_mof.tif"))
grass <- linkGRASS7(r,
                    default_GRASS7 = grass[which(grass$installation_type=="osgeo4W"),],
                    search_path = grass$instDir[which(grass$installation_type=="osgeo4W")],
                    #ver_select = TRUE,
                    gisdbase = envrmt$path_data_grass,
                    location="caldern",
                    returnPaths = TRUE,
                    quiet = FALSE)
rm(r)
}else{
  r <- raster(paste0(envrmt$path_data,"aerial/mosaic_mof.tif"))
grass <-  linkGRASS7(r,
                     default_GRASS7 = grass[which(grass$installation_type=="osgeo4W"),],
                     search_path = grass$instDir[which(grass$installation_type=="osgeo4W")],
                     ver_select = TRUE,
                     gisdbase = envrmt$path_data_grass,
                     returnPaths = TRUE,
                     quiet = FALSE)
rm(r)
}


# Find GDAL installations
gdal <- list()
if (length(list.files(envrmt$path_data, pattern = "gdal.rds"))==0){
  gdal = linkGDAL()
  saveRDS(gdal, file = paste0(envrmt$path_data,"gdal.rds"))
}else{
  gdal <- readRDS(paste0(envrmt$path_data,"gdal.rds"))
}



           

giLinks <- list()

giLinks$grass <- grass
giLinks$saga <- saga
giLinks$otb <- otb
giLinks$gdal <- gdal
gdalUtils::gdal_setInstallation(search_path = gdal[[1]]$path)
