#Make sure to have run clean_order.R and hierarchy_order.R before this

library(stringr)
library(dplyr)


setwd("C:/Carabid_Data/CV-eDNA")

#Load data
invert_cleanlab = read.csv("invertmatch.csv")
edna_rmdup = read.csv("edna_rmdup.csv")
hierarchy = read.csv("hierarchy.csv")

# Fills hierarchy for given single-level labels
longhier = function(x, hierarchy){
  simphier = hierarchy[,c('Species',
                          'Genus',
                          'Family',
                          'Order',
                          'Class',
                          'Phylum')]
  
  longlabs = data.frame(matrix(NA, nrow = length(x), ncol = 6))
  longlabs[,1] = x
  for(i in 2:6){
    for(j in 1:nrow(longlabs)){
      longlabs[j,i] = simphier[which(simphier[,i-1] == longlabs[j,i-1])[1], i]
    }
  } 
  colnames(longlabs) = c("Species",
                        "Genus",
                        "Family",
                        "Order",
                        "Class",
                        "Phylum")
  return(longlabs)
}

# Create longlabels df
longlabels = longhier(invert_cleanlab$AllTaxa, hierarchy)

# Merging up finer-grain labels of gastropods and annelids
longlabels = longlabels%>%
  mutate(
    Order = case_when(
      Order == "Chilopoda" ~ "Myriapoda",
      Order == "Diplopoda" ~ "Myriapoda",
      Class == "Myriapoda" ~ "Myriapoda",
      Class == "Gastropoda" ~ "Gastropoda",
      Phylum == "Annelida" ~ "Annelida",
      TRUE ~ Order
    ),
    Class = case_when(
      Class == "Chilopoda" ~ "Myriapoda",
      Class == "Diplopoda" ~ "Myriapoda",
      Phylum == "Annelida" ~ "Annelida",
      TRUE ~ Class
    )
  )



# Determine which taxa are >100 obs
alltable = table(longlabels$Order)
allname = names(which(alltable > 99))

Orders = longlabels$Order
Keep_Orders = Orders[Orders %in% allname]
Keep_Orders = as.factor(Keep_Orders)
Keep_Orders = levels(Keep_Orders)

# Get the taxonomic level a given label is known at (i.e. which level is in Keep_Orders)
getknown = function(simphier, testlab){
  simphier$known = NA
  for(i in 1:nrow(simphier)){
    simphier$known[i] = which(simphier[i,] %in% testlab)[1]
  }
  return(simphier)
}

# Add known column to longlabels
longlabels = getknown(longlabels, Keep_Orders)

invert_cleanlab = invert_cleanlab[-which(is.na(longlabels$known)),]
longlabels = longlabels[-which(is.na(longlabels$known)),]

order_plus = c()
for(i in 1:nrow(longlabels)){
  order_plus[i] = longlabels[i,longlabels$known[i]]
}

invert_cleanlab$order_plus = order_plus

longlab_vector = apply(longlabels[,-c(1:3,7)], 1, function(row) {
  reversed_row <- rev(row)
  paste(reversed_row, collapse = "_")
})
invert_cleanlab$longlab = longlab_vector

################################################################################

# Now for the DNA
colnames(edna_rmdup) = str_to_title(colnames(edna_rmdup))
edna_rmdup$Det_level = str_to_title(edna_rmdup$Det_level)

#Rename oorder
edna_rmdup = edna_rmdup %>%
  rename(Order = Oorder)


LITL = c()
for(i in 1:nrow(edna_rmdup)){
  if(edna_rmdup$Det_level[i] == 'Species'){
    LITL[i] = edna_rmdup$Speciesname[i]
  }
  else{
    LITL[i] = edna_rmdup[i,edna_rmdup$Det_level[i]]
  }
}

edna_rmdup$LITL = LITL

#hier_fun from hier_fun.R
dna_hierarchy = hier_fun(edna_rmdup, "LITL", det_level = 'Det_level')

dna_longlabels = longhier(edna_rmdup$LITL, dna_hierarchy)
dna_longlabels$Class[which(dna_longlabels$Class %in% c("Diplopoda", "Chilopoda"))] = "Myriapoda"
dna_longlabels$Order[which(edna_rmdup$Subclass == "Acari")] = "Acari"

# Add known column to longlabels
dna_longlabels = getknown(dna_longlabels, Keep_Orders)


dna_order_plus = c()
for(i in 1:nrow(dna_longlabels)){
  if(is.na(dna_longlabels$known[i])){
    dna_order_plus[i] = NA
  }
  else{
    dna_order_plus[i] = dna_longlabels[i,dna_longlabels$known[i]]
  }
}

edna_rmdup$order_plus = dna_order_plus

dnalonglab_vector = longhier(dna_order_plus, hierarchy)
dnalonglab_vector = apply(dnalonglab_vector[,-c(1:3,7)], 1, function(row) {
  reversed_row <- rev(row)
  paste(reversed_row, collapse = "_")
})
edna_rmdup$longlab = dnalonglab_vector






