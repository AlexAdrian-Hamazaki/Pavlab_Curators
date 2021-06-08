
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install("GEOquery")

library(GEOquery)




#---Get getGEO information for a GSE
gse_data <- getGEO("GSE106678", GSEMatrix = FALSE)

#---Get metadata from the gse_data

gse_meta <- Meta(gse_data)

#---Get a GSM S4 object from gse_data and get its metadata

gsm_data <- GSMList(gsm_get)[[1]]
gsm_meta <- Meta(gsm_data)

#---See if we can detect single cell/ single nuclus within the GSE page. If not, then we move on to exploring the GSM for it.
#If at any point we detect a hit, we catch our error and add the given GSE to our output list

tryCatch( {
  stopifnot(!str_detect(str_to_lower(meta$overall_design), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
  stopifnot(!str_detect(str_to_lower(meta$summary), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl).*")))
  stopifnot(!str_detect(str_to_lower(meta$title), pattern = (".*sc.?(rna|nucl).* | .*single.?(cell|nucl).*")))
  
},
error = function(cond) {
  message("GSM is likely single cell")
}
)






