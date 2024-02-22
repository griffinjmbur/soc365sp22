capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_5.log", replace

*FILE:    Exercise_5.do
*PURPOSE: Answer key to Exercise 5


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

**************
* QUESTION 2 *
**************

*These are the data
use nhanes.dta
describe

*Rename all variables to lower case
rename *, lower

*describe data
describe


**************
* QUESTION 3 *
**************

*First tabulate the measure of vigorous physical activity
tab pad200, miss



//// 3A ////
*In terms of recoding, it probably makes sense to recode 
*"unable to do activity" as "no" and to recode the refused 
*and don't know responses as missing

*need to look at codebook or retabulate to view category values
*let's use the numlabel command
numlabel, add // this adds number category prefixes to all value labels in the dataset
tab pad200, miss

*generate a new variable before recoding
gen exercise=pad200
recode exercise 3=2 7/9=.

*tabulate new and original variables to make sure that you have done 
*the recoding as you intended
tab pad200 exercise, miss




//// 3B ////
*Missing data - there are 2,273 missing on the original 
*variable (.) and additional two missing on the newly constructed variable
*given that I've recoded the DKs and Refused to .s 




//// 3C ////
*Reason for missing values - based on careful examination of the 
*codebook, it seems likely that the 2,273 missing values are for cases 
*where the SP - sample person - is outside the age range of 12-150 yrs.

*Note the codebook description for pad2000 says "Target: B(12 Yrs. to 150 Yrs.)"



//// 3D ////
*check this by tabulating age when pad2000 is missing
tab ridageyr if pad200==., miss

*Most but not all of the missing cases are under age 12
*A smaller number of missing cases are 12-15 


**************
* QUESTION 4 *
**************

*Look at hours of TV watched
tab pad590, miss

*begin by generating a new variable prior to recoding
gen tv=pad590

*recode appropriately - "none" coded as 0 hours, less than 1 hour coded 
*as 0.5 hours, 5 or more arbitrarily coded as 7 hours, and missing codes 
*are assigned missing value
*note that these recodes reflect assumptions about values for range 
*categories (less than 1 and 5 or more)
recode tv 0=.5 6=0 5=7 77=. 99=.

*Check the variable recode
tab pad590 tv, miss

*This gives a mean hours of TV watching measure for the entire sample
*About 2.6 hours per day.
sum tv


**************
* QUESTION 5 *
************** 

*Distribution of respondent's age.
summarize ridageyr, detail
count if ridageyr==. // this allows me to see how many instances of . there are for ridageyr
					 // there are no missings

*The youngest person in the sample is 2 and the oldest is 85 years or older
*(85 is an open ended age category). The mean age is 30.6

*Recode respondent's age into a categorical variable
*I will use categories that correspond to children, teenagers, 
*young adults, middle age, older

gen agec=ridageyr
recode agec 0/12=1 13/19=2 20/35=3 36/64=4 65/85=5

*Check the creation of this variable 
tab ridageyr agec, miss //this output is a tad long, but in this case it is acceptable
						//to feel confident that new variable was correctly generated
						
*Another option for checking this variable would be a combination of:
bysort agec: sum ridageyr // I can see the min and max age for each category
count if agec==. // confirm that I didn't accidentally generate any missings

*label the new variable and its values
label variable agec "Age Category (based on ridageyr)"
label define agec 1 "1:0-12" 2 "2:13-19" 3 "3:20-35" 4 "4:36-64" 5 "5:65-85"
label values agec agec

*Analysis: does tv hours vary by age?
format tv %10.2f
tab age, sum(tv)
*this shows that not surprisingly, retirees watch the most TV, followed by
*teenagers



**************
* QUESTION 6 *
**************

*construct a table of mean tv hours by age group and sex

tab age riagendr, sum(tv) nost nof

*The table shows that there are not really any noticeable differences in 
*the number of hours of TV that men and women watch (by age)

log close
exit
