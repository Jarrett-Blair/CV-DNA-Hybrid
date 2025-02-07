# Extract ground truth and predicted labels
ground_truth = unname(image_multilab)
predicted_labels = unname(dna_multilab)

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
event_names = names(image_multilab)
df = data.frame(event = event_names, predicted_labels_bin)
