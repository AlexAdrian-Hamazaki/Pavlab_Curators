
# Install New packages

packages <- c(
              "tidyverse",
              "data.table",
              "rstudioapi",
              "rvest")

new_packages <- setdiff(packages, installed.packages()[,"Package"])
install.packages(new_packages)

#--- 

library(rvest)


sc_geo <- read_html("https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE116470")
