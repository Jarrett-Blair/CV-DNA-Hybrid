# Extract ground truth and predicted labels
ground_truth = unname(image_multilab_train)
predicted_labels = unname(dna_multilab_train)

# Combine all labels and get unique labels
all_labels = sort(unique(unlist(c(ground_truth, predicted_labels))))

# Create a mapping of labels to indices
label_to_index = setNames(seq_along(all_labels), all_labels)

# Function to convert labels to binary arrays
label_to_binary = function(label_list) {
  binary_array = integer(length(all_labels))
  indices = unlist(label_to_index[label_list])
  binary_array[indices] = 1
  return(binary_array)
}

# Convert ground truth and predicted labels to binary format
ground_truth_bin = t(sapply(ground_truth, label_to_binary))
predicted_labels_bin = t(sapply(predicted_labels, label_to_binary))

# Combine event names with binary predicted labels
event_names = names(image_multilab_train)
df = data.frame(event = event_names, predicted_labels_bin)

# Calculate precision, recall, and specificity for each label
metrics = data.frame(label = all_labels, precision = NA, recall = NA)

for (label_index in seq_along(all_labels)) {
  true_values = ground_truth_bin[, label_index]
  pred_values = predicted_labels_bin[, label_index]
  
  # Precision and recall
  precision = posPredValue(as.factor(pred_values), as.factor(true_values), positive = "1")
  recall = sensitivity(as.factor(pred_values), as.factor(true_values), positive = "1")
  
  # Store metrics
  metrics[label_index, "precision"] = precision
  metrics[label_index, "recall"] = recall
}

# Calculate mean precision, recall, and specificity
mean_precision = mean(metrics$precision, na.rm = TRUE)
mean_recall = mean(metrics$recall, na.rm = TRUE)



