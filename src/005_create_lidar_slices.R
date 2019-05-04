source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

proj4 = "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"

# function to filter for specific heights
levelFilt = function(las, minZ = 0, maxZ=5){
  las = readLAS(las)
  if (is.empty(lidR::lasfilter(las, Z >=minZ & Z < maxZ))) return(NULL) 
  las = lidR::lasfilter(las, Z >=minZ & Z < maxZ)
  return(las)
}

# read in normalized lidar data
mof_snip_norm = uavRst::make_lidr_catalog(path = paste0(envrmt$path_data_lidar_prc,"normalized/"), 
                                                chunksize = 500, 
                                                chunkbuffer = 0, 
                                                proj4=proj4, cores = 6)
## all returns
lidR::opt_output_files(mof_snip_norm)<-paste0(envrmt$path_data_lidar_prc,"allLevels/returns/{ID}_allLevel")
returnsAL = grid_density(mof_snip_norm, res = 2)
returnsAL[is.na(values(returnsAL))] = 0
writeRaster(returnsAL, filename = paste0(envrmt$path_data_lidar_prc,"allLevels/returns/allLevels.tif"))
returnsAL = raster( paste0(envrmt$path_data_lidar_prc,"allLevels/returns/allLevels.tif"))

###level 1 0 to 1.5 meters Krautschicht
lidR::opt_output_files(mof_snip_norm)<-paste0(envrmt$path_data_lidar_prc,"level1/{ID}_level1LAS")
mof_level1 = lidR::catalog_apply(mof_snip_norm,levelFilt,0,1.5)
mof_level1 = uavRst::make_lidr_catalog(unlist(mof_level1),chunksize = 500, 
                                       chunkbuffer = 10, 
                                       proj4=proj4, cores = 6)

lidR:::catalog_laxindex(mof_level1)
lidR::opt_output_files(mof_level1)<-paste0(envrmt$path_data_lidar_prc,"level1/returns/{ID}_level1LAS")
level1 = lidR::grid_density(mof_level1, res = 2)
level1[is.na(level1)] = 0
writeRaster(level1, filename = paste0(envrmt$path_data_lidar_prc,"level1/returns/level1_rn.tif"))



###level 2 1.5 to 5 meters Strauchschicht
lidR::opt_output_files(mof_snip_norm)<-paste0(envrmt$path_data_lidar_prc,"level2/{ID}_level2LAS")
mof_level2 = lidR::catalog_apply(mof_snip_norm,levelFilt,1.5,5)
mof_level2 = uavRst::make_lidr_catalog(unlist(mof_level2),chunksize = 500, 
                                       chunkbuffer = 10, 
                                       proj4=proj4, cores = 6)
lidR:::catalog_laxindex(mof_level2)
lidR::opt_output_files(mof_level2)<-paste0(envrmt$path_data_lidar_prc,"level2/returns/{ID}_level2LAS")
level2 = lidR::grid_density(mof_level2, res = 2)
level2[values(level2)<0] = 0 
level2[is.na(level2)] = 0
writeRaster(level2, filename = paste0(envrmt$path_data_lidar_prc,"level2/returns/level2_rn.tif"))

###level 3 5 to 15 meters Stammschicht
lidR::opt_output_files(mof_snip_norm)<-paste0(envrmt$path_data_lidar_prc,"level3/{ID}_level3LAS")
mof_level3 = lidR::catalog_apply(mof_snip_norm,levelFilt,5,15)
mof_level3 = uavRst::make_lidr_catalog(unlist(mof_level3),chunksize = 500, 
                                       chunkbuffer = 10, 
                                       proj4=proj4, cores = 6)
lidR:::catalog_laxindex(mof_level3)
lidR::opt_output_files(mof_level3)<-paste0(envrmt$path_data_lidar_prc,"level3/returns/{ID}_level3LAS")
level3 = lidR::grid_density(mof_level3, res = 2)
level3[values(level3)<0] = 0 
level3[is.na(level3)] = 0
writeRaster(level3, filename = paste0(envrmt$path_data_lidar_prc,"level3/returns/level3_rn.tif"))


###level 4 15 to 60 meters Kronenschicht
lidR::opt_output_files(mof_snip_norm)<-paste0(envrmt$path_data_lidar_prc,"level4/{ID}_level4LAS")
mof_level4 = lidR::catalog_apply(mof_snip_norm,levelFilt,15,60)
mof_level4 = uavRst::make_lidr_catalog(unlist(mof_level4),chunksize = 500, 
                                       chunkbuffer = 10, 
                                       proj4=proj4, cores = 6)
lidR:::catalog_laxindex(mof_level4)
lidR::opt_output_files(mof_level4)<-paste0(envrmt$path_data_lidar_prc,"level4/returns/{ID}_level4LAS")
level4 = lidR::grid_density(mof_level4, res = 2)
level4[values(level4)<0] = 0 
level4[is.na(level4)] = 0
writeRaster(level4, filename = paste0(envrmt$path_data_lidar_prc,"level4/returns/level4_rn.tif"))




pcL1 = round((level1/returnsAL)*100,0)
pcL1[is.na(pcL1)] = 0
writeRaster(pcL1, filename =  paste0(envrmt$path_data_lidar_prc,"level1/returns/pcR_L1.tif"))
pcL1 = raster( paste0(envrmt$path_data_lidar_prc,"level1/returns/pcR_L1.tif"))
pcL2 = round((level2/returnsAL)*100,0)
pcL2[is.na(pcL1)] = 0
writeRaster(pcL2, filename =  paste0(envrmt$path_data_lidar_prc,"level2/returns/pcR_L2.tif"))
pcL2 = raster(paste0(envrmt$path_data_lidar_prc,"level2/returns/pcR_L2.tif"))
pcL3 = round((level3/returnsAL*100),0)
pcL3[is.na(pcL1)] = 0
writeRaster(pcL3, filename =  paste0(envrmt$path_data_lidar_prc,"level3/returns/pcR_L3.tif"))
pcL3 = raster(paste0(envrmt$path_data_lidar_prc,"level3/returns/pcR_L3.tif"))
pcL4 = round((level4/returnsAL)*100,0)
pcL4[is.na(pcL1)] = 0
writeRaster(pcL4, filename =  paste0(envrmt$path_data_lidar_prc,"level4/returns/pcR_L4.tif"), overwrite = T)


rm(level1,level2,level3,level4,
   mof_level1, mof_level2, mof_level3, mof_level4,
   pcL1,pcL2,pcL3,pcL4,
   returnsAL, mof_snip_norm)
gc()



st = stack(pcL1,pcL2,pcL3,pcL4)
library(vegan)
test = vegan::diversity(as.data.frame(values(st)))


r = st[[1]]
r[]= test
plot(r)

entropy(values(st),by = 4)
