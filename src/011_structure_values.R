source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_fun.R")

# read in necessary data for forest structure analysis
#crowns = readOGR("segmentation_complete.shp")
crowns = readOGR(paste0(envrmt$path_data_data_mof,"segmentation_complete.shp"))
# filter to small and to big trees
crowns = crowns[crowns$crownArea>=10,]
crowns = crowns[crowns$crownArea<=350,]
crowns$id = 1:length(crowns)


species = raster("predicted_species.tif")
species = raster(paste0(envrmt$path_data_data_mof,"predicted_species.tif"))


countReturns = raster(paste0(envrmt$path_data_lidar_prc,"returns_allLevels.tif"))
groundReturns =  raster(paste0(envrmt$path_data_lidar_prc,"level1/returns/level1_rn.tif"))

# faster extraction of species values through rasterization
#ext = extent(species)
#crowns_ras = gdalUtils::gdal_rasterize(src_datasource = paste0(envrmt$path_data_data_mof,"segmentation_complete.shp"),
#                                       dst_filename = paste0(envrmt$path_data_data_mof,"seg_rasterized.tif"), 
#                                       a = "id", 
#                                       tr = c(xres(species),yres(species)),
#                                       te = c(ext[1],ext[3],ext[2],ext[4]),
#                                       l = "segmentation_complete",
#                                       output_Raster = TRUE)
crowns_ras = raster(paste0(envrmt$path_data_data_mof,"seg_rasterized.tif"))

segId = values(crowns_ras)
index0 = which(segId == 0)
Specvalues = values(species)[-index0]
segId = segId[-index0]
id = unique(segId)
extractData = data.frame(ID = segId, species=Specvalues)




# test with smaller subset
#test = raster("chm3.tif")
#crowns = crop(crowns, test)
#species = crop(species, test)
#countReturns = crop(countReturns,test)
#groundReturns = crop(groundReturns, test)


# find maximum species ID within each segment
#extractData = extract(species,crowns,df = TRUE)
#saveRDS(extractData, file = "extract_species_data.rds")
#extractData = na.omit(extractData)

specInfo = table(extractData)
specInfo = data.frame(ID = rownames(specInfo),
                  sp1 = specInfo[,1],
                  sp2 = specInfo[,2],
                  sp3 = specInfo[,3],
                  sp4 = specInfo[,4])
specInfo$N = rowSums(specInfo[,2:5])

maxS_prc = lapply(seq(nrow(specInfo)), function(i){
  return(specInfo[i,which(specInfo[i,2:5]==max(specInfo[i,2:5]))+1]/specInfo$N[i]*100)
  })

len = unlist(lapply(maxS_prc, length))
maxS_prc[len!=1] =  NA
maxS_prc = do.call("rbind",maxS_prc)
specInfo$maxS_prc = maxS_prc[,1]

specID = 1:4
maxSpecies = lapply(seq(nrow(specInfo)), function(i){
  return(specID[which(specInfo[i,2:5]==max(specInfo[i,2:5]))])
})

len = unlist(lapply(maxSpecies, length))
maxSpecies[len!=1] =  NA
maxSpecies = do.call("rbind",maxSpecies)
specInfo$species = maxSpecies[,1]



# asign species ID to crowns
crowns = sp::merge(crowns,specInfo,by.x = "treeID",by.y = "ID", all.x = T)

#writeOGR(crowns,dsn = "test2.shp",
#         layer = "test",
#         driver = "ESRI Shapefile")

# extract centroids of crowns
centroids = rgeos::gCentroid(crowns, byid = TRUE)
# add species Info
species = crowns$species
centroids = SpatialPointsDataFrame(centroids, data = data.frame(id=id,species=species))


# vertical density computation
dens = (countReturns - groundReturns) / countReturns
dens = resample(dens,species)
densvalues = values(dens)[-index0]
densvalues = data.frame(densvalues=densvalues, id = segId)

#densVals = lapply(id, function(id){
#  print(id)
#  return(densvalues$densvalues[densvalues$id==id])
#})
index = match(densvalues$id,id)
densVals = lapply(seq(length(id)), function(i){
  print(i)
  tmp = mean(densvalues$densvalues[index==id[i]], na.rm = TRUE)
  return(tmp)
})

densVals = do.call("rbind", densVals)
densVals = readRDS(paste0(envrmt$path_data_lidar_prc,"densVals_bind.rds"))
crowns$density = as.vector(densVals)


# tree density in 1 ha buffer zone for individual trees (from centroids)
# from a point a radial buffer of one hectar will have a radius of 56.41896 meters

hectar_buffer = rgeos::gBuffer(crowns, width = 56.41896, byid = T)
hectar_trees = rgeos::gContains(spgeom1 = hectar_buffer, spgeom2 = crowns, byid = TRUE, returnDense = FALSE)
nTrees_hectar = unlist(lapply(hectar_trees, length))
crowns$nTreeAcre = nTrees_hectar


# crown coverage per 1 hectar centered on individual trees
hectar_crowns = rgeos::gContains(spgeom1 = hectar_buffer, spgeom2 = crowns, byid = TRUE, returnDense = FALSE)
crownArea_hectar = unlist(lapply(hectar_crowns,function(index){
  area = sum(crowns$crownArea[index])
  return(area)
}))


crowns$crownAreaPrc = (crownArea_hectar/10000)*100


# calculate average crown area in one hectar per stem
crowns$avgAFSPerStem = (10000-crownArea_hectar) / crowns$nTreeAcre

# calculate direct neighbourhood counts 
neigh_buff = rgeos::gBuffer(crowns, width = .1, byid = TRUE)
neigh_count = rgeos::gIntersects(neigh_buff, crowns, byid = TRUE, returnDense = FALSE)
neigh_count = unlist(lapply(neigh_count,length))
crowns$NdirNeigh = neigh_count
 
# calculate direct neighbourhood entropy based on ntrees in buffer zones

buffer_10 = rgeos::gBuffer(centroids, width = 10, byid = TRUE)
buffer_20 = rgeos::gBuffer(centroids, width = 20, byid = TRUE)
buffer_30 = rgeos::gBuffer(centroids, width = 30, byid = TRUE)
buffer_50 = rgeos::gBuffer(centroids, width = 50, byid = TRUE)

buffer_10N =
  rgeos::gContains(spgeom1 = buffer_10,spgeom2 = centroids,byid = TRUE,returnDense = FALSE) %>% 
  lapply(.,length) %>% unlist(.)
buffer_20N =
  rgeos::gContains(spgeom1 = buffer_20,spgeom2 = centroids,byid = TRUE,returnDense = FALSE) %>% 
  lapply(.,length) %>% unlist(.)
buffer_30N =
  rgeos::gContains(spgeom1 = buffer_30,spgeom2 = centroids,byid = TRUE,returnDense = FALSE) %>% 
  lapply(.,length) %>% unlist(.)
buffer_50N =
  rgeos::gContains(spgeom1 = buffer_50,spgeom2 = centroids,byid = TRUE,returnDense = FALSE) %>% 
  lapply(.,length) %>% unlist(.)


df = data.frame(buffer10=buffer_10N,buffer20=buffer_20N,buffer30=buffer_30N,buffer50=buffer_50N)
df$entropy = vegan::diversity(df)
crowns$Nentropy= df$entropy

# calculate biodiversity shannon index for tree environment
# get list with same elements as trees and vector of species IDs within buffered zone
buffer10B = rgeos::gContains(spgeom1 = buffer_10, spgeom2 = centroids, byid  = TRUE, returnDense = FALSE) %>%
  lapply(., function(i){
    return(centroids$species[i])
  })

buffer30B = rgeos::gContains(spgeom1 = buffer_30, spgeom2 = centroids, byid  = TRUE, returnDense = FALSE) %>%
  lapply(., function(i){
    return(centroids$species[i])
  })

bufferacreB = rgeos::gContains(spgeom1 = hectar_buffer, spgeom2 = centroids, byid  = TRUE, returnDense = FALSE) %>%
  lapply(., function(i){
    return(centroids$species[i])
  })


calcShannon1 = function(i){
  char = as.vector(unlist(attributes(buffer10B[i])))
  tmp = as.numeric(unlist(buffer10B[i][char]))
  if(sjmisc::is_empty(tmp)){
    return(0)
  }else{
    tmp = as.vector(na.omit(tmp))
    N = length(tmp)
    t = as.data.frame(table(tmp))
    tmp = t[,2]/N
    tmp = vegan::diversity(tmp, index = "shannon")
    print(i)
    return(tmp)}
}
calcShannon3 = function(i){
  char = as.vector(unlist(attributes(buffer30B[i])))
  tmp = as.numeric(unlist(buffer30B[i][char]))
  if(sjmisc::is_empty(tmp)){
    return(0)
  }else{
    tmp = as.vector(na.omit(tmp))
    N = length(tmp)
    t = as.data.frame(table(tmp))
    tmp = t[,2]/N
    tmp = vegan::diversity(tmp, index = "shannon")
    print(i)
    return(tmp)}
}
calcShannonA = function(i){
  char = as.vector(unlist(attributes(bufferacreB[i])))
  tmp = as.numeric(unlist(bufferacreB[i][char]))
  if(sjmisc::is_empty(tmp)){
    return(0)
  }else{
    tmp = as.vector(na.omit(tmp))
    N = length(tmp)
    t = as.data.frame(table(tmp))
    tmp = t[,2]/N
    tmp = vegan::diversity(tmp, index = "shannon")
    print(i)
    return(tmp)}
}


diversity10 = lapply(seq(length(buffer10B)),calcShannon1)
diversity30 = lapply(seq(length(buffer30B)),calcShannon3)
diversityA = lapply(seq(length(bufferacreB)),calcShannonA)
diversity10 = unlist(diversity10)
diversity30 = unlist(diversity30)
diversityA = unlist(diversityA)


crowns$div10 = diversity10
crowns$div30 = diversity30
crowns$divA = diversityA

saveRDS(names(crowns), file = paste0(envrmt$path_data_data_mof,"names_strcdata.rds"))
crowns$species = as.character(crowns$species)
crowns$species[crowns$species=="1"] = "Beech"
crowns$species[crowns$species=="2"] = "Dgl. Spruce"
crowns$species[crowns$species=="3"] = "Oak"
crowns$species[crowns$species=="4"] = "Spruce"
crowns$species = as.factor(crowns$species)

writeOGR(crowns, dsn = paste0(envrmt$path_data_data_mof,"mof_strcdata.shp"),layer = "mof_strcdata", driver = "ESRI Shapefile", overwrite_layer = T)


#  1: BUCHE 2: DGL, 3: Eiche, 4: Fichte
