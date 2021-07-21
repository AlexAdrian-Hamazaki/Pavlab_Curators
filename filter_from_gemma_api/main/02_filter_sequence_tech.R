#
#Purpose : Identify which GSEids are RNAseq, microarray. And within the microarray, identify which are two color vs one color. Writes text files for these 4 categories
#


#-----------Outputs: 5 tsv files
# rnaseq_GSEs -> GSEs that are RNAseq
# micr_GSEs-> GSEs that are microarray
# unknown_GSEs-> GSEs that are neither RNAseq nor microarray
# two_col_GSEs-> GSEs that are two color microarrays
# one_col_GSEs-> GSEs that are one color microarrays

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
#---- getting RNAseq experiments.
rnaseq_GSEs <- API_output %>%
  select(shortName, technologyType)%>%
  filter(API_output$technologyType =="GENELIST" | API_output$technologyType == "SEQUENCING")


#---- getting microarray experiments
micr_GSEs <- API_output %>%
  dplyr::select(shortName, technologyType)%>%
  dplyr::filter(API_output$technologyType == "ONECOLOR" | API_output$technologyType == "TWOCOLOR" | API_output$technologyType == "DUALMODE")

#----getting experiments that  fall through cracks
other_GSEs <- API_output %>%
  dplyr::select(shortName, technologyType)%>%
  dplyr::filter(!(API_output$shortName %in% rnaseq_GSEs$shortName) & !(API_output$shortName %in% micr_GSEs$shortName))

#----Checking to see if there's any weird platforms. If this fails, then there are some strange platforms to investigate
if (!is_empty(other_GSEs$shortName)) {
  warning("There may be some weird platforms in these experiments")
}
#----Checking to make sure experiment count adds up at this point
stopifnot(length(API_output$shortName) == (nrow(rnaseq_GSEs)+nrow(micr_GSEs)+nrow(other_GSEs)))


#----------------identifying two color experiments from the microarray experiments
two_col_GSEs <- micr_GSEs %>%
  dplyr::filter(micr_GSEs$technologyType == "TWOCOLOR" | micr_GSEs$technologyType == "DUALMODE")
one_col_GSEs <- micr_GSEs %>%
  dplyr::filter(micr_GSEs$technologyType == "ONECOLOR")

#---checking to see if they add up
stopifnot(nrow(two_col_GSEs)+nrow(one_col_GSEs) == nrow(micr_GSEs))


#--------Get affymetrix experiments
affymetrix_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, ".?(A|a)ffymetrix.?"))

#--------Get Ion Torrent experiments
ion_torrent_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, ".?(I|i)on.?(T|t)orrent.?"))

#--------Get NanoString experiments
nano_string_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, ".?(N|n)ano.?(S|s)tring.?"))

#--------Get lncRNA experiments
lnc_rna_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, c(".?lnc.?rna.? | long.?non.?coding")))

#--------Get AB experiments
ab_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, ".?ab.?"))

#--------Get Pacbio experiments
pacbio_experiments <- API_output %>%
  select(shortName, name.1) %>%
  mutate(name.1 = str_to_lower(name.1))%>%
  filter(str_detect(API_output$name.1, ".?pacbio.?"))


#---writing files

#create directory if it doesnt exist yet

if (!dir.exists(paste0(results_dir,"/","filter_by_technology"))) {
  dir.create(paste0(results_dir,"/","filter_by_technology"))
}

write_delim(data.frame(rnaseq_GSEs$shortName), file = paste0(results_dir,"/","filter_by_technology/","rnaseq_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(micr_GSEs$shortName), file = paste0(results_dir,"/","filter_by_technology/","micr_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(other_GSEs$shortName), file = paste0(results_dir,"/","filter_by_technology/","unknown_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(two_col_GSEs$shortName), file = paste0(results_dir,"/","filter_by_technology/","two_col_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(one_col_GSEs$shortName), file = paste0(results_dir,"/","filter_by_technology","/","one_col_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(affymetrix_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","affymetrix_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(ion_torrent_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","ion_torrent_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(nano_string_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","nano_string_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(lnc_rna_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","lnc_rna_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(ab_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","ab_GSEs.txt"), delim = "\n", col_names = FALSE)
write_delim(data.frame(pacbio_experiments$shortName), file = paste0(results_dir,"/", "filter_by_technology", "/","pacbio_GSEs.txt"), delim = "\n", col_names = FALSE)

