library(tidyverse)
library(dplyr)
library(data.table)
setwd("/home/wlinshuan/R/Gemma/Pavlab_Curators/curator_scripts")
raw_list <- fread('BlackList.csv', header = TRUE, quote = "", sep=',')

i