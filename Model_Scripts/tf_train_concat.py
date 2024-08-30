"""
@author: blair

Description:
    Training script for fusion models.
"""

from tensorflow.keras.layers import Dense, BatchNormalization, GlobalAveragePooling2D, Dropout, Activation
from tensorflow.keras.callbacks import ModelCheckpoint
from tensorflow.keras.applications.resnet50 import ResNet50
from tensorflow.keras.models import Model
from tensorflow.keras.layers import concatenate
from tensorflow.keras.optimizers import Adam
from keras.layers import Input
from sklearn.utils.class_weight import compute_class_weight
import numpy as np
import pandas as pd
import os
os.chdir(r"C:\Users\blair\OneDrive - UBC\CV-eDNA-Hybrid\ct_classifier")

import json
import argparse
import yaml
from util_order import init_seed
from tf_loader_concat import CTDataset



parser = argparse.ArgumentParser(description='Train deep learning model.')
parser.add_argument('--config', help='Path to config file', default='../configs/exp_order_fusion.yaml')
parser.add_argument('--seed', help='Seed index', type=int, default = 0)
args = parser.parse_args()

# load config
print(f'Using config "{args.config}"')
cfg = yaml.safe_load(open(args.config, 'r'))

# Unpacking some stuff from the config
cfg["seed"] = cfg["seed"][args.seed]
seed = cfg["seed"]
batch_size = cfg["batch_size"]
ncol = cfg["num_col"]
num_class = cfg["num_classes"]
experiment = cfg["experiment_name"]

# Path to the image annotations
anno_path = os.path.join(
    cfg["data_root"],
    cfg["annotate_root"],
    'train.csv'
)

# Reading in the annotations and setting class weights
meta = pd.read_csv(anno_path)
classes = meta["longlab"].values
class_weights = compute_class_weight(class_weight="balanced", classes=np.unique(classes), y=classes)
class_weights = dict(enumerate(class_weights))

# Setting the seed
init_seed(seed)

# Initialize the datasets
train_loader = CTDataset(cfg, split='train')
valid_loader = CTDataset(cfg, split='valid')

# Create TensorFlow datasets
train_data = train_loader.create_tf_dataset()
valid_data = valid_loader.create_tf_dataset()

# Define simple ANN for tabular data
inputs = Input(shape = (ncol,))
annx = Dense(128)(inputs)
annx = BatchNormalization()(annx)
annx = Activation('relu')(annx)
annx = Dropout(0.3)(annx)
ann = Model(inputs, annx)

# Define ResNet for image data
base_model = ResNet50(include_top = False, weights = 'imagenet')
x = base_model.output
x = GlobalAveragePooling2D()(x)
resnet = Model(inputs = base_model.input, outputs = x)

for layer in base_model.layers:
    layer.trainable = False

# Concatenating the ANN output with the ResNet output
concat = concatenate([ann.output, resnet.output])

# Inputting the concatenated layer to another ANN for final classification
combined = Dense(128)(concat)
combined = BatchNormalization()(combined)
combined = Activation('relu')(combined)
combined = Dropout(0.3)(combined)
combined = Dense(num_class, activation = "softmax")(combined)
model = Model(inputs = [ann.input, resnet.input], outputs = combined)
    
# Setting parameters
learning_rate = cfg['learning_rate']
optimizer = Adam(learning_rate=learning_rate)
epochs = 150

model.compile(optimizer = optimizer, loss = 'categorical_crossentropy', metrics = ['accuracy'])

# We save the models with the best loss and accuracy in case of weird outliers
cp_loss = ModelCheckpoint(f'{experiment}_loss.h5', monitor='val_loss', save_best_only=True)
cp_acc = ModelCheckpoint(f'{experiment}_acc.h5', monitor='val_accuracy', save_best_only=True)

# Model fitting
history = model.fit(train_data,
                    epochs = epochs, 
                    verbose = 1,
                    validation_data = valid_data,
                    callbacks = [cp_loss,
                                 cp_acc],
                    class_weight = class_weights)

# Finding the best epoch and saving
best_epoch = np.argmin(history.history['val_loss']) + 1
with open(f'{experiment}_{best_epoch}.json', 'w') as json_file:
    json.dump(history.history, json_file)

