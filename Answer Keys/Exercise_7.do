capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_7.log", replace

*FILE:    Exercise_7.do
*PURPOSE: Answer key to Exercise 7


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

***Examine the data

*Householder data
use sscouples2000_hhldr.dta, clear
describe
	
*Nonhouseholder data
use sscouples2000_nonhhldr.dta, clear
describe

**************
* QUESTION 2 *
**************

***Merge data for householders and non-householders to create
***one record per couple

merge 1:1 serial using sscouples2000_hhldr.dta
tab _merge
drop _merge

*Everyone in the householder data was merged to a partner in the non-householder
*file. (_merge == 3)

*Let's look at some of the data
list serial age0 age1 sex0 sex1 in 1/10

* here I'm just performing a check to confirm that all of our couples are same-sex
list serial sex1 sex0 if sex1!=sex0

*Looks like it worked. We have same-sex male and female couples.

*If you wanted to be really thorough, you might also check that the age difference
*between partners wasn't suspiciously large:
	/*
	
	gen agediff = abs(age1-age0) // here I create a variable that shows the difference in age.
								// I have used the function abs() to make this an absolutel value
	sum agediff, detail

	sort agediff
	list agediff rel_var age0 educ0 age1 educ1 if agediff>25
		// here I am listing all couples with an age difference that puts them above
		// the 99th percentile for this variable
		// there's not a ton of information that I can use to make a decision about these
		// outliers, so I might just leave them. Or I could create a flag to run a 
		// robustness check to see if my final results differeed if I were to exclude them.

	sort serial
	
	*/

**************
* QUESTION 3 *
**************

*For now only look at same-sex male couples
tab sex0
tab sex0, nolab

keep if sex0 == 1 & sex1 == 1

*Check
tab sex0 sex1


**************
* QUESTION 4 *
**************

***Variable that indicates they are in the same ed category
	
*Check to see if we have to deal with missing values
tab educ0 educ1, miss
	
*No, we don't
	
*Create variable
gen sameeduc = (educ0 == educ1)
	
*Check to make sure the variable creation worked
bysort sameeduc: tab educ0 educ1
sort serial
list sameeduc educ0 educ1 in 1/20
	
*Creation of sameeduc appears to have worked


**************
* QUESTION 5 *
**************
	
*What proportion share the same education? ANSWER: About 53%
tab sameeduc

	
**************
* QUESTION 6 *
**************

*How does this vary by the householder's education?
tab educ1 sameeduc, row nofreq
	
*ANSWER: College graduates are quite a bit more likely to 
*be matched with each other. High school dropouts are also
*somewhat more likely to share the same education.


**************
* QUESTION 7 *
**************
	
***Save as temporary file
tempfile couples
save `couples'


**************
* QUESTION 8 *
**************

*Read in metropolitan area file
use conc_ssmale.dta
describe

*Make a 4 category variable based on quartiles
xtile conc_quart = cssex_male, nq(4)

*Check -- each quartile should contain roughly 25% of metro areas
tab conc_quart
* Looks good

lab var conc_quart "Proportion of Couples in Same-Sex Male Relationships, Quartiles"
lab def quartiles 1 "1:<=25" 2 "2:26 to <=50" 3 "3:51 to <=75" 4 "4:76 to <= 100"
lab val conc_quart quartiles

tab conc_quart

*Look at a few cases
sort cssex_male
list in 1/10 // 10 metro areas with smallest proportion of couples in same-sed male relationships
list in -10/L // 10 metro areas with largest proportion of couples in same-sed male relationships
  
  
***************
* QUESTION 9 *
**************

***Perform the merge
merge 1:m metarea using `couples'
	
*Look at some cases to check
sort cssex_male serial
list metarea cssex_male conc_quart serial educ1 educ0 in 1/20
	
*Note that the values for cssex_male for Canton,OH match in the merge file
*and the original file. The merge worked.


**************
* QUESTION 10 *
**************
	
*Relationship between concentration and likelihood of sharing ed
tab conc_quart sameeduc, row
	
*I don't see much of an obvious relationship here. Couples in the 
*2nd quartile are the most likely to share the same educational
*attainment. Maybe there's something about these towns -- smaller 
*overall, or more homogenous overall?
	
log close
exit
