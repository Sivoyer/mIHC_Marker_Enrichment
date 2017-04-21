
option_list = list(
  make_option(c("-f", "--file"), type = "character", default = NULL, help= "data file name or file path", metavar = "character"),
  make_option(c("-o", "--outfile"), type = "character", default= paste(strftime(Sys.time(),"%Y-%m-%d_%H%M%S"),"enrichment_output.txt"), help = "output file name [default = (date)enrichment_output.txt]", metavar = "character"),
  make_option(c("-s", "--scale"), type = "character", default = TRUE, help = "use -s option to scale mean=0, sd=1", metavar = "character")
);
opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);


prep.file <- function(f = opt$file, scale = opt$scale, outfile = opt$outfile) {
  markers <- c("Tbet", "CD68", "CD45", "CD4", "CD3", "PD1", "Ki67", "CD8", "Tbr2", "GrzB", "IDO")
  col_select <- as.vector(c("Intensity_MeanIntensity_Unmix10", "Intensity_MeanIntensity_Unmix11",
                            "Intensity_MeanIntensity_Unmix12","Intensity_MeanIntensity_Unmix2", 
                            "Intensity_MeanIntensity_Unmix3", "Intensity_MeanIntensity_Unmix4", 
                            "Intensity_MeanIntensity_Unmix5", "Intensity_MeanIntensity_Unmix6", 
                            "Intensity_MeanIntensity_Unmix7", "Intensity_MeanIntensity_Unmix8", 
                            "Intensity_MeanIntensity_Unmix9"))
  
  #find which column names to use, markers or apiero names.
  temp <-fread(f, header=TRUE, nrows = 2)
  if(col_select[1] %in% colnames(temp)){select = col_select} else{select=markers}
  rm(temp)
  
  #create a matrix of only columns selected
  dat <- fread(f, header=TRUE, stringsAsFactors = TRUE, select = select, col.names = markers)
  return(dat);
  if(scale == TRUE){
    dat <- as.data.frame(scale(dat))
  }
  return(dat);

  #write.table(dat, file= paste(strftime(Sys.time(),"%Y-%m-%d_%H%M%S"), "file_ready.csv"), sep=",", eol="\n", na="NA", row.names = TRUE, col.names = TRUE)
  
}

#Example: dat <- prep.file("testfile.csv", scale = TRUE, outfile = TRUE)