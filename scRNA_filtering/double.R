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


#-----load

positive_hits <- (read_delim(file = "~/Projects/Pavlab_Curators/scRNA_filtering/positive_sc_hits.txt", delim = "\n", col_names = FALSE))
positive_hits_pull <- as.list(positive_hits$X1)

negative_hits <- (read_delim(file = "~/Projects/Pavlab_Curators/scRNA_filtering/negative_sc_hits.txt", delim = "\n", col_names = FALSE))
negative_hits_pull <- as.list(negative_hits$X1)


#------scRNA

term = paste0(gseid,"[ACCN] AND (scR[ALL] OR (single[ALL] AND (cell[ALL] OR mit[ALL] or nucl[ALL])))")
gseid <- "GSE90809"
other <- "GSE148266"
mergedsearch <- entrez_search(db = "gds", term = paste0(other,"[ACCN] AND (scRNA[ALL] OR (single.?cell OR single.?nuc))"), retmax = 10)
mergedsearch$ids
mergedsearch$QueryTranslation

mergedsearch$ids
mergedsearch$ids
test_function <- function(gseid) {
  mergedsearch <- entrez_search(db = "gds", term = paste0(gseid,"[ACCN] AND (
                                                          scRNA[ALL] OR scN[ALL] OR 
                                                          singlecell[ALL] OR (single cell[ALL]) OR single_cell[ALL] OR single-cell[ALL] OR
                                                          singlenucl[ALL] OR single nucl[ALL] OR single_nucl[ALL] OR single-nucl[ALL] OR
                                                          singlemit[ALL] OR single mit[ALL] OR single-mit[ALL] OR single_mit[ALL]
                                                          )"
                                                          , retmax = 100)
  )
  if (!is_empty(mergedsearch$ids)) {
    sum <- entrez_summary(db = "gds", mergedsearch$ids[[1]])
    if (sum$entrytype == "GSE") {
      message(paste(gseid, "might be single cell"))
      return(gseid)
    } else if (sum$entrytype != "GSE") {
      message(paste(gseid,"is likely not single cell"))
      return(NA)
    } else {
      message(paste("not sure about",gseid))
    }
  } else {
    message(paste(gseid, " is likely not single cell"))
  }
}
test_run_pos <- lapply(positive_hits_pull, test_function)
test_run_neg <- lapply(negative_hits_pull, test_function)


#------Individual testing



