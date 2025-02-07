#' Reference hierarchy data frame generator.
#'
#' @description
#' The `refhier` function takes a data set with taxonomic information for individual observations
#' as input and outputs a reference hierarchy data frame. The hierarchy data frame contains taxonomic
#' information for all unique taxa in the input data frame.
#'
#' If the taxonomic name for a given observation is missing at one or more ranks, the value for that
#' rank will be copied from the closest, coarser taxonomic rank with a name. For example, if an
#' observed species does not have an infraorder or suborder name, but it does have an order name,
#' the infraorder and suborder values for that species will match the order level name, assuming all
#' three ranks are included in `ranks`.
#'
#' @param df A data frame.
#' @param ranks A character vector of the taxonomic ranks to be included in the hierarchy. These will
#' be the column names of the output data frame.
#' @param base_rank The name of the column in `df` that contains the base taxa names (e.g. "Species")
#' @param det_level The name of the column in df that contains the detection levels. Detection levels
#' are the finest taxonomic rank that an observation was classified to. Any given value within the
#' column must correspond to the name of a column in `df`.
#' @return A data frame.
#' @export

refhier = function(df, ranks, base_rank, det_level = 'Det_Level'){

  allname = levels(as.factor(df[,base_rank]))

  hierarchy = data.frame(matrix(NA, nrow = length(allname), ncol = length(ranks)))
  names(hierarchy) = ranks
  hierarchy[,1] = allname

  for(i in 2:ncol(hierarchy)){
    for(j in 1:length(allname)){
      if(allname[j] != "Ignore"){
        if(which(ranks == df[which(df[,base_rank] == allname[j])[1], det_level]) < i){
          hierarchy[j,i] = as.character(df[which(df[,base_rank] == allname[j])[1],names(hierarchy)[i]])
        }
        else{
          hierarchy[j,i] = hierarchy[j,1]
        }
      }
      else{
        hierarchy[j,i] = hierarchy[j,1]
      }
    }
  }

  for(i in ncol(hierarchy):1){
    for(j in nrow(hierarchy):1){
      if(hierarchy[j,i] == "NULL"){
        hierarchy[j,i] = hierarchy[j,i+1]
      }
    }
  }

  return(hierarchy)
}
