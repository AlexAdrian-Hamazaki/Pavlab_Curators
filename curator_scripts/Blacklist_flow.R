### Usage ----> Download the backlist sheet from Google Sheets and name it as 'Blacklist.csv'
###       ----> Put it in the same folder as this script

### ----------------- Install necessary packages in not installed -------------- ###
list.of.packages <- c("tidyverse", "dplyr", "data.table", "gemmaAPI", "getPass", "rentrez", "googlesheets4")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
## Import packages
library(tidyverse)
library(dplyr)
library(data.table)
library(googlesheets4)

## Read From sheet name Platform/Experiment Blacklist Form
raw_list <- read_sheet("https://docs.google.com/spreadsheets/d/17xm2eFFqhhT-M6-jTC_lsar7RMgk8Ln-TwQPDWlRfIY/edit?ts=5744cba9#gid=1202292448",
                       sheet = "Platform/Experiment Blacklist Form")

## Reanme Columns accordingly
raw_list <- raw_list %>%
  rename(Accession=1, Reason=2, Name=3)
raw_list <- raw_list %>%
  select(c(1,2,3))

## Using pubmed api
library(rentrez)
### ****Note speed can be substanitally optimized using by creating a query list, and use "anti_join"
### function for extracting title using a GSE
extract_gse <- function(gses) {
  sapply(gses, function(gse){
    if(!is.null(gse)){
      if (grepl("\\.", gse)){
        gse <- gsub("\\..*","",gse)
      }
      print(gse)
      term <- entrez_search(db='gds', term=paste(gse,"[ACCN]"), retmax=1)
      sum <- entrez_summary(db='gds', id=term$ids)
      return (sum$title)
    }else{
      print(gse)
      return("") 
    }
  })
}

### Adding titles to each GSEs
raw_list <- raw_list %>%
  mutate(Name=extract_gse(raw_list$Accession))

 ## more conditions can be added here using regex match pattern ##
  taxon<- ".*(species|taxons?|animal).*"
  dye_swap <- ".*(dye|swap|dye swap|dye-swap|two colou?r|two-colou?r).*"
  plat_form <- ".*(platform|plat|form|unusable|unsupported).*"
  to_be_deleted <- ".*(delet(ed)*|mark(ed)?).*"
  pipe_line_problem <- ".*(stop|rna-?seq|(pipe(line)?)|corrupted|line).*"
  quality <- "(data)? ?quality|unusable|poor"
  zscore <- ".*((z( )?score)|z-?score|score).*"
  single_cell <- ".*((single(-)?|( )?cell)|sc).*"
  duplicate <- ".*(duplicate|dup|in another).*"
  long_rna<- ".*(long|lnc(rna)?).*"
  not_relevant <- "interest|relevant"
  unavilable <- ".*(unavailable|available|supplements).*"
  small_size <- "sample|size|sample size"
  should_not_blackist <- ".*(replicate|one|n ?= ?1|condition).*"
  
  ## The actual output text for each category ##
  text_taxon <- "Unsupported Taxon"
  text_dye_swap <- "Unsupported Design; Dye-Swap"
  text_platform <- "Platform issue. Unsupported Platform/unusable platform"
  text_pipeline <- "Pipeline problem full stop as indicated on the master sheet"
  text_quality <- "Poor data quality associated with this experiment or unable to find data associated with experiment or unusable data"
  text_zscore <- "Zscore used as values, unsupported unit"
  text_single_cell <- "Single cell Experiment"
  text_duplicate <- "Duplicated experiment, samples already in other GSE"
  text_long_rna <- "Long non-coding RNA Experiment"
  text_unavilable <- "Insufficent available information in paper/GEO"
  text_not_relevant <- "This experiment is not relevant to our interest"
  text_to_be_deleted <- "Flagged as to be deleted. More information needed"
  text_small_size <- "Sample size too small. Usually experiments with total samples < 3"
  text_should_not_blacklist <- "This experiment probably shoudn't be on the balcklist. Double check what cateogry, or add a category"
  text_no_match <- "No match for this reason. Check Google Sheet for the correct word to use. Or if applicable, add a new category"
  
  
  regex_check <- function(x) {
    #---AAA What is x?
    ## ----------------------- actual matching function -------------------- ##
    ## More conditions can be added using the same ifelse format
    ifelse(grepl(taxon, tolower(x)),
           text_taxon,
           ifelse(
             grepl(dye_swap, tolower(x)),
             text_dye_swap,
             ifelse(
               grepl(plat_form, tolower(x)),
               text_platform,
               ifelse(
                 grepl(to_be_deleted, tolower(x)),
                 text_to_be_deleted,
                 ifelse(
                   grepl(pipe_line_problem, tolower(x)),
                   text_pipeline,
                   ifelse(
                     grepl(quality, tolower(x)),
                     text_quality,
                     ifelse(
                       grepl(zscore, tolower(x)),
                       text_zscore,
                       ifelse(
                         grepl(single_cell, tolower(x)),
                         text_single_cell,
                         ifelse(
                           grepl(duplicate, tolower(x)),
                           text_duplicate,
                           ifelse(
                             grepl(long_rna, tolower(x)),
                             text_long_rna,
                             ifelse(
                               grepl(not_relevant, tolower(x)),
                               text_not_relevant,
                               ifelse(
                                 grepl(unavilable, tolower(x)),
                                 text_unavilable,
                                 ifelse(
                                   grepl(small_size, tolower(x)),
                                   text_small_size,
                                   ifelse(
                                     grepl(should_not_blackist, tolower(x)),
                                     text_should_not_blacklist,
                                     text_no_match
                                   )
                                 )
                               )
                             )
                           )
                         )
                       )
                     )
                   )
                 )
               )
             )
           )
    )
           }
  
  
### Create a new column that has all the standardized reasons
processed_list <- raw_list %>% 
  mutate(processed_reason=regex_check(Reason))

### Create a list of reasons that "potentially should not be blasklisted"
false_positives = c(text_to_be_deleted, text_should_not_blacklist, text_no_match)

full_list <- processed_list

double_check_list <- processed_list %>% 
  filter(processed_reason  %in% false_positives)

good_list <- processed_list %>% 
  filter(!processed_reason %in% false_positives)

# library(getPass)
# library(gemmaAPI)
# logged_in = FALSE
# while (!logged_in) {
#   if ((Sys.getenv('GEMMAUSERNAME') == "" ||
#        Sys.getenv('GEMMAPASSWORD') == "")) {
#     print(
#       "You currently do not have Gemma authentication in the enviroment. Setting your usename and password now\n"
#     )
#     user = trimws(readline(prompt = 'Please input your username here: '))
#     pass = trimws(getPass(msg = "Enter your password here: "))
#   }
#   else {
#     print(
#       "Credntials entred previously are detected. Trying to login with given information...."
#     )
#     user = Sys.getenv('GEMMAUSERNAME')
#     pass = Sys.getenv('GEMMAPASSWORD')
#   }
#   tryCatch({
#     setGemmaUser(user,pass)
#     datasetInfo('1')
#     print("Sucesfully logged in!")
#     logged_in = TRUE
#   },
#   error = function(e) {
#     print("Could not login, possibly problem with username and password. Try again")
#     Sys.unsetenv('GEMMAUSERNAME')
#     Sys.unsetenv('GEMMAPASSWORD')
#   })
# }





library(readr)
###---AAA I belive you could use https://googlesheets4.tidyverse.org/ also to write str8 to the sheet. Not necessary, but could be cool/nice 
write_csv(full_list, 'full_list.csv')
write_csv(double_check_list, 'double_check_list.csv')
write_csv(good_list, 'blacklist_list.csv')
###---AAA could name good_list to something more explicetly indicating that they should be blacklisted






