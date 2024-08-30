"""
@author: blair

Description:
    Training script for baseline model.
"""

from tensorflow.keras.layers import Dense, BatchNormalization, GlobalAveragePooling2D, Dropout, Activation
from tensorflow.keras.callbacks import ModelCheckpoint
from tensorflow.keras.applications.resnet50 import ResNet50
from tensorflow.keras.models import Model
from tensorflow.keras.optimizers import Adam
import pandas as pd
import numpy as np
import os
os.chdir(r"C:\Users\blair\OneDrive - UBC\CV-eDNA-Hybrid\ct_classifier")

import json
import argparse
import yaml
from util_order import init_seed
from tf_loader import CTDataset

from sklearn.utils.class_weight import compute_class_weight

parser = argparse.ArgumentParser(description='Train deep learning model.')
parser.add_argument('--config', help='Path to config file', default='../configs/exp_order_base.yaml')
parser.add_argument('--seed', help='Seed index', type=int, default = 0)
args = parser.parse_args()

# load config
print(f'Using config "{args.config}"')
cfg = yaml.safe_load(open(args.config, 'r'))

# Unpacking some stuff from the config
cfg["seed"] = cfg["seed"][args.seed]
seed = cfg["seed"]
batch_size = cfg["batch_size"]
num_class = cfg["num_classes"]
experiment = cfg["experiment_name"]

output_file = f'{experiment}.txt'

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

# Initialize the dataset
train_loader = CTDataset(cfg, split='train')
valid_loader = CTDataset(cfg, split='valid')

# Create a TensorFlow dataset
train_data = train_loader.create_tf_dataset()
valid_data = valid_loader.create_tf_dataset()

# Define ResNet for image data
base_model = ResNet50(include_top = False, weights = 'imagenet')
x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128)(x)
x = BatchNormalization()(x)
x = Activation('relu')(x)
x = Dropout(0.3)(x)
predict = Dense(num_class, activation = "softmax")(x)
model = Model(inputs = base_model.input, outputs = predict)

for layer in base_model.layers:
    layer.trainable = False

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
                    class_weight=class_weights)

# Finding the best epoch and saving
best_epoch = np.argmin(history.history['val_loss']) + 1
with open(f'{experiment}_{best_epoch}.json', 'w') as json_file:
    json.dump(history.history, json_file)

