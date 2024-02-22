* 1. 
/* Make a new “do” file using the do file “standard header” we created in class 
as a template. Save your do file as exercise1_YourLastName.do in the “do” folder 
on your personal computer). In your do file, specify that your log
file should be called exercise1_YourLastName.log.Make sure that your
do and log files are called exactly the same thing other than the “.do” and 
“.log” extension. */ 

	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"
	pwd // note that this worked correctly. also, this allows you to potentially
	// not need to replace every folder here with a folder on your computer, if
	// you follow my example and just make a folder on your desktop called 
	// SOC365sp22 
	
	/* We'll need to make a folder for the answer keys. I'll leave this as a 
	comment since, after we do this once, it will generate an error message. */ 
	* mkdir "./do/answer keys"
	log using "./do/answer keys/2022-02-21 Exercise1 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-02-07 
	   SOC 365, Spring 2022.*/ 
	   
	cd ./original_data

* 2. 
/* Using your do file, read these data into Stata using one of the commands 
we discussed in class and save it as a Stata data file. Use the Stata command
“describe” to determine the contents of your data. */ 
	
	// Let's start by taking a look at the data...
	type gpa.csv, lines(20)
	// OK, so, it's a CSV -- we can see visually and also look at the extension.
	

	import delimited using gpa.csv, delimiter(",") clear 
	// This gives a slightly funky ID label. The data are still usable, but what 
	// if we try ol' reliable instead? 
	insheet using gpa.csv, clear 
	// This is a bit better. You have to take a bit of tinkerer's approach
	// w/ Stata. 

* 3. 
/* In a comment in your do file that’s easy for me to find, indicate how many
students are in the data file.*/ 

	describe
	list in 1/10 
	// Here's the only really tricky part of this data-set -- we have those
	// long-formatted data that I briefly mentioned in L2. Notice that each ID
	// appears twice. I didn't take off for this since it's a bit of an advanced
	// question, but I did want to make you think a bit. 

	duplicates report 
	// We can confirm that these are duplicates only in virtue of the ID var. 

	// and we can see that each observation has exactly one copy.
	duplicates report id
	* so, we have 366 people. 

// 4. 
/* Using the following Stata command, determine what percentage of student
athletes in these data are female

In a comment in your do file, give a one sentence interpretation of the results,
i.e., what percentage of student athletes in these data are female?*/ 

	tab female
	// This is an example of how to make value-labels. We only learned this trick
	// after this assignment was due, but I show it here since it makes things
	// so much easier. 
	// First, we define the value-label. 
	label define fem 0 "male" 1 "female"
	// Then we assign it to a variable. 
	label values female fem
	// Then check our work. 
	tab female
	* 24.58 percent are female

* 5
/* Using the following Stata command, determine what the average gpa is in this
sample. In a comment in your do file, give a one sentence interpretation of 
the results.*/

	sum cumgpa 
	// The mean GPA is 2.08. 

log close 

