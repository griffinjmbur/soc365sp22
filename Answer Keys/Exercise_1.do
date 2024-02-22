capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_1.log", replace

*FILE:    Exercise_1.do
*PURPOSE: Sarah's Answer Key to Exercise 1

*Set working directory
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

////// STEP 1 ////////
*** make and save your do file.

////// STEP 2 ////////
*** You can use type if you want to see the type of data you are working with
type gpa.csv, lines(10) // because we don't want super long outputs (they make our log files annoying)
						// we can use the "lines()" option to limit the number of lines displayed.
						// in this case, I have decided to display 10 lines.
						// from looking at the output, I see the looks to be comma delimited.
						
*** Reading/importing comma delimited data
insheet using gpa.csv,clear // could use "insheet"
import delimited gpa.csv,clear // could use "import delimited." I notice that that the id variable name is a little wonky.
import delimited gpa.csv , delimiters(",") clear // could try to specify the delimiter, but it still looks a bit wonky.
// I would probably go with insheet.
insheet using gpa.csv,clear 
	
*** to save the data as Stata data:
save gpa, replace // this will save a file "gpa.dta".
				// I don't have to specify the file type as ".dta" because that's the default
				// note that this saves my new gpa.dta file to my working directory (the Original data folder)
				// if I want to save it somwhere else, I have to include the path location.
	save "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Modified data/gpa.dta", replace
	// this will save a copy in my "Modified data folder"
	// note that here I had to specify the file type as ".dta" because its all within quotations

*** describe the dataset
describe // I can see that there are 732 observations (rows) and 6 variables (columns)
		// but am I sure there are actually 732 students?
		// let's investigate! (if you didn't do this for the exercise, don't worry--I wasn't really expecting it)

*** let's list some of our data
list in 1/15 // note that I limit the output because I really don't want to list the whole dataset (732 rows!!!)
			// Here, I'm listing the first 15 observations.
			// This especially important when you start to work with larger datasets
			// what do you notice in the output?
			// I notice that it looks like each student appears twice in the dataset.
			// I think this is the case because each id number occurs twice,
			// once for term 8808 and once for term 8901.

*** let's confirm our hypohtesis about the duplicate id numbers
duplicates report id // this will give me a report about duplicates for just the variable "id"
					// the output confirms my suspicion: each student is repeated twice
					// this means the number of students in my data is 366.

	// note the if you just checked for duplicates across *all* variables, you might think that
	// there were 732 unique students in the dataset:
	duplicates report
	// this is because each row is, in fact, unique in that it is for a different term.
	// this is why there are no duplicated data when considering all variables.

////// STEP 3 ////////
** there are 366 unique students (732 observations because each student appears twice)



////// STEP 4 ////////
tab female // the mini codebook included in the exercise instructions tells you that 1=female and 0= male
tab female, miss // might want to see if there is missing data. there isn't.
* 24.59% of the athletes in this dataset are female.



////// STEP 5 ////////
summarize cumgpa
sum cumgpa // can also just write "sum" for short

* The average cumulative gpa of student athletes in this dataset is 2.08.


log close
