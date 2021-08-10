list.of.packages <- c("gemmaAPI", "rstudioapi", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

input_txt <- read.table("input.txt", header=FALSE)

output_frame <- data.frame(Accession=character(), InGemma=character())
library(gemmaAPI)

##login to gemma
logged_in = FALSE
while (!logged_in) {
  if ((Sys.getenv('GEMMAUSERNAME') == "" ||
       Sys.getenv('GEMMAPASSWORD') == "")) {
    print(
      "You currently do not have Gemma authentication in the enviroment. Setting your usename and password now\n"
    )
    user = trimws(readline(prompt = 'Please input your username here: '))
    pass = trimws(getPass(msg = "Enter your password here: "))
  }
  else {
    print(
      "Credntials entred previously are detected. Trying to login with given information...."
    )
    user = Sys.getenv('GEMMAUSERNAME')
    pass = Sys.getenv('GEMMAPASSWORD')
  }
  tryCatch({
    setGemmaUser(user,pass)
    datasetInfo('1')
    print("Sucesfully logged in!")
    logged_in = TRUE
  },
  error = function(e) {
    print("Could not login, possibly problem with username and password. Try again")
    Sys.unsetenv('GEMMAUSERNAME')
    Sys.unsetenv('GEMMAPASSWORD')
  })
}


for (gse in unlist(input_txt[,1])){
  if (length(datasetInfo(gse)) == 0) {
    output_frame <- output_frame %>% add_row(Accession=gse ,InGemma="False")
  } else {
    output_frame <- output_frame %>% add_row(Accession=gse ,InGemma= "True")
  }
}


write.table(output_frame, "output_file.tsv", sep= "\t")
write.table(output_frame[,2], "state_only.tsv", sep= "\t", row.names = FALSE)
