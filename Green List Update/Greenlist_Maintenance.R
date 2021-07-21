# Loading Libraries
list.of.packages <- c("googlesheets4", "rstudioapi", "gtools", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(data.table)
library(gtools)
library(rstudioapi)
library(googlesheets4)
library(tidyverse)
#########################

#Purpose: Confirm that experiments on the temporary greenlist are greenlisted, and to see if any of those experiements have problems being greenlisted

#Returns cleanGreenList.tsv: a tab deliniated file with ee.id and GSE.id of experiments that were successfully greenlisted
#Returns Recuration.tsv: a tab deliniated file with ee.id and GSE.id of experiments that were not successfully greenlisted, and require re-curation
#Three fields must be edited prior to running this script
#1)greenTable is a tsv deliniated table of the temporary greenlist. It must have column id's ee.ID and ee.Name respectively. Change the location from which fread opens this file
#2)Change the directory to which the Recuration.tsv file is directed. Change it to your home/user/etc, wherever you want it to be outputted
#3)Change the directory to which cleanGreenList.tsv is directed. change it to your home/user/etc, wherever you want it to be outputted

########################

#*****************************Change variables here******************************
url_to_sheet = "https://docs.google.com/spreadsheets/d/17xm2eFFqhhT-M6-jTC_lsar7RMgk8Ln-TwQPDWlRfIY/edit?ts=5744cba9#gid=956906386"
sheet_name ="[June2021] Curation Complete (Green List)"
 #********************************************************************************
## Read From sheet name [April 2021] Curation Complete (Green List) on google sheets. Change the link and name of sheet accordingly
greenTable <- read_sheet(url_to_sheet,
                       sheet = sheet_name, range = cell_cols(1:2))
setDT(greenTable)
# Load Tables
#greenTable = fread(######'/home/user/curation_complete_list.tsv######, sep = '\t', header = TRUE, select = 1:2)
eeTable = fread('/space/grp/nlim/CronGemmaDump/EE_Dump.TSV', sep = '\t', header = TRUE, quote = '')
eeTable = eeTable[, .(ee.ID, ee.Name, ee.OriginalID)]
### checking what the largest GSE in gemma is
#eeTable_above = dplyr::select(eeTable, ee.OriginalID)
#eeTable_above = mixedsort(eeTable_above)
#mixedsort(eeTable$ee.OriginalID, decreasing=TRUE)

reason_master <- data.table(ee.ID=double(),
                 ee.Name=character(), 
                 Reason=character()) 

# 1. Existence Check
IDVector = greenTable$ee.ID %in% eeTable$ee.ID
nameVector = greenTable$ee.Name %in% eeTable$ee.Name

# 1A. Check for disagreement of existence between ee.ID and ee.Name
existence_disagreement = xor(IDVector, nameVector)

#@@ Collapsed View of Check-state
# cbind(greenTable[existence_disagreement], ID_PASS = IDVector[existence_disagreement], NAME_PASS = nameVector[existence_disagreement])

# Problem Case 1: IDs exist in Gemma --> All needs to be recurated
problemID_1 = greenTable[existence_disagreement & IDVector, ee.ID]

# Problem Case 2: Names exist in Gemma --> All needs to be recurated
problemName = greenTable[existence_disagreement & nameVector, ee.Name]
problemID_2 = eeTable[.(problemName), ee.ID, on = 'ee.Name']
rm(problemName)
mis_match <- unique(c(problemID_1,problemID_2))
mis_match <- data.table(ee.ID=mis_match, reason="ee.ID and GSE are not correctly matched. Double check")
reason_master <- mis_match
rm(mis_match)
# Problem Case 3: Both IDs and Names do not exist in Gemma --> Non-issue
## NO CODE

# Update Greenlist for ID and Name-existant experiments
greenTable = greenTable[IDVector & nameVector]
rm(existence_disagreement, IDVector, nameVector)

# 2. Duplicate Removal
greenTable = unique(greenTable)

# 3. Consistency/Mismatch Check
# 3A. Collect mismatched duplicates of IDs (and related Names)
table_duplicated_IDs = greenTable[, .N, by = ee.ID][N > 1]
problemID_3 = table_duplicated_IDs[, ee.ID]
tempNameVector = greenTable[table_duplicated_IDs, ee.Name, on = 'ee.ID']
problemID_3A = eeTable[tempNameVector, ee.ID, on = 'ee.Name']
rm(tempNameVector)
ee_duplicate <- unique(c(problemID_3,problemID_3A))
ee_duplicate <- data.table(ee.ID=ee_duplicate, reason="ee.ID duplicated. Double check")
reason_master <- left_join(reason_master, ee_duplicate, by="ee.ID")

# 3B. Same as 3A, but for duplicated Names
table_duplicated_Names = greenTable[, .N, by = ee.Name][N > 1]
problemID_4 = greenTable[table_duplicated_Names, ee.ID, on = 'ee.Name']
problemID_4A = eeTable[table_duplicated_Names$ee.Name, ee.ID, on = 'ee.Name']
name_duplicate <- unique(c(problemID_4,problemID_4A))
name_duplicate <- data.table(ee.ID=name_duplicate, reason="GSE name duplicated. Double check")
reason_master <- left_join(reason_master, name_duplicate, on="ee.ID")

# Update GreenList for non-duplicates
greenTable = greenTable[!(ee.ID %in% table_duplicated_IDs$ee.ID)][!(ee.Name %in% table_duplicated_Names$ee.Name)]
rm(table_duplicated_IDs, table_duplicated_Names)

# 3C. Final mismatch check
name_mismatch_vector = (eeTable[greenTable, ee.Name, on = 'ee.ID'] != greenTable$ee.Name)
id_mismatch_vector = (eeTable[greenTable, ee.ID, on = 'ee.Name'] != greenTable$ee.ID)
problem_table = greenTable[name_mismatch_vector | id_mismatch_vector]

problemID_5 = problem_table$ee.ID
problemID_5A = eeTable[problem_table, ee.ID, on = 'ee.Name']
rm(problem_table)
final_test <- unique(c(problemID_5,problemID_5A))
final_test <- data.table(ee.ID=final_test, reason="Didn't pass the final check. ee.ID and GSE name not matched in GEMMA")
reason_master <- left_join(reason_master, final_test, on="ee.ID")
# Update GreenList for non-mismatches, sort by ID
greenTable = greenTable[!(name_mismatch_vector | id_mismatch_vector)]
setorder(greenTable, ee.ID)
rm(name_mismatch_vector, id_mismatch_vector)

# FINAL STEPS
# Join all Problem IDs for recuration and Dump out Recuration Table
problemID_ALL = unique(c(
	problemID_1,
	problemID_2,
	problemID_3,
	problemID_3A,
	problemID_4,
	problemID_4A,
	problemID_5,
	problemID_5A
))
#recurationTable = eeTable[.(problemID_ALL), .(ee.ID, ee.Name), on = 'ee.ID']
reason_master = eeTable[reason_master , on = 'ee.ID']
x <- dirname(getActiveDocumentContext()$path)
setwd(x)
#write.table(recurationTable, file = 'OneOffScripts/Curation/Recuration.tsv', sep = '\t', quote = FALSE, col.names = TRUE, row.names = FALSE)
write.table(reason_master, file = "Recuration.tsv", sep = '\t', quote = FALSE, col.names = TRUE, row.names = FALSE)

# Dump out Cleaned GreenList
write.table(greenTable, file = "cleanGreenList.tsv", sep = '\t', quote = FALSE, col.names = TRUE, row.names = FALSE)

