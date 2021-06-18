#!/usr/bin/env Rscript
input_GSEids <- commandArgs(TRUE)[1]
username <-  commandArgs(TRUE)[2]
password <- commandArgs(TRUE)[3]
message(paste("Username Input:", username))
message(paste("Password Input:", password))

# print(interactive())
# 
# #---Asking user to double check their user information
# cat( "Please double check  your Gemma user and password, if they are correct type in \"yes\", if not, type \"no\". Please advise that this script is unable to determine if you successfully log into gemma or not. If your user and pass are incorrect, the gemma API will only return info on experiments that are public.")
# correct_gemma <- readline(con=stdin(),1)
# print(correct_gemma)
# if (correct_gemma != "yes") {
#   cat("You\'ve claimed your gemma user is incorrect, or you inputted an invalid answer, try again")
# }
# 

#---For now, the running directory and target directory are hard wired to this folder system. This is where they sohuld be if you've cloned from github
running_dir <- "~/Projects/Pavlab_Curators/filter_from_gemma_api"
target_dir <- "~/Projects/Pavlab_Curators/filter_from_gemma_api"



#---Check to see if the input GSEid file exists/ is in the right place
stopifnot(file.exists(paste0(target_dir,"/",input_GSEids)))

#---set results dir, lcoation to save files. Create results dir if it does not exist
results_dir <- paste0(target_dir,"/","results")

if (!dir.exists(paste0(results_dir))) {
  dir.create(paste0(results_dir))
}

#--- load functions
source("main/functions.R")


#---Retrieve Gemma API information for all of the GSEs
source("main/01_get_gemma_API.R")
stopifnot(file.exists(paste0(results_dir,"/API_output")))

#---Filter Gemma API for RNAseq, Microarray (one and two color) experiments. and "other" experiments

source("main/02_filter_sequence_tech.R")

#---Filter Gemma API for experiments that are in Gemma, and experiments that are not in Gemma

source("main/03_filter_in_gemma_or_not.R")

#---Filter for species

source("main/filter_by_species.R")

#---filter for complete gses and non-complete gses

source("main/filter_for_complete_GSEs.R")

#---generate summary stats

source("main/generate_summary_stats.R")

#---Use the tables to get the GSEs that need action

source('main/action_knowledge.R')

message("Script ran successfully. See your results in results/summary_statistics and results/actionable_items")
