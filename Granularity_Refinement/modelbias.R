#' Model-biased classification refiner.
#'
#' @description
#' The `modelbias` function refines computer vision classifications by cross-referencing them
#' with DNA metabarcoding detections. It differs from the `dnabias` function in how it handles
#' disagreements between the classifications and the DNA metabarcoding detections.
#'
#' @param dna_df Data frame of the DNA detections. The data frame must have these columns:
#'   - `sample_id`: The name of the sample the detection came from.
#'   - `known_class`: The class label known by the model (can be `NA` if it is not known by the model).
#'   - Taxonomic levels: Columns with the taxonomic name of the detection at each level. For example,
#'     the `Species` column would have the species name of the detection (e.g., Gryllus rubens), and
#'     the `Order` column would have the order level name of the detection (e.g., Orthoptera).
#' @param og_classes The original specimen classifications.
#' @param samples The sample IDs of the specimens.
#' @param agreed A logical vector that indicates if each classification was detected by the DNA in its 
#'   corresponding sample.
#' @param hierarchy A hierarchy data frame.
#' @return A list with refined classifications and levels.
#' @export

modelbias = function(dna_df, og_classes, samples, agreed, hierarchy){
  # Initializing the objects where we store the refined class names and levels.
  refined_class = c()
  refined_level = c()
  for(x in 1:length(samples)){
    current_sample = samples[x]
    classification = og_classes[x]
    # If the DNA detections agree with the presence of the detected class:
    if(agreed[x]){
      # Subset dna_df to detections where the sample_id and known_class match the classification
      sub_edna_a = subset(dna_df, sample_id == current_sample & known_class == classification)
      sub_edna_a = sub_edna_a %>%
        select(-sample_id, -known_class)
      # Find all of the taxonomic levels that have one unique value in the subsetted df (i.e.
      # they are not forked)
      common_group = which(lengths(apply(sub_edna_a, 2, unique)) == 1
                           & !apply(sub_edna_a, 2, unique) %in% c("NULL", "indet."))
      # The refined class is the name of the finest grained common group
      refined_class[x] = sub_edna_a[1, names(common_group)[1]]
      # The refined level is the taxonomic level of the finest grained common group
      refined_level[x] = names(common_group)[1]
      
    }
    # If the DNA detections do not agree with the presence of the detected class, leave the 
    # classification unchanged
    else{
      refined_class[x] = classification
      refined_level[x] = og_level[x]
    }
  }
  ret_list = list(refined_class, refined_level)
  
  return(ret_list)
}
