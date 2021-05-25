# Title     : 00_setup
# Objective :
# Created by: Alex
# Created on: 2021-05-25

#
# Purpose: Setup proper packages for data wranglign and visualization
#

if (!("tidyverse" %in% installed.packages())) {
  install.packages("tidyverse")
}
if (!("ggplot2" %in% installed.packages())) {
  install.packages("ggplot2")
}

library(ggplot2)
library(tidyverse)

# Library() imports a package

