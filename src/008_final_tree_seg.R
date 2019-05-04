source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/validierung.R")

################# True CHM with tiling ############################################
chm <- raster(paste0(envrmt$path_data_lidar_prc,"chm.tif"))
tiles<- TileManager::TileScheme(chm, dimByCell = c(1200, 1200), buffer = 50, bufferspill = FALSE)


################ Test CHM to retrive optimal settings #############################
chm <- raster(paste0(envrmt$path_data_lidar_prc,"testalle.tif"))
shp <- rgdal::readOGR(paste0(envrmt$path_data_data_mof,"Val_Tree_pos_Group.shp"))
#######################################################################################
######################## Mean Filter for CHM ################################

kernel = matrix(1,3,3)
chm = raster::focal(chm, w = kernel, fun = mean)
#writeRaster(chm, filename= paste0(envrmt$path_data_tmp,"mean_chm.tif"),overwrite=TRUE)

#######################################################################################
################################## Testing Parameteres with Small CHM ##############

### Forest Tools

### 130 trees with {x* 0.07 + 0.5} for 12m min heigh and 
### 132 with {x * 0.08 + 0.25} for 8m min height
#treeposFT <- ForestTools::vwf(chm, winFun = function(x){x * 0.07+ 0.3},
#                              minHeight = 12, verbose = TRUE)
treeposFT <- ForestTools::vwf(chm, winFun = function(x){x * 0.08+ 0.2},
                              minHeight = 8, verbose = TRUE)
#crownsFT <- ForestTools::mcws(treeposFT,chm,minHeight = 8, format ="polygons", verbose =TRUE)
#segValues(crownsFT,shp)



#treeposFT
#plot(treeposFT)

splitseg <- lapply(seq(15,16), function (i){
  tmp <- crop(chm,tiles$buffPolygons[i,])
  crowns <- ForestTools::mcws(treeposFT,tmp,minHeight = 8,format= "polygons", verbose =TRUE)
  crs(crowns) <- crs(chm)
  ids <- na.omit(over(treeposFT,crowns))
  ids$rownames <- as.numeric(row.names(ids))
  crowns@data$treeID <- ids$rownames
  crowns <- crop(crowns,tiles$tilePolygons[i,])
  print(paste0("Done with tile ",i," out of ",length(tiles$buffPolygons)))
  return(crowns)})

#ids <- na.omit(over(treeposFT,splitseg[[1]]))
#ids$rownames <- as.numeric(row.names(ids))
#splitseg[[1]]@data$treeID <- ids$rownames

#ids <- na.omit(over(treeposFT,splitseg[[2]]))
#ids$rownames <- as.numeric(row.names(ids))
#splitseg[[2]]@data$treeID <- ids$rownames


#splitseg <- lapply(seq(2), function(i){
#  tmp <- crop(splitseg[[i]],tiles$tilePolygons[i,])
#return(tmp)
#})
  
shp <- rbind(splitseg[[1]],splitseg[[2]]),splitseg[[3]],splitseg[[4]],
             splitseg[[5]],splitseg[[6]],splitseg[[7]],splitseg[[8]],
             splitseg[[9]],splitseg[[10]],splitseg[[11]],splitseg[[12]],
             splitseg[[13]],splitseg[[14]],splitseg[[15]],splitseg[[16]])

shp <- aggregate(shp,by = c("treeID","height","crownArea","winRadius"))
writeOGR(shp, dsn = paste0(envrmt$path_data_data_mof,"FTseg8m_15_16.shp"), driver = "ESRI Shapefile", layer ="FTseg8m_8_14", overwrite_layer = TRUE)


shp <- readOGR( dsn = paste0(envrmt$path_data_data_mof,"FTseg8m_1_7.shp"))
shp2 <- readOGR( dsn = paste0(envrmt$path_data_data_mof,"FTseg8m_8_14.shp"))
shp3 <- readOGR( dsn = paste0(envrmt$path_data_data_mof,"FTseg8m_15_16.shp"))
shp <- rbind(shp,shp2,shp3)
shp <- aggregate(shp,by = c("treeID","height","crownArea","winRadius"))
writeOGR(shp,  dsn = paste0(envrmt$path_data_data_mof,"FTseg8.shp"),layer ="FTseg8", overwrite_layer = TRUE, driver = "ESRI Shapefile")
shp <- shp[-which(shp$crownArea<5),]
writeOGR(shp,  dsn = paste0(envrmt$path_data_data_mof,"FTseg8_5m.shp"),layer = "FTseg8_5m", overwrite_layer = TRUE, driver = "ESRI Shapefile")
summary(shp@data)

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
segITC <- itcSegment::itcIMG(chm, epsg = 25832, TRESHSeed = 0.4,TRESHCrown = 0.9, DIST=25,
                             th=8, ischm = TRUE)
segValues(segITC,shp)


