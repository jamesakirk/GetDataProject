
#0. Load in the 2 data sets:
testX  <- read.table("./UCI HAR Dataset/test/X_test.txt")
testY  <- read.table("./UCI HAR Dataset/test/Y_test.txt")
testS  <- read.table("./UCI HAR Dataset/test/subject_test.txt")
trainX  <- read.table("./UCI HAR Dataset/train/X_train.txt")
trainY  <- read.table("./UCI HAR Dataset/train/Y_train.txt")
trainS  <- read.table("./UCI HAR Dataset/train/subject_train.txt")

#0. Load in the labels:
raw.features  <- read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)
features  <- lapply(raw.features$V2, function(x) gsub("\\(\\)", "", x))
features  <- lapply(features, function(x) gsub("-", ".", x))
raw.activities  <- read.table("./UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
activities  <- raw.activities$V2

#1a. Merges the training and the test sets to create one data set.
mergedX  <- rbind(trainX, testX)
mergedY  <- rbind(trainY, testY)
mergedS  <- rbind(trainS, testS)

#3. Uses descriptive activity names to name the activities in the data set
names(mergedX)  <- features
names(mergedY)  <- "activity"
names(mergedS)  <- "subject"

#2. Extract only means ond standard deviations from data
indicies  <- c(grep("mean", features), grep("std", features))
mergedX <- mergedX[,indicies] 

#4. Appropriately labels the data set with descriptive activity names.
mergedY$activity  <- factor(mergedY$activity, labels=activities)

#1b. Final Merge for means and sd data set
tidy.data  <- cbind(mergedY, mergedS, mergedX)

#5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
grouped.means <- aggregate(mergedX, by=list(subject=tidy.data$subject, activity=tidy.data$activity), FUN=mean, na.remove = TRUE)
#cleanup the names, to represent the computation of the mean
colNames = names(grouped.means)
colNames[-c(1,2)]  <- sapply(colNames[-c(1,2)], function(x) paste("mean.", x, sep=""))
names(grouped.means)  <- colNames

#Save the tidy data sets to disk
write.table(x=grouped.means, file="data.txt",sep="\t", row.names=FALSE)