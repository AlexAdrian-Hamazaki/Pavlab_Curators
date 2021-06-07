########################################

#Returns the number of public experiments in Gemma

########################################


library(tidyverse)
library(data.table)

##command to read Gemma files 
eeTable = fread('/space/grp/nlim/CronGemmaDump/EE_Dump.TSV', sep = '\t', header = TRUE, quote = '')
eeTable
# template: GSEIDCheck <- scan(file = "/home/fieldima/R/GemmaLoadCheck/BrainScrapeSubSuper", what = character())
#GSEIDCheck <- scan(file = "/home/mhuang/Loadingdata/Loadcheck/TFloadcheck_Oct1", what = character())

## For indicating experiments loaded into GEMMA already from list
# GSEsTF <- GSEIDCheck %in% inGemma
#GSEsTFdataframe <- data.frame(GSEIDCheck[GSEIDCheck %in% inGemma])
#GSEsTFdataframe

## For indicating experiments NOT loaded into GEMMA already from list
#GSEsToLoad <- GSEIDCheck[!GSEIDCheck %in% inGemma]
#GSEsToLoad <- data.frame(GSEsToLoad)
#GSEsToLoad

#write_delim(GSEsToLoad, "/home/fieldima/R/GemmaLoadCheck/BrainScrapeMisc2.1", col_names = F)

#GSEsOldLoad <- read.delim(file = "/home/fieldima/R/GemmaLoadCheck/BrainScrapeMisc2", col.names = c("GSEsOldLoad"))

#LoadedExp <- filter(GSEsOldLoad, !GSEsOldLoad %in% GSEsToLoad$GSEsToLoad)

#write_delim(LoadedExp, "/home/fieldima/R/GemmaLoadCheck/SubSuperLoadedExps", col_names = F)

#SubSuperLoadedExpsInfo <- eeTable %>% filter(ee.Name %in% LoadedExp$GSEsOldLoad) %>% select(ee.ID, ee.Name, ee.Taxon, ad.Name, ad.Num)

#write_delim(SubSuperLoadedExpsInfo, "/home/fieldima/R/GemmaLoadCheck/SubSuperSeriesExperiments")

gse_ids <- eeTable%>%
  select(ee.Name, ee.IsPublic) %>%
  filter(ee.IsPublic == TRUE)
tail(gse_ids)
glimpse(gse_ids)

NumPublic <- sum(eeTable$ee.IsPublic)
#NumBlacklist <- sum(eeTable$ee.IsTroubled)
NumPublic

