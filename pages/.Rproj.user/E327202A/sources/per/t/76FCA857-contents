#' function to create a large test dataset for comprehensive analysis of pre-processing steps
#'
#'@description

#' This function takes a raw FTIR database and applies various pre-processing steps as well as adding different levels of noise.
#' The resulting object can be used to assess the the effect of different pre-processing techniques on the classification result.

#'@author Darius Görgen

#'@param data an object of type DataFrame which numeric variables represent the FTIR spectrum of various samples.

#'@param category  string which is equal to one of the names in data and relates to the classes of the samples.

#'@param noise  numeric vector indicating the levels of noise to be added by the base::jitter function

#'@param savG list containing the parameters to be used in the Savitzkiy-Golay filtering of the spectra. Default is p =3 and w=11

#'

#'

#'@value returns a list element of the same length as indicated by the noise vector, the first element containing all the pre-process steps 

#' at the first noise level. The order within each noise level is: raw data, normalized data, SG-filter data, 1st derivative, 2nd derivative, SG-filter of 1st derivative
#' SG-filter of 2nd derivative, SG-filter of normalized data, SG-filter of normalized 1st derivative, SG-filter of normalized 2nd derivative,
#' SG-filter of normalized 1st derivative, SG-filter of normalized 2nd derivative,
#' 
#' 



createTestDataset = function(data,category = "Abbreviation",noise = c(),savG = list(p=3,w=11)){
  if(!category %in% names(data)) print("The categorial variable you provided does not match any column in the dataframe")
  
  # adding noise to data
  addNoise = function(n){
    tmp = as.matrix(data[,-which(names(data) ==category)])
    tmp = as.data.frame(jitter(tmp, n))
    tmp[category] = data[category]
    return(tmp)
  }
  
  data.noise = lapply(noise,addNoise)
  
  PreProcess = function(data){
    # center and scale data
    data.norm = as.data.frame(base::scale(data[,-which(names(data)==category)]))
    data.norm[category] = data[category]
    
    # 1st and 2nd derivative on raw data 
    data.d1 = as.data.frame(t(diff(t(data[,-which(names(data)==category)]), differences = 1, lag = 11)))
    data.d1[category] = data[category]
    data.d2 = as.data.frame(t(diff(t(data[,-which(names(data)==category)]), differences = 2, lag = 11)))
    data.d2[category] = data[category]
    # 1st and 2nd derivative on normalized data 
    data.d1.norm = as.data.frame(t(diff(t(data.norm[,-which(names(data.norm)==category)]), differences = 1, lag = 11)))
    data.d1.norm[category] = data.norm[category]
    data.d2.norm = as.data.frame(t(diff(t(data.norm[,-which(names(data.norm)==category)]), differences = 2, lag = 11)))
    data.d2.norm[category] = data.norm[category]
    # savitzkiy golay filter on raw data
    data.sg = as.data.frame(prospectr::savitzkyGolay(data[,-which(names(data)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg[category] = data[category]
    data.sg.d1 = as.data.frame(prospectr::savitzkyGolay(data.d1[,-which(names(data.d1)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg.d1[category] = data[category]
    data.sg.d2 = as.data.frame(prospectr::savitzkyGolay(data.d2[,-which(names(data.d2)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg.d2[category] = data[category]
    # savitzkiy golay filter on normalized data
    data.sg.norm = as.data.frame(prospectr::savitzkyGolay(data.norm[,-which(names(data.norm)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg.norm[category] = data.norm[category]
    data.sg.d1.norm = as.data.frame(prospectr::savitzkyGolay(data.d1.norm[,-which(names(data.d1.norm)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg.d1.norm[category] = data.norm[category]
    data.sg.d2.norm = as.data.frame(prospectr::savitzkyGolay(data.d2.norm[,-which(names(data.d2.norm)==category)], p = savG[[1]], w = savG[[2]], m = 0))
    data.sg.d2.norm[category] = data.norm[category]
    
    # prepare for adding noises
    data.clean = list(data,
                      data.norm,
                      data.sg,
                      data.d1,
                      data.d2,
                      data.sg.d1,
                      data.sg.d2,
                      data.sg.norm,
                      data.d1.norm,
                      data.d2.norm,
                      data.sg.d1.norm,
                      data.sg.d2.norm
                      )
    return(data.clean)
  }
  
  data.return = lapply(data.noise,PreProcess)
  return(data.return)  
}
