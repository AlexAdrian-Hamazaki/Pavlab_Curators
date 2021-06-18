library(rentrez)
library(stringr)

entrez_db_searchable("gds")


#----method 1
superid <- "GSE166015"
subid <- "GSE166012"
testsuper <- entrez_search(db = "gds", term = paste0(superid,"[ACCN]"), retmax = 50)
testsub <- entrez_search(db = "gds", term = paste0(subid,"[ACCN]"), retmax = 50)

testsuper$ids
testsub$ids

testsuper$ids %in% testsub$ids
testsub$ids %in% testsuper$ids

super_summary <- entrez_summary(db = "gds", "200166015")
super_summary

sub_summary <- entrez_summary(db = "gds", testsub$ids[1])
#-----------------


#----method 2?
mergedsearch <- entrez_search(db = "gds", term = paste0(superid,"[ACCN] AND SuperSeries[DESC]"), retmax = 50)
mergedsearch <- entrez_search(db = "gds", term = paste0(superid,"[SSDE]" ), retmax = 50)

mergedsearch <- entrez_search(db = "gds", term = paste0(testsuper$ids[1],"[SSTP]" ), retmax = 50)
mergedsearch

mergedsearch <- entrez_search(db = "gds", term = paste0(testsub$ids[1],"[SSDE]" ), retmax = 50)
mergedsearch


wut <- entrez_search(db = "gds", term = paste0("subset[SSDE]" ), retmax = 50)
wut$ids
super_summary <- entrez_summary(db = "gds", "3995")
