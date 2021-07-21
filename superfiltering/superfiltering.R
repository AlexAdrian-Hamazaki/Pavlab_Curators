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


identify_subseries <- function(gse, char_input_gses) {
  # Identify the GSEs that are superseries, if they are superseries, 
  # the identify if it's subseries are also in the input file. If they are,
  # then point out those gse's as being the correct subseries to add
  
  #@Params
  #gse: a GSEid
  #char_input_gses: a character vector containing the total input of GSEids that you are searching
  
  
  tryCatch(
    {

  stopifnot(is.character(char_input_gses))
  stopifnot(is.character(gse))
  

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
    # Extract the GSEids of the subseries GSEs. Delete non-dinstict GSEs
    subseries <- gse_html[!is.na(str_extract(gse_html, "GSE[:digit:]+$"))]
    subseries <- str_extract(subseries, "GSE[:digit:]+$")
    subseries <- data.frame(subseries,
                            stringsAsFactors = FALSE)
    subseries <- distinct(subseries[1])
    
    # Remove the Superseries GSEid if it was parsed
    subseries <- filter(subseries, subseries != gse)
    
    # If the subseries GSEids are present in the l_input_GSEs, then
    # we know that the subseries is what should be put into gemma, and not 
    # the superseries. If the subseries GSEids are not in l_input_GSEs, then
    # we will print out a warning message here, as theyw ill warrent further
    # investigation
    
    boulion_sub_in_input <- subseries[[1]] %in% char_input_gses
    
    subseries <- subseries[[1]] [ boulion_sub_in_input ]
    

    # if subseries is empty, then none of the subseries GSEs were scraped in the
    # input file. This case returns a DF where the first column is the superseries
    # and the second has a string message
    if (is_empty(subseries)) {
      subseries <- "No Subseries Scraped"
      message(paste("\n In"
                    , gse, 
                    ": \n no subseries GSEs were also identified in the input file \n")) 
      
      df_sub_super <- data.frame("Superseries" = gse,
                                 "Subseries_hits" = subseries,
                                 stringsAsFactors = FALSE)
      return (df_sub_super)
      
      # If there were subseries found to match our input. then 
      # Output our results as a data frame where the first column is the
      # superseries GSE and the second is a vector containing the subseries that
      # were positive hits in the input
    } else if (!is_empty(subseries)) {  
            message(paste("\n In",
                          gse, 
                  ": \n" , subseries, "has been identified as a subseries that was also in the initial input scrape \n"))
      df_sub_super <- data.frame("Superseries" = gse,
                                 "Subseries_hits" = subseries,
                                 stringsAsFactors = FALSE)
      return( df_sub_super )
      
    } else {
      warning("Unknown error is happening with", gse)
      df_sub_super <- data.frame("Superseries" = gse,
                                 "Subseries_hits" = "ERROR",
                                 stringsAsFactors = FALSE)
      return(df_sub_super)
      }
    
  } else {
    message(paste(gse, "is not superseries"))
    df_sub_super <- data.frame("Superseries" = gse,
                               "Subseries_hits" = "Not_Superseries",
                               stringsAsFactors = FALSE)
  }},
  error = function(cond) {
    browser()
  }
  )
}

## Read From sheet name SubSuperFiltered on google sheets. Change the link and name of sheet accordingly
df_raw_input <- read_sheet("https://docs.google.com/spreadsheets/d/15w03FK5pzr19yqReWLV_Kai5w0740N91RyNbjDscziY/edit#gid=287890379",
                           sheet = "SubSuperFiltered")

#identify which column has your GSEs in it and make it your workable list
char_gse_inputs <- df_raw_input$x

# generate a list containing data frames
l_sub_super <- lapply(char_gse_inputs,
                      identify_subseries,
                      char_gse_inputs)

# Turn that list of data frames into a single dataframe

tryCatch(
  {

bind_list <- function(df) {
  r <-  1:nrow(df)
  output_table <- do.call(rbind, list(df[r,]))
  return(output_table)
}

df_sub_super <- do.call(rbind, lapply(l_sub_super, bind_list))

  }, 
error = function(cond) {
  browser()
}
)



# Get the GSEs that are superseries
# and get the GSEs that are subseries, or arn't a part of the super/subseries type

#not_super is all of the GSEs that are superseries,
# but they are also GSES that might not be a part of the super/subseries
# data structure. They could just be non-subsuper experiments
not_super <- filter(df_sub_super,
                    Subseries_hits == "Not_Superseries")

superseries <- df_sub_super %>%
  filter(Subseries_hits != "Not_Superseries") %>%
  distinct(Superseries)


# Get the negative and positives hits
# Positive hits had subseries GSEs also in the input

nsuperseries <- df_sub_super %>%
  filter(Subseries_hits != "Not_Superseries") %>%
  distinct()

negative_hits <- filter(df_sub_super,
                        Subseries_hits == "No Subseries Scraped")
positive_hits <- filter(df_sub_super,
                        Subseries_hits != "No Subseries Scraped" &
                          Subseries_hits != "Not_Superseries" &
                          Subseries_hits != "ERROR")


# Write files
 

# Write the entire table
write_delim( x = (df_sub_super),
             file = "master_table.tsv",
             delim = "\t",
             col_names = TRUE)

# write all superseries
write_delim( x = superseries,
             file = "all_superseries.tsv",
             delim = "\t",
             col_names = TRUE)

#write all non-superseries
write_delim( x = not_super ,
             file = "all_non_superseries.tsv",
             delim = "\t",
             col_names = TRUE)

#write negative hits as 1 column
write_delim( x = (negative_hits[1]),
             file = "negative_hits.tsv",
             col_names = TRUE)

#write positive hits as table column
#It might be usefull to see which subseries are under which superseries
write_delim( x = (positive_hits),
             file = "table_positive_hits.tsv",
             delim = "\t",
             col_names = TRUE)

#write positive hits but with only the subseries GSEs
write_delim( x = (positive_hits[2]),
             file = "table_positive_hits.tsv",
             delim = "\t",
             col_names = TRUE)



