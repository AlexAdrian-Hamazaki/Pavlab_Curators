#
#Purpose : Filter experiements by species. Write files of GSEs for human, mouse, rat, and other
#

#---------------------------
library(tidyverse)

#----------If 01_get_gemma_API rds object if it exists, if it does note xist then generate it and open it.
if (file.exists(paste0(results_dir,"/","API_output.rds"))) { 
  print('It looks like API information has already been retrieved, opening it up now...') 
  API_output <- readRDS(paste0(results_dir,"/","API_output.rds"))
} else {print("It looks like there is no API information, running 01_get_API_output to try again...")
  source("01_get_API_output.R")
  API_output <- readRDS(paste0(results_dir,"/","API_output.rds"))
}

#---------Getting species table for downstream use

taxon_table <- API_output %>%
  select(shortName, taxon)

#---------Getting GSEs with specific species

human_GSEs <- taxon_table %>%
  filter(taxon_table$taxon == "human")

mouse_GSEs <- taxon_table %>%
  filter(taxon_table$taxon == "mouse")

rat_GSEs <- taxon_table %>%
  filter(taxon_table$taxon == "rat")

#---------Getting GSEs for "other" species that are most likely not supported by Gemma

other_GSEs <- taxon_table %>%
  filter(taxon_table$taxon != "rat" & taxon_table$taxon != "human" & taxon_table$taxon !="mouse")

#--------Create seperated_by_species directory
if (!dir.exists(paste0(results_dir,"/","seperate_by_species"))) {
  dir.create(paste0(results_dir,"/","seperate_by_species"))
}

#--------Writing files

write_delim(data.frame(human_GSEs$shortName), file = paste0(results_dir,"/","seperate_by_species/","human_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(mouse_GSEs$shortName), file = paste0(results_dir,"/","seperate_by_species/","mouse_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(rat_GSEs$shortName), file = paste0(results_dir,"/","seperate_by_species/","rat_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(other_GSEs$shortName), file = paste0(results_dir,"/","seperate_by_species/","other_GSEs.txt"), delim = "\n", col_names = FALSE)


         
         