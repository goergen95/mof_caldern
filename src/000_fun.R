##### script wich includes pre-defined function for the workflow

#check for equal projections of tif and shape
checkProj <- function (x,y) {
  projs <- c()
  for (i in 1:length(x)){
    r <- raster(x[i])
    projs[i] <- proj4string(r)
  }
  if (length(unique(projs))==1){
    cat("All projectons of the rasters are equal!")
  }else{
    cat("Projections do not match. Please reproject the data.")
  }
  if (compareCRS(shp,raster(listImages[[1]]))){
    cat("The shapefile has the same projection like the tif files.")
  }else{
    shp <- spTransform(y,CRSobj = crs(raster(listImages[[1]])))
    return(shp)
    
  }
}

##Function to check if rasters have the same Extent
#For cases raster overlapp, functions applies the following function:
# rnew = r1 + r2 - 255

checkExt <- function(x, path = NULL) {
  rls <- lapply(x,brick)##brick all rasters in a list
  ext <- data.frame()##initiate empty dataframe
  for (i in 1:length(rls)){
    ext[1,i]<- i
    for (j in 1:length(rls)-1)#loop iterates trough bricks, and delivers 1 if extent overlap and 0 if not
      ext[j+1,i] <- compareRaster(rls[[i]],rls[[j+1]],extent=TRUE,rowcol = FALSE,crs=FALSE,rotation = FALSE, stopiffalse =  FALSE)
  }
  
  for(i in 1:length(ext)){
    if (sum(ext[,i])!=1) {#checks if equal extent rasters are present in current iteration
      
      index <- which(ext[,i]==1) #if so, get index for which rasters overlap
      ls <- list.files(path, pattern =".tif")#create a list with the present rasters
      if (0<sum(which(ls==paste0("merge_",stringr::str_sub(x[index[1]],-18,-1))))) {#check if raster with the same name exists
        cat(paste0("Position A: Next Iteration ",i," Reason: Tif already exists."))#if so skip to next iteration
        next
      }else{
        cat(paste0("Now actually merging. Iteration ",i))
        rmerge <- (rls[[index[1]]]+rls[[index[2]]])-255 #if it doesnt exist, start merging
        #rmerge <- mosaic(rls[[index[1]]],rls[[index[2]]],fun="min")
        writeRaster(rmerge, filename = paste0(path,"merge_",stringr::str_sub(listImages[index[1]],-18,-1)), overwrite = TRUE)
      }
      
    }else{
      cat(paste0("Position B: Next Iteration ",i," Reason: Extent is non-equal!"))
      next}
  }
}






# function to filter PCs
focalOP <- function(viStack, filters = c("mean5","mean15","mean21","sobel5","sobel15","sobel21","gauss5","gauss15","gauss21","LoG5","LoG15","LoG21"),path = NULL){
  
  for (i in 1:nlayers(viStack)){
    
    filtered <- lapply(filters, function(item) {
      
      if (item == "mean5"){
        
        cat("\napplying 5x5 mean filter")
        
        raster::focal(viStack[[i]], matrix(1/25,nrow=5,ncol=5), fun = sum, 
                      filename = paste0(path,names(viStack)[i],"_mean5.tif"))
        
        
      }else if (item == "mean15"){
        
        cat("\napplying 15x15 mean filter")
        
        raster::focal(viStack[[i]], matrix(1/225),nrow=15,ncol=15, fun = sum, 
                      filename = paste0(path,names(viStack)[i],"_mean15.tif"))
        
      }else if (item == "mean21"){
        
        cat("\napplying 21x21 mean filter")
        
        raster::focal(viStack[[i]], matrix(1/441),nrow=21,ncol=21, fun = sum, 
                      filename = paste0(path,names(viStack)[i],"_mean21.tif"))
        
      } else if (item=="sobel5"){
        #sobel 5 pix 2,5m
        cat("\napplying sobel5 filter")
        sobel5 <- sqrt(raster::focal(viStack[[i]], matrix(c(2,1,0,-1,-2,2,1,0,-2,-1,4,2,0,-2,-4,2,1,0,-1,-2,2,1,0,-1,-2),nrow=5), fun = sum)**2+
                         raster::focal(viStack[[i]], matrix(c(-2,-2,-4,-2,-2,-1,-1,-2,-1,-1,0,0,0,0,0,1,1,2,1,1,2,2,4,2,2),nrow=5), fun = sum)**2)
        writeRaster(sobel5, filename = paste0(path,names(viStack)[i],"_sobel5.tif"))
        rm(sobel5)
      }
      
      else if (item=="sobel15"){
        
        #sobel 15 pix 7,5m
        
        cat("\napplying sobel15 filter")
        
        sobel15 <- sqrt(raster::focal(viStack[[i]], matrix(c(rep(-64, 7), -128, rep(-64, 7), rep(-32, 7), -64, rep(-32, 7), rep(-16, 7), -32, rep(-16, 7), rep(-8, 7), -16, rep(-8, 7), rep(-4, 7), -8, rep(-4, 7), rep(-2, 7), -4, rep(-2, 7), rep(-1, 7), -2, rep(-1, 7),rep(0, 15),rep(1, 7), 2, rep(1, 7), rep(2, 7), 4, rep(2, 7), rep(4, 7), 8, rep(4, 7), rep(8, 7), 16, rep(8, 7), rep(16, 7), 32, rep(16, 7), rep(32, 7), 64, rep(32, 7), rep(64, 7), 128, rep(64, 7)), nrow = 15), fun = sum)**2 
                        +raster::focal(viStack[[i]], t(matrix(c(rep(-64, 7), -128, rep(-64, 7), rep(-32, 7), -64, rep(-32, 7), rep(-16, 7), -32, rep(-16, 7), rep(-8, 7), -16, rep(-8, 7), rep(-4, 7), -8, rep(-4, 7), rep(-2, 7), -4, rep(-2, 7), rep(-1, 7), -2, rep(-1, 7),rep(0, 15),rep(1, 7), 2, rep(1, 7), rep(2, 7), 4, rep(2, 7), rep(4, 7), 8, rep(4, 7), rep(8, 7), 16, rep(8, 7), rep(16, 7), 32, rep(16, 7), rep(32, 7), 64, rep(32, 7), rep(64, 7), 128, rep(64, 7)), nrow = 15)), fun = sum)**2)
        writeRaster(sobel15, filename = paste0(path,names(viStack)[i],"_sobel15.tif"))
        rm(sobel15)}
      
      else if (item=="sobel21"){
        
        #sobel 21 pix 10,5m
        
        cat("\napplying sobe21 filter")
        
        sobel21 <- sqrt(raster::focal(viStack[[i]], matrix(c(rep(-512, 10), -1024, rep(-512, 10), rep(-256, 10), -512, rep(-256, 10), rep(-128, 10), -256, rep(-128, 10), rep(-64, 10), -128, rep(-64, 10), rep(-32, 10), -64, rep(-32, 10), rep(-16, 10), -32, rep(-16, 10), rep(-8, 10), -16, rep(-8, 10), rep(-4, 10), -8, rep(-4, 10), rep(-2, 10), -4, rep(-2, 10), rep(-1, 10), -2, rep(-1, 10),rep(0, 21),rep(1, 10), 2, rep(1, 10), rep(2, 10), 4, rep(2, 10), rep(4, 10), 8, rep(4, 10), rep(8, 10), 16, rep(8, 10), rep(16, 10), 32, rep(16, 10), rep(32, 10), 64, rep(32, 10), rep(64, 10), 128, rep(64, 10), rep(128, 10), 256, rep(128, 10), rep(256, 10), 512, rep(256, 10), rep(512, 10), 1024, rep(512, 10)), nrow = 21), fun = sum)**2 
                        +raster::focal(viStack[[i]], t(matrix(c(rep(-512, 10), -1024, rep(-512, 10), rep(-256, 10), -512, rep(-256, 10), rep(-128, 10), -256, rep(-128, 10), rep(-64, 10), -128, rep(-64, 10), rep(-32, 10), -64, rep(-32, 10), rep(-16, 10), -32, rep(-16, 10), rep(-8, 10), -16, rep(-8, 10), rep(-4, 10), -8, rep(-4, 10), rep(-2, 10), -4, rep(-2, 10), rep(-1, 10), -2, rep(-1, 10),rep(0, 21),rep(1, 10), 2, rep(1, 10), rep(2, 10), 4, rep(2, 10), rep(4, 10), 8, rep(4, 10), rep(8, 10), 16, rep(8, 10), rep(16, 10), 32, rep(16, 10), rep(32, 10), 64, rep(32, 10), rep(64, 10), 128, rep(64, 10), rep(128, 10), 256, rep(128, 10), rep(256, 10), 512, rep(256, 10), rep(512, 10), 1024, rep(512, 10)), nrow = 21)), fun = sum)**2)
        writeRaster(sobel21, filename = paste0(path,names(viStack)[i],"_sobel21.tif"))
        rm(sobel21) }
      
      else if (item=="gauss5"){
        #gauss 5 pix 2,5m
        cat("\napplying gauss5 filter")
        raster::focal(viStack[[i]],  matrix(c(1,1,2,1,1,1,2,4,2,1,2,4,8,4,2,1,2,4,2,1,1,1,2,1,1),nrow=5), fun = sum,filename = paste0(path,names(viStack)[i],"_gauss5.tif"))
      }
      
      else if (item=="gauss15"){
        #gauss 15 pix 7,5m
        cat("\napplying gauss15 filter")
        raster::focal(viStack[[i]], w=smoothie::kernel2dmeitsjer(type = "gauss",nx=15,ny=15,sigma=1),fun = sum, filename = paste0(path,names(viStack)[i],"_gauss15.tif"))
      }
      
      else if (item=="gauss21"){
        #gauss 21 pix 10,5m
        cat("\napplying gauss21 filter")
        raster::focal(viStack[[i]], w=smoothie::kernel2dmeitsjer(type = "gauss",nx=21,ny=21,sigma=1),fun = sum, filename = paste0(path,names(viStack)[i],"_gauss21.tif"))
      }
      
      else if (item=="LoG5"){
        #laplacian of gaussian 5 pix 2,5m
        cat("\napplying LoG5 filter")
        raster::focal(viStack[[i]], w=smoothie::kernel2dmeitsjer(type = "LoG", nx=5,ny=5,sigma=1),fun = sum, filename = paste0(path,names(viStack)[i],"_LoG5.tif"))
      }
      
      else if (item=="LoG15"){
        #laplacian of gaussian 15 pix 7,5m
        cat("\napplying LoG15 filter")
        raster::focal(viStack[[i]], w=smoothie::kernel2dmeitsjer(type = "LoG", nx=15,ny=15,sigma=1),fun = sum, filename = paste0(path,names(viStack)[i],"_LoG15.tif"))
      }
      
      else if (item=="LoG21"){
        #laplacian of gaussian 21 pix 10,5m
        cat("\napplying LoG21 filter")
        raster::focal(viStack[[i]], w=smoothie::kernel2dmeitsjer(type = "LoG", nx=21,ny=21,sigma=1),fun = sum, filename = paste0(path,names(viStack)[i],"_LoG21.tif"))
      }
    })
    cat(paste0("\nDone with layer ",i," out of ",nlayers(viStack),"."))
  }
}

# function to create vegetation indices from rgb image
#main body of the function was adopted by F.Detsch in envrionmentalinformatics-marburg/satelliteTools/rgbIndices.R
rgbIndices<- function(rgb,
                      
                      rgbi=c("VVI","VARI","CI","BI","SI","HI","TGI","GLI","NGRDI","RGRI","MGRVI","ExG","CIVE")) {
  
  
  
  ## compatibility check
  
  if (raster::nlayers(rgb) < 3)
    
    stop("Argument 'rgb' needs to be a Raster* object with at least 3 layers (usually red, green and blue).")
  
  
  
  ### processing
  
  
  
  
  
  ## separate visible bands
  
  red <- rgb[[1]]
  
  green <- rgb[[2]]
  
  blue <- rgb[[3]]
  
  
  
  indices <- lapply(rgbi, function(item){
    
    ## calculate Visible Vegetation Index vvi
    
    if (item=="VVI"){
      
      cat("\ncalculate Visible Vegetation Index (VVI)")
      
      VVI <- (1 - abs((red - 30) / (red + 30))) * 
        
        (1 - abs((green - 50) / (green + 50))) * 
        
        (1 - abs((blue - 1) / (blue + 1)))
      
      names(VVI) <- "VVI"
      
      return(VVI)
      
      
      
    } else if (item=="VARI"){
      
      # calculate Visible Atmospherically Resistant Index (VARI)
      
      cat("\ncalculate Visible Atmospherically Resistant Index (VARI)")
      
      VARI<-(green-red)/(green+red-blue)
      
      names(VARI) <- "VARI"
      
      return(VARI)
      
      
      
      #} else if (item=="RI"){
      
      # redness index
      
      # cat("\ncalculate redness index (RI)")
      
      #  RI<-red**2/(blue*green**3)
      
      #  names(RI) <- "RI"
      
      #  return(RI)
      
      
      
    } else if (item=="CI"){
      
      # CI Soil Colour Index
      
      cat("\ncalculate Soil Colour Index (CI)")
      
      CI<-(red-green)/(red+green)
      
      names(CI) <- "CI"
      
      return(CI)
      
      
      
    } else if (item=="BI"){
      
      #  Brightness Index
      
      cat("\ncalculate Brightness Index (BI)")
      
      BI<-sqrt((red**2+green**2+blue*2)/3)
      
      names(BI) <- "BI"
      
      return(BI)
      
      
      
    } else if (item=="SI"){
      
      # SI Spectra Slope Saturation Index
      
      cat("\ncalculate Spectra Slope Saturation Index (SI)")
      
      SI<-(red-blue)/(red+blue) 
      
      names(SI) <- "SI"
      
      return(SI)
      
      
      
    } else if (item=="HI"){    
      
      # HI Primary colours Hue Index
      
      cat("\ncalculate Primary colours Hue Index (HI)")
      
      HI<-(2*red-green-blue)/(green-blue)
      
      names(HI) <- "HI"
      
      return(HI)
      
      
      
    } else if (item=="TGI"){
      
      # Triangular greenness index
      
      cat("\ncalculate Triangular greenness index (TGI)")
      
      TGI <- -0.5*(190*(red - green)- 120*(red - blue))
      
      names(TGI) <- "TGI"
      
      return(TGI)
      
      
      
    } else if (item=="GLI"){
      
      cat("\ncalculate green leaf index (GLI)")
      
      # green leaf index
      
      GLI<-(2*green-red-blue)/(2*green+red+blue)
      
      names(GLI) <- "GLI"
      
      return(GLI)
      
      
      
    } else if (item=="NGRDI"){
      
      # NGRDI Normalized green red difference index 
      
      cat("\ncalculate Normalized green red difference index  (NGRDI)")
      
      NGRDI<-(green-red)/(green+red) 
      
      names(NGRDI) <- "NGRDI"
      
      return(NGRDI)
      
      
      
    } else if (item=="RGRI"){
      
      # Red-green Ration Index (RGRI): R/G 
      
      cat("\ncalculate red green ratio index  (RGRI)")
      
      RGRI<-(red/green) 
      
      names(RGRI) <- "RGRI"
      
      return(RGRI)
      
      
    } else if (item=="MGRVI"){
      
      #Modified green Red Vegetation Index (MGRVI): (G^2-R^2)/(G^2+R^2)
      
      cat("\ncalculate modified green Red Vegetation Index (MGRVI)")
      
      MGRVI<-(green**2-red**2)/(green**2+red**2) 
      
      names(MGRVI) <- "MGRVI"
      
      return(MGRVI)
      
      
    } else if (item=="ExG"){
      
      #Excess green Index (ExG): 2*G-R-B
      
      cat("\ncalculate Excess green Index (ExG)")
      
      ExG<-(2*green-red-blue) 
      
      names(ExG) <- "ExG"
      
      return(ExG)
      
      
    } else if (item=="CIVE"){
      
      # Color Index of Vegetation (CIVE): 0.441*R - 0.881*G + 0.385*B + 18.787
      
      cat("\ncalculate Color Index of Vegetation (CIVE)")
      
      CIVE<-(0.441*red-0.881*green+0.385*blue+18.787)
      
      names(CIVE) <- "CIVE"
      
      return(CIVE)
      
    }
    
  })
  
  return(raster::stack(indices))
  
}


# validation of segmentation algorithm
segValues <- function(model, pts){
  proj4string(model) <- crs(pts)
  df <- sp::over(SpatialPoints(pts),SpatialPolygons(model@polygons), returnList = TRUE) 
  df <- data.frame(unlist(df)) 
  df$pts <- rownames(df) 
  names(df) <- c("polygons", "pts") 
  ###################################################################################
  over <- length(model) - length(unique(df$polygons))   #übersegmentierung (segmente ohne punkt)
  hit <- length(unique(df$polygons)) - sum(duplicated(df$polygons)) #treffer (segment mit einem 1)
  under <-  sum(duplicated(df$polygons)) #untersegmentierung (segmente mit mehr als einem punkt)
  ntree = over + hit + under
  summary = data.frame(ntree = ntree, overratio = over/length(model), hitratio = hit/length(model), underratio = under/length(model))
  return(summary)
  
  print(paste0("Ntree is ",over + hit + under,".")) 
  print(paste0("Oversegmentation ratio is ",over/length(model)*100,"%."))
  print(paste0("Hit ratio is ",hit/length(model)*100,"%."))  
  print(paste0("Under segmentation ratio is ",under/length(model)*100,"%.")) } 


