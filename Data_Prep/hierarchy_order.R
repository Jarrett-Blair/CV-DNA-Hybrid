

setwd("C:/Users/jarre/ownCloud/CV-eDNA")

invertmatch = read.csv("invertmatch.csv")

allname = levels(as.factor(invertmatch$AllTaxa))
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
      if(which(hierarchylevels == invertmatch[which(invertmatch$AllTaxa == allname[j])[1], "Det_Level"]) < i){
        hierarchy[j,i] = as.character(invertmatch[which(invertmatch$AllTaxa == allname[j])[1],names(hierarchy)[i]])
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


write.csv(hierarchy, "hierarchy.csv", row.names = F)

