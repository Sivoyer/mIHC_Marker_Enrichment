# mIHC_Marker_Enrichment
Multiplex Immunohistochemistry Marker Enrichment for lymphocyte dense regions of tumor samples labeled with biomarkers. These functions can find inherant clusters by first determining the number of clusters that may exist, performing hierarchical agglomerative clustering, and analyzing the values of proteins within each cluster against values of proteins in all other clusters and providing a quantitative relative number on a scale of -1:1.


## Opt.k
Function that runs NbClust to find optimal K using euclidean distance, complete linkage, and evaluated by all indicies. See NbClust docs for full details on how clustering is performed and evaluated. 

## make.Mastermatrix
Function that takes output csv files from Apiero scope single cell values and selects only mean intensity columns from each file and merges them into a one matrix written as a csv, and renames columns to (my) specific markers associated for each mean intensity column. 

## prep.file
Function that takes a file path or csv file in working directory from an Apiero output file and selects only mean intensity columns or marker names.
Options:
Scale, -s: this will scale the values to mean=0 and sd=1

## newmem_function
Function called 'marker_enrichment()' that takes:
input file, -f: must be a path to csv file or file name in working directory
group, -g: group refers to the lymphocyte density, high, med, or low. This is based on reference clustering and selects a k value based on the group type if classification or k-size is undetermined. 
'high': k= 4
'med': k= 8
'low': k= 10
You can also just put an int value for k 
heatmap, -h: this builds a heatmap for the enrichment matrix with dendrograms for the clusters and proteins.

## make_heatmap
Function that makes a heatmap based on the values in the matrix created from the newmem function. 



