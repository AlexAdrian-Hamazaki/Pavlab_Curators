running_dir <- "~/R_scripts/gemma_API"

target_dir <- "~/R_scripts/gemma_API"
input_GSEids <- "input_GSEids"

username <-  ""
password <- ""

#----setwd
setwd(running_dir)

#---Check to see if the input GSEid file exists/ is in the right place
stopifnot(file.exists(paste0(target_dir,"/",input_GSEids)))

#---set results dir, lcoation to save files
results_dir <- paste0(target_dir,"/","results")

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


