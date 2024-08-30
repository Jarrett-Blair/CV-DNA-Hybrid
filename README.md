# CV-eDNA-Hybrid

### Model_Scripts
In this subdirectory you can find the python scripts required to train and evaluate our models. Scripts of note include:<br>
**tf_train.py** and **tf_train_concat.py** - These train the baseline and fusion models, respectively.<br>
**order_eval.py**, **order_concat_eval.py**, and **order_eval_allmask.py** - These evaluate the baseline, fusion, and classification masks, respectively.

### Granularity_Refinement
In this subdirectory you can find scripts to cross reference model classifications with DNA metabarcoding data to refine classification taxonomic granularity.<br>
**dnabias.R** and **modelbias.R** include functions to refine granularity using the DNA biased and model biased approaches, respectively.<br>
**applied_refinement.R** is a script that runs the granularity refinement methods on our data.<br>
**sankey_plot.py** produces a sankey plot showing the improvement in classification granularity after applying our methods.

### Data
In this subdirectory you can find all of the data we used in our study.<br>
**Granularity_Refinement** and **Model_Data** contain the data needed to run their corresponding scripts.<br>
**Raw_Data** contains the raw .csv data for our study. It is manipulated by the scripts in **Data_Prep**.