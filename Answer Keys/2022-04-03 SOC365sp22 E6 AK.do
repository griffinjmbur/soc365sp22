/* 1. Write a do file to conduct this assignment and save it as
exercise6_YourLastName.do in your “Do” folder. In your do file, specify that your
log file should be called exercise5_YourLastName.log. Use the standard do file
header that we’ve been using in class. */ 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise6 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-04-03
	   SOC 365, Spring 2022.*/ 

use ./original_data/sysd.dta, clear

/* 2. Note that the variables are all in upper case. If you prefer working 
with lower case variable names, you can use “rename *, lower” to change the case.
We’ll begin by working with the variables GENDER,RACE, and GRADE. Begin by 
tabulating these variables so you can see the distribution of data. */ 

rename *, lower

/* 3. Create a dummy variable that is equal to 1 if respondents have MVs 
on any of the following variables: GENDER, or RACE, or GRADE. Set this variable 
equal to 0 if respondents have non-missing values for all three variables. Check 
the creation of this variable using the list command (do this thoughtfully—no 
long outputs please!). Perform a tab with your new variable to determine the 
percentage of respondents who are missing values on any of these three variables. 
Comment on the results. Do the distributions change meaningfully? */ 

* Investigate missing values
tab gender, miss
tab race, miss
tab grade, miss

	* Nb: only race has missing values
	
* Create a variable that measures missingness on any of the three.
gen miss_3 = (gender == . | race == . | grade == .)
label define m3 0 "not missing grade, race, and/or gender" ///
	1 "missing grade, race, and/or gender"
label values miss_3 m3

* Check variable creation by listing first 20 rows for these variables
list miss_3 gender race grade in 1/20

* Looks good so far, but this list doesn't show many cases where one is missing.
* So, let's look at those. 
list miss_3 gender race grade if gender ==. | race ==. | grade == . in 1/100

* In short, about 12.79 percent of cases are missing on any variable. 
tab miss_3, miss 

	// we shouldn't having any "missings" for this variable, but we can include 
	// the "missing" option to confirm

* The distributions don't really change. Because race is the only missing var.,
* its distribution can't change since miss_3 == 1 iff race = . Gender happens to
* change not at all; grade changes slightly, but not really substantially. 
tab gender
tab gender if miss_3 == 0
tab race
tab race if miss_3 == 0
tab grade
tab grade if miss_3 == 0

/* 4. Let’s look at some questions regarding students’ plans to attend college  
and the factors that they consider important in choosing a college. The variable 
name for the question that asked about plans to go to college is SFIS51. Which 
codes would you treat as missing values? Would you treat values “5” and “6” as 
missing or as non-missing? Why? Answer these questions in a well-formatted 
comment in your do file. */ 

* We begin by investigating missing data on plans to go to college. 
tab sfis51, miss
* We can quickly add a number label to facilitate this analysis. 
numlabel, add
tab sfis51, miss

* I would treat "multiple responses" (6) as missing because I know nothing about 
* the responses chosen. 
*
* I would also probably treat "don't know" (5) as missing but this could be 
* meaningfully treated as its own separate category, as could "refused" (7). 

* In such a data-set, codes such as code 9 -- "missing" -- are thus likely being
* given this label as a catch-all and sadly we can say no more if so. 

/* 5. Are there differences in who is missing values of SFIS51 by gender, race, &
 grade? That is, are some people (characterized by their gender, race, and grade)
 more likely to have missing values on this question than others? From your 
 results, does it look like the values are missing at random? If not, what kinds
 of people are more likely to have missing values on this variable? You can 
 “eyeball it”, though including a proportion or a chi-square test – these 
 coincide if both predictor and outcome are dummies – gives you a chance to 
 practice your inferential statistics ☺ */ 

* Here, we can use two-way tables. 

	tab sfis51 gender, col
	tab sfis51 race, col
	tab sfis51 grade, col
	
	* Note the way that we've calculated conditional probabilities here. 

	* From an "eyeball" test standpoint, we might conclude...
	
		* 1. There aren't big differences by gender 
		* 2. Whites are the least likely to have missing or "don't know" values.
		* 3. Students in lower grades are more likely to have MVs and "dk".

	* What about inference? Let's conduct some chi-square tests.  

	* First create a dummy variable that indicates whether each respondent
	* is missing or non missing on sfis51. Code as missing
	* DK (5), multiple response (6), and missing (9). 
 
	gen miss_sfis51 = (sfis51 == 5 | sfis51 == 6 | sfis51 == 9)

	* Check to ensure that it worked. 
	tab miss_sfis51 sfis51, miss

	* And, finally, let's conduct the the tests.  
	tab gender miss_sfis51, row cchi2 chi2
	tab grade miss_sfis51, row cchi2 chi2
	tab miss_sfis51 race, col cchi2 chi2

	* So, we see no significant difference in gender in who is missing values of
	* this var, though we also see significant difference by grade and race. 
	* People in lower grades more likely to have missings, as are all non-white
	* respondents vis-a-vis white people. 
	
	* By the way, an alternative approach -- slightly more roundabout -- would be
	* to run chi-square tests on the college-plan "parent variable" and the three
	* predictors. Include the missing option and the chi-square contribution 
	* option and see if the cells involving missingness contribute strongly to
	* a significant chi-square stat. 
		
log close
exit
