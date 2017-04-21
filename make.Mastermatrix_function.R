#function to get all files in a directory into a master matrix for analysis
#files must be in THIS particular marker order - TO ADD: user input for marker list
#currently, exp_dir must be the directory with csv files
#it looks for columns with the names output by Apiero feature selection for mean intensity

make.Mastermatrix <- function(exp_dir) {
  file_list = list.files(exp_dir, pattern = "*.csv")
  col_select <- as.vector(c("Intensity_MeanIntensity_Unmix10", "Intensity_MeanIntensity_Unmix11",
                  "Intensity_MeanIntensity_Unmix12","Intensity_MeanIntensity_Unmix2", 
                  "Intensity_MeanIntensity_Unmix3", "Intensity_MeanIntensity_Unmix4", 
                  "Intensity_MeanIntensity_Unmix5", "Intensity_MeanIntensity_Unmix6", 
                  "Intensity_MeanIntensity_Unmix7", "Intensity_MeanIntensity_Unmix8", 
                  "Intensity_MeanIntensity_Unmix9"))
  markers <- c("Tbet", "CD68", "CD45", "CD4", "CD3", "PD1", "Ki67", "CD8", "Tbr2", "GrzB", "IDO")
  cat("master matrix created from files:")
  for(f in file_list){
      if (!exists("masterset")){
      masterset <- fread(f, header=TRUE,stringsAsFactors = TRUE, select = col_select, col.names = markers)
      #print("adding file")
    } 
      if (exists("masterset")){
      temp_dataset <- fread(f, header=TRUE, stringsAsFactors = TRUE, select = col_select, col.names = markers)
      masterset <- rbind(masterset, temp_dataset)
      #print("added file")
      rm(temp_dataset)
    }
  #rename columns and output new matrix
  #colnames(masterset) <- markers
  write.csv(masterset, "masterset.csv")
  cat(" ", f)
  }
}