capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_2.log", replace

*FILE:    Exercise_2.do
*PURPOSE: Week 2 Exercise - Data Cleaning

*Set working directory
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

*Read in data
type gpa_errors.csv, lines(5) // comma delimited data

insheet using gpa_errors.csv, clear

describe

*Question 4: There are 733 observations in this data set.

duplicates report

*Question 5/6: It looks like there is 1 duplicate record 
*            (2 observations that are identical)

*Question 7: tag duplicate cases
duplicates tag, gen(dup)

list if dup == 1
*Question 7 continued: Yes, it looks like we did catch a duplicate

*Question 8: drop duplicates and check
duplicates drop
list if dup == 1

describe
*Question 8 continued: There are now 732 observations in the file

*Question 9: compute mean SAT scores in the "naive" way.
*            I see problems with very high values, which are probably
*            missings.
summarize verbal, detail
summarize math, detail

* Check to see if there are other values above 800.
tab verbal if verbal > 800
tab math if math > 800


*Question 10: The issue with both of these variables are the 9999s. 
*             These are most likely missing values.
*             I will set these values to "." and re-estimate

gen verbal2 = verbal
replace verbal2 = . if verbal == 9999

gen math2 = math
replace math2 = . if math == 9999

*Check creation of new variables -- it worked 9999s have been coded to .
tab math math2 if math > 750, miss
tab verbal verbal2 if verbal > 750, miss

*Question 11: Reestimate mean SAT scores.
summarize verbal2
summarize math2

*Interpretation: The mean verbal SAT score for student athletes is 410 
*and the mean math score is 488.

*Question 12: Estimate means by gender.
bysort female: summarize verbal2
bysort female: summarize math2

*Female athletes are getting somewhat higher verbal scores and basically
*the same math scores as male athletes.

*Question 13: Check cumgpa variable
summarize cumgpa, detail


*There are two gpa values that are out of range, 17.1 and 29.7.
*We don't know what they actually are so change them to missing
*values.

gen cumgpa2 = cumgpa
replace cumgpa2 = . if cumgpa > 4

*check -- it worked
list cumgpa2 cumgpa if cumgpa > 4

summarize cumgpa2

*The cumulative gpa after we've recoded these high values is 2.08 whereas
*before it was 2.14.

*Another potnetial reason why these values might be out of range
*is if the decimal places are in the wrong place. Divide by 10
*for these cases to see how much of a difference this makes.

gen cumgpa3 = cumgpa
replace cumgpa3 = cumgpa/10 if cumgpa > 4

*Check -- it worked
list cumgpa3 cumgpa if cumgpa > 4

summarize cumgpa3

*The cumulative gpa after we've recoded these high values is 2.08 whereas
*before it was 2.14.
*
*This is the same result when we replaced the values with missings, 
*demonstrating that the results are robust to different ways of handling
*these outliers.

*There's also potentially an issue with the 0s. look at low values
tab cumgpa if cumgpa < 1

*13 percent of people have a 0 cumulative gpa. Did they really get all "F"s
*for their entire career? How does it change the results if we 
*exclude these people as well?

summarize cumgpa2 if cumgpa2 > 0
summarize cumgpa3 if cumgpa2 > 0

*It rises from 2.08 to 2.4 using the first recoded version of cumgpa 
*(where the high outliers were recoded as missing) and about the same
*for the other version, both quite substantial shifts.

capture log close

