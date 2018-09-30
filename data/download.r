# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
loadPackages(c("h5"))
# ----------------------------------------------

# ----------------------------------------------
# CONFIG
# ----------------------------------------------
#REMOVE RAW FILE AFTER DOWNLOAD?
removeRawFile = TRUE
# ----------------------------------------------

# ----------------------------------------------
# PREPARATION / LOAD FILE LISTS
# ----------------------------------------------
rawPath = file.path(folders$data, "raw")
savePath = file.path(folders$data, "processed")
dir.create(savePath, showWarnings = FALSE)
hdf5Files = read.table(file.path(folders$data, "hdf5Files.txt"), stringsAsFactors = FALSE)
hdf5Saved = list.files(savePath, pattern = "\\.rData$", recursive=TRUE)
# ----------------------------------------------

for(i in 1:nrow(hdf5Files)){
    hdf5File = hdf5Files[i,]
    #FOR NOW, ONLY 2018 DATA
    if(substr(hdf5File, 3, 6) != "2018")
        next
    
    hdf5FileName = sub('.*\\/', '', hdf5File)
    
    saveDataPath = file.path(savePath, substr(hdf5File, 3, 6), substr(hdf5File, 8, 9), substr(hdf5File, 11, 12))
    
    if(file.exists(file.path(saveDataPath, gsub(".HDF5", ".rData", hdf5FileName))))
        next
    
    print(hdf5File)
    dir.create(saveDataPath, showWarnings = FALSE, recursive = TRUE)
    url=paste0("https://atmos.eoc.dlr.de/products/gome2b/offline/", substring(hdf5File, 3, nchar(hdf5File)))
    download.file(url,
                  destfile = file.path(rawPath, hdf5FileName),
                  quiet = TRUE,
                  method="wget",
                  extra=paste0("--user=", authUser, " --password=", authPassword))
    
    print("Downloading completed. Processing.")
    
    #LOAD HDF5 FILE
    prec = h5file(file.path(rawPath, hdf5FileName))
    
    #REMOVE RAW FILE AGAIN EVENTUALLY
    if(removeRawFile)
        file.remove(file.path(rawPath, hdf5FileName))
    
    
    lons = prec["GEOLOCATION"]["LongitudeCentre"][]
    lats = prec["GEOLOCATION"]["LatitudeCentre"][]
    no2tropo = prec["TOTAL_COLUMNS"]["NO2Tropo"][]
    no2 = prec["TOTAL_COLUMNS"]["NO2"][]
    h5close(prec)
    
    tmp <- data.table(X=as.vector(lons), 
                      Y=as.vector(lats),
                      no2=as.vector(no2),
                      no2tropo=as.vector(no2tropo))
    tmp$date = paste(substr(hdf5File, 3, 6), substr(hdf5File, 8, 9), substr(hdf5File, 11, 12), sep = "-")
    
    #SAVE/RM DATA
    saveData(tmp, file=file.path(saveDataPath, gsub(".HDF5", ".rData", hdf5FileName)))
    rm(tmp)
}



