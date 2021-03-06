# ----------------------------------------------
# BASE
# ----------------------------------------------
rm(list=ls())
source("./base/init.r", chdir=TRUE)
# ----------------------------------------------

# ----------------------------------------------
# GEF FILELIST (lftp required
# ----------------------------------------------
savePath = file.path(folders$data)
dir.create(savePath, showWarnings = FALSE, recursive = TRUE)
url = "https://atmos.eoc.dlr.de/products/gome2b/offline/"
hdf5Files = system(paste0('lftp -u ', authUser, ',', authPassword, " ", url,' <<<\'find| grep "\\\\.HDF5$"; exit;\';'),intern=T)
write.table(hdf5Files,file.path(savePath, "hdf5Files.txt"),row.names=FALSE, col.names=FALSE)
# ----------------------------------------------