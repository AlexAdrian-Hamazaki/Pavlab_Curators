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
      # design <- datasetInfo(GSEid, request = 'design')
      # annotations <- datasetInfo(GSEid, request = 'annotations')
      if (is_empty(diff)) { 
        diff = list(diff = "NO DIFF")
      } else {
        diff <- list(diff = "HAS DIFF")
      }
      # if (ncol(design)==2) {
      #   design <- list(design = "NO DESIGN")
      # } else {
      #   design <- list(design = "HAS DESIGN")
      # }
      # if (length(annotations) > 0) {
      #   annotations <- list(annotations = names(annotations))
      # } else{
      #   annotations <- list(annotations = "NO DESIGN")
      # }
    

    },
    error = function(cond) {
      message(paste0(" ", GSEid, " is not in Gemma"))

      return(NA)
    }
  )
  tryCatch(
    {#try
      merged <- append(dataset[[1]], platform[[1]])
      merged <- append(merged,diff)
      # a <- append(a,design)
      # a <- append(a,annotations[1])
      return (merged)
    }, 
    error = function(cond) {
      message(cond)
    }
  )
  
}


