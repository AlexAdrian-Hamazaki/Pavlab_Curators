
# Install New packages

packages <- c(
              "tidyverse",
              "data.table",
              "rstudioapi")

new_packages <- setdiff(packages, installed.packages()[,"Package"])
install.packages(new_packages)

#--- 
