* 1. 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"
	pwd // note that this worked correctly. also, this allows you to potentially
	// not need to replace every folder here with a folder on your computer, if you
	// follow my example and just make a folder on your desktop called SOC365sp22 
	log using "./do/answer keys/Exercise2 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-02-07 
	   SOC 365, Spring 2022.*/ 
	   
	cd ./original_data

// 3. 
* Using your do file, read these data into Stata using the appropriate command.
* Use the Stata command “describe” to determine the contents of your data

	* Read in data
	type gpa_errors.csv, lines(5) 

	// So, these are comma delimited data. Last time, we saw that insheet seemed
	// to handle them better. 

	insheet using gpa_errors.csv, clear

// 4. 
/* In a comment in your do file that’s easy for me to find, indicate how many
observations are in the data file. */ 

	describe
	// There are 733 observations in this data set. N.b. that an observation is
	// just a distinct set of measurements that "coheres" to some unit, but this
	// does not need to be the "atomic unit" of the population you care about
	// -- e.g., you have panel data on the same people. The "basic unit" of the
	// population might be the individual, but the observations are some 
	// intersection of a person and a point in time. 
// 5. 

/* The data has multiple observations per student for each term. In this case,
duplicate observations are those in which the values of all the variables are
identical. Check to see if there are duplicates records in the file using one
of the Stata commands we discussed in class. */ 

	duplicates report

// 6. 
/* If there are duplicates, make a comment in your do file about how many there
are. */ 

	* It looks like there is 1 duplicate record (ie, two obs. are identical). 

* Question 7: 

/* Then, generate a variable that tags duplicate observations. List the values 
of all variables for only cases with duplicates to convince yourself that you 
have indeed identified duplicates. Comment on your results in your do file.*/ 

	duplicates tag, gen(dup)
	tab dup

	list if dup == 1
	* Yes, this is clearly a duplicate. 

*Question 8: 
/* Finally, delete the duplicates leaving only one record per observation. 
List the values of all variables for cases with duplicates to make sure that 
the correct observation(s) were dropped. Now how many observations are in the 
file? */ 
	
	duplicates drop
	
	list if dup == 1
	duplicates report

	describe
	// We have successfully dropped the duplicates, and there are now 732 
	// observations in the file. 

*Question 9
/* You have been asked to compute mean SAT math and verbal scores. Do this first
in a “naïve” way without checking the data for both the math and verbal
variables (use the summarize command). What problem do you see? */ 

	summarize verbal, detail
	summarize math, detail
	
	/* OK, so, I see some really large values, which are problematic. The maximum
	SAT score actually has changed over the years. But we could either search
	the web for the maximum when these students tested or just infer that, no
	matter what the max was, 9999 is clearly much higher if we, say, try a classic
	outlier test. */ 
	
	scalar UBmath = r(p75) + 1.5*(r(p75)-r(p25))
	scalar LBmath = r(p25) - 1.5*(r(p75)-r(p25))
	
	// Remember that calling these stored results requires us to have *just* 
	// run the command. Above we did it for math; now for verbal. 
	
	summarize verbal, detail
	scalar UBverb = r(p75) + 1.5*(r(p75)-r(p25))
	scalar LBverb = r(p25) - 1.5*(r(p75)-r(p25))
	
	list math if math > UBmath | math < LBmath
	list verbal if verbal > UBverb | verbal < LBverb

	// OK, so, clearly these 9999 values are way different even from other 
	// outliers, and we can consider them data errors or missing values. 

*Question 10/11: 

/* Locate and “fix” or otherwise deal with the problem you encounter here.
Describe the problem and provide some justification for how you choose to
handle it. If you create a new variable that is the “fixed” version of the 
original variable, be sure to check your creation of the new variable by using
the most appropriate of the methods discussed in class. 
Note: do not use the drop or keep commands to “fix” the data. 

After handling the problem, re-estimate the mean SAT math and verbal scores
and comment on the results.*/ 

	/* The issue with both of these variables are the 9999s. These are most
	likely missing values. We have two options. One, we can just write down
	that they are missing; or, two, we can run some conditional commands */ 
	
	// Let's do conditional commands first. 
	
	sum verbal if verbal <= 800
	scalar verbalmean = r(mean)
	sum math if math <= 800
	scalar mathmean = r(mean)
		
	// Now let's try making them missing values. 

	gen verbal2 = verbal
	replace verbal2 = . if verbal == 9999
	sum verbal2
	scalar verbalmean2 = r(mean)

	gen math2 = math
	replace math2 = . if math == 9999
	sum math2
	scalar mathmean2 = r(mean)
	
	*Check creation of new variables -- it worked: 9999s have been coded to "."
	tab math math2 if math > 750, miss
	tab verbal verbal2 if verbal > 750, miss
	
	// Let's show that this is the same thing as making these into missing
	// values. 
	matrix results = (verbalmean, mathmean \ verbalmean2, mathmean2)
	matrix rownames results = "conditional commands" "missing values"
	matrix colnames results = "verbal" "math"
	matrix list results
	// These both fix the problem in the same way.

	* Interpretation: The mean verbal SAT score for student athletes is 410 
	* and the mean math score is 488.

*Question 12: 
/* Now estimate mean SAT math and verbal scores separately for male and female
athletes. Comment on the results. */ 

	bysort female: summarize verbal2
	bysort female: summarize math2

	*Female athletes are getting somewhat higher verbal scores and basically
	*the same math scores as male athletes.

*Question 13: 
/* Now compute average cumulative GPA. Locate and “fix” or otherwise deal with
any problems you find with this variable. Describe any problems in a comment
in your do file. Decide what you think the problem is and how you want to fix it.
Explain your thinking. If you create a new variable that is the “fixed” version 
of the original variable, be sure to check your creation of the new variable by 
using the most appropriate of the methods discussed in class. 

Note: do not use the drop or keep commands to “fix” the data. */ 

	summarize cumgpa, detail

	*There are two gpa values that are out of the conventional range, 17.1 and 29.7.
	*We don't know what they actually are so change them to missing
	*values.

	gen cumgpa2 = cumgpa
	replace cumgpa2 = . if cumgpa > 4

	* Let's make sure that this worked. 
	list cumgpa2 cumgpa if cumgpa > 4

	sum cumgpa2 cumgpa

	*The cumulative gpa after we've recoded these high values is 2.08 whereas
	*before it was 2.14.

	*Another potnetial reason why these values might be out of range
	*is if the decimal places are in the wrong place. Let's perhaps divide by 10
	*for these cases to see how much of a difference this makes.

	gen cumgpa3 = cumgpa
	replace cumgpa3 = cumgpa/10 if cumgpa > 4

	*Check -- it worked
	list cumgpa3 cumgpa if cumgpa > 4

	summarize cumgpa3

	/* The cumulative gpa after we've recoded these high values is 2.08 whereas
	before it was 2.14.

	This is the same result when we replaced the values with missings, 
	suggesting that the results are robust to different ways of handling
	these outliers. We'd still probably want to go back and check these at any
	rate because other operations -- e.g. regression -- can change since we did
	change other parts of these variables' distribution, such as their SD. 

	There's also potentially an issue with the 0s. Let's now at low values. */ 
	
	tab cumgpa if cumgpa < 1

	/* 13 percent of people have a 0 cumulative gpa. Did they really get all "F"s
	for their entire career? How does it change the results if we 
	exclude these people as well?*/ 

	summarize cumgpa2 if cumgpa2 > 0
	summarize cumgpa3 if cumgpa2 > 0

	/*It rises from 2.08 to 2.4 using the first recoded version of cumgpa 
	(where the high outliers were recoded as missing) and about the same
	for the other version, both quite substantial shifts.
	
	Why are the results not identical? Note that some set of observations
	K = {X11, X21, ... Xn1} can have the same mean if we add some second set
	to the first, say J = {Xn+11 ... } where all Xn+i, over i, are equal to the
	mean of the data-set ... but the *distribution* can change. Some people kind
	of ran into this problem naturally in thinking through this problem. So, 
	the takeaway: be careful with that method! */ 

log close

