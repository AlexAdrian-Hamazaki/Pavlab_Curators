get_API_data <- function(GSEid) {
  #
  # Use Gemma API to get platform, differentiation, and dataset information
  # If the experiment is private, it will print "GSE is private". But the API will still succeed
  # IF the experiment is public, the API should succeed
  # If the experiment is missing a DEA, the "diff" column will read "NO DIFF"
  #
  # Returns a list of API information for a GSEid
  #
  tryCatch(
    {#try
      platform <- datasetInfo(GSEid, request = 'platforms')
      diff <- datasetInfo(GSEid, request = 'differential')
      dataset <- datasetInfo(GSEid)
      if (is_empty(diff)) { 
        diff = list(diff = "NO DIFF")
      } else {
        names(diff) <- "diff"
      }
    },
    error = function(cond) {
      message(paste0(" ", GSEid, " is not in Gemma"))

      return(NA)
    }
  )
  merged <- tryCatch(
    {#try
      a <- append(dataset[[1]], platform[[1]])
      a <- append(a,diff[1])
    }, 
    error = function(cond) {
      message(cond)
    }
  )
  return (merged)
}


