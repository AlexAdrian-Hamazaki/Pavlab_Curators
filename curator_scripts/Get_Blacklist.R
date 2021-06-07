library(tidyverse)
library(data.table)
library(dplyr)

files <- fread('/space/grp/nlim/CronGemmaDump/BE_Dump.TSV', sep = '\t', header = TRUE, quote = '')

Platforms = fread('/space/grp/nlim/CronGemmaDump/AD_Dump.TSV', header = TRUE, sep = '\t')

Experiments = fread('/space/grp/nlim/CronGemmaDump/EE_Dump.TSV', header = TRUE, sep = '\t', quote = '')

select(files, geo.ID)

find_banned = (files$geo.Type == 'Platform') #what nathaniel recommended
#find_banned <- grepl("Unsupported technology", files$ban.Reason)

sum(find_banned)
files[find_banned]
