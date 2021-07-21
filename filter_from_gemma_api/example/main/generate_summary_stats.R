#
# Opens up all of the saved filtered API information and generats row numbers for them
#

#--------------------------
# running_dir <- "~/R_scripts/gemma_API"
# setwd(running_dir)
# 
# target_dir <- "~/sheet_cleanup/cleaning/the_script"
# input_GSEids <- "input_GSEids"
# 
# username <-  "alexadrianhamazaki"
# password <- "Doglukepotato3!"

library(tidyverse)

#------Opening up data frames with GSeids

#---technologies
rnaseq_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","rnaseq_GSEs.txt"), delim = "\n", col_names = FALSE)
micr_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","micr_GSEs.txt"), delim = "\n", col_names = FALSE)
unknown_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","unknown_GSEs.txt"), delim = "\n", col_names = FALSE)
two_colour_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","two_col_GSEs.txt"), delim = "\n", col_names = FALSE)
one_colour_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","one_col_GSEs.txt"), delim = "\n", col_names = FALSE)
affymetrix_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","affymetrix_GSEs.txt"), delim = "\n", col_names = FALSE)
ion_torrent_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","ion_torrent_GSEs.txt"), delim = "\n", col_names = FALSE)
nano_string_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","nano_string_GSEs.txt"), delim = "\n", col_names = FALSE)
lnc_rna_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","lnc_rna_GSEs.txt"), delim = "\n", col_names = FALSE)
ab_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","ab_GSEs.txt"), delim = "\n", col_names = FALSE)
pacbio_GSEs <- read_delim(paste0(results_dir,"/","filter_by_technology/","pacbio_GSEs.txt"), delim = "\n", col_names = FALSE)

#---in Gemma or not
total_GSE_input <- read_delim(paste0(results_dir,"/","input_GSEids_unique"),  delim = "\n", col_names = FALSE)
GSEs_in_gemma <- read_delim(paste0(results_dir,"/", "GSEs_in_gemma_or_not", "/","GSEs_in_gemma"), delim = "\n", col_names = FALSE)
GSEs_not_in_gemma <- read_delim(paste0(results_dir,"/", "GSEs_in_gemma_or_not", "/","GSEs_not_in_gemma"), delim = "\n", col_names = FALSE)

#---species
human_GSEs <- read_delim(paste0(results_dir,"/","seperate_by_species/","human_GSEs.txt"), delim = "\n", col_names = FALSE)
mouse_GSEs <- read_delim(paste0(results_dir,"/","seperate_by_species/","mouse_GSEs.txt"), delim = "\n", col_names = FALSE)
rat_GSEs <- read_delim(paste0(results_dir,"/","seperate_by_species/","rat_GSEs.txt"), delim = "\n", col_names = FALSE)
other_GSEs <- read_delim(paste0(results_dir,"/","seperate_by_species/","other_GSEs.txt"), delim = "\n", col_names = FALSE)

#---completion
public_gses <- read_delim(paste0(results_dir,"/","completion_filter/","public_gses.txt"), delim = "\n", col_names = FALSE)
private_gses <- read_delim(paste0(results_dir,"/","completion_filter/","private_gses.txt"), delim = "\n", col_names = FALSE)
no_diff_gses <- read_delim(paste0(results_dir,"/","completion_filter/","no_diff_gses.txt"), delim = "\n", col_names = FALSE)
diff_gses <- read_delim(paste0(results_dir,"/","completion_filter/","diff_gses.txt"), delim = "\n", col_names = FALSE)
completed_gses <- read_delim(paste0(results_dir,"/","completion_filter/","completed_gses.txt"), delim = "\n", col_names = FALSE)
non_completed_gses <- read_delim(paste0(results_dir,"/","completion_filter/","non_complete_gses.txt"), delim = "\n", col_names = FALSE)

#-----------------create data frame with the row counts for each data frame

data_frames <- c("rnaseq_GSEs", "micr_GSEs", "unknown_GSEs", "two_colour_GSEs", "one_colour_GSEs", "affymetrix_GSEs", 
                 "ion torrent_GSEs", "nano_string_GSEs", "lnc_rna_GSEs", "ab_GSEs", "pacbio_GSEs","total_GSE_input", "GSEs_in_gemma", "GSEs_not_in_gemma",
                 "human_GSEs", "mouse_GSEs", "rat_GSES", "other_GSEs", "public_GSEs", "private_GSEs", "no_diff_GSEs", "diff_GSEs", "completed_GSEs",
                 "non_completed_GSEs")
row_counts <- c(nrow(rnaseq_GSEs), nrow(micr_GSEs), nrow(unknown_GSEs), nrow(two_colour_GSEs), nrow( one_colour_GSEs), nrow(affymetrix_GSEs),
                nrow(ion_torrent_GSEs), nrow(nano_string_GSEs), nrow(lnc_rna_GSEs), nrow(ab_GSEs), nrow(pacbio_GSEs),nrow(total_GSE_input), nrow(GSEs_in_gemma), nrow(GSEs_not_in_gemma),
                nrow(human_GSEs), nrow(mouse_GSEs), nrow(rat_GSEs), nrow(other_GSEs), nrow(public_gses), nrow(private_gses), nrow(no_diff_gses), nrow(diff_gses),
                nrow(completed_gses), nrow(non_completed_gses))
summary_statistics <- data.frame(data_frames, row_counts)


#----------------saving summary_statistics

write_delim(summary_statistics, file = paste0(results_dir,"/", "summary_statistics"), delim = "\t", col_names = TRUE)

view(summary_statistics)


