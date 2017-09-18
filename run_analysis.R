
#the run_analysis function returns a list of two dataframes which are the two dataset required in the assignement.
#
#there are some paramenters in input, useful to specify where the data folder has been located in case it is different from the working
#directory set up in R. Also it is possible to specify a different name for the data folder and a different number of subjects.
#the structure and file naming within the data folder is assumed to be the same as the one of the assignement.
#
#the libray plyr is necessary.
#
#how to call the funtion example: my_list <- run_analysis()
# tidy_data <- my_list[[1]]
# tidy_data_means <- my_list[[2]]
#
# author: Paolo Raffin; date:18SEP2017

run_analysis <- function(workingDirectory = NULL, dataFolderName = "./UCI HAR Dataset", number_of_subjects = 30) {
        
        #including necessary plibraries and 'cleaning' up the console
        library(plyr)
        cat("\014")
        
        #setting up the directory if passed
        if(!is.null(workingDirectory)){setwd(workingDirectory)}
        
        #reading the list of activities, dataframe with two column which will be used to map activity numbers to names
        activities <- read.table(paste(dataFolderName, "/activity_labels.txt", sep = ""), colClasses = c("character","character"),  col.names = c("activity_code","activity_name"))
        
        #reading the features names. 
        #I create a character vector and I 'clean' the names to make them more readable
        featuresNames <- read.table(paste(dataFolderName, "/features.txt", sep = ""))
        featuresNames <- as.character(featuresNames$V2)
        featuresNames <- gsub("\\(\\)","",featuresNames)
        featuresNames <- gsub("\\(","-",featuresNames)
        featuresNames <- gsub("\\)","-",featuresNames)
        
        #I find the index of the features names which are relted to either mean or std
        indexMeanStd <- grep("mean|std", featuresNames)
        
        #creating a char vector to be used when reading the data. in this way I only read the data about mean and std features,
        # the colClasses paramenter of  the read.table  allows us to avoid reading columns with class set as 'NULL'
        # therefore i set all column classes as NULL exceot the ones related to either mean or std
        colClass <- rep("NULL", length(featuresNames))
        colClass[indexMeanStd] <- "numeric"
        
        #i read the TRAIN dataset and set the names
        train_original_dataset <- read.table(paste(dataFolderName, "/train/X_train.txt", sep = ""), colClasses = colClass, numerals = "no.loss")
        names(train_original_dataset) <- featuresNames[indexMeanStd]
       
        #i read the activity labels of each row for the dataset and, as they are numbers, I replace them with more descriptive activity names
        train_original_dataset_activity_labels <- read.table(paste(dataFolderName, "/train/y_train.txt", sep = ""), colClasses = c("character"),  col.names = c("activity_code"))
        train_original_dataset$activity_labels <- mapvalues(train_original_dataset_activity_labels$activity_code, from = activities$activity_code, to = activities$activity_name)
        
        #i read the subjects of each row for the dataset and replace the numbers with more descriptive strings
        train_original_dataset_subjects <- read.table(paste(dataFolderName, "/train/subject_train.txt", sep = ""), colClasses = c("character"),  col.names = c("subject_number"))
        train_original_dataset$subject_number <- paste("subject_number_", train_original_dataset_subjects$subject_number, sep = "")
        
        # i decided to add a column to mark whether the observation was used for testing or training purposes
        train_original_dataset$observation_used_for <- rep("TRAIN", nrow(train_original_dataset))
                
        #i read the TEST dataset and set the names       
        test_original_dataset <- read.table(paste(dataFolderName, "/test/X_test.txt", sep = ""), colClasses = colClass, numerals = "no.loss")
        names(test_original_dataset) <- featuresNames[indexMeanStd]
        
        #i read the activity labels of each row for the dataset and, as they are numbers, I replace them with more descriptive activity names
        test_original_dataset_activity_labels <- read.table(paste(dataFolderName, "/test/y_test.txt", sep = ""), colClasses = c("character"),  col.names = c("activity_code"))
        test_original_dataset$activity_labels <- mapvalues(test_original_dataset_activity_labels$activity_code, from = activities$activity_code, to = activities$activity_name)
        
        #i read the subjects of each row for the dataset and replace the numbers with more descriptive strings
        test_original_dataset_subjects <- read.table(paste(dataFolderName, "/test/subject_test.txt", sep = ""), colClasses = c("character"),  col.names = c("subject_number"))
        test_original_dataset$subject_number <- paste("subject_number_", test_original_dataset_subjects$subject_number, sep = "")
        
        # i decided to add a column to mark whether the observation was used for testing or training purposes
        test_original_dataset$observation_used_for <- rep("TEST", nrow(test_original_dataset))
        
        # I append the two datasets - train and test - and re-order the columns so to have the activity, subject and purpose as first three - more readable
        total_tidy_dataset <- rbind(train_original_dataset,test_original_dataset)
        unordered_names <- names(total_tidy_dataset)
        ordered_names <- c(tail(unordered_names,3),head(unordered_names,length(unordered_names)-3))
        total_tidy_dataset <- total_tidy_dataset[ , ordered_names]
        
        
        
        ####CREATING SECOND TIDY DATA SET
        
        # I initialise the second dataframe and set the varaibles which i will need in the following double for loop
        second_tidy_dataset<-total_tidy_dataset[1,]
        colums_number<-ncol(total_tidy_dataset)
        index_r<-1
        
        #In this double for loop i basically loop on subjects and activities and append a row to the initialised 
        #new dataframe with the mean values for that specific pair subject/activity
        for(subject_n in 1:number_of_subjects){
                for(activity_l in activities$activity_name){
                        
                        subject_n_character <- paste("subject_number_", as.character(subject_n), sep = "")
                        data_temp <- filter(total_tidy_dataset,subject_number==subject_n_character,activity_labels==activity_l)
                        
                        if(index_r){
                        second_tidy_dataset[index_r,"subject_number"]<-subject_n_character
                        second_tidy_dataset[index_r,"activity_labels"]<-activity_l
                        second_tidy_dataset[index_r,"observation_used_for"]<-NA
                        second_tidy_dataset[index_r,4:colums_number]<-lapply(data_temp[,4:colums_number],mean)
                        index_r <- index_r+1
                        }else{
                                second_tidy_dataset <- rbind(second_tidy_dataset,list(activity_l,subject_n_character,NA,lapply(data_temp[,4:colums_number],mean)))       
                                
                        }
                        
                }
                
                
        }
        
        # save dataframes as cvs files in the working directory
        write.csv(total_tidy_dataset, file = "./total_tidy_dataset.csv")
        write.csv(second_tidy_dataset, file = "./means_tidy_dataset.csv")
        
        # save dataframes as txt files in the working directory
        write.table(total_tidy_dataset, file = "./total_tidy_dataset.txt", row.names = FALSE)
        write.table(second_tidy_dataset, file = "./means_tidy_dataset.txt", row.names = FALSE)
        
        # The funtion returns a list of the two required dataframes.
        list(total_tidy_dataset,second_tidy_dataset)
      
}