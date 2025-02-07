#' Binary assemblage data generator
#'
#' @description
#' The `get_assemblage` function takes a vector of observations and their corresponding sampling events
#' and outputs a data frame with binary assemblage data for each sampling event.
#'
#' @param obs A vector of observations (e.g. taxonomic names)
#' @param events A vector of sampling events (i.e. sample IDs)
#' @param all_taxa Optional parameter to input a vector of all the unique taxa names of interest if they
#' are not all represented in `obs`. Default = NULL
#' @return A data frame.
#' @export

get_assemblage = function(obs, events, all_taxa = NULL){
  if(is.null(all_taxa)){
    all_taxa = unique(obs)
  }

  all_taxa = sort(all_taxa)

  presence_list = lapply(split(obs, events), unique)

  # Create a mapping of labels to indices
  label_to_index = stats::setNames(seq_along(all_taxa), all_taxa)

  # Function to convert labels to binary arrays
  label_to_binary = function(label_list) {
    binary_array = integer(length(all_taxa))
    indices = unlist(label_to_index[label_list])
    binary_array[indices] = 1
    return(binary_array)
  }

  # Convert ground truth and predicted labels to binary format
  mhe_mat = t(sapply(presence_list, label_to_binary))

  # Combine event names with binary predicted labels
  event_names = names(presence_list)
  df = data.frame(mhe_mat)
  colnames(df) = all_taxa

  return(df)
}



