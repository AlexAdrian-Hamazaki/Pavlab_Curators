#
#Purpose : Filter experiments that are complete. If an experiment is Public,and is untroubled and we say it is complete. Outputs a GSE of experiments that
#are complete, and GSEs that are NOT complete
#However, there are some special types of experiments, such as sample studies, that don't have designs. If an experiment has a sample study tag, then it is counted as complete even if it does not have a DEA
#Furthermore, it is commonplace to push through experiments that do not have DEA-usable data, but are still propper. So overall, DEA's are not neccesary for our definition of complete


#---------------------------
library(tidyverse)

#----------If 01_get_gemma_API rds object if it exists, if it does note xist then generate it and open it.
if (file.exists(paste0(results_dir,"/","API_output"))) { 
  print('It looks like API information has already been retrieved, opening it up now...') 
  API_output <- readRDS(paste0(results_dir,"/","API_output"))
} else {print("It looks like there is no API information, running 01_get_API_output to try again...")
  source("01_get_API_output.R")
  API_output <- readRDS(paste0(results_dir,"/","API_output"))
}


#---------------------get smaller API table
api_output_compressed <- API_output %>%
  select(shortName, isPublic, diff, needsAttention)


#------------------get public experiments and private experiments


public_gses <- api_output_compressed %>%
  filter(api_output_compressed$isPublic == TRUE)

private_gses <- api_output_compressed %>%
  filter(api_output_compressed$isPublic == FALSE)



#-----------------get experiments that have diff vs those that dont have diff

no_diff_gses <- api_output_compressed %>%
  filter(api_output_compressed$diff == "NO DIFF")

diff_gses <-  api_output_compressed %>%
  filter(!(api_output_compressed$diff == "NO DIFF"))

#---------------gses that are completed: they have diff, are public, and do not "need attention"

completed_gses <- filter(public_gses, needsAttention == FALSE)

#---------------geses that are not completed:

non_complete_gses <- api_output_compressed %>%
  filter(!(api_output_compressed$shortName %in% completed_gses$shortName))


#-------------create directory

#create directory if it doesnt exist yet

if (!dir.exists(paste0(results_dir,"/","completion_filter"))) {
  dir.create(paste0(results_dir,"/","completion_filter"))
}

#-----------write files

write_delim(data.frame(public_gses$shortName), file = paste0(results_dir,"/","completion_filter/","public_gses.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(private_gses$shortName), file = paste0(results_dir,"/","completion_filter/","private_gses.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(no_diff_gses$shortName), file = paste0(results_dir,"/","completion_filter/","no_diff_gses.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(diff_gses$shortName), file = paste0(results_dir,"/","completion_filter/","diff_gses.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(completed_gses$shortName), file = paste0(results_dir,"/","completion_filter","/","completed_gses.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(non_complete_gses$shortName), file = paste0(results_dir,"/","completion_filter","/","non_complete_gses.txt"), delim = "\n", col_names = FALSE)
