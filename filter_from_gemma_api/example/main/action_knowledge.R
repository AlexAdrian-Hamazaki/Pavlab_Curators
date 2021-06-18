#
#this script returns the common informatino that you will take action on. Aka, the microarray experiments in gemma that are not completed, or rnaseq. etc
#

library(tidyverse)
setwd(results_dir)

# #---Open up required text files
# 
# rnaseq_GSEs <- read_delim(paste0("filter_by_technology","/","rnaseq_GSEs.txt"), delim = "\n", col_names=FALSE)
# microarray_GSEs <- read_delim(paste0("filter_by_technology","/","micr_GSEs.txt"), delim = "\n", col_names=FALSE)
# completed_gses <- read_delim(paste0("completion_filter","/","completed_gses.txt"), delim = "\n", col_names=FALSE)
# non_complete_gses <- read_delim(paste0("completion_filter","/","non_complete_gses.txt"), delim = "\n", col_names=FALSE)
# human_GSEs <- read_delim(paste0("seperate_by_species","/","human_GSEs.txt"), delim = "\n", col_names=FALSE)
# mouse_GSEs <- read_delim(paste0("seperate_by_species","/","mouse_GSEs.txt"), delim = "\n", col_names=FALSE)
# rat_GSEs <- read_delim(paste0("seperate_by_species","/","rat_GSEs.txt"), delim = "\n", col_names=FALSE)
# 
# microarray_GSEs <- read_delim(paste0("filter_by_technology","/","micr_GSEs.txt"), delim = "\n", col_names=FALSE)
# 
#                               
# setwd(target_dir)
# 
# # #---getting rnaseq gses that are complete or not and are rat/mouse/human
# rna_seq_in_gemma_complete <- rnaseq_GSEs %>%
#   filter(X1 %in% completed_gses$X1) %>%
#   filter(X1 %in% human_GSEs$X1 | X1 %in% mouse_GSEs$X1 | X1 %in% rat_GSEs$X1)
# # 
# rna_seq_in_gemma_notcomplete <- rnaseq_GSEs %>%
#   filter(X1 %in% non_complete_gses$X1) %>%
#   filter(X1 %in% human_GSEs$X1 | X1 %in% mouse_GSEs$X1 | X1 %in% rat_GSEs$X1)
# # 
# #---getting microarray gses that are complete or not and are rat/mouse/human
# micr_in_gemma_complete <- microarray_GSEs %>%
#   filter(X1 %in% completed_gses$X1)%>%
#   filter(X1 %in% human_GSEs$X1 | X1 %in% mouse_GSEs$X1 | X1 %in% rat_GSEs$X1)
# 
# micr_in_gemma_not_complete <- microarray_GSEs %>%
#   filter(X1 %in% non_complete_gses$X1)%>%
#   filter(X1 %in% human_GSEs$X1 | X1 %in% mouse_GSEs$X1 | X1 %in% rat_GSEs$X1)



#---open and write for RNAseq experiments



filter_for_actionable_items <- function() {
  #This script writes files that tell you which GSEs are RNAseq and completed, RNAseq and not completed, microarray and completed, and microarray and not completed
  
  #opens required tables
  #For RNAseq experiments: It writes empty text file if a category is empty. Otherwise writes table
  #Same for microarray
  
  
  #---open files
  if (!dir.exists(paste0(results_dir,"/","actionable_items"))) {
    dir.create(paste0(results_dir,"/","actionable_items"))
  }
  
  setwd(results_dir)
  
  
  rnaseq_GSEs <- read_delim(paste0("filter_by_technology","/","rnaseq_GSEs.txt"), delim = "\n", col_names=FALSE)
  microarray_GSEs <- read_delim(paste0("filter_by_technology","/","micr_GSEs.txt"), delim = "\n", col_names=FALSE)
  completed_gses <- read_delim(paste0("completion_filter","/","completed_gses.txt"), delim = "\n", col_names=FALSE)
  non_complete_gses <- read_delim(paste0("completion_filter","/","non_complete_gses.txt"), delim = "\n", col_names=FALSE)
  # human_GSEs <- read_delim(paste0("seperate_by_species","/","human_GSEs.txt"), delim = "\n", col_names=FALSE)
  # mouse_GSEs <- read_delim(paste0("seperate_by_species","/","mouse_GSEs.txt"), delim = "\n", col_names=FALSE)
  # rat_GSEs <- read_delim(paste0("seperate_by_species","/","rat_GSEs.txt"), delim = "\n", col_names=FALSE)  
  
  setwd(target_dir)
  
  
  #---Filtering RNAseq experiments that are complete or not complete
  if (is_empty(rnaseq_GSEs)) {
  message("No RNAseq experiments were found in Gemma")
  file.create(file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"))
  file.create(file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"))
  
} else if(is_empty(completed_gses)) {
  message("There were no completed experiments")
  file.create(file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"))
  
  rna_seq_in_gemma_notcomplete <- rnaseq_GSEs %>%
    filter(X1 %in% non_complete_gses$X1)
  write_delim(data.frame(rna_seq_in_gemma_notcomplete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"), delim = "\n", col_names = FALSE)
  
} else if (is_empty(non_complete_gses)) {
  message("All experiments were completed")
  file.create(file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"))
  
  rna_seq_in_gemma_complete <- rnaseq_GSEs %>%
    filter(X1 %in% completed_gses$X1)
  write_delim(data.frame(rna_seq_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)

  } else {
    rna_seq_in_gemma_notcomplete <- rnaseq_GSEs %>%
      filter(X1 %in% non_complete_gses$X1)
    rna_seq_in_gemma_complete <- rnaseq_GSEs %>%
      filter(X1 %in% completed_gses$X1)
  write_delim(data.frame(rna_seq_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
  write_delim(data.frame(rna_seq_in_gemma_notcomplete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"), delim = "\n", col_names = FALSE)
  }
  
  
  #---Filtering microarray experiments that are complete or not complete
  if (is_empty(microarray_GSEs)) {
    message("No Microarray experiments were found in Gemma")
    file.create(file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"))
    file.create(file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"))
    
  } else if(is_empty(completed_gses)) {
    message("There were no completed experiments")
    file.create(file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"))
    
    micr_in_gemma_not_complete <- microarray_GSEs %>%
      filter(X1 %in% non_complete_gses$X1)
    write_delim(data.frame(micr_in_gemma_not_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"), delim = "\n", col_names = FALSE)
    
  } else if (is_empty(non_complete_gses)) {
    message("All experiments were completed")
    file.create(file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"))
    
    micr_in_gemma_complete <- microarray_GSEs %>%
      filter(X1 %in% completed_gses$X1)
    write_delim(data.frame(micr_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
    
  } else {
    micr_in_gemma_complete <- microarray_GSEs %>%
      filter(X1 %in% completed_gses$X1)
    micr_in_gemma_not_complete <- microarray_GSEs %>%
      filter(X1 %in% non_complete_gses$X1)
    write_delim(data.frame(micr_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
    write_delim(data.frame(micr_in_gemma_not_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"), delim = "\n", col_names = FALSE)
  }
}

filter_for_actionable_items()
  
#---Writing
# 
# if (!dir.exists(paste0(results_dir,"/","actionable_items"))) {
#   dir.create(paste0(results_dir,"/","actionable_items"))
# }
# 
# write_delim(data.frame(rna_seq_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
# write_delim(data.frame(rna_seq_in_gemma_notcomplete$X1), file = paste0(results_dir,"/","actionable_items/","rna_seq_in_gemma_notcomplete.txt"), delim = "\n", col_names = FALSE)
# write_delim(data.frame(micr_in_gemma_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_complete.txt"), delim = "\n", col_names = FALSE)
# write_delim(data.frame(micr_in_gemma_not_complete$X1), file = paste0(results_dir,"/","actionable_items/","micr_in_gemma_not_complete.txt"), delim = "\n", col_names = FALSE)
# 
# 

