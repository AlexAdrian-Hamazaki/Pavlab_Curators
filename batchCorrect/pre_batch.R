# file <- read_delim("rna-seq-to-update-batch (1).txt", "\t", col_names = FALSE)


# get_pre_batch <- function(x){
#   sapply(x, function(x){
#   GSE <- datasetInfo(x)
#   if(!is.null(GSE[[x]]$batchConfound) && !is.null(GSE[[x]]$batchEffect)){
#     return(paste0(GSE[[x]]$batchConfound, " ", GSE[[x]]$batchEffect))
#   } else if(!is.null(GSE[[x]]$batchConfound)){
#     return(GSE[[x]]$batchConfound)
#   } else if(!is.null(GSE[[x]]$batchEffect)){
#     return(GSE[[x]]$batchEffect)
#   } else{
#     return("No batch info")
#   }
#   })
# }
# 
# file <- data.frame(file)
# file <- file %>% rename("GSEs"= X1, "Date of Event"=X2, "Audit Event"=X3, "eeid"=X4, "Technology"=X5)
# prepared_file <- file %>% mutate(pre_processing_batch = get_pre_batch(GSEs))
# 
# write_delim(prepared_file, "rna-seq_pre_update.txt", "\t")


get_after_batch <- function(x){
  sapply(x, function(x){
    GSE <- datasetInfo(x)
    if(!is.null(GSE[[x]]$batchConfound) && !is.null(GSE[[x]]$batchEffect)){
      return(paste0(GSE[[x]]$batchConfound, " ", GSE[[x]]$batchEffect))
    } else if(!is.null(GSE[[x]]$batchConfound)){
      return(GSE[[x]]$batchConfound)
    } else if(!is.null(GSE[[x]]$batchEffect)){
      return(GSE[[x]]$batchEffect)
    } else{
      return("No batch info")
    }
  })
}

processed_file <- prepared_file %>% mutate(post_processing_batch = get_pre_batch(GSEs))




