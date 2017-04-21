opt.k <- function(exp_dir) {
  file_list = list.files(exp_dir, pattern = "*.csv")
  col_select <- as.vector(c("Intensity_MeanIntensity_Unmix10", "Intensity_MeanIntensity_Unmix11",
                            "Intensity_MeanIntensity_Unmix12","Intensity_MeanIntensity_Unmix2", 
                            "Intensity_MeanIntensity_Unmix3", "Intensity_MeanIntensity_Unmix4", 
                            "Intensity_MeanIntensity_Unmix5", "Intensity_MeanIntensity_Unmix6", 
                            "Intensity_MeanIntensity_Unmix7", "Intensity_MeanIntensity_Unmix8", 
                            "Intensity_MeanIntensity_Unmix9"))
  markers <- c("Tbet", "CD68", "CD45", "CD4", "CD3", "PD1", "Ki67", "CD8", "Tbr2", "GrzB", "IDO")
  cat("Evaluating optimal K for files:")
  for(f in file_list){
    dat <- fread(f, header=TRUE, stringsAsFactors = TRUE, select = col_select, col.names = markers)
    dat <- scale(dat)
    nb <- NbClust(dat, 
                  distance = "euclidean", 
                  min.nc = 2, max.nc = 15, 
                  method = "complete", 
                  index = "all")
    #nbindex <- nb$All.index
    #nbbestk <- nb$Best.nc
    #write.csv(nbindex, 'NB_index',f)
    #write.csv(nbbestk, 'NB_best',f)
    pdf(file="NBclust_",f,'.pdf')
    fviz_nbclust(nb) + theme_minimal()
    dev.off()
    rm(nb)
  }
}
    