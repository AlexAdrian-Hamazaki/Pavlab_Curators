### Usage ----> Download the backlist sheet from Google Sheets and name it as 'Blacklist.csv'
###       ----> Put it in the same folder as this script

### ----------------- Install necessary packages in not installed -------------- ###
list.of.packages <- c("tidyverse", "dplyr", "data.table", "gemmaAPI", "getPass", "rentrez", "googlesheets4", "multidplyr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
## Import packages
library(tidyverse)
library(dplyr)
library(data.table)
library(googlesheets4)
try <- 0
tries <- 20
while (TRUE && try < tries){
  tryCatch({
    x <- dirname(getActiveDocumentContext()$path)
    setwd(x)
    break
  }, error=function(x){
    print("cannot set directory try again")
    try <- try + 1
    next
  })
}

##***************Change the variables here************************
url_to_sheet = "https://docs.google.com/spreadsheets/d/17xm2eFFqhhT-M6-jTC_lsar7RMgk8Ln-TwQPDWlRfIY/edit?ts=5744cba9#gid=1202292448"
sheet_name ="Platform/Experiment Blacklist Form"
##****************************************************************


## Read From sheet name Platform/Experiment Blacklist Form
raw_list <- read_sheet(url_to_sheet,
                       sheet = sheet_name)


## Reanme Columns accordingly
raw_list <- raw_list %>%
  rename("#Accession"=1, Reason=2)
raw_list <- raw_list %>%
  select(c(1,2))

## Using pubmed api
library(rentrez)
### ****Note speed can be substanitally optimized using by creating a query list, and use "anti_join"
### function for extracting title using a GSE
extract_gse <- function(gses) {
  sapply(gses, function(gse){
    try <- 0
    while (TRUE && try < tries){
    tryCatch({
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
    }}, 
    error=function(x){
      print("Cannot retrive GSE. Try again")
      try <- try + 1
      next
    })}
    }
  )
}


### Adding titles to each GSEs
raw_list <- raw_list %>%
  mutate(Name=extract_gse(raw_list$`#Accession`))

### Clean duplicates
raw_list <- raw_list[!duplicated(raw_list[,1]),]

 ## more conditions can be added here using regex match pattern ##
  taxon<- ".*(species|taxons?|animal).*"
  dye_swap <- ".*(dye|swap|dye swap|dye-swap|two colou?r|two-colou?r).*"
  plat_form <- ".*(platform|plat|form|unusable|unsupported).*"
  to_be_deleted <- ".*(delet(ed)*|mark(ed)?).*"
  pipe_line_problem <- ".*(stop|rna-?seq|(pipe(line)?)|corrupted|line).*"
  #unusable <- "(data)? ?quality|unusable|poor"
  zscore <- ".*((z( )?score)|z-?score|score).*"
  single_cell <- ".*((single(-)?|( )?cell)|sc).*"
  long_rna<- ".*(long|lnc(rna)?).*"
  #unavilable <- ".*(unavailable|available|supplements).*"
  nano_string <- ".nano|nano string|string."
  should_not_blackist <- ".*(replicate|one|n ?= ?1|condition).*"
  mirna <- "mirna|micro|mi"
  ion_torrent <- "ion|torrent|iontorrent"
  promethian <- "promethian"
  abplatform <- "abplatform|abp"
  bad_library <- "badlibrarystrategy|library|bad|strategy"
  pacbio <- "pac|bio"
  nimble_gen <- "nimble|gen"
  seqeunces <- "sequence|seq"
    
  ## The actual output text for each category ##
  text_taxon <- "Unsupported taxon"
  text_dye_swap <- "Unsupported design: Dye-swap"
  text_platform <- "Unsupported platform"
  text_pipeline <- "Raw RNA-seq read data unavailable/unusable"
  text_unusable <- "Unable to retrieve data from GEO"
  text_zscore <- "Unsupported quantitation type"
  text_single_cell <- "Unsupported experiment type: Single cell"
  text_long_rna <- "Unsupported experiment type: Long non-coding RNA"
  text_unavilable <- "Insufficent available information in paper/GEO"
  text_mirna <- "Unsupported experiment type: micro RNA"
  text_to_be_deleted <- "Flagged as to be deleted. More information needed"
  text_nano_string <- "Unsupported experiment type: NanoString"
  text_should_not_blacklist <- "This experiment probably shoudn't be on the balcklist. Double check what cateogry, or add a category"
  text_no_match <- "No match for this reason. Check Google Sheet for the correct word to use. Or if applicable, add a new category"
  
  ## Platform version of text
  text_plat_mirna <- "Unsupported platform type: micro RNA"
  text_plat_nano <- "Unsupported platform type: NanoString"
  text_plat_long_rna <- "Unsupported platform type: Long non-coding RNA"
  text_plat_ion_torrent <- "Unsupported platform type: IonTorrent"
  text_plat_promethian<- "Unsupported platform type: Promethian"
  text_plat_abplatform<- "Unsupported platform type: ABPlatform"
  text_plat_pacbio<- "Unsupported platform type: PacBio"
  text_plat_badlibrarystrat<- "Unsupported platform type: BadLibraryStrategy"
  text_plat_seq <- "Probe sequences not available"
  text_plat_nimble <- "Unsupported platform type: Nimble Gen"
 
  ## platform text

  regex_check <- function(x, y) {
    #---AAA What is x?
    ## ----------------------- actual matching function -------------------- ##
    ## More conditions can be added using the same ifelse format
    ifelse(grepl("^gse", tolower(y)),
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
                       grepl(zscore, tolower(x)),
                       text_zscore,
                       ifelse(
                         grepl(single_cell, tolower(x)),
                         text_single_cell,
                         ifelse(
                           grepl(long_rna, tolower(x)),
                           text_long_rna,
                           ifelse(
                             grepl(nano_string, tolower(x)),
                             text_nano_string,
                           ifelse(
                           grepl(mirna, tolower(x)),
                           text_mirna,
                               ifelse(
                                 grepl(should_not_blackist, tolower(x)),
                                 text_should_not_blacklist,
                                 text_no_match),
                           ifelse(
                             grepl("^gpl", tolower(y)),
                             ifelse(
                               grepl(mirna, tolower(x)),
                               text_plat_mirna,
                               ifelse(
                                 grepl(nano_string, tolower(x)),
                                 text_plat_nano,
                                 ifelse(
                                   grepl(long_rna, tolower(x)),
                                   text_plat_long_rna,
                                   ifelse(
                                     grepl(ion_torrent, tolower(x)),
                                     text_plat_ion_torrent,
                                     ifelse(
                                       grepl(abplatform, tolower(x)),
                                       text_plat_abplatform,
                                       ifelse(
                                         grepl(promethian, tolower(x)),
                                         text_plat_promethian,
                                         ifelse(
                                           grepl(pacbio, tolower(x)),
                                           text_plat_pacbio,
                                           ifelse(
                                             grepl(bad_library, tolower(x)),
                                             text_plat_badlibrarystrat,
                                             ifelse(
                                               grepl(seqeunces, tolower(x)),
                                               text_plat_seq,
                                               ifelse(
                                                 grepl(nimble_gen, tolower(x)),
                                                 text_plat_nimble,
                                               text_no_match),
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
                       )
                     )
                   )
                 )
             )
             )
    )
  }
  
### Check if it's GSE or GPL
  #processed_list <- raw_list %>% mutate(type = ifelse(grepl("^gp|",tolower(`#Accession`)), "Plat"), ifelse(grepl("^gse",tolower(`#Accession`)), "Exp", "Incorrect"))
  
### Create a new column that has all the standardized reasons
processed_list <- raw_list %>% 
  mutate(processed_reason=regex_check(Reason, `#Accession`))

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


good_list <- good_list %>% select(1,4,3)

library(readr)
write_tsv(full_list, 'full_list.tsv')
write_tsv(double_check_list, 'double_check_list.tsv')
write_tsv(good_list, 'blacklist_list.tsv')






