####Principal Component Analysis for the Spectral Data
# setup envrionment
source("~/edu/mpg-envinsys-plygrnd/mpg-envinfosys-teams-2018-rs_18_axmideda/src/000_env_setup.R")


# read in needed files
# original rgb image
rgb <- stack(paste0(envrmt$path_data,"/aerial/mosaic_mof.tif"))
names(rgb) <- c("red","green","blue")
# read VIs, if BI was calculated make sure to exclude because of dozens of NAs...
indices <- stack(list.files(path=envrmt$path_data_aerial_VI, pattern = ".tif", full.names=TRUE))
#create one common stack
names <- names(indices)
spectral <- stack(indices,rgb)
rm(rgb)
rm(indices)

#chm <- raster(paste0(envrmt$path_data_lidar_prc,"chm.tif"))
#indices <- resample(indices,chm)

######################################################################################
################################Subset of dataset for evaluation porpuse #####################################
#shp <- readOGR(paste0(envrmt$path_data_data_mof,"subset.shp"))
#shp <- spTransform(shp, CRSobj = crs(indices))
#indices <- crop(indices,shp)
###mean filter to remove NAs
#kernel = matrix(1,3,3)
#for(i in 1:nlayers(indices)){
#indices[[i]] = raster::focal(indices[[i]], w = kernel, fun = mean)
#}
#names(indices) <- names
######################################################################################


##Prepare data for PCA
spectral_norm <- RStoolbox::normImage(spectral)
writeRaster(spectral_norm, filename = paste0(envrmt$path_data_aerial_pca,"spectral_norm.tif"))

# create PCA with RStoolbox
pca <- RStoolbox::rasterPCA(spectral_norm,maskCheck = TRUE, spca = TRUE, nComp = 4)
writeRaster(pca$map, filename = paste0(envrmt$path_data_aerial_pca,"std_pca_pc1-pc4.tif"))
#saveRDS(pca,file = paste0(envrmt$path_data_aerial_pca,"pca.rds"))
pca <- readRDS(paste0(envrmt$path_data_aerial_pca,"pca.rds"))


#####Visualising Eigenvalues according to kassambra available at:
#####http://www.sthda.com/english/articles/31-principal-component-methods-in-r-practical-guide/112-pca-principal-component-analysis-essentials/

eigvalue.pca <- factoextra::get_eigenvalue(pca$model)


factoextra::fviz_eig(pca$model, addlabels = TRUE,ylim=c(0,50))

########################Graph of results for variables##############################

var.pca <- factoextra::get_pca_var(pca$model)
var.pca
###correlation circle
factoextra::fviz_pca_var(pca$model, col.var = "black")
#Positively correlated variables are grouped together.
#Negatively correlated variables are positioned on opposite sides of the plot origin (opposed quadrants). 
#The distance between variables and the origin measures the quality of the variables
#on the factor map. Variables that are away from the origin are well represented 
#on the factor map.



################### Quality of representation#######################################
## as visualization of correlation matrix
corrplot::corrplot(var.pca$cos2, is.corr=FALSE)
##as visualization of bar plot
factoextra::fviz_cos2(pca$model, choice = "var", axes = 1:2)

#A high cos2 indicates a good representation of the variable on the principal 
#component. In this case the variable is positioned close to the circumference 
#of the correlation circle. 
#A low cos2 indicates that the variable is not perfectly represented by the PCs. 
#In this case the variable is close to the center of the circle. 


# Color by cos2 values: quality on the factor map
factoextra::fviz_pca_var(pca$model, col.var = "cos2",
                         gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
                         alpha.var = "cos2",# add transparency according to cos2-values
                         repel = TRUE # Avoid text overlapping
)


###############################Contrinution of variables to PCA####################
corrplot::corrplot(var.pca$contrib,is.corr = FALSE)
factoextra::fviz_contrib(pca$model,choice = "var",axes=1)
factoextra::fviz_contrib(pca$model,choice = "var",axes=2)
factoextra::fviz_contrib(pca$model,choice = "var",axes=3)
factoextra::fviz_contrib(pca$model,choice = "var",axes=4)
#total contribution for several components
factoextra::fviz_contrib(pca$model, choice = "var", axes = 1:2)
factoextra::fviz_contrib(pca$model, choice = "var", axes = 1:3)

#The most important (or, contributing) variables can be highlighted on the 
#correlation plot as follow:
factoextra::fviz_pca_var(pca$model, col.var = "contrib",
                           gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07")
  )
  
###########################Group variables by Cluster#############################
#set.seed(123)
#res.km <- kmeans(var.pca$coord, centers = 5, nstart = 25)
#grp <- as.factor(res.km$cluster)
#factoextra::fviz_pca_var(pca$model, col.var = grp, 
#            palette = c("#0073C2FF", "#EFC000FF", "#868686FF","red","green"),
#            legend.title = "Cluster")

# clean workspace
rm(spectral_norm ,pca, eigvalue.pca , pca, var.pca)
gc()