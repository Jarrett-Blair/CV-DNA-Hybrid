#' Calculates weights for classification mask
#'
#' @description
#' The `get_weights()` function takes two assemblage data frames (generated using the `get_assemblage()`
#' function) as input and outputs a data frame with the weighted classification mask weights for each 
#' taxon in the assemblages. One input data frame should represent the ground truth assemblages and the 
#' other input data frame should represent the detected assemblages (e.g. the assemblages detected using
#' DNA metabarcoding).
#'
#' @param x A data frame containing the ground truth assemblages.
#' @param y A data frame containing the detected assemblages.
#' @param all_taxa Optional parameter to input a vector of all the unique taxa names of interest if they 
#' are not all represented in column names of `x`. Default = NULL.
#' @return A data frame.
#' @export

get_weights = function(x, y, all_taxa = NULL){
  if(is.null(all_taxa)){
    all_taxa = colnames(x)
  }
  
  # Calculate precision, recall, and specificity for each label
  metrics = data.frame(label = all_taxa, precision = NA, recall = NA)
  
  for(label_index in seq_along(all_taxa)){
    true_values = x[, label_index]
    pred_values = y[, label_index]
    
    # Precision and recall
    precision = caret::posPredValue(as.factor(pred_values), as.factor(true_values), positive = "1")
    recall = caret::sensitivity(as.factor(pred_values), as.factor(true_values), positive = "1")
    
    # Store metrics
    metrics[label_index, "precision"] = precision
    metrics[label_index, "recall"] = recall
  }
  
  metrics$precision[is.nan(metrics$precision)] = 1
  
  return(metrics)
}

