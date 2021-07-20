list.of.packages <- c("tidyverse",
                      "dplyr",
                      "data.table",
                      "rentrez",
                      "googlesheets4",
                      "rstudioapi")

new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(tidyverse)
library(dplyr)
library(data.table)
library(googlesheets4)
library(rvest)
library(rstudioapi)
library(rentrez)
library(stringr)

x <- dirname(getActiveDocumentContext()$path)
setwd(x)

## Read From sheet name SubSuperFiltered on google sheets. Change the link and name of sheet accordingly
raw_list <- read_sheet("https://docs.google.com/spreadsheets/d/15w03FK5pzr19yqReWLV_Kai5w0740N91RyNbjDscziY/edit#gid=287890379",
                       sheet = "SubSuperFiltered")

new_vector <- c()
## Function that checks if a GSE is superseries. If it is we will fetch all it's subseries
get_sub <- function(gses){
  
  sapply(gses, function(gse){
    
    # First use the entrez_search API to check the if the GSE is a supseries
    super <- entrez_search(db="gds", term=paste(gse,"[ACCN]"), retmax=1)
    super_sum <- entrez_summary("gds", id =super$ids)
    
    # If GSE is a supseries, download the HTML. Search for "td" nodes
    if (grepl(" SuperSeries ", super_sum$summary)){
      message(paste(gse, "is a Superseries. Checking for its subseries..."))
      url <- paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=", gse)
      gse_html <- read_html(url) %>%
        html_nodes("td") %>%
        html_text()
      browser()qqqqqqq
      subseries
      GSEs <- str_extract_all(text, '\\bGSE\\d+')
      GSEs <- strsplit(GSEs[[1]], " ")
      GSEs <- unique(GSEs)
      subs <- setdiff(GSEs, gse)
      new_vector <<- c(new_vector, subs)
      print(new_vector)
      return (unlist(subs))
    }else {
      new_vector <<- c(new_vector,gse)
      print(new_vector)
      return ("This is a subseries")
    }
  })
}

## Outputs two list:
## sub_only.csv ouputs a list of GSEs that are either (1) Subseries GSE in the original sheet (2) Subseries of the superies that were in the orignal sheet
## super+sub.csv is a csv file that added a subseries column which has all the subseries of a superseries
new_list <- raw_list %>% mutate(subseries=get_sub(.[[1]]))
list_of_gse <- data.frame(GSEs=unlist(new_vector))
out_put_list <- data.frame(lapply(new_list, as.character), stringsAsFactors=FALSE)
write.csv(list_of_gse, "sub_only.csv", row.names=FALSE)
write.csv(out_put_list, "super+sub.csv", row.names=FALSE)


