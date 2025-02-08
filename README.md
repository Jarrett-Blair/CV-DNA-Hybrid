# CV-eDNA-Hybrid

### CV.eDNA
This subdirectory contains the files for the CV.eDNA R package. The package can be installed from the tar.gz file found in the root directory.

### Data
This subdirectory contains code vignettes of our methods and their associated data. Vignettes include data prep (`prep.Rmd`), classification granularity refinement (`granularity_refinement.Rmd`), and model training (`fusion_train.ipynb`).

### Model_Scripts
In this subdirectory you can find the python scripts required to train and evaluate our models. Scripts of note include:<br>
**tf_train.py** and **tf_train_concat.py** - These train the baseline and fusion models, respectively.<br>
**order_eval.py**, **order_concat_eval.py**, and **order_eval_allmask.py** - These evaluate the baseline, fusion, and classification masks, respectively.
