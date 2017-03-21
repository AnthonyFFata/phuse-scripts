####################################################################################
### Functions to Create from ts.xpt files from excel spreadsheet
####################################################################################
### See example spreadsheet - it can be expanded with any additional parameters
### TS File must match example for rows 1 through 3
### This code has the capabiltiy to output more than 1 TS.xpt file from 1 input file, each different study number will create a different output.  See example input file

## = Instructions
# = Code discription

## Install both R and optionally a R program like RStudio
## Install Java that matches the Bit of your computer/R program that you have installed (either 32 or 64 bit)
## To run this script, copy and paste all of the text into your R program and hit enter after text, or hit run (depends on program) after following specified instructions
####################################################################################
# Improvements that can be made: 
#    Could use file chooser result directory to use for output location
####################################################################################

## Install the required packages
install.packages("XLConnect")
install.packages("SASxport")
## You do not need to run the above 2 lines of code again once the packages are installed the first time

## R Script for TS domain starts here (after first run)
require(XLConnect)
require(SASxport)

## Open the code "write.xport2.R" on Github and save as a R script (.XPORT2) using your R program nameing it as "write" into desired folder 
## Rename the file/file path to where you saved the file "write"(ex: C:/Users/Example/Documents/R/write) into the qutoes ("File path/File Name) after the source in red font below
## Always use the "/" slash for file paths
# Here is temporary override of write xport function to get desired minimum variable lengths.
# Use environment for other function in package to allow use of unexported functions in package
	source("File path/File Name")
	tmpfun <- get("read.xport", envir = asNamespace("SASxport"))
	environment(write.xport2) <- environment(tmpfun)
	attributes(write.xport2) <- attributes(tmpfun)
	assignInNamespace("write.xport", write.xport2, ns="SASxport")

## Set the location of the folder location of your TS.xlsx file 
# Select file to read
mainDir <- "File path/File Name"
# Set output files
setwd(mainDir)

## Second popup window in R will prompt you to select the TS.xlsx imput file to read
## Sometimes this does not come up in front of your main R window

myFile <- file.choose()
# Read in XLSX file
df <- readWorksheetFromFile(myFile,
                            sheet=1,
                            startRow = 1,
                            endCol = 7)
# make copy skipping first two rows (field type and field label)
 df2 = df[-1,]
 df2 = df2[-1,]
# for those that are num, transform to numeric
  df2=transform(df2, TSSEQ = as.numeric(TSSEQ))
# set labels for each field 
  Hmisc::label(df2)=df[2,]
# For each set of rows belonging to a study create TS.XPT file
studyList <- unique(df2$STUDYID)
for(aStudy in studyList){
	# Create subdirectory
	# Set output files
	setwd(mainDir)
	if (file.exists(aStudy)){
	    setwd(file.path(mainDir, aStudy))
	} else {
	    dir.create(file.path(mainDir, aStudy))
	    setwd(file.path(mainDir, aStudy))
	}
	# filter to this study
	studyData <- subset(df2, STUDYID==aStudy,keepNA=FALSE)
	# Set length for character fields
	SASformat(studyData$DOMAIN) <-"$2."	
	# place this dataset into a list with a name
	aList = list(studyData)
	# name it
	names(aList)[1]<-"TS"
	# and label it
	attr(aList,"label") <- "TRIAL SUMMARY"
	# write out dataframe
	write.xport2(
		list=aList,
		file = "ts.xpt",
		verbose=FALSE,
		sasVer="7.00",
		osType="R 3.0.1",	
		cDate=Sys.time(),
		formats=NULL,
		autogen.formats=TRUE
	)
	aLine <- paste("Created file:  ", mainDir, "/",aStudy,"/ts.xpt",sep = "")
	print(aLine)
}  # end of study loop
setwd(mainDir)

## TS.xpt export files should be in folders with their respective study names in the same folder as your imput
