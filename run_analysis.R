# Download dataset and set working directory to unzipped file folder

fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "Dataset.zip", method = "curl")
unzip("Dataset.zip")
setwd("./UCI HAR Dataset")

# Load test data and train data into R, and merge the two dataframes

testDataRaw <- read.table("./test/X_test.txt")
trainDataRaw <- read.table("./train/X_train.txt")
mergedDataRaw <- rbind(testDataRaw, trainDataRaw)

# Create new dataframe containing only the mean and standard deviation of each measurement

mergedDataNew <- mergedDataRaw[ , c(grep("mean()", featureNamesRaw[ ,2], fixed = TRUE), grep("std()", featureNamesRaw[ ,2], fixed = TRUE))]

# Loads activity IDs into R, creates a new column with IDs, and a new column with activity names

testActivityId <- read.table("./test/y_test.txt")
trainActivityId <- read.table("./train/y_train.txt")
mergedActivityId <- rbind(testActivityId, trainActivityId)

mergedDataNew$ActivityID <- NULL
mergedDataNew$ActivityID <- mergedActivityId$V1

activityName <- c()
for (i in 1:10299) {
        if (mergedActivityId$V1[i] == 1L) {
                activityNameId <- "Walking"
        } else if (mergedActivityId$V1[i] == 2L) {
                activityNameId <- "Walking_Upstairs"
        } else if (mergedActivityId$V1[i] == 3L) {
                activityNameId <- "Walking_Downstairs"
        } else if (mergedActivityId$V1[i] == 4L) {
                activityNameId <- "Sitting"
        } else if (mergedActivityId$V1[i] == 5L) {
                activityNameId <- "Standing"
        } else if (mergedActivityId$V1[i] == 6L) {
                activityNameId <- "Laying"
        }
        activityName <- c(activityName, activityNameId)
}

mergedDataNew$ActivityName <- NULL
mergedDataNew$ActivityName <- activityName

# Load feature names into R and append to dataframe as the column names

featureNamesRaw <- read.table("features.txt")
featureNamesNew <- featureNamesRaw[c(grep("mean()", featureNamesRaw[ ,2], fixed = TRUE), grep("std()", featureNamesRaw[ ,2], fixed = TRUE)), ]
colnames(mergedDataNew) <- c(as.character(featureNamesNew$V2), "ActivityID", "ActivityName")

# Load subject IDs into R and create a new column with subject IDs

testSubjectId <- read.table("./test/subject_test.txt")
trainSubjectId <- read.table("./train/subject_train.txt")
mergedSubjectId <- rbind(testSubjectId, trainSubjectId)

mergedDataNew$SubjectID <- NULL
mergedDataNew$SubjectID <- mergedSubjectId$V1

# Create a new dataframe containing the average of each variable for each activity and each subject

finalData <- aggregate(mergedDataNew, by = list(Activity = mergedDataNew$ActivityName, Subject = mergedDataNew$SubjectID), mean)
finalData$ActivityID <- NULL
finalData$ActivityName <- NULL
finalData$SubjectID <- NULL

# Writes the new dataframe to a text file

write.table(finalData, "../TidyData.txt", row.names = FALSE)
