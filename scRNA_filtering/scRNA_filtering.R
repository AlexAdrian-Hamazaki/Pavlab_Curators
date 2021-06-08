#This script takes an input of GSEids, and gets GEO API information from them. It then filters that information to see if the experiment is scRNA/snRNA
#If an experiment is scRNA, it is written into this script's output. "scRNA_GSEids.txt"

#---Change the following variables as you desire

#running_dir is the directory where you are running this code. Must be a string
running_dir <- "~/Projects/Pavlab_Curators/scRNA_filtering"

#target_dir is the directory where your input_GSEids.txt file is, and where you will output your results. By default it is == running_dir
target_dir <- running_dir

#input_GSEids.txt is your text file with GSEIds you are testing. The file must be \n delimited
input_GSEids.txt <- "input_GSEids.txt"

#-----------------------------------------------------

#---Installing packages
if (!requireNamespace("BiocManager", quietly = TRUE)){
  install.packages("BiocManager")
  BiocManager::install("GEOquery")
}

library(GEOquery)
library(tidyverse)
#----------------------------------------------------


# #---Get getGEO information for a GSE
# gse_data <- getGEO("GSE106678", GSEMatrix = FALSE, destdir = target_dir, getGPL = FALSE, AnnotGPL = FALSE, parseCharacteristics = FALSE)
# 
# #---Get metadata from the gse_data
# 
# gse_meta <- Meta(gse_data)
# 
# #---Get a GSM S4 object from gse_data and get its metadata
# 
# gsm_data <- GSMList(gse_data)[[1]]
# gsm_meta <- Meta(gsm_data)
# 
# #---See if we can detect single cell/ single nuclus within the GSE page. If not, then we move on to exploring the GSM for it.
# #If at any point we detect a hit, we catch our error and add the given GSE to our output list
# 
# tryCatch( {
#   stopifnot(!str_detect(str_to_lower(gse_meta$overall_design), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gse_meta$summary), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gse_meta$title), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gsm_meta$characteristics_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gsm_meta$data_processing), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gsm_meta$extraction_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gsm_meta$growth_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
#   stopifnot(!str_detect(str_to_lower(gsm_meta$treatment_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
# },
# error = function(cond) {
#   message("GSM is likely single cell")
#   
# }
# )
# 


#---Load input file
gseids <- read.delim(paste0(target_dir, "/", input_GSEids.txt), header= FALSE)
typeof(gseids$V1)

#---Clean input file
dictionary <- lapply(gseids, str_split, pattern = "\\.")
length(dictionary$V1[[1]])
dictionary <- lapply(dictionary, function(x) <- dictionary[length(dictionary$V1)==1]

gseids_clean <- str_extract(string = "GSE15123.1", pattern = "\\..*")
str_view(string = "GSE15123.1", pattern = "\\..*")



#------Turn that shit into a function

filter_scRNA <- function(GSEid) {
  
  #---Get getGEO information for a GSE
  gse_data <- getGEO(GSEid, GSEMatrix = FALSE, destdir = target_dir, getGPL = FALSE, AnnotGPL = FALSE, parseCharacteristics = FALSE)
  
  #---Get metadata from the gse_data
  
  gse_meta <- Meta(gse_data)
  
  #---Get a GSM S4 object from gse_data and get its metadata
  
  gsm_data <- GSMList(gse_data)[[1]]
  gsm_meta <- Meta(gsm_data)
  
  #---See if we can detect single cell/ single nuclus within the GSE page. If not, then we move on to exploring the GSM for it.
  #If at any point we detect a hit, we catch our error and add the given GSE to our output list
  
  tryCatch( {
    stopifnot(!str_detect(str_to_lower(gse_meta$overall_design), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gse_meta$summary), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gse_meta$title), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$characteristics_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$data_processing), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$extraction_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$growth_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$treatment_protocol_ch1), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
  },
  error = function(cond) {
    message(paste0(GSEid," GSM is likely single cell"))
    return (GSEid)
  }
  )
}
  
scRNA_GSEids <- lapply(gseids$V1, filter_scRNA)

scRNA_GSEids_filtered <- scRNA_GSEids[lengths(scRNA_GSEids) != 0]

write_delim(as.data.frame(scRNA_GSEids_filtered), file = paste0(target_dir, "/", "scRNA_GSEids.txt"), delim = "\n", col_names = FALSE)



