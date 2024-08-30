library(stringr)
library(dplyr)

# Set your working directory to where you have "../CV-eDNA-Hybrid/Data/Granularity_Refinement"

# Load necessary csvs
edna_rmdup = read.csv("edna_rmdup.csv")
mhe = read.csv("dna_mhe_order.csv")
valid = read.csv("valid.csv")
train = read.csv("train.csv")
hierarchy = read.csv("hierarchy.csv")

# numeric classification labels
numnewclass = read.csv("concat_DNA_preds.csv")
numnewclass = numnewclass[,1]
numnewclass = numnewclass + 1

# named classifications
classes = c(levels(as.factor(train$longlab)))
newclass = classes[numnewclass]
newclass = sub(".*_", "", newclass)

# agreed is a logical vector indicating if the predicted class is detected by the DNA 
events = mhe$event
mhe = mhe[,-1]
agreed = c()
for(x in 1:length(numnewclass)){
  agreed[x] = mhe[which(events == valid$Event[x]),numnewclass[x]]
}
agreed = as.logical(agreed)

# og_level stores the taxonomic levels of the original classifications
short_classes = levels(as.factor(unique(train$order_plus)))
class_levels = c("Subclass",
                 "Phylum",
                 "Order",
                 "Order",
                 "Order",
                 "Order",
                 "Order",
                 "Class",
                 "Order",
                 "Order",
                 "Order",
                 "Order",
                 "Subphylum",
                 "Order",
                 "Order",
                 "Order",
                 "Order")
og_level = class_levels[match(newclass, short_classes)]

# Initializing taxaorder
taxaorder = c("Species",
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

# These values will be used for the functions below
dna_df = edna_rmdup[,c(taxaorder, "Event", "order_plus")]
colnames(dna_df) = c(taxaorder, "sample_id", "known_class")
Events = valid$Event


################
### DNA Bias ###
################

# Make sure to run dnabias.R

output_DNA = dnabias(dna_df = dna_df, 
               og_classes = newclass, 
               samples = Events, 
               agreed = agreed, 
               hierarchy = hierarchy)
refined_class = output_DNA[[1]]
refined_level = output_DNA[[2]]
refined_level = str_to_title(refined_level)

spec_change = data.frame(cbind(og_level, refined_level))
colnames(spec_change) = c("Original", "New")

# This will be used to make a Sankey plot
write.csv(spec_change, "DNABias.csv")


###############
### ML Bias ###
###############

# Make sure to run modelbias.R

output_mbias = modelbias(dna_df = dna_df, 
                     og_classes = newclass, 
                     samples = Events, 
                     agreed = agreed, 
                     hierarchy = hierarchy)
refined_class_mbias = output_mbias[[1]]
refined_level_mbias = output_mbias[[2]]
refined_level_mbias = str_to_title(refined_level_mbias)

spec_change_mbias = data.frame(cbind(og_level, refined_level_mbias))
colnames(spec_change_mbias) = c("Original", "New")

# This will be used to make a Sankey plot
write.csv(spec_change_mbias, "ModelBias.csv")


####################
### Just Agreed  ###
####################

# Uses output from dnabias, so as long as you've run that section above, you
# don't need to run anything else before this

refined_level_agreed = refined_level[agreed]
og_level_agreed = og_level[agreed]

spec_change_agreed = data.frame(cbind(og_level_agreed, refined_level_agreed))
colnames(spec_change_agreed) = c("Original", "New")

# This will be used to make a Sankey plot
write.csv(spec_change_agreed, "just_agreed.csv")

