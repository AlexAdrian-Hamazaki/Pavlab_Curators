
# Install New packages

packages <- c(
              "tidyverse",
              "data.table",
              "rstudioapi",
              "rvest",
              "stringr",
              "assertthat")

new_packages <- setdiff(packages, installed.packages()[,"Package"])
install.packages(new_packages)

#--- 

library(rvest)
library(stringr)
library(assertthat)
library(tidyverse)
library(rstudioapi)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Input a data frame of GSEids and clean it up

GSE_ids <- read.delim(file = "input.txt", header = FALSE, sep = "\n", stringsAsFactors = FALSE)
clean_GSE_ids<- lapply(GSE_ids[,1], function(gse) str_replace(pattern = "\\.[:digit:].?", replacement =  "", string = gse))
clean_GSE_ids <- lapply(clean_GSE_ids, function(gse) str_replace(pattern = " ", replacement =  "", string = gse))

# Remove duplicates
clean_GSE_ids[duplicated(clean_GSE_ids)]
clean_GSE_ids <- clean_GSE_ids[!duplicated(clean_GSE_ids)]



# 

# 
# sc_geo
# 
# td_html <- sc_geo %>%
#   html_nodes("td") %>%
#   html_text()
# # 
# # if (any(str_detect(td_html, 
# #                    pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*")))) {
# #   message (paste(GEO, "is likely single-cell"))
# # }
# # 



parse_GSM <- function(GSM_id) { 
  html_download <- read_html(paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
                                    GSM_id))
  td_html <- html_download %>%
    html_nodes("td") %>% 
    html_text()
  
  # First parse the GEO page for single cell or lnc information
  # If we find anything, return that info and move on to next GSE
  
  if (any
      (str_detect(str_to_lower(td_html), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*") )))
  {
    return (c(TRUE, "sc"))
  }
  else if (any
           (str_detect(str_to_lower(td_html), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*"))))
  {
    return (c(TRUE, "lnc"))
  } else {
    return (FALSE)
  }
}


parse_GSE <- function(GSE_id) {
  tryCatch(
    {
      
  html_download <- read_html(paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
                                    GSE_id))
  td_html <- html_download %>%
    html_nodes("td") %>% 
    html_text()
  
  # First parse the GEO page for single cell or lnc information
  # If we find anything, return that info and move on to next GSE
  if (any
      (str_detect(str_to_lower(td_html), pattern = (".*sc.?(rna|nucl).*|.*single.?(cell|nucl|mito|neur).*") )))
    {
    message (paste(GSE_id, "is likely single-cell"))
    return (c(GSE_id, "sc"))
  }
  else if (any
      (str_detect(str_to_lower(td_html), pattern = (".*(lnc|linc).?rna.*|.*long.?non.*|.?long.?n.?c.*"))))
    {
    message (paste(GSE_id, "is likely lnc"))
    return (c(GSE_id, "lnc"))
  }
  
  # If we cannot find any information in the GEO page, try to look at GSM page(s)
  # for sc or lnc information
  
  #GSMs is a double containing all of the GSMs in the GEO page
  GSMs <- td_html[!is.na(str_extract(td_html, "GSM[:digit:]+$"))]
  
  if (is_empty(GSMs)) {
    return (c(GSE_id, "Unknown"))
  }

  if (length(GSMs) <= 50) {
    sample_size <- 1
  } else if (100 >= length(GSMs) & length(GSMs) > 50 ) {
    sample_size <- 2
  } else if (length(GSMs) > 100) {
    sample_size <- 3
  }
  
  #Take a sample of GSMs
  
  GSM_samples <- sample(GSMs, sample_size)
  
  GSM_test <- lapply(GSM_samples, parse_GSM)

  for (element in GSM_test) {
    if (element[1] == TRUE) {
    return (c(GSE_id, element[2]))
    }
    }
    
  return (c(GSE_id, "Unknown"))
  
  }, 
  error = function(cond) {
    message(paste(cond, "at", GSE_id))
  })
}

# Generate a list that lets you know if a GSE is sc or lnc or unknown

complete_list <- lapply(clean_GSE_ids, parse_GSE)


# Seperate the GSEs into different dataframes
# based on if they are sc lnc or umknown
sc_GSEs <- c()
lnc_GSEs <- c()
unknown_GSEs <- c()


for (element in complete_list) {
  if (element[2] == "sc") {
    sc_GSEs <- append(sc_GSEs,element[1])
  } else if(element[2] == "lnc") {
    lnc_GSEs <- append(lnc_GSEs,element[1])
  } else {
    unknown_GSEs <- append(unknown_GSEs,element[1])
  }
}

sc_df <- data.frame(sc_GSEs)
lnc_df <- data.frame(lnc_GSEs)
unknown_df <- data.frame(unknown_GSEs)

# Write Tables

write_delim(x = sc_df, 
            file = "single_cell_GSEs.txt",
            col_names = TRUE
            )
write_delim(x = lnc_df,
            file = "lnc_GSEs.txt",
            col_names = TRUE
)
write_delim(x = unknown_df,
            file = "unknown_GSEs.txt",
            col_names = TRUE
)

# 
# GEO <- "GSE116470"
# sc_geo <- read_html(paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
#                            GEO))
# 
# td_html <- sc_geo %>%
#   html_elements(c("td"))%>%
#   html_text()
# 
# GSMs <-  str_extract(td_html, "GSM.*")
# 
# 
# GSMs1 <- GSMs[!is.na(GSMs)]
# GSMs1
# 
# GSMs3 <- td_html [!is.na(str_extract(td_html, "GSM.*"))]
# GSMs3
# 
# if (length(GSMs1) <= 50) {
#   sample_size <- 1
# } else if (100 >= length(GSMs1) & length(GSMs1) > 50 ) {
#     sample_size <- 2
# } else if (length(GSMs1) > 100) {
#       sample_size <- 3
# }
#   
# 
# GSM_samples <- sample(GSMs1, size = sample_size)
# 
# 
# 


