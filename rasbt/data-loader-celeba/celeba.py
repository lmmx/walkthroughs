# Model Zoo -- Using PyTorch Dataset Loading Utilities for Custom Datasets (Face Images from CelebA)
# via https://github.com/rasbt/deep-learning-book/blob/master/code/model_zoo/pytorch_ipynb/custom-data-loader-celeba.ipynb

# download the "img_align_celeba.zip" (1.34 GB) file from http://mmlab.ie.cuhk.edu.hk/projects/CelebA.html
# and unzip in the current directory where this script is located.
# Similarly, download the attribute list "list_attr_celeba.txt" (25.48 MB) into this directory.
# (run download_datasets.sh in this repo to download/remove archive once unzipped)

import pandas as pd
import numpy as np

df = pd.read_csv('list_attr_celeba.txt', sep="\s+", skiprows=1, usecols=['Male'])

# Make 0 (female) & 1 (male) labels instead of -1 & 1
df.loc[df['Male'] == -1, 'Male'] = 0

df.head()

# (unfinished)
