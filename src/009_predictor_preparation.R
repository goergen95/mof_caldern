#### filter the pca
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/filterFunction.R")

shape = readOGR("~/edu/mpg-envinsys-plygrnd/data/data_mof/training.shp")
############ preparation####################
#PCA
pca = brick("~/edu/mpg-envinsys-plygrnd/data/aerial/pca/std_pca_pc1_pc4.tif")
names(pca) = c("PC1","PC2","PC3","PC4")
#Filtering
focalOP(pca, path = "~/edu/mpg-envinsys-plygrnd/data/aerial/pca/filter/")

#aerial images & VIs
rgb = brick("~/edu/mpg-envinsys-plygrnd/data/aerial/mosaic_mof.tif")
names(rgb) = c("red","green","blue")
indices = stack(list.files("~/edu/mpg-envinsys-plygrnd/data/aerial/VI/", pattern = ".tif", full.names = T))
filt_pca = stack(list.files("~/edu/mpg-envinsys-plygrnd/data/aerial/pca/filter/", full.names = T))

#lidar statistics
zstats = brick("~/edu/mpg-envinsys-plygrnd/data/lidar/prc/zstats_allLevels.tif")
names(zstats)=c("zmax", "zmean","zsd","zskew","zkurt", "zentropy","pzabovezmean","pzabove2","zq5",
                "zq10","zq15","zq20","zq25","zq30","zq35","zq40","zq45","zq50","zq55","zq60","zq65",
                "zq70","zq75","zq80","zq85","zq90","zq95","zpcum1","zpcum2","zpcum3","zpcum4","zpcum5",
                "zpcum6","zpcum7","zpcum8","zpcum9")
zstats = resample(zstats,rgb)
entropy = raster("~/edu/mpg-envinsys-plygrnd/data/lidar/prc/entropy_allLevels.tif")
entropy = resample(entropy,rgb)
slope = raster("~/edu/mpg-envinsys-plygrnd/data/lidar/prc/slope_pfree.tif")
slope = resample(slope,rgb)
treestats = brick("~/edu/mpg-envinsys-plygrnd/data/lidar/prc/treestats_allLevels.tif")
treestats = resample(treestats, rgb)
names(treestats) = c("npoints","convhull_area")


# extraction
predictors = stack(rgb,indices,pca,filt_pca, zstats, entropy,slope,treestats)
rasterOptions(tmpdir = "C:/Users/dagoe/tmp")#set tmpDir on disk with plenty of free space
training_data = extract(predictors,shape, na.rm =F,df =TRUE)


########### writing files
saveRDS(training_data, file = "~/edu/mpg-envinsys-plygrnd/data/training/training_data.rds")
names = names(predictors)
saveRDS(names, file ="~/edu/mpg-envinsys-plygrnd/data/training/names_predictors.rds")
writeRaster(predictors, filename = "C:/Users/dagoe/Desktop/predictors.tif")
