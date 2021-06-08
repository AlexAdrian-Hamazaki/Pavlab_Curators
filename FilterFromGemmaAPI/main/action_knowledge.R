#
#this script returns the common informatino that you will take action on. Aka, the microarray experiments in gemma that are not completed, or rnaseq. etc
#

library(tidyverse)
setwd(results_dir)

#---Open up required text files
rnaseq_GSEs <- read.delim(paste0("filter_by_technology","/","rnaseq_GSEs.txt"), sep = "\n", header=FALSE)
microarray_GSEs <- read.delim(paste0("filter_by_technology","/","micr_GSEs.txt"), sep = "\n", header=FALSE)
completed_gses <- read.delim(paste0("completion_filter","/","completed_gses.txt"), sep = "\n", header=FALSE)
non_complete_gses <- read.delim(paste0("completion_filter","/","non_complete_gses.txt"), sep = "\n", header=FALSE)
human_GSEs <- read.delim(paste0("seperate_by_species","/","human_GSEs.txt"), sep = "\n", header=FALSE)
mouse_GSEs <- read.delim(paste0("seperate_by_species","/","mouse_GSEs.txt"), sep = "\n", header=FALSE)
rat_GSEs <- read.delim(paste0("seperate_by_species","/","rat_GSEs.txt"), sep = "\n", header=FALSE)

                              

#---getting rnaseq gses that are complete or not and are rat/mouse/human
rna_seq_in_gemma_complete <- rnaseq_GSEs %>%
  filter(V1 %in% completed_gses$V1) %>%
  filter(V1 %in% human_GSEs$V1 | V1 %in% mouse_GSEs$V1 | V1 %in% rat_GSEs$V1)

rna_seq_in_gemma_notcomplete <- rnaseq_GSEs %>%
  filter(V1 %in% non_complete_gses$V1) %>%
  filter(V1 %in% human_GSEs$V1 | V1 %in% mouse_GSEs$V1 | V1 %in% rat_GSEs$V1)

#---getting microarray gses that are complete or not and are rat/mouse/human
micr_in_gemma_complete <- microarray_GSEs %>%
  filter(V1 %in% completed_gses$V1)%>%
  filter(V1 %in% human_GSEs$V1 | V1 %in% mouse_GSEs$V1 | V1 %in% rat_GSEs$V1)

micr_in_gemma_not_complete <- microarray_GSEs %>%
  filter(V1 %in% non_complete_gses$V1)%>%
  filter(V1 %in% human_GSEs$V1 | V1 %in% mouse_GSEs$V1 | V1 %in% rat_GSEs$V1)


#---Writing

if (!dir.exists(paste0(results_dir,"/","actionable_items"))) {
  dir.create(paste0(results_dir,"/","actionable_items"))
}

write_delim(data.frame(rna_seq_in_gemma_complete$V1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(rna_seq_in_gemma_notcomplete$V1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(micr_in_gemma_complete$V1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(micr_in_gemma_not_complete$V1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"), delim = "\n", col_names = FALSE)
