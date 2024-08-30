hier_fun = function(alldata, base_taxa, det_level = 'Det_Level'){
  
  # alldata is the dataframe
  # base_taxa is the name of the column in alldata that contains the base taxa names
  # det_level is the name of the column in alldata that contains the detection levels
  
  allname = levels(as.factor(alldata[,base_taxa]))
  
  hierarchylevels = c("Species", 
                      "Genus", 
                      "Subfamily", 
                      "Family", 
                      "Superfamily", 
                      "Infraorder", 
                      "Suborder", 
                      "Order", 
                      "Superorder", 
                      "Subclass", 
                      "Class", 
                      "Subphylum", 
                      "Phylum")
  hierarchy = data.frame(matrix(NA, nrow = length(allname), ncol = length(hierarchylevels)))
  names(hierarchy) = hierarchylevels
  hierarchy[,1] = allname
  
  for(i in 2:ncol(hierarchy)){
    for(j in 1:length(allname)){
      if(allname[j] != "Ignore"){
        if(which(hierarchylevels == alldata[which(alldata[,base_taxa] == allname[j])[1], det_level]) < i){
          hierarchy[j,i] = as.character(alldata[which(alldata[,base_taxa] == allname[j])[1],names(hierarchy)[i]])
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
