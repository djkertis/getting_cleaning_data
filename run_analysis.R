library(dplyr)
library(reshape2)

### Setup the file structure
# Default working directory is a getdata directory within the home directory
workingDirectory <- file.path(Sys.getenv("HOME"), "getdata")

# Create the directory if necessary
if (!dir.exists(workingDirectory)) {
  dir.create(workingDirectory)
}

# Set the working directory to this directory
setwd(workingDirectory)

# If the dataset isn't local, download and extract it
if (!file.exists("UCI HAR Dataset")) {
  download.file('https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip', 
              'dataset.zip', method="curl")
  unzip('dataset.zip')
}

# Change the directory to the location of the dataset
setwd(file.path(workingDirectory, "UCI HAR Dataset"))

### Read in the data
# Read the features.txt file to get the mean and std variables
featuresData <- read.table("./features.txt",as.is=2)

# Read in the test data
testSubjectData <- read.table("./test/subject_test.txt")
testActivityData <- read.table("./test/Y_test.txt")
testXData <- read.table("./test/X_test.txt")

# Read in the Training data
trainSubjectData <- read.table("./train/subject_train.txt")
trainActivityData <- read.table("./train/Y_train.txt")
trainXData <- read.table("./train/X_train.txt")


### Extract only the measurements on the mean and standard deviation for each measurement. 
# Store the indexes and names we are interested in using
measurementIndexes <- filter(featuresData, grepl("mean\\(|std\\(", V2)) %>% select(V1,V2)
testXData <- testXData[,measurementIndexes$V1]
trainXData <- trainXData[,measurementIndexes$V1]

# Add the subjects and Activity to the data frame
testData <- cbind(testXData, testSubjectData, testActivityData)
trainData <- cbind(trainXData, trainSubjectData, trainActivityData)

### Merge the training and the test sets to create one data set.
allData <- rbind(testData, trainData)

### Appropriately label the data set with descriptive variable names
# Label the data set with descriptive variable names
names(allData) <- c(measurementIndexes$V2, "Subject", "Activity")

#### Use descriptive activity names to name the activities in the data set
# Read in the activity labels to use as a factor
activityData <- read.table("./activity_labels.txt",as.is=2)
# Change the numbers to factors
allData$Activity <- factor(allData$Activity, activityData$V1, activityData$V2)

###  Create an independent tidy data set with the average of each variable for
###    each activity and each subject.
# melt all the columns by Subject and Activity
meltedData <- melt(allData, id=c("Subject", "Activity"))

# dcast it back using mean
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

# Save the dataset
write.table(tidyData, "tidy_data.txt", row.name=FALSE)

