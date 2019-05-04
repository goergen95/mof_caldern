source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

## read needed data
# shapefile of AOI
shp = readOGR(paste0(envrmt$path_data_data_mof,"uwcWaldorte_AOI.shp"))
#list lidar files
las_files = list.files(path = envrmt$path_data_lidar_org, pattern = ".las",
                       full.names = TRUE)

# Write index file for each LAS file to speed up processing
for(las in las_files){
  writelax(las)
}

# correct las files with uavRst functionality
base::dir.create(paste0(envrmt$path_data_lidar_org,"corrected/"))
uavRst::llas2llv0(las_files,paste0(envrmt$path_data_lidar_org,"corrected/"))


#create catalog of corrected las files
proj4 = c("+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0")
las_files = list.files(paste0(envrmt$path_data_lidar_org,"corrected/"), pattern = "las", full.names =T)
las_total = uavRst::make_lidr_catalog(path = las_files, 
                                     chunksize = 500, 
                                     chunkbuffer = 20, 
                                     proj4=proj4, cores = 6)

# Clip catalog to the area of interest
aoi_bb = sp::bbox(shp)
rm(shp)
lidR::opt_output_files(las_total)<-paste0(envrmt$path_data_lidar_org,"aoi_1/{ID}_aoi")
mof_snip = lidR::lasclipRectangle(las_total, xleft = aoi_bb[1], ybottom = aoi_bb[2], 
                                  xright = aoi_bb[3], ytop = aoi_bb[4])
# retile clipped las file
lidR::opt_output_files(mof_snip)<-paste0(envrmt$path_data_lidar_org,"aoi_2/{ID}_aoi")
lidR::opt_chunk_buffer(mof_snip) = 0
lidR::opt_chunk_size(mof_snip) = 500
lidR::catalog_retile(mof_snip)
# and create lax files for each LAS file to speed up future processing
las_files = list.files(path = paste0(envrmt$path_data_lidar_org,"aoi_2/"), pattern = ".las",
                                     full.names = TRUE)
for(las in las_files){
  writelax(las)
}


# reclassify ground returns
lidR::opt_chunk_buffer(mof_snip) = 20
lidR::opt_output_files(mof_snip)<-paste0(envrmt$path_data_lidar_prc,"ground/","{ID}_csf")
mof_snip_ground_csf <- lidR::lasground(mof_snip, csf())
rm(mof_snip)
# and create lax files for each LAS file to speed up future processing
las_files = list.files(path = paste0(envrmt$path_data_lidar_prc,"ground/"), pattern = ".las",
                       full.names = TRUE)
for(las in las_files){
  writelax(las)
}

# normalize height values
lidR::opt_output_files(mof_snip_ground_csf)<-paste0(envrmt$path_data_lidar_prc,"normalized/","{ID}_norm")
mof_snip_norm = lidR::lasnormalize(mof_snip_ground_csf,tin())
rm(mof_snip_ground_csf)
# and create lax files for each LAS file to speed up future processing
las_files = list.files(path = paste0(envrmt$path_data_lidar_prc,"normalized/"), pattern = ".las",
                       full.names = TRUE)
for(las in las_files){
  writelax(las)
}


# clean workspace
rm(mof_snip_norm, las_files, aoi_bb, las_total, shp, las)
gc()
