# Setup envrionment
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")

# load needed files
mof <- brick(paste0(envrmt$path_data,"aerial/mosaic_mof.tif"))

# apply VI-function
indices <- rgbIndices(mof, rgbi=c("VVI","VARI","RI","CI","SI","HI","TGI","GLI","NGRDI","RGRI","MGRVI","ExG","CIVE"))

#remove aerial stack to save some RAM
rm(mof)


# write out indices in single files
for (i in 1:nlayers(indices)){
  tmp <- indices[[i]]
  writeRaster(tmp, filename = paste0(envrmt$path_data_aerial_VI,names(indices)[i],".tif"), overwrite=TRUE)
  print(names(indices)[i])
}

# remove index stack 
rm(indices)

# garbage collection
gc()

