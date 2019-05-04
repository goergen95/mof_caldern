source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")


# get some colors
#pal = mapview::mapviewPalette("mapviewTopoColors")
# define projection
proj4 = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"


##- Get all *.las files of a folder into a list
las_files = list.files(paste0(envrmt$path_data_tmp,"ground/"),
                       pattern = glob2rx("*.las"),
                       full.names = TRUE)



# create DSM
# add an output option FOR THE dsmtin algorithm
#lidR::opt_output_files(mof_snip_ground)<-paste0(envrmt$path_data_tmp,"tin/{ID}_tin_dsm")
#lidR::opt_progress(mof_snip_ground)<-FALSE
#dsm_tin_csf <- lidR::grid_canopy(mof_snip_ground, 
#                                 res = 2, 
#                                 lidR::dsmtin())


# add an output option FOR THE  pitfree algorithm
#lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_tmp,"pfree/{ID}_pfree_dsm")
#dsm_pfree_csf <- lidR::grid_canopy(mof_snip_ground_csf, 
#                                     res = 2,
#                                     lidR::pitfree(c(0,2,5,10,15), c(0, 0.5)))



# add an output option FOR THE  p2r algorithm
#lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_tmp,"p2r/{ID}_p2r_csf")
#dsm_p2r_csf<- lidR::grid_canopy(mof_snip_ground_csf, res = 2, 
#                                lidR::p2r(0.2,na.fill = knnidw()))



# reclass spurious negative values
#dsm_tin_csf[dsm_tin_csf<minValue(dsm_tin_csf)]<-minValue(dsm_tin_csf)
#dsm_pfree_csf[dsm_pfree_csf<0]<-0
#dsm_p2r_csf[dsm_p2r_csf<0]<-0


#writeRaster(dsm_tin_csf, filename = paste0(envrmt$path_data_lidar_prc,"tin/dsm_tin.tif"), overwrite = TRUE)
#writeRaster(dsm_pfree_csf, filename = paste0(envrmt$path_data_lidar_prc,"dsm_pfree.tif"), overwrite = TRUE)
#writeRaster(dsm_p2r_csf, filename = paste0(envrmt$path_data_lidar_prc,"dsm_p2r.tif"), overwrite = TRUE)

#raster::plot(dsm_tin_csf,col=pal(32),main="csf dsmtin 0.5 DSM")

# create DTM
#lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_tmp,"dtm/{ID}_knn_dtm")
#dtm_knn_csf = lidR::grid_terrain(mof_snip_ground_csf, res=2,  algorithm = lidR::knnidw(k=50, p=3))
#writeRaster(dtm_knn_csf, filename = paste0(envrmt$path_data_lidar_prc,"dtm_knn.tif"))

# create chm

#dsm_pfree_csf = resample(dsm_pfree_csf,dtm_knn_csf, method ="bilinear")
#dsm_p2r_csf = resample(dsm_p2r_csf,dtm_knn_csf, method = "bilinear")
#slope = terrain(dsm_pfree_csf,filename = paste0(envrmt$path_data_lidar_prc,"slope_pfree.tif"), opt = "slope", unit = "degrees", overwrite = TRUE)
#writeRaster(dsm_pfree_csf, filename = paste0(envrmt$path_data_lidar_prc,"dsm_pfree.tif"), overwrite = TRUE)
#writeRaster(dsm_p2r_csf, filename = paste0(envrmt$path_data_lidar_prc,"dsm_p2r.tif"), overwrite = TRUE)



#chm1 = dsm_pfree_csf - dtm_knn_csf
#chm2 = dsm_p2r_csf - dtm_knn_csf
#writeRaster(chm,filename = paste0(envrmt$path_data_lidar_prc,"pitfree-knn_chm.tif"), overwrite = TRUE)

#filter LAS catalog for different height levels

#### important: This only works if the following preparation steps have been conducted on LAS files:
#### 1. Find errors with uavRst::llas2llv0()
#### 2. Normalize Z values with lidR::lasnormalize()
#### 3. Reclassify ground returns with lidR::lasground()



#mof_snip_ground_csf = uavRst::make_lidr_catalog(path = paste0(envrmt$path_data_tmp,"ground/"), 
#                                                chunksize = 500, 
#                                                chunkbuffer = 20, 
#                                                proj4=proj4, cores = 6)




# read in mof catalog with buffer included for stats calculation over all levels
mof_snip_ground_csf = uavRst::make_lidr_catalog(path = paste0(envrmt$path_data_tmp,"ground/"), 
                                                chunksize = 500, 
                                                chunkbuffer = 20, 
                                                proj4=proj4, cores = 6)
#entropy - shannon index
#all heights
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"allLevels/entropy/{ID}_entropy")
ent = grid_metrics(mof_snip_ground_csf,lidR::entropy(Z,by = 5), res = 2, start = c(0,0))
writeRaster(ent, filename = paste0(envrmt$path_data_lidar_prc,"entropy_allLevels.tif"))
#level1
lidR::opt_output_files(mof_level1)<-paste0(envrmt$path_data_lidar_prc,"level1LAS/entropyL1/{ID}_entropyL1")
ent1 = grid_metrics(mof_level1,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
writeRaster(ent1, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L1.tif"))
#level2
lidR::opt_output_files(mof_level2)<-paste0(envrmt$path_data_lidar_prc,"level2LAS/entropyL2/{ID}_entropyL2")
ent2 = grid_metrics(mof_level2,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
writeRaster(ent2, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L2.tif"))
#level3
lidR::opt_output_files(mof_level3)<-paste0(envrmt$path_data_lidar_prc,"level3LAS/entropyL3/{ID}_entropyL3")
ent3 = grid_metrics(mof_level3,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
writeRaster(ent3, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L3.tif"))
#level4
lidR::opt_output_files(mof_level4)<-paste0(envrmt$path_data_lidar_prc,"level4LAS/entropyL4/{ID}_entropyL4")
ent4 = grid_metrics(mof_level4,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
writeRaster(ent4, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L4.tif"))
#level5
#lidR::opt_output_files(mof_level5)<-paste0(envrmt$path_data_lidar_prc,"level5LAS/entropyL5/{ID}_entropyL5")
#ent5 = grid_metrics(mof_level5,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
#writeRaster(ent5, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L5.tif"))
#level6
#lidR::opt_output_files(mof_level6)<-paste0(envrmt$path_data_lidar_prc,"level6LAS/entropyL6/{ID}_entropyL6")
#ent6 = grid_metrics(mof_level6,lidR::entropy(Z,by = 1), res = 2, start = c(0,0))
#writeRaster(ent6, filename = paste0(envrmt$path_data_lidar_prc,"entropy_L6.tif"))

t = grid_metrics(las,.stdtreemetrics, res = 2, start = c(0,0))
names(t)
### height information
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"allLevels/zstats/{ID}_zstats")
zstats = grid_metrics(mof_snip_ground_csf,.stdmetrics_z, res = 2, start = c(0,0))
writeRaster(zstats, filename = paste0(envrmt$path_data_lidar_prc,"zstats_allLevels.tif"))


### intensity information
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"allLevels/istats/{ID}_istats")
itstats = grid_metrics(mof_snip_ground_csf,.stdmetrics_i, res = 2, start = c(0,0))#Intensity not found
writeRaster(istats, filename = paste0(envrmt$path_data_lidar_prc,"istats_allLevels.tif"))

### Tree metrics information
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"allLevels/treestats/{ID}_treestats")
treetstats = grid_metrics(mof_snip_ground_csf,.stdtreemetrics, res = 2, start = c(0,0))#ReturnNumber not found
writeRaster(treetstats, filename = paste0(envrmt$path_data_lidar_prc,"treestats_allLevels.tif"))


