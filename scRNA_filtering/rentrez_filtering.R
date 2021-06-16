library(rentrez)
library(stringr)


entrez_db_searchable("gds")
search_result <- entrez_search(db = "gds", term = paste0("GSE119248","[ACCN]"), retmax = 3)
id <- "200097353"
search_result1 <- entrez_search(db = "gds", term = paste0("GSE119248","[ACCN]"), retmax = 3)

#-------------------------------

use_rentrez_API <- function (GSEid) {
  search_result <- entrez_search(db = "gds", term = paste0(GSEid,"[ACCN]"), retmax = 3)
  result_summary <- entrez_summary(db = "gds", id = search_result$ids)
  check_propper_types(result_summary)
  result_summary <- rename_IDs(result_summary)
  return(result_summary)
}



filtering_for_targets <- function(list_from_entrez_output) {
  tryCatch( {
    name <- names(list_from_entrez_output)[1]
    stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["title"]), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")))
    stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["summary"]), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")))
    stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["gdstype"]), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")))
    stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[3]]["summary"]), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")))
    stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[3]]["title"]), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*")))
    warning("not sc, testing lnc...")
  },
  error = function(cond) {
    message(paste0(name," GSM is likely single cell"))
    return (c(name,"sc"))
  },
  warning = function(cond) {
    message(cond)
    tryCatch( 
      {
        name <- names(list_from_entrez_output)[1]
        stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["title"]), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
        stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["summary"]), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
        stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[1]]["gdstype"]), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
        stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[3]]["summary"]), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
        stopifnot(!str_detect(str_to_lower(list_from_entrez_output[[3]]["title"]), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*")))
      },
      error = function(cond) {
        message(paste0(name," GSM is likely lnc"))
        return (c(name,"lnc"))
      }
    )
  }
  )
}


filtering_for_targets(entrez_output1)

GSEids <- c("GSE97353")

entrez_output <- lapply(GSEids, use_rentrez_API)

entrez_output1 <- entrez_output[[1]]




str_view(str_to_lower("Comparison of scAAV9-CßA and scAAV9-U6 driven artificial miRNAs targeting human huntingtin"), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*"))
str_detect(str_to_lower("Comparison of scAAV9-CßA and scAAV9-U6 driven artificial miRNAs targeting human huntingtin"),
           pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito).*"))


check_propper_types <- function(results_summary) {
  index1_type <- results_summary[[1]]["entrytype"]
  index2_type <- results_summary[[2]]["entrytype"]
  index3_type <- results_summary[[3]]["entrytype"]
  stopifnot(index1_type == "GSE")
  stopifnot(index2_type == "GPL")
  stopifnot(index3_type == "GSM")
  print(index1_type)
  print(index2_type)
  print(index3_type)
}

rename_IDs <- function(results_summary) {
  index1_name <- results_summary[[1]]["accession"]
  index2_name <- results_summary[[2]]["accession"]
  index3_name <- results_summary[[3]]["accession"]
  names(results_summary) <- c(index1_name, index2_name, index3_name)
  print(index1_name)
  print(index2_name)
  print(index3_name)
  return(results_summary)
}

# rename_output <- function(entrez_output){
#   browser()
#   for (i in entrez_output) {
#     browser()
#     names(entrez_output[i]) <- names(i)[[1]]
#     browser()
#   }
#   browser()
#   return(entrez_output)
# }
# 


list <- list(list("tt"), list("aa"))
names(list)
