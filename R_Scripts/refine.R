library(stringr)
library(dplyr)
library(CV.eDNA)

parent_path = "C:/Users/au761482/OneDrive - Aarhus universitet/Documents/GitHub_repos/public/CV-DNA-Hybrid/Data"
refine_path = file.path(parent_path, "Granularity_Refinement")

hierarchy = read.csv(file.path(refine_path, "hierarchy.csv"))
dna_df = read.csv(file.path(refine_path, "dna_df.csv"))
valid = read.csv(file.path(refine_path, "valid.csv"))
train = read.csv(file.path(refine_path, "train.csv"))
num_ids = read.csv(file.path(refine_path, "num_ids.csv"))
assemblages = read.csv(file.path(refine_path, "assemblages.csv"))

num_ids = num_ids[,1]
num_ids = num_ids + 1

# named classifications
classes = c(levels(as.factor(train$longlab)))
ids = classes[num_ids]
ids = sub(".*_", "", ids)

# Initializing taxonomic granularity
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
og_levels = class_levels[match(ids, short_classes)]

# Initializing taxonomic levels of interest
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

# agreed is a logical vector indicating if the predicted class is detected by the DNA 
samples = valid$Event
event_names = assemblages$event
assemblages = subset(assemblages, select = -event)
agreed = c()
for(x in 1:length(num_ids)){
  agreed[x] = assemblages[which(event_names == samples[x]), num_ids[x]]
}
agreed = as.logical(agreed)

# These values will be used for the functions below
dna_df = dna_df[,c(taxaorder, "Event", "known_class")]
colnames(dna_df) = c(taxaorder, "sample_id", "known_class")

output_dbias = dnabias(dna_df = dna_df, 
                       og_classes = ids,
                       og_levels = og_levels,
                       samples = samples, 
                       agreed = agreed, 
                       hierarchy = hierarchy)
refined_class_dbias = output_dbias[[1]]
refined_level_dbias = output_dbias[[2]]
refined_level_dbias = str_to_title(refined_level_dbias)

# specificity change
spec_change_dbias = data.frame(cbind(og_level, refined_level_dbias))


output_mbias = modelbias(dna_df = dna_df, 
                         og_classes = ids, 
                         og_levels = og_levels,
                         samples = samples, 
                         agreed = agreed, 
                         hierarchy = hierarchy)
refined_class_mbias = output_mbias[[1]]
refined_level_mbias = output_mbias[[2]]
refined_level_mbias = str_to_title(refined_level_mbias)

spec_change_mbias = data.frame(cbind(og_level, refined_level_mbias))


refined_level_agreed = refined_level_dbias[agreed]
og_level_agreed = og_level[agreed]

spec_change_agreed = data.frame(cbind(og_level_agreed, refined_level_agreed))















