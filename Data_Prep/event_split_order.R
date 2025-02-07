library(caret)

setwd("C:/Users/au761482/Git_Repos/CV-eDNA-Hybrid/Data/Granularity_Refinement")

mhe = read.csv("dna_mhe_order.csv")
mhe = mhe[,-1]

events = as.data.frame(table(invert_cleanlab$Event))
colnames(mhe) = c(levels(as.factor((invert_cleanlab$longlab))))
event_names = events$Var1
mhe$Event = event_names

invert_cleanlab = merge(invert_cleanlab, mhe, by = "Event", all = F)

set.seed(123)
shuffled_data <- events[sample(nrow(events)), ]

# Initialize variables for tracking
cumulative_freq <- 0
sampled_events <- character(0)
stop = nrow(invert_cleanlab) * 0.15

set.seed(123)
# Iterate through shuffled rows
for (i in 1:nrow(shuffled_data)) {
  site <- as.character(shuffled_data[i, "Var1"])
  freq <- shuffled_data[i, "Freq"]
  
  # Check if adding the current frequency exceeds 100
  if (cumulative_freq + freq >= stop) {
    sampled_events <- c(sampled_events, site)
    break
  } else {
    sampled_events <- c(sampled_events, site)
    cumulative_freq <- cumulative_freq + freq
  }
}

invert_cleanlab$order_plus = as.factor(invert_cleanlab$order_plus)
invert_cleanlab$longlab = as.factor(invert_cleanlab$longlab)
invert_cleanlab$Label = paste0(invert_cleanlab$Label, ".tif.", invert_cleanlab$ROI, ".jpg")

valid = invert_cleanlab[which(invert_cleanlab$Event %in% sampled_events),]
train = invert_cleanlab[-which(invert_cleanlab$Event %in% sampled_events),]

write.csv(train, "train.csv", row.names = F)
write.csv(valid, "valid.csv", row.names = F)


dna_train = edna_rmdup[which(edna_rmdup$event %!in% sampled_events),]
dna_train_LKTL_Long = dna_LKTL_Long[which(edna_rmdup$event %!in% sampled_events)]
