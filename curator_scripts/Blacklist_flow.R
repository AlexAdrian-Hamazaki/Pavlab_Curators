### Usage ----> Download the backlist sheet from Google Sheets and name it as 'Blacklist.csv'
###       ----> Put it in the same folder as this script

### ----------------- Install necessary packages in not installed -------------- ###
list.of.packages <- c("tidyverse", "dplyr", "data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)

## Import packages
library(tidyverse)
library(dplyr)
library(data.table)

#import df
raw_list <- fread('BlackList.csv', header = TRUE, quote = "\"", sep=',')

 ## more conditions can be added here using regex match pattern ##
  taxon<- ".*(species|taxons?|animal).*"
  dye_swap <- ".*(dye|swap|dye swap|dye-swap|two colou?r|two-colou?r).*"
  plat_form <- ".*(platform|plat|form|unusable|unsupported).*"
  to_be_deleted <- ".*(delet(ed)*|mark(ed)?).*"
  pipe_line_problem <- ".*(stop|rna-?seq|(pipe(line)?)|corrupted|line).*"
  zscore <- ".*((z( )?score)|z-?score|score).*"
  single_cell <- ".*((single(-)?|( )?cell)|sc).*"
  duplicate <- ".*(duplicate|dup|in another).*"
  long_rna<- ".*(long|lnc(rna)?).*"
  unavilable <- ".*(unavailable|available|supplements).*"
  should_not_blackist <- ".*(sample size|size|too samll|replicate|one|n ?= ?1|sample).*"
  
  ## The actual output text for each category ##
  text_taxon <- "Unsupported Taxon"
  text_dye_swap <- "Unsupported Design; Dye-Swap"
  text_platform <- "Platform issue"
  text_to_be_deleted <- "Flagged as to be deleted. More information needed"
  text_pipeline <- "Pipeline problem/Data unusable"
  text_zscore <- "Zscore used as values"
  text_single_cell <- "Single cell Experiment"
  text_duplicate <- "Duplicated experiment, samples already in other GSE"
  text_long_rna <- "Long non-coding RNA Experiment"
  text_unavilable <- "Insufficent available information in paper/GEO"
  text_should_not_blacklist <- "This experiment probably shoudn't be on the balcklist. Double check what cateogry, or add a category"
  text_no_match <- "No match for this reason. Check Google Sheet for the correct word to use. Or if applicable, add a new category"
  
  
regex_check <- function(x){
  ## ----------------------- actual matching function -------------------- ##
  ## More conditions can be added using the same ifelse format
  ifelse(grepl(taxon, tolower(x)),text_taxon,
    ifelse(grepl(dye_swap,tolower(x)), text_dye_swap,
           ifelse(grepl(plat_form,tolower(x)), text_platform,
                  ifelse(grepl(to_be_deleted,tolower(x)), text_to_be_deleted,
                         ifelse(grepl(pipe_line_problem,tolower(x)), text_pipeline,
                                ifelse(grepl(zscore,tolower(x)), text_zscore,
                                       ifelse(grepl(single_cell,tolower(x)), text_single_cell,
                                              ifelse(grepl(duplicate,tolower(x)), text_duplicate,
                                                     ifelse(grepl(long_rna,tolower(x)), text_long_rna,
                                                            ifelse(grepl(unavilable,tolower(x)), text_unavilable,
                                                                   ifelse(grepl(should_not_blackist,tolower(x)), text_should_not_blacklist,
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
}
  
### Create a new column that has all the standardized reasons
processed_list <- raw_list %>% mutate(processed_reason=regex_check(Reason))

### Create a list of reasons that "potentially should not be blasklisted"
false_positives = c(text_to_be_deleted, text_should_not_blacklist, text_no_match)

full_list <- processed_list

double_check_list <- processed_list %>% filter(processed_reason  %in% false_positives)

good_list <- processed_list %>% filter(!processed_reason %in% false_positives)

write_csv(full_list, 'full_list.csv')
write_csv(double_check_list, 'double_check_list.csv')
write_csv(good_list, 'good_list.csv')








