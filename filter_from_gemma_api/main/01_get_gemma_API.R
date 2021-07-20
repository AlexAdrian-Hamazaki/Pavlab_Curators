#
#Purpose: This script takes the gemma API, and returns an RDS data structure for an input of GSEids
#
#----------------Things to Change------------------------------------------------

# #-target_dir is the directory where you are working
# target_dir <- "~/R_scripts/gemma_API"
# 
# #-input_GSEids is your txt file with your GSEids. Must be line delimited
# input_GSEids <- paste0("input_GSEids"

#-------------------------------------------------------------------------------


if (!("devtools" %in% installed.packages())) {
  install.packages("devtools")
}

library(devtools)

if (!("gemmaAPI" %in% installed.packages())) {
  devtools::install_github('PavlidisLab/gemmaAPI.R')
}

library(tidyverse)
library(gemmaAPI)
library(stringr)

#----------------set Gemma Username and Password so you can retrieve info about private experiments

setGemmaUser(username, password)
message('Attempted to login to gemma account')

#----------------open the file that is full of input GSEids

df_input_GSEids <- read_delim(file = paste0(target_dir,"/",input_GSEids), col_names=FALSE, delim = "\n")

#----------------remove empty spaces
df_input_GSEids$X1 <- str_replace(string = df_input_GSEids$X1, pattern = " ", replacement =  "")

#---remove non unique GSEids. Save it as a text file
df_input_GSEids_unique <- df_input_GSEids %>%
  distinct(X1)
write_delim(df_input_GSEids_unique, file = paste0(results_dir,"/","input_GSEids_unique"), delim = "\n", col_names = FALSE)


#---get the actual GSEids that were duplicated
bool_duplicates <- df_input_GSEids %>%
  duplicated()
duplicate_gses <- df_input_GSEids$X1[bool_duplicates]
message(paste(length(duplicate_gses), "duplicates were removed from input_GSEs"))

#---quick check to see if duplicate lengths removed match
stopifnot(length(duplicate_gses) == nrow(df_input_GSEids)-nrow(df_input_GSEids_unique))


#---------------Retireve API info
l_output_API <-  lapply(as.character(unlist(df_input_GSEids_unique$X1)), get_API_data)

#---------------Due to the reduce function, we cannot handle when l_output_API is length 1 with our reduce function. So we have a different function.
if (length(l_output_API) == 1) {
  df_output_API <- data.frame(t(sapply(l_output_API,c)))
  warning("The GSEinput was of length 1")
} else {
  df_output_API <- data.frame(Reduce(rbind, l_output_API))
}

# df <- unlist(l_output_API[1])
# df <- data.frame(matrix(unlist(l_output_API), nrow=length(l_output_API[[1]]), byrow=TRUE), stringsAsFactors=FALSE)
# 
# length(l_output_API)
# df_output_API
# l_output_API[[1]]
#---------------Turn l_output_API into a data frame


#---------------MAke rown ames equal to short names
row.names(df_output_API) <- df_output_API$shortName

#--------------remove l_output_API because its so big

# rm(l_output_API)

#--------------save df_output_API as an rdsobject
saveRDS(df_output_API, file = paste0(results_dir,"/","API_output.rds"))


# get_API_data <- function(GSEid) {
#   #
#   # Use Gemma API to get platform, differentiation, and dataset information
#   # If the experiment is private, it will print "GSE is private". But the API will still succeed
#   # IF the experiment is public, the API should succeed
#   # If the experiment is missing a DEA, the "diff" column will read "NO DIFF"
#   #
#   # Returns a list of API information for a GSEid
#   #
#   tryCatch(
#     {#try
#       platform <- datasetInfo(GSEid, request = 'platforms')
#       diff <- datasetInfo(GSEid, request = 'differential')
#       dataset <- datasetInfo(GSEid)
#       if (is_empty(diff)) { 
#         diff = list(diff = "NO DIFF")
#       }
#     },
#     error = function(cond) {
#       if (str_detect(string = message(cond), pattern = "404")) {
#         print(paste0(GSEid, " is private"))
#       } else {
#         print(paste0(GSEid, " is not in Gemma"))
#       }
#     }
#   )
#   merged <- tryCatch(
#     {#try
#       a <- append(dataset[[1]], platform[[1]])
#       a <- append(a,diff[1])
#     }, 
#     error = function(cond) {
#       message(cond)
#     }
#   )
#   return (merged)
# }





