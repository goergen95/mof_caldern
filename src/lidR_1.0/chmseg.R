source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

chm <- raster(paste0(envrmt$path_data_lidar_prc,"chm.tif"))
#chm <- raster(paste0(envrmt$path_data_tmp,"test_chm.tif"))

#######################################################################################
########################create small subset for testing################################

kernel = matrix(1,3,3)
chm = raster::focal(chm, w = kernel, fun = mean)
#writeRaster(chm, filename= paste0(envrmt$path_data_tmp,"test_chm.tif"),overwrite=TRUE)

#######################################################################################
#chm = raster::focal(chm, w = kernel, fun = mean)



###Treepositions with Forest Tools

treeposFT <- ForestTools::vwf(chm, winFun = function(x){x * 0.07 + 0.73},
                              minHeight = 12, verbose = TRUE)
#treeposFT
#plot(treeposFT)
crownsFT <- uavRst::chmseg_FT(treeposFT,chm,minTreeAlt = 12,format= "polygons", verbose =TRUE)
writeOGR(crownsFT, dsn = paste0(envrmt$path_data_data_mof,"FT_crowns.shp"), layer = "FT_crowns")
#crownsFT
#plot(chm)
#plot(crownsFT, add =TRUE)


####################################################################################
###Treepositions with lidR

#las <- readRDS(paste0(envrmt$path_data,"lidar/las_mof_aoi.rds"))
#las <- readLAS(paste0(envrmt$path_data_tmp,"las_mof_aio.las"))
####################################################################################
## creating test area
#aio_bb = sp::bbox(chm)

#las <- lasclipRectangle(las, xleft = aio_bb[1], ybottom = aio_bb[2], 
#                 xright = aio_bb[3], ytop = aio_bb[4])
####################################################################################
#treeposlidRlas <- lidR::tree_detection(las,ws =4.8, hmin = 357)
#treeposlidRchm <- lidR::tree_detection(chm,ws =7, hmin = 12)
#which(values(treeposlidRchm>0))

#plot(las)
#with(treeposlidRlas, rgl::points3d(X, Y, Z, col = "red", size = 5, add = TRUE))

#dalpont <- lidR::lastrees_dalponte(las,chm,treeposlidRlas,th_tree=6,th_seed = 0.45,
 #                                  th_cr=0.55, max_cr = 100,extr=TRUE)
#plot(las, color = "treeID", colorPalette = pastel.colors(200))
#plot(dalpont)
#lidR::lastrees_li(las,dt1=1.5,dt2=2,Zu=15,hmin=3,R=10, field = "treeIDli1")
#lidR::lastrees_li2(las,dt1=1.5,dt2=2,Zu=15,hmin=6,R=2,speed_up = 30, field = "treeIDli2")
#plot(las, color = "treeIDli1", colorPalette = pastel.colors(200))

#silva <- lidR::lastrees_silva(las,chm,treeposlidRlas,max_cr_factor = 0.6,exclusion=0.3,extra=TRUE, field = "treeIDsilva")
#plot(las, color = "treeIDsilva", colorPalette = pastel.colors(200))


#devtools::install_github("aoles/EBImage", ref = "master")
#library(EBImage)
#water <- lidR::lastrees_watershed(las,chm,th_three=2,tol=1,ext=1,extra = TRUE,field="treeIDwater")



####################################################################################

###Segmentation with ITC
#segITC <- itcSegment::itcIMG(chm, searchWinSize = 7, TRESHSeed = 0.45, TRESHCrown = 0.55, DIST = 10, th = 0, ischm = TRUE, epsg = 25832)
#plot(segITC,axes=TRUE)

#segITClas <- itcSegment::itcLiDAR(X=las@data$X,Y=las@data$Y,Z=las@data$Z,epsg = 25832,
#                      resolution = 0.5, MinSearchFilSize = 5, MaxSearchFilSize = 9,
#                      TRESHSeed = 0.45, TRESHCrown = 0.5, minDIST = 3,maxDIST= 150,
#                      HeightThreshold = 12, cw=10)
#segITClas
#plot(chm)
#plot(segITClas,add=TRUE)

segITC <- uavRst::chmseg_ITC(chm, EPSG = 25832, minTreeAlt = 12, maxCrownArea = 150, movingWin = 7,  TRESHSeed = 0.45, TRESHCrown = 0.5)
#segITC
#plot(chm)
#plot(segITC,add=TRUE)
