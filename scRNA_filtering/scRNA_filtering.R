#This scrript takes an input of GSEids, and outputs the ones that are single cell or lncRNA


#---Installing packages
if (!'GEOquery' %in% installed.packages()){
  install.packages("BiocManager")
  BiocManager::install("GEOquery")
}
if (!'rstudioapi' %in% installed.packages()){
  install.packages("rstudioapi")
}
library(GEOquery, quietly = TRUE, verbose = FALSE)
library(tidyverse)
library(rstudioapi)

#----------------------------------------------------


#---Change the following variables as you desire

#running_dir is the directory where you are running this code. Must be a string
#**** Suggestiong can we use relative path so we don't need to setup enviroment differently for everyone
#running_dir <- "~/Projects/Pavlab_Curators/scRNA_filtering"

running_dir <- dirname(getActiveDocumentContext()$path)

#target_dir is the directory where your input_GSEids.txt file is, and where you will output your results. By default it is == running_dir
target_dir <- running_dir
#input_GSEids.txt is your text file with GSEIds you are testing. The file must be \n delimited
input_GSEids.txt <- "negative_sc_hits.txt"

#---Note: GSEs that are split (have .1, .2 ... after its GSEid), cannot be retrieved from GEO. This script takes off the split and uses the base GSE for API accession.
#As a result, if it turns out that the base has scRNA/lnc, the outputted GSEid will NOT have the split name on it. You must manually check the outputs
#to match the sc/lnc GSEs to their respective splits within gemma.

#---Note: This script downloads a lot of information so it may take some time. We may look into using rentrez to reduce how much is downloaded

#-----------------------------------------------------



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
#---remove non distinct
gseids_uniq <- unique(gseids)

#---Clean input file
# <- lapply(gseids, str_split, pattern = "\\.")
#length(dictionary$V1[[1]])
#dictionary <- lapply(dictionary, function(x) <- dictionary[length(dictionary$V1)==1])
#****** Is this what you were trying to do?
clean_gseids<- lapply(gseids[,1], function(gse) str_replace(pattern = "\\.[:digit:].?", replacement =  "", string = gse))

#gseids_clean <- str_extract(string = "GSE15123.1", pattern = "\\..*")
#str_view(string = "GSE15123.1", pattern = "\\..*")



#------Turn that shit into a function

filter_scRNA <- function(GSEid) {
  
  #---Get getGEO information for a GSE
  gse_data <- getGEO(GSEid, GSEMatrix = FALSE, destdir = target_dir)
  
  #---Get metadata from the gse_data
  
  gse_meta <- Meta(gse_data)
  
  n_samples <- length(gse_meta$sample_id)

  #---Get  GSM S4 objects from gse_data and get its metadata
  
  gsm_data <- GSMList(gse_data)[[1]]
  gsm_meta <- Meta(gsm_data)
  
  gsm_data_end <- GSMList(gse_data)[[n_samples]]
  gsm_meta_end <- Meta(gsm_data_end)
  
  gsm_data_mid <-  GSMList(gse_data)[[n_samples/2]]
  gsm_meta_mid <- Meta(gsm_data_mid)
  
  #---Delete the soft file that was just downloaded
  file.remove(paste0(target_dir,"/",GSEid,".soft.gz"))
  
  #---See if we can detect single cell/ single nuclus within the GSE page. If not, then we move on to exploring the GSM for it.
  #If at any point we detect a hit, we catch our error and add the given GSE to our output list
  tryCatch( {
    stopifnot(!str_detect(str_to_lower(gse_meta$overall_design), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gse_meta$summary), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gse_meta$title), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$title), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$description), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$extraction_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$growth_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$data_processing), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$source_name_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$characteristics_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta$treatment_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    
    #Try for the other gsm_meta's because there might be different types of samples within 1 GEO page
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$title), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$description), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$extraction_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$growth_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$data_processing), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$source_name_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$characteristics_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_end$treatment_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$title), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$description), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$extraction_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$growth_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$data_processing), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$source_name_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$characteristics_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    stopifnot(!str_detect(str_to_lower(gsm_meta_mid$treatment_protocol_ch1), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))
    warning(paste(GSEid,"not single cell, testing lnc..."))
  },
  error = function(cond) {
    message(paste0(GSEid," GSM is likely single cell"))
    return (c(GSEid,"sc"))
  },
  warning = function(cond) {
    message(cond)
    tryCatch( 
      {
      stopifnot(!str_detect(str_to_lower(gse_meta$overall_design), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gse_meta$summary), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gse_meta$title), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      
      stopifnot(!str_detect(str_to_lower(gsm_meta$characteristics_ch1), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gsm_meta$data_processing), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gsm_meta$extraction_protocol_ch1), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gsm_meta$growth_protocol_ch1), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      stopifnot(!str_detect(str_to_lower(gsm_meta$treatment_protocol_ch1), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      message(paste(GSEid,"not single cell, or lnc"))
      
    },
    error = function(cond) {
      message(paste0(GSEid," GSM is likely lnc"))
      return (c(GSEid,"lnc"))
    }
    )
  }
  )
}
#-------testing



# str_view(string = "we used single-cell RNA-sequencing (scRNA-seq) to analyze the transc", pattern = ".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")

questionable_GSEs <- lapply(clean_gseids, filter_scRNA)

questionable_GSEs_filtered <- questionable_GSEs[lengths(questionable_GSEs) != 0]

sep_sc <- function(GSEid_with_string) { 
  if (GSEid_with_string[2] == "sc"){
    return (GSEid_with_string[1])
  }
}
sep_lnc <- function(GSEid_with_string) { 
  if (GSEid_with_string[2] == "lnc"){
    return (GSEid_with_string[1])
  }
}

scRNA_GSEs <-lapply(questionable_GSEs_filtered,sep_sc)
scRNA_GSEs <- scRNA_GSEs[lengths(scRNA_GSEs) != 0]

lnc_GSEs <- lapply(questionable_GSEs_filtered,sep_lnc)
lnc_GSEs <- lnc_GSEs[lengths(lnc_GSEs) != 0]


write_delim(as.data.frame(scRNA_GSEs), file = paste0(target_dir, "/", "scRNA_GSEids.txt"), delim = "\n", col_names = FALSE)
write_delim(as.data.frame(lnc_GSEs), file = paste0(target_dir, "/", "lnc_GSEs.txt"), delim = "\n", col_names = FALSE)



