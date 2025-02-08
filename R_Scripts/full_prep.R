# Sections of the code are marked by comment dividers

#######################
# From prep.Rmd
#######################

library(stringr)
library(dplyr)
library(CV.eDNA)

parent_path = "C:/Users/au761482/OneDrive - Aarhus universitet/Documents/GitHub_repos/public/CV-DNA-Hybrid/Data"
data_path = file.path(parent_path, "Clean_Data")
image_df = read.csv(file.path(data_path, "image_df.csv"))
dna_df = read.csv(file.path(data_path, "dna_df.csv"))

ranks = c("Species", 
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

image_df$base_name = NA
dna_df$base_name = NA

for(i in 1:nrow(image_df)){
  image_df$base_name[i] = image_df[i,image_df$Det_level[i]]
}

for(i in 1:nrow(dna_df)){
  dna_df$base_name[i] = dna_df[i,dna_df$Det_level[i]]
}

image_hier = refhier(df = image_df,
                     ranks = ranks, 
                     base_rank = "base_name",
                     det_level = "Det_level")

dna_hier = refhier(df = dna_df,
                   ranks = ranks,
                   base_rank = "base_name",
                   det_level = 'Det_level')

simphier = image_hier[,c('Species',
                         'Genus',
                         'Family',
                         'Order',
                         'Class',
                         'Phylum')]

# Create longlabels df
image_longlab_df = simphier[match(image_df$base_name, simphier$Species), ]

image_longlab_vector = apply(image_longlab_df[,-c(1:3)], 1, function(row) {
  reversed_row = rev(row)
  paste(reversed_row, collapse = "_")
})
image_df$longlab = image_longlab_vector

dna_longlabels = dna_hier[match(dna_df$base_name, dna_hier$Species), ]

# Add known column to longlabels
known_classes = unique(image_longlab_df$Order)

known_level = apply(dna_longlabels, 1, function(row) {
  match(TRUE, row %in% known_classes)
})

dna_df$known_class = c()
for(i in 1:nrow(dna_longlabels)){
  if(is.na(known_level[i])){
    dna_df$known_class[i] = NA
  }
  else{
    dna_df$known_class[i] = dna_longlabels[i,known_level[i]]
  }
}

dnalonglab_vector = simphier[match(dna_df$known_class, simphier$Order), ]
dnalonglab_vector = apply(dnalonglab_vector[,-c(1:3)], 1, function(row) {
  reversed_row = rev(row)
  paste(reversed_row, collapse = "_")
})
dna_df$longlab = dnalonglab_vector

dna_rmna = dna_df[!is.na(dna_df$known_class),]
dna_assemblage = get_assemblage(obs = dna_rmna$longlab,
                                events = dna_rmna$Event,
                                all_taxa = unique(image_df$longlab)
)

########################
# Train/test split
########################

library(caret)

image_df$order_plus = sub(".*_(.*)", "\\1", image_df$longlab)

events = as.data.frame(table(image_df$Event))
dna_assemblage$Event = rownames(dna_assemblage)
image_df = merge(image_df, dna_assemblage, by = "Event", all = F)

set.seed(123)
shuffled_data = events[sample(nrow(events)), ]

# Initialize variables for tracking
cumulative_freq = 0
sampled_events = character(0)
stop = nrow(image_df) * 0.15

set.seed(123)
# Iterate through shuffled rows
for (i in 1:nrow(shuffled_data)) {
  site = as.character(shuffled_data[i, "Var1"])
  freq = shuffled_data[i, "Freq"]
  
  # Check if adding the current frequency exceeds 100
  if (cumulative_freq + freq >= stop) {
    sampled_events = c(sampled_events, site)
    break
  } 
  else {
    sampled_events = c(sampled_events, site)
    cumulative_freq = cumulative_freq + freq
  }
}

image_df$order_plus = as.factor(image_df$order_plus)
image_df$longlab = as.factor(image_df$longlab)
image_df$Label = paste0(image_df$Label, ".tif.", image_df$ROI, ".jpg")

valid = image_df[which(image_df$Event %in% sampled_events),]
train = image_df[-which(image_df$Event %in% sampled_events),]

########################
# Generate weighted mask
########################

image_assemblage = get_assemblage(obs = image_df$longlab,
                                  events = image_df$Event)

image_assemblage_train = image_assemblage[unique(train$Event),]
dna_assemblage_train = dna_assemblage[unique(train$Event),]

mask_weights = get_weights(x = image_assemblage_train,
                           y = dna_assemblage_train)
