This packaged function takes a list of GSEids, and filter them into various categories.



-----------Results are saved into various categories...

API_output: an RDS object that is the Gemma API output
completion_filter: Wether the input GSEids are "complete" or not. A complete experiment is public, has a DEA, and does not have the "needs attention" flag
filter_by_technology: GSEs are seperated by their platform type
GSEs_in_gemma_or_not: Filters the GSEs into GSEs that are in gemma, and those which are not
seperate_by_species: Seperates GSEs into species
summary_statistics: Various sunmmary statistics that are generated


#-----------Configuring the script before running

Open up master_executable.R

Change the following variables as you desire...


running_dir: The directory path containing these functions as a string. Example: running_dir <- "~/R_scripts/FilterFromGemmaAPI"

target_dir: The directory path where your input file is as a string, and where you want to save your Results. 
            The default is that it will be the same as your running_dir. Example: target_dir <- running_dir
            
input_GSEids: The file name of your input GSEs as a string. This file must be in your target_dir location. Example: input_GSEids <- "input_GSEids"

username: Your Gemma username as a string. Example: username <- "mygemmausername"
password: Your Gemma password as a string. Example: password <- "mygemmapassword"
**Warning** The API is unable to check if your login to Gemma was successfull or not. If you are not logged in, API information about private experiments will not be returned. Check to make sure your login was successfull by trying to run the function using a GSEid you know is public, and one you know is private.

#----------Running the script

Simply source master_executable.R and it should run.



