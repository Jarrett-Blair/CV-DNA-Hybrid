"""
@author: blair

Description:
    Generates sankey plots based on the outputs from the granularity refinement
    R scripts. I also use a custom modified version of sankey.py from the 
    pySankey library.
"""

import os
import numpy as np
import pandas as pd
from pySankey.sankey import sankey

os.chdir(r"C:\Carabid_Data\CV-eDNA\splits\order")

# Read in old vs refined classification levels, produced by R scripts
df = pd.read_csv("ML_DNABias.csv", sep = ",")

# Set taxonomic level names
taxaorder = np.array(["Phylum",
              "Subphylum",
              "Class",
              "Subclass",
              "Superorder",
              "Order",
              "Suborder",
              "Infraorder",
              "Superfamily",
              "Family",
              "Subfamily",
              "Genus",
              "Species"])

# Set right labels of Sankey plot (the refined labels)
rightLabels = [x in df["New"].values for x in taxaorder]
rightLabels = taxaorder[rightLabels]
rightLabels = rightLabels.tolist()

# Set left labels of Sankey plot (the old labels)
leftLabels = [x in df["Original"].values for x in taxaorder]
leftLabels = taxaorder[leftLabels]
leftLabels = leftLabels.tolist()

# Adjust gap between groups
leftgap = 0.275
rightgap = 0.1

# Make the plot
sankey(left = df["Original"], 
       right = df["New"],
       leftLabels = leftLabels,
       rightLabels = rightLabels,
       fontsize = 12,
       leftgap = leftgap,
       rightgap = rightgap)
