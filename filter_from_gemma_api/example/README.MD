This packaged function takes a list of GSEids, and filter them into various categories.


-----------Results are saved into various categories...

------actionable_items
actionable_items: Several tables that have probably the most useful categories of GSEids. For example you can get the GSEids that are RNAseq and not complete, these might need to be put in the RNAseq pipeline
---Texts within actionable_items
micr_in_gemma_complete.txt = microarray experiments in gemma that are complete
micro_in_gemma_not_complete.txt = microarray experiments in gemma that were not complete
rna_seq_in_gemma_complete.txt = rnaseq experiments in gemma that are not complete
rna_seq_in_gemma_notcomplete.txt = rnaseq experiments that are in gemma and NOT complete
---------------------------------------

---------------------------------------
API_output: an RDS object that is the Gemma API output
---------------------------------------

------completion_filter
completion_filter: Whether the input GSEids are "complete" or not. A complete experiment is public, has a DEA, and does not have the "needs attention" flag
---Texts within completion_filter
completed_gses.txt = all complete experiments
diff_gses.txt = all experiments with a differential expression analysis
no_diff_gses.txt = all experiments without a DEA
non_complete_gses.txt = all experiments that are NOT complete
private_gses.txt = private experiments
public_gses.txt = public experiments
---------------------------------------

------filter_by_technology:
filter_by_technology: GSEs are separated by their platform type. Note that experiments one_col would also be in micr_GSEs, as would lnc_rna, ion_torrent etc.
---Texts within filter_by_technology
ab_experiments = experiments run on AB platforms (should be blacklisted)
affymetrix_GSEids = experiments run on affymetrix platforms
ion_torrent_GSEs.txt = experiments run on ion torrent platforms (should be blacklisted)
lnc_rna_GSEs.txt = experiments using lncRNA platforms (should be blacklisted)
micr_GSEs.txt = All microarray experiments
nano_string_GSEs.txt = experiments run on nanostring platforms (should be blacklisted)
one_col_GSEs.txt = Experiments that are one color microarrays
pacbio_GSEs.txt = experiments run on pacbio platforms (should be blacklisted)
rnaseq_GSEs.txt = experiments run on RNAseq platforms
two_col_GSEs.txt = experiments that are two color microarrays
unknown_GSEs.txt = experiments that are neither RNAseq or Microarray. They should be investigated
---------------------------------------

------GSEs_in_gemma_or_not:
GSEs_in_gemma_or_not: Filters the GSEs into GSEs that are in gemma, and those which are not
---Texts within GSEs_in_gemma_or_not
GSEs_in_gemma = all gses that are in gemma
GSEs_not_in_gemma = all gses that are not in gemma
---------------------------------------

---------------------------------------
input_GSEids_unique: the GSEids you input, but without any duplicates
---------------------------------------

------seperate_by_species
seperate_by_species: Separates GSEs into species
---Texts within seperate_by_species
human_GSEs.txt = human experiments
mouse_GSEs.txt = mouse experiments
rat_GSEs.txt = rat experiments
other_GSEs.txt = all other species experiments
---------------------------------------

---------------------------------------
summary_statistics: Various summary statistics that are generated about how the filtering went
---------------------------------------



----------------------Running the script
The CLI for this script follows this syntax

./filter_from_gemma_api.R <name_of_input_file> $GEMMAUSERNAME $GEMMAPASSWORD\

Note: You must be CD'd within the directory where your input file is located. Furthermore, these scripts must be within within "~/Projects/Pavlab_Curators/filter_from_gemma_api"

**Warning** The API is unable to check if your login to Gemma was successfull or not. If you are not logged in, API information about private experiments will not be returned. Check to make sure your login was successfull by trying to run the function using a GSEid you know is public, and one you know is private.
-----------------------------------------




