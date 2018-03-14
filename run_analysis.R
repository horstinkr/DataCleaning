# programming assignment for Data Cleaning Class
# student: Reinoud Horstink - reinoud.horstink@arcadis.com

# This R script does the following:
# 1. Merge the training and the test sets to create one data set.
# 2. Extract only the measurements on the mean and standard deviation for each measurement. 
# 3. Use descriptive activity names to name the activities in the data set
# 4. Appropriately label the data set with descriptive variable names. 
# 5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.



merge_testtrain <- function() {

	# first we read both datasets by a separate function
	data_test  <- read_data ("test")
 	data_train <- read_data ("train")													
	
	# then merge both datasets into one datatable:
	data_all <- rbind(data_test, data_train, make.row.names = TRUE)						
#	data_all <- data_test																### TODO disabled for testing purposes (speed)

	# reclaim some memory
	data_test <- NULL
	data_train <- NULL
		
	return (data_all)
	
}



alter_column_names <- function (data_all) {

	# read feature names from features.txt and assign them to column names in data_all datatable

	features <- data.table(read.table("dataset/features.txt", stringsAsFactors=FALSE))

	# store features plus additional two columns in a vector
	mycolnames <- as.vector(features$V2)
	mycolnames <- c(mycolnames, "subject", "activity")
	
	# label columns with descriptive variable names
	mycolnames <- make.names(mycolnames)
	colnames(data_all) <- mycolnames

	return (data_all)
	
}



read_data <- function(dataset) {

	# read data from main X file and put into data table:
	filename <- paste("X_", dataset, ".txt", sep="")
	myfile <- paste("dataset", dataset, filename, sep="/")
	mydata <- data.table(read.table(myfile))
	
	# read subject data from file and add to data table:
	filename <- paste("subject_", dataset, ".txt", sep="")
	myfile <- paste("dataset", dataset, filename, sep="/")
	mysubject <- data.table(read.table(myfile, col.names=c("subject")))
	mydata$subject <- mysubject$subject
	
	# read activity data from file and add to data table:
	filename <- paste("y_", dataset, ".txt", sep="")
	myfile <- paste("dataset", dataset, filename, sep="/")
	myactivity <- data.table(read.table(myfile, col.names=c("activity")))
	mydata$activity <- myactivity$activity
	
	# read body_acc_x_test data from file and add this as a vector to data table:
	# no need for this assignment to read the vectors in the Inertial Data folder
	
#	print (head(mydata))
#	print (str(mydata, list.len=999))
#	print (names(mydata))
		
	return (mydata)

}



extract_meanstd <- function (data_all) {

	# Extract only the measurements on the mean and standard deviation for each measurement
	# iterate over all columns and check whether column name contains "mean", "std" or is one of the special columns "subject" or "activity"
	
	for (i in colnames(data_all)) {
		if (!grepl("mean|std", tolower(i))) {
			if ( ! i %in% c("subject", "activity")) {
				# remove column if column name does not fit the criteria
				data_all[[i]] <- NULL
			}
		}
	}
	
	return (data_all)
	
}



translate_activities <- function (data_all) {

	# use descriptive activity names to name the activities in the data set

	# load activity names from file and store in data frame
	activities <- read.table("dataset/activity_labels.txt", stringsAsFactors=FALSE)

	# add new column to main data table with translated activity names
	data_all$activity_name <- activities[ match(data_all[['activity']], activities[['V1']] ) , 'V2']
	
	return (data_all)
	
}



generate_averages <- function (data_all) {

	# From the data set in step 4 (3), create a second, independent tidy data set with the average of each variable for each activity and each subject.

	# create new empty data table with same structure as data_all data table
	DT_means <- data_all[0, ]
	numcols <- ncol(data_all)-3
	
	
	# iterate over each subject, activity and column name to calculate mean value and store it in DT_means data table
	
	for (mysubject in unique(data_all$subject)) {
	
		for (myactivity in unique(data_all$activity)) {

			# subsetted data must be converted to matrix in order to be processed by colMeans:
			x <- data.matrix(data_all[subject == mysubject & activity == myactivity, 1:numcols])
			
			# calculate colMeans over all data columns, excluding the three additional auxiliary columns for subject, activity and activity_name:
			avgs <- as.list(colMeans(x, na.rm = TRUE))
			
			# add auxiliary columns to averages vector, so that its structure resembles the original data_all table:
			avgs[["subject"]] <- mysubject
			avgs[["activity"]] <- myactivity
			avgs[["activity_name"]] <- data_all[subject == mysubject & activity == myactivity][1][["activity_name"]]
			
			# store avgs as row in data table:
			DT_means <- rbind(DT_means, avgs)
			
		}
	
	}
	
	# write output to text file:
	write.table(DT_means, "analysis_output.txt", row.name=FALSE)
	
}



# MAIN PROGRAM:

library("data.table")

# 1. Read and merge the training and the test sets to create one data set
data_all <- merge_testtrain()

# 4. Appropriately label the data set with descriptive variable names. 
# Note: this step is deliberately performed before step 2, so that step 2 will be easier.
data_all <- alter_column_names (data_all)

# 2. Extract only the measurements on the mean and standard deviation for each measurement
data_all <- extract_meanstd (data_all)

# 3. Use descriptive activity names to name the activities in the data set
data_all <- translate_activities (data_all)

# 5.From the data set in step 4 (3), create a second, independent tidy data set with the average of each variable for each activity and each subject.
generate_averages (data_all)