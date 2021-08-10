
packages <- c(
  "tidyverse",
  "data.table",
  "rstudioapi",
  "rvest",
  "stringr",
  "assertthat",
  "googlesheets4")

new_packages <- setdiff(packages, installed.packages()[,"Package"])
install.packages(new_packages)

#--- 
library(parallel)
library(rvest)
library(stringr)
library(assertthat)
library(tidyverse)
library(rstudioapi)
library(googlesheets4)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
##**************************************************************** Change variables here
url_to_sheet = "https://docs.google.com/spreadsheets/d/1oXA9sNimUvsdR5k6DcTC4oD-BZGu8P1GLECCqWVcgEo/edit#gid=805085132"
sheet_name ="NonSuperFiltered"
##****************************************************************

## Read From sheet name SubSuperFiltered on google sheets. Change the link and name of sheet accordingly
raw_sheet <- read_sheet(url_to_sheet,
                       sheet = sheet_name)

clean_GSE_ids <- raw_sheet[,1]





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
      library(rvest)
      breakpoint = 0
      html_download <- read_html(paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=",
                                        GSE_id))
      td_html <- html_download %>%
        html_nodes("td") %>% 
        html_text()
      breakpoint = 1
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
      breakpoint = 2
      # If we cannot find any information in the GEO page, try to look at GSM page(s)
      # for sc or lnc information
      
      #GSMs is a double containing all of the GSMs in the GEO page
      GSMs <- td_html[!is.na(str_extract(td_html, "GSM[:digit:]+$"))]
      breakpoint = 3
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
      breakpoint = 4 
      #Take a sample of GSMs
      
      GSM_samples <- sample(GSMs, sample_size)
      
      GSM_test <- lapply(GSM_samples, parse_GSM)
      breakpoint = 5
      for (element in GSM_test) {
        if (element[1] == TRUE) {
          return (c(GSE_id, element[2]))
        }
      }
      
      return (c(GSE_id, "Unknown"))
      
    }, 
    error = function(cond) {
      message(paste(cond, "at", GSE_id))
      return (breakpoint)
    })
}

# Generate a list that lets you know if a GSE is sc or lnc or unknown

# complete_list_mt <- mclapply(unlist(clean_GSE_ids), parse_GSE)
# 
# test_func_mt <- function(GSEid){
#   tryCatch({
#   html_download <- read_html("https://stackoverflow.com/")
#   html_download2 <- read_html("https://stackoverflow.com/")
#   td_html <- html_download %>%
#     html_text()
#   },
#   error=function(cond){
#     return (1212)
#   })
#   return (html_download)
# }
# 
# test_result_mt <- mclapply(1:100, test_func_mt)

complete_list <- lapply(unlist(clean_GSE_ids), parse_GSE)
# Seperate the GSEs into different dataframes
# based on if they are sc lnc or umknown


platform_frame <- data.frame(Accessions=character(), PlatformType=character())
for (element in complete_list) {
  if (element[2] == "sc") {
    platform_frame <- platform_frame %>% add_row(Accessions=element[1], PlatformType="sc")
  } else if(element[2] == "lnc") {
    platform_frame <- platform_frame %>% add_row(Accessions=element[1], PlatformType="lnc")
  } else {
    platform_frame <- platform_frame %>% add_row(Accessions=element[1], PlatformType="Unknown")
  }
}

merge_frame <- inner_join(raw_sheet, platform_frame, by="Accessions")

write_sheet(merge_frame, url_to_sheet, sheet_name)





