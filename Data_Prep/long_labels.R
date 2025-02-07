#Make sure to have run clean_order.R and hierarchy_order.R before this

library(stringr)
library(dplyr)


setwd("C:/Users/au761482/Git_Repos/CV-eDNA-Hybrid/Data/Clean_Data")

#Load data
invert_cleanlab = read.csv("invertmatch.csv")
edna_rmdup = read.csv("edna_rmdup.csv")
hierarchy = read.csv("hierarchy.csv")

simphier = hierarchy[,c('Species',
                        'Genus',
                        'Family',
                        'Order',
                        'Class',
                        'Phylum')]

# Create longlabels df
longlabels = simphier[match(invert_cleanlab$Fine_Name, simphier$Species), ]

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

keep_idx = longlabels$Order %in% allname

invert_cleanlab = invert_cleanlab[keep_idx,]
longlabels = longlabels[keep_idx,]

longlab_vector = apply(longlabels[,-c(1:3)], 1, function(row) {
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


edna_rmdup$LITL = NA
for(i in 1:nrow(edna_rmdup)){
  if(edna_rmdup$Det_level[i] == 'Species'){
    edna_rmdup$LITL[i] = edna_rmdup$Speciesname[i]
  }
  else{
    edna_rmdup$LITL[i] = edna_rmdup[i,edna_rmdup$Det_level[i]]
  }
}

#hier_fun from hier_fun.R
dna_hierarchy = refhier(df = edna_rmdup, 
                        ranks = ranks, 
                        base_rank = "LITL", 
                        det_level = 'Det_level')

dna_longlabels = dna_hierarchy[match(edna_rmdup$LITL, dna_hierarchy$Species), ]
# dna_longlabels$Class[which(dna_longlabels$Class %in% c("Diplopoda", "Chilopoda"))] = "Myriapoda"
# dna_longlabels$Order[which(edna_rmdup$Subclass == "Acari")] = "Acari"

# Add known column to longlabels
known_classes = unique(longlabels$Order)
dna_longlabels = getknown(dna_longlabels, known_classes)

known_level = apply(dna_longlabels, 1, function(row) {
  match(TRUE, row %in% known_classes)
})

dna_order_plus = c()
for(i in 1:nrow(dna_longlabels)){
  if(is.na(known_level[i])){
    dna_order_plus[i] = NA
  }
  else{
    dna_order_plus[i] = dna_longlabels[i,known_level[i]]
  }
}

edna_rmdup$order_plus = dna_order_plus


dnalonglab_vector = simphier[match(dna_order_plus, simphier$Order), ]
dnalonglab_vector = apply(dnalonglab_vector[,-c(1:3)], 1, function(row) {
  reversed_row <- rev(row)
  paste(reversed_row, collapse = "_")
})
edna_rmdup$longlab = dnalonglab_vector






