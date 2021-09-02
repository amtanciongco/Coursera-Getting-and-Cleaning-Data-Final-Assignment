# Setting the working directory & load libraries
setwd("D:/Grad/Coursera/Getting and Cleaning Data/UCI HAR Dataset")
library(plyr)
library(dplyr)

# Read the files
x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")
x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")

# Reading label files
feature_labels <- read.table("./features.txt",)
activity_labels <- read.table("./activity_labels.txt")

# Naming variables for each file
feature_labels <- feature_labels[,-1]
names(x_train) <- feature_labels; names(x_test) <- feature_labels
names(subject_train) <- "Subject_Number"; names(subject_test) <- "Subject_Number"
y_train_labeled <- join(y_train,activity_labels); y_test_labeled <- join(y_test,activity_labels)
names(y_train_labeled) <- c("ID","Activity"); names(y_test_labeled) <- c("ID","Activity")

# Some polishing (convert subject IDs as numeric and put leading zeros for later sorting)
subject_test$Subject_Number <- as.numeric(subject_test$Subject_Number)
subject_train$Subject_Number <- as.numeric(subject_train$Subject_Number)
subject_test$Subject_Number <- sprintf('%02d', subject_test$Subject_Number)
subject_train$Subject_Number <- sprintf('%02d', subject_train$Subject_Number)

# Merging 
merged <- rbind(cbind(set="test",subject_test,y_test_labeled,x_test),cbind(set="train",subject_train,y_train_labeled,x_train))
merged$Subject <- paste(merged$set, merged$Subject_Number,sep="_")

# Get columns with mean & std with grep
merged <- merged %>% select("Subject","Activity",contains(c("mean","std")))

# Edit column names
y <- names(merged)
y <- gsub("^t","Time_",y)
y <- gsub("^f","Frequency_",y)
y <- gsub("^angle\\(","Angle_",y)
y <- gsub("Jerk","Jerk_",y)
y <- gsub("Mag","Mag_",y)
y <- gsub("BodyAcc", "BodyAcceleration_",y)
y <- gsub("BodyGyro", "BodyGyro_",y)
y <- gsub("GravityAcc", "GravityAcceleration_",y)
y <- gsub("-std","StandardDeviation_",y)
y <- gsub("(-)[Mm]ean","Mean_",y)
y <- gsub("\\(\\)|\\)","",y)
y <- gsub("-","",y)
y <- gsub(",","_",y)
y <- gsub("tBody","Time_Body",y)
names(merged) <- y

# Incorporating as tidy data
merged_tidydata <- merged %>% group_by(Subject, Activity) %>% summarise(across(everything(), mean))

# Final data!
View(merged_tidydata)

# Save file as csv
write.table(merged_tidydata, file="uci_har_tidy.csv",sep=",",row.names = F)
