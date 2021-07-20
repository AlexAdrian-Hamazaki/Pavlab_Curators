list.of.packages <- c("tidyverse", "dplyr", "data.table", "rentrez", "googlesheets4", "rstudioapi")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

library(tidyverse)
library(dplyr)
library(data.table)
library(googlesheets4)
library(rvest)
library(rstudioapi)
x <- dirname(getActiveDocumentContext()$path)
setwd(x)
##***************Change the variables here************************
url_to_sheet = "https://docs.google.com/spreadsheets/d/1oXA9sNimUvsdR5k6DcTC4oD-BZGu8P1GLECCqWVcgEo/edit#gid=805085132"
sheet_name ="SubOnly"
##****************************************************************

## Read From sheet name SubSuperFiltered on google sheets. Change the link and name of sheet accordingly
raw_list <- read_sheet(url_to_sheet,
                       sheet = sheet_name)

library(rentrez)
library(stringr)
new_vector <- c()
## Function that checks if a GSE is superseries. If it is we will fetch all it's subseries
get_sub <- function(gses){
  sapply(gses, function(gse){
    tryCatch(
      {
    super <- entrez_search(db="gds", term=paste(gse,"[ACCN]"), retmax=1)
    super_sum <- entrez_summary("gds", id =super$ids)
    if (grepl(" SuperSeries ", super_sum$summary)){
      url <- paste0("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=", gse)
      raw <- read_html(url)
      text <- raw %>% html_text()
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
    }},
    error=function(e) {
      return ("There is a problem")
    }
  )})
}



## Outputs two list:
## sub_only.csv ouputs a list of GSEs that are either (1) Subseries GSE in the original sheet (2) Subseries of the superies that were in the orignal sheet
## super+sub.csv is a csv file that added a subseries column which has all the subseries of a superseries
new_list <- raw_list %>% mutate(subseries=get_sub(.[[1]]))

sub_frame <- data.frame(Accessions=character(), Species=character(), Sample_Size=integer(), Title=character(), Platforms=character(), 
                        Num_of_Platforms=integer(), Status=character())

for (gse in unlist(new_vector)) {
  tryCatch({
  search = entrez_search(db="gds", term=paste(gse,"[ACCN]"), retmax=1)
  search_sum <- entrez_summary("gds", id =search$ids)
  plats = unlist(strsplit(search_sum$gpl, ";"))
  platforms = ""
  print(paste0("Processing ", gse))
  
  
  for (plat in plats) {
    plat_search = entrez_search(db="gds", term=paste0("GPL", plat,"[ACCN] AND gpl[FILT]"))
    plat_search_sum = entrez_summary("gds", id = plat_search$ids)
    multiple_plat_sum = extract_from_esummary(plat_search_sum, "gpl")
    if (is.null(names(multiple_plat_sum))){
      right_plat_sum <- plat_search_sum
    }else{
      correct_plat_id <- names(multiple_plat_sum)[multiple_plat_sum==plat]
      right_plat_sum <- entrez_summary("gds", id = correct_plat_id)
    }
    print(paste0("Fetching platforms for ", "GPL", plat))
    if (platforms != "") {
      platforms <- paste0(platforms, ", ", plat, " ", right_plat_sum$title)
    }else {
      platforms <- paste0(plat, " ",  right_plat_sum$title, " ")
    }
    print(paste0("Done platforms"))
  }
  sub_frame <- sub_frame %>% add_row(Accessions=gse, Species= search_sum$taxon, Sample_Size=search_sum$n_samples, Title=search_sum$title, 
                        Platforms=platforms, Num_of_Platforms=length(plats))
  print(paste0("Adding row "))
  print("____________________________________________")
  },
  error=function(cond){
    sub_frame <- sub_frame %>% add_row(Accessions=gse, Species=NULL, Sample_Size=search_sum$NULL, Title=NULL, 
                                       Platforms=NULL, Num_of_Platforms=NULL)
  })
}


out_put_list <- data.frame(lapply(new_list, as.character), stringsAsFactors=FALSE)
write.csv(sub_frame, "sub_only.csv", row.names=FALSE)
write.csv(out_put_list, "super+sub.csv", row.names=FALSE)


