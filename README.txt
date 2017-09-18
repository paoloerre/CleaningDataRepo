==================================================================
The run_analysis R script returns a list of two dataframes which are the two dataset required in the assignement.
It also saves the two dataframes as csv files in the working directory.

There are some paramenters in input, useful to specify where the data folder has been located in case it is different from the working
directory set up in R. Also it is possible to specify a different name for the data folder and a different number of subjects.
the structure and file naming within the data folder is assumed to be the same as the one of the assignement.

The libray plyr is necessary.

how to call the function example: my_list <- run_analysis()
 tidy_data <- my_list[[1]]
 tidy_data_means <- my_list[[2]]

author: Paolo Raffin; date:18SEP2017

==================================================================

The tidy total_tidy_dataset.csv includes
======================================

- A 82-feature vector with mean and std values for time and frequency domain variables for each observation. 
- The activity label for each observation. 
- An identifier of the subject for each observation.
- The purpose of the single observation (train or test)


The tidy means_tidy_dataset.csv includes
======================================

- A 82-feature vector with the values of total_tidy_dataset.csv averaged by (activity/subject) pair
- The activity label for each observation. 
- An identifier of the subject for each observation.
- The purpose of the single observation (train or test) = NA 

The overall dataset includes the following files:
=========================================

- 'README.txt'

- 'features_analysis_info.txt': Shows information about the variables used on the feature vector.

- 'features_analysis.txt': List of all features.

- 'total_tidy_dataset.csv': Tidy data set.

- 'means_tidy_dataset.csv': Tidy data set with the average features values per (activity-subject) pair.


Notes: 
======
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the csv files.

For more information about this dataset contact: paoloraffin@gmail.com

