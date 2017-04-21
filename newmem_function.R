
setwd("~/Documents/R/MEM_OHSU/Cohort_selected")

library(cluster)
library(tidyr)
library(knitr)
library(MASS)
library(MEM)
library(reshape2)
library(reshape)
library(plyr)
library(ggplot2)
library(data.table)

library("optparse")
option_list = list(
  make_option(c("-f", "--file"), type = "character", default = NULL, help= "data file name or file path", metavar = "character"),
  make_option(c("-c", "--group"), type = "character", default = "none", help = "Must be input of 'high': k=4, 'med1': k=3, 'med2'; : k=8, or 'low' : k=10.\nThis refers to the high, medium and low CD45 levels.", metavar = "character"),
  make_option(c("-o", "--outfile"), type = "character", default="enrichment_output.txt", help = "output file name [default = enrichment_output.txt]", metavar = "character"),
  make_option(c("-h", "--heatmap"), type = "character", default = TRUE, help = "use -h TRUE option to include a heatmap pdf.", metavar = "character")
  );
opt_parser = OptionParser(option_list = option_list);
opt = parse_args(opt_parser);


marker_enrichment <- function(fp = opt$file, group = opt$group, heatmap = opt$heatmap){
  dat <- file.prep(fp)
  #create hierarchical clustering classifiers
  dat.agnes <- agnes(dat, diss=FALSE, metric = "euclidean", stand = FALSE, 
                     method = "complete", keep.diss = TRUE, keep.data = TRUE, trace.lev = 1)
  
  #for cluster size option:
  if(group == "high"){
    optimk <- cutree(as.hclust(dat.agnes), k=4)
  }
  if(group == "med"){
    optimk <- cutree(as.hclust(dat.agnes), k=8)
  }
  if(group == "low"){
    optimk <- cutree(as.hclust(dat.agnes), k=10)
  }
  if(group == "none"){
    optimk <- cutree(as.hclust(dat.agnes), k=3)
  }

  class_dat <- cbind(dat, cluster = optimk)
  class_df <- as.data.frame(class_dat)
  class_df$cluster <- as.factor(class_df$cluster)
  class_melt <- melt((as.data.frame(class_dat)), id="cluster")
  
  
  #IQRpop
  meltIQR <- cast(class_melt, cluster~variable, IQR)
  meltIQR <- as.matrix(abs(meltIQR[2:12]))
  colnames(meltIQR) <- markers
  
  #MAGpop
  meltmedian <- cast(class_melt, cluster~variable, median)
  meltmedian <- as.matrix(abs(meltmedian[2:12])) 
  colnames(meltmedian) <- markers  #Same as MAGpop
  
  meltmean <- cast(class_melt, cluster~variable, mean)
  meltsd <- cast(class_melt, cluster~variable, sd)
  
  #Set variables from data
  pop_cluster <- unique(class_melt$cluster)
  num_cluster <- length(pop_cluster)
  num_cells <- nrow(class_dat)
  marker_names <- markers
  num_markers <- length(markers)
  
  #Initialize MEM variable matricies
  MAGpop = as.matrix(meltmedian)
  MAGref = matrix(nrow=num_cluster,ncol=num_markers)
  IQRpop = as.matrix(meltIQR)
  IQRref = matrix(nrow=num_cluster,ncol=num_markers)
  SDpop = as.matrix(meltsd)
  SDpop[!is.finite(SDpop)] <- 0
  SDref = matrix(nrow=num_cluster,ncol=num_markers)
  
  
  #MAGref
  for(i in 1:num_cluster){
    pop = pop_cluster[i]
    temp_ref = as.data.frame(subset(class_df, cluster!= pop))
    MAGref[i,] = abs(apply(temp_ref[1:11], 2, FUN=median, na.rm = TRUE))
    remove(temp_ref)
  }
  colnames(MAGref)= marker_names
  
  #IQRref
  for(i in 1:num_cluster){
    pop = pop_cluster[i]
    temp_ref = as.data.frame(subset(class_df, cluster!= pop))
    IQRref[i,] = abs(apply(temp_ref[1:11], 2, FUN=IQR, na.rm = TRUE))
    remove(temp_ref)
  }
  colnames(IQRref)= marker_names
  
  #SDref
  for(i in 1:num_cluster){
    pop = pop_cluster[i]
    temp_ref = as.data.frame(subset(class_df, cluster!= pop))
    SDref[i,] = abs(apply(temp_ref[1:11], 2, FUN=sd, na.rm = TRUE))
    remove(temp_ref)
  }
  colnames(SDref)= marker_names
  
  
  MAGdiff = MAGpop-MAGref
  #MEM
  score = abs(MAGpop-MAGref)+(IQRref/IQRpop)-1 
  score[!(MAGdiff>=0)] <- (-score[!(MAGdiff>=0)])
  
  # Put MEM values on -10 to +10 scale
  scale_max = max(abs(score[,c(1:ncol(score)-1)]))
  MEM_matrix = cbind((score[,c(1:ncol(score)-1)]/scale_max)*10,score[,ncol(score)])
  
  MEM_matrix[!is.finite(MEM_matrix)] <- 0
  colnames(MEM_matrix) <- markers
  
  #write MEM Matrix into a file
  write.table(MEM_matrix, file = opt$outfile, sep=",", eol="\n", na="NA", row.names = TRUE, col.names = TRUE)
  
  #heatmap 
  if(is.null(heatmap)){
    heatmap == TRUE
  }
  #heatmap
  scale_max=1
  scale_min=-1
  heat_palette_MEM <- colorRampPalette(c("salmon","lightgoldenrod","whitesmoke","palegreen","seagreen4"))
  pairs.breaks_MEM <- c(seq(scale_min, scale_min/3.3, 0.1), seq(scale_min/3.3, scale_min/6.6, 0.1), seq(scale_min/6.6,0,0.1), seq(0, scale_max/6.6,0.1), seq(scale_max/6.6,scale_max/3.3, 0.1), seq(scale_max/3.3,scale_max,0.1))
  
  heatmap2 <- heatmap.2(MEM_matrix,
                        dendrogram = 'both',
                        breaks = pairs.breaks_MEM,
                        key = TRUE, 
                        col = heat_palette_MEM)
  
  #save heatmap to png file
  png("enrichment_heatmap.png")
  new_mem
  dev.off()
}
