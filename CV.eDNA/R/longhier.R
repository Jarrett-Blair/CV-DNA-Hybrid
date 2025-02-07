#' Long hierarchy data frame generator.
#'
#' @description
#' The `longhier` function takes a character vector of taxonomic names as input and cross references
#' them with a reference hierarchy data frame to create a long hierarchy data frame. This can be
#' useful for getting coarser grained taxonomic names from the class outputs of a classification
#' model.
#'
#' @param x A character vector of taxonomic names. These names must be found in the first column of
#' the reference hierarchy data frame.
#' @param hierarchy A reference hierarchy data frame. This can be generated using the `hierarchy`
#' function.
#' @return A data frame.
#' @export

longhier = function(x, hierarchy){

  df = data.frame(matrix(NA, nrow = length(x), ncol = ncol(hierarchy)))
  df[,1] = x
  for(i in 2:ncol(df)){
    for(j in 1:nrow(df)){
      df[j,i] = hierarchy[which(hierarchy[,i-1] == df[j,i-1])[1], i]
    }
  }
  colnames(df) = colnames(hierarchy)

  return(df)
}
