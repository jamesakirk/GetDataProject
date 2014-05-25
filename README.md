README.md:
========================================================

This is the course project for Coursera's "Getting an Cleaning Data", May 2014 session. I will explain the construction of my solution, and describe how to access the resultant data set "data.txt".

#The construction of my run_analysis.R script:

First, we read in the data sets to be merged:

```r
testX <- read.table("./UCI HAR Dataset/test/X_test.txt")
testY <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testS <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainX <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainY <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainS <- read.table("./UCI HAR Dataset/train/subject_train.txt")
```


Second, we read in and clean up the names of the activities and data variable names. We strip the superfluous row numbers and parantheses, and replace dahses with periods, so our variable names will be tidier.

```r
raw.features <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
features <- lapply(raw.features$V2, function(x) gsub("\\(\\)", "", x))
features <- lapply(features, function(x) gsub("-", ".", x))
raw.activities <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
activities <- raw.activities$V2
```


Next, we merge the training and testing data for the activity, subject, and accelerometer data. Later, we will merge the activity, subject and accelerometer data into one data frame.

```r
# 1a. Merges the training and the test sets to create one data set.
mergedX <- rbind(trainX, testX)
mergedY <- rbind(trainY, testY)
mergedS <- rbind(trainS, testS)
```


Next, we apply logical, easily-read names to our variables

```r
# 3. Uses descriptive activity names to name the activities in the data set
names(mergedX) <- features
names(mergedY) <- "activity"
names(mergedS) <- "subject"
```


Next, we search for columns in the accelerometer data who's name contains the words "mean" or "std",
because we are only interested in that subset of the data.

```r
# 2. Extract only means ond standard deviations from data
indicies <- c(grep("mean", features), grep("std", features))
mergedX <- mergedX[, indicies]
```


Next, translate the numerical factors of the activity data into descriptive english words

```r
# 4. Appropriately labels the data set with descriptive activity names.
mergedY$activity <- factor(mergedY$activity, labels = activities)
```


Next, merge the activity, subject, and accelerometer data onto one data frame

```r
# 1b. Final Merge for means and sd data set
tidy.data <- cbind(mergedY, mergedS, mergedX)
```


Next, for each (subject, activity) pair, compute the mean of each accelerometer data column. This is done with the aggregate function. Then, paste "mean-" into each accelerometer data column name to reflect the transformation of the variable. 

```r
# 5. Creates a second, independent tidy data set with the average of each
# variable for each activity and each subject.
grouped.means <- aggregate(mergedX, by = list(subject = tidy.data$subject, activity = tidy.data$activity), 
    FUN = mean, na.remove = TRUE)
# cleanup the names, to represent the computation of the mean
colNames = names(grouped.means)
colNames[-c(1, 2)] <- sapply(colNames[-c(1, 2)], function(x) paste("mean-", 
    x, sep = ""))
names(grouped.means) <- colNames
```


Finally, write the data to disk in a tab-delimited txt file:

```r
write.table(x = grouped.means, file = "data.txt", sep = "\t", row.names = FALSE)
```

========================================================

#How to access "data.txt":

"data.txt" is a tab-delimited file with column headers. To load it into R simply run:

```r
final.data <- read.table("data.txt", header = TRUE)
```

