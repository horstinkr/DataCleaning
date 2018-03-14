This file describes the data, program structure and any transformations or work that I performed to clean up the data, as programmed in R code file run_analyis.R.  

The input data is available from this url:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Within this script, it is assumed that input data has already been downloaded and extracted into the local working directory for R.

This R script does the following:
1. Merge the training and the test sets to create one data set.
2. Extract only the measurements on the mean and standard deviation for each measurement.
3. Use descriptive activity names to name the activities in the data set
4. Appropriately label the data set with descriptive variable names.
5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.

The script first defines several functions that perform specific tasks. At least every numbered activities of the script (see above) are assigned a separate function.

The main program is at the bottom of the code. It calls library data.table and then calls the five main functions. Please note that activity 4 (labeling with descriptive variable names) will be performed right after merging and loading data, since this makes the rest of the program more readible and consistent.

1. Loading and merging data sets: Using the function merge_testtrain() the data for the test and train datasets will be read using two calls to the function read_data(), since their data structure is identical. The read_data() function loads the x_test.txt / x_train.txt observations into the main data table. It then reads the subject data from file subject_test.txt / subject_train.txt and adds it as a separate column to the main data table. It then reads the activity data from file y_test.txt / y_train.txt and adds it as another separate column to the main data table. The script will _not_ read the vectors in the Inertial Data folder, since this data is not needed for this assignment.
The resulting output is a merged test+train dataset, consisting of a data table with all observations, consisting of 561 numeric variable columns plus two integer columns for "subject" and "activity".

4. Appropriately label the data set with descriptive variable names: the function translate_activities() reads the features.txt file and extracts the textual column names and stores them in a vector, with added column names "subject" and "activity". This vector is then taken as column names for the main data table with all observations.

2. Extract only the measurements on the mean and standard deviation for each measurement: using the function extract_meanstd() the program iterates over all column names, and when the column name does not contains "std" or "mean" (case-insensitive!) and is not equal to the auxiliary columns "subject" and "activity", it sets the column to NULL, effectively removing it since it is not a mean or std.

3. Use descriptive activity names to name the activities in the data set: Using the function translate_activities() we load the activities from file activity_labels.txt and add a third auxiliary column to the main data table, called "activity_name".

5. Create a second, independent tidy data set with the average of each variable for each activity and each subject: this is performed within function generate_averages(). It defines a independent data table with the same structure as the main data table. The three auxiliary columns "subject", "activity" and "activity_name" are the index for each combination of activity and subject. The function iterates over each possible combination (subject, activity) using nested for() loops and then calculates colMeans for each variable (NA values will be ignored). In order to calculate the colMeans, the subset of observations for each combination of (subject, activity) must be converted to a matrix, in order for this function colMeans to work. The averages, including the index, are stored in a list which is then added to the DT_means data table containing all calculated means. Finally this independent data table is written ot disk, named analysis_output.txt. 
