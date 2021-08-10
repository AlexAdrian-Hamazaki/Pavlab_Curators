#!/usr/bin/env Rscript
# input_GSEids <- commandArgs(TRUE)[1]
# username <-  commandArgs(TRUE)[2]
# password <- commandArgs(TRUE)[3]
# message(paste("Username Input:", username))
# message(paste("Password Input:", password))

# 
input_GSEids <- "testers.txt"
username <-  "alexadrianhamazaki"
password <- "Doglukepotato3!"


#---For now, the running directory and target directory are hard wired to this folder system. This is where they sohuld be if you've cloned from github
running_dir <- "~/R/Gemma/Pavlab_Curators/filter_from_gemma_api"
target_dir <- "~/R/Gemma/Pavlab_Curators/filter_from_gemma_api"



#---Check to see if the input GSEid file exists/ is in the right place
stopifnot(file.exists(paste0(target_dir,"/",input_GSEids)))

#---set results dir, lcoation to save files. Create results dir if it does not exist
results_dir <- paste0(target_dir,"/","results")

if (!dir.exists(paste0(results_dir))) {
  dir.create(paste0(results_dir))
}

setwd(running_dir)
#--- load functions
source("main/functions.R")


#---Retrieve Gemma API information for all of the GSEs
source("main/01_get_gemma_API.R")
stopifnot(file.exists(paste0(results_dir,"/API_output.rds")))


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
