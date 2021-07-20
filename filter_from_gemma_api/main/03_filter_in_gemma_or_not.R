#
# Purpose: Identify if a given GSEids is in Gemma 
#

#-----------Output
#Two files, one where all GSEids are in Gemma, and another where they are not in Gemma


#----------If 01_get_gemma_API rds object if it exists, if it does note xist then generate it and open it.
if (file.exists(paste0(results_dir,"/","API_output.rds"))) { 
  print('It looks like API information has already been retrieved, opening it up now...') 
  API_output <- readRDS(paste0(results_dir,"/","API_output.rds"))
} else {print("It looks like there is no API information, running 01_get_API_output to try again...")
  source("01_get_API_output.R")
  API_output <- readRDS(paste0(results_dir,"/","API_output.rds"))
}

#----------Open up the inputGSEids as a text file

df_input_GSEids_unique <- read_delim(file = paste0(results_dir,"/","input_GSEids_unique"), col_names=FALSE, delim = "\n")

#----------Compare inputGSEids to API_output to get all the GSEs that are in gemma

in_gemma <- df_input_GSEids_unique %>%
  filter(df_input_GSEids_unique$X1 %in% API_output$shortName)

#----------Compare inputGSEids to API_output to get all the GSEs that are NOT in gemma

not_in_gemma <- df_input_GSEids_unique %>%
  filter(!(df_input_GSEids_unique$X1 %in% API_output$shortName))

#--------Generate directory to save file


if (!dir.exists(paste0(results_dir,"/","GSEs_in_gemma_or_not"))) {
  dir.create(paste0(results_dir,"/","GSEs_in_gemma_or_not"))
}

#---------writing files

write_delim(data.frame(in_gemma$X1), file = paste0(results_dir,"/", "GSEs_in_gemma_or_not", "/","GSEs_in_gemma"), delim = "\n", col_names = FALSE)
write_delim(data.frame(not_in_gemma$X1), file = paste0(results_dir,"/", "GSEs_in_gemma_or_not", "/","GSEs_not_in_gemma"), delim = "\n", col_names = FALSE)

