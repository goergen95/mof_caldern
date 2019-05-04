source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

lcat <- readRDS(file= paste0(envrmt$path_data,"lidar/las_mof_aoi.rds"))


dtm <- as.raster(grid_terrain(lcat,
                    method = "knnidw",
                    k = 10L,
                    p = 2,
                    keep_lowest = TRUE))
#dtm <- as.raster(dtm)
crs(dtm) = lcat@crs
writeRaster(dtm, filename = paste0(envrmt$path_data_lidar_prc,"dtm.tif"))

dsm <- as.raster(grid_canopy(lcat,
                   res = 0.5,
                   subcircle = 0.2,
                   na.fill = "knnidw",
                   k = 10L,
                   p = 2))

#dsm <- as.raster(dsm)
crs(dsm) = lcat@crs
dsm <- raster::resample(dsm,dtm, method = "bilinear")
writeRaster(dsm, filename = paste0(envrmt$path_data_lidar_prc,"dsm.tif"))


chm <- dsm - dtm
chm[chm<0] <- 0
writeRaster(chm, filename = paste0(envrmt$path_data_lidar_prc,"chm.tif"))




