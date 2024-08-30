# -*- coding: utf-8 -*-
"""
Created on Tue Jun 18 06:29:10 2024

@author: blair

Description:
    This script evaluates the output of the baseline model. The outputs are 
    the models predictions (numeric and names), the classification probabilities,
    a confusion matrix, and an sklearn report (accuracy, precision, recall, etc.).
"""

import os
os.chdir(r"C:\Users\blair\OneDrive - UBC\CV-eDNA-Hybrid\ct_classifier")

import yaml
import argparse
import tensorflow as tf
import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import classification_report, confusion_matrix
from tf_loader import CTDataset   # Leave this, it helps for some reason
from util_order import conf_table, plt_conf


parser = argparse.ArgumentParser(description='Train deep learning model.')
parser.add_argument('--config', help='Path to config file', default='../configs')
parser.add_argument('--exp', help='Experiment name', default='exp_order_base')
args = parser.parse_args()

# load config
print(f'Using config "{args.config}"')
cfg_path = os.path.join(
    args.config,
    args.exp)
cfg = yaml.safe_load(open(cfg_path + ".yaml"))

# Unpacking config
experiment = cfg['experiment_name']
data_root = cfg['data_root']
seed = cfg['seed']

# setup entities
test_loader = CTDataset(cfg, split='valid')   
test_generator = test_loader.create_tf_dataset()

# load validation annotation file
annoPath = os.path.join(
    data_root,
    cfg["annotate_root"],
    'valid.csv'
)

# Load training annotations
trainPath = os.path.join(
    os.path.dirname(annoPath),
    'train.csv'
)
train  = pd.read_csv(trainPath)      

# Getting long (i.e. hierarchical) class names
class_labels = cfg['class_labels']
Y = train[class_labels]
Y = Y.unique()

# Encoding class labels as numeric values
encoder = LabelEncoder()
encoder.fit(Y)
labelIndex = encoder.transform(Y)

# Getting short written class names
short_labels = cfg['short_labels']
short_Y = train[short_labels]
short_Y = short_Y.unique()

# Ordering short class names
Y_ordered = sorted(Y)
short_Y_ordered = [0] * len(short_Y)
for i in labelIndex:
    short_Y_ordered[labelIndex[i]] = short_Y[i]

# Getting ground truth numeric class labels
all_true = []
for idx, (data, labels) in enumerate(test_generator):

    all_true.append(labels)
all_true = tf.concat(all_true, axis=0)
all_true = tf.argmax(all_true, axis=1)
all_true = all_true.numpy()

# Getting named long and short class names
named_true_long = [Y_ordered[index] for index in all_true]
named_true_short = [Y_ordered[index] for index in all_true]
  

# load model
model = tf.keras.models.load_model(f'model_states\{experiment}\{experiment}_loss_w.h5')

# Get softmax values and classifications
probs = model.predict(test_generator)
predicted_classes = tf.argmax(probs, axis=1)
predicted_classes = predicted_classes.numpy()

# Getting named long and short class names for predictions
named_pred_long = [Y_ordered[index] for index in predicted_classes]
named_pred_short = [Y_ordered[index] for index in predicted_classes]

# Measuring top 3 accuracy
top3_indices = np.argsort(probs, axis=1)[:, -3:]
t3_class = np.any(top3_indices == all_true[:, np.newaxis], axis=1)
t3_acc = np.mean(t3_class)

# Generating a classification report
report = classification_report(named_true_short,
                      named_pred_short,
                      output_dict=True,
                      zero_division=1)
recall_values = [report[key]['recall'] for key in set(named_true_short)]
average_recall = sum(recall_values) / len(recall_values)
        
# Generating a confusion matrix
conf_matrix = confusion_matrix(named_true_long,
                      named_pred_long,
                      labels = Y_ordered)

conf_tab = conf_table(conf_matrix, Y_ordered)    
figure, n = plt_conf(conf_tab, short_Y_ordered, report)



