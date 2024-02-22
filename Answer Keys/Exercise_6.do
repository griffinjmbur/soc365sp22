capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_6.log", replace

*FILE:    Exercise_6.do
*PURPOSE: Answer key to Exercise 6


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

use sysd.dta, clear

**************
* QUESTION 2 *
**************

*Change variables to lower case for easier manipulation
rename *, lower

*Investiage missing values
tab gender, miss
tab race, miss
tab grade, miss

*Note: only race has missing values

**************
* QUESTION 3 *
**************
*Create a varaible that measures missing on any of the three 3 variables (although only race has missing values)
gen miss_3 = (gender == . | race == . | grade == .)

*Check variable creation by listing first 20 rows for these variables
list miss_3 gender race grade in 1/20

*Looks good so far, but this list doesn't show many cases where one var is missing.

*Look at some more with missings
list miss_3 gender race grade if gender ==. | race ==. | grade == . in 1/100

*List of cases shows that miss_3 is working

*12.79% of cases
tab miss_3, miss // we shouldn't having any "missings" for this variable, but include "miss" option to confirm



**************
* QUESTION 4 *
**************

*Missing data on plans to go to college
tab sfis51, miss

*Redo tabulation showing underlying values
numlabel, add
tab sfis51, miss

*I would treat "multiple responses" (6) as missing because I know nothing about 
*the responses chosen 
*
*I would also probably treat "don't know" (5) as missing but this could be 
*meaningfully treated as its own separate category
*
*Code 9 "Missing" is clearly missing. 




**************
* QUESTION 5 *
**************

*Are there differences in who is missing SFIS51 by gender race and grade?

tab sfis51 gender, col
tab sfis51 race, col
tab sfis51 grade, col
* note: the way that I have formatted by tabulations, I see the percent of each gender/sex/race/grade
* category that falls into each level of the sfis51 variable. This allows me to say:
* X percent of males are missing and X percent of females are missing.

*ANSWER from "eyeball" tests. 
*(1) There aren't big differences by gender 
*(2) Whites are the least likely to have missing or "don't know" values.
*(3) Students in lower grades are more likely to have missing and "dk" values.


*What about ttests?

*First create a dummy variable that indicates whether each respondent
*is missing or non missing on sfis51. Code as missing
*DK (5), multiple response (6), and missing (9)
 
gen miss_sfis51 = (sfis51 == 5 | sfis51 == 6 | sfis51 == 9)

*Check -- it worked
tab miss_sfis51 sfis51, miss

*ttests
ttest gender, by(miss_sfis51)
ttest grade,  by(miss_sfis51)

*RESULTS: 
* - No significant difference in gender in who is missing values of this var
* - Significant difference by grade. People in lower grades more likely to have missings.


/* - Race needs different code than what we learned in class. You could use a chi-square test:

tab miss_sfis51 race, col chi

	// this tells us that there are significant differences across groups
	// depending on whether or not sfis51 is missing.
	// results indicate that missingness on sfis51 is not at random across racial groups.
	*/

**************
* QUESTION 6 *
**************

*asess missing data on reasons to attend college
tab1 sfis52a-sfis52l, miss

*ANSWER: there are three reasons for missing (or potentially missing) data here
*(1) multiple responses, 
*(2) Non-response (value of 9),
*(3) System missing (value of .)

*System missing (value of .) is by far the most common. Looking at the codebook,
*I suspect that some of the system missing may be the result of the skip pattern.
*It seems like some of these questions would be hard for younger students to answer:
*To test this:

tab grade sfis52a, miss

*Confirmed! 6th and 8th graders were not asked these questions and marked as .


********************************************
*    NOTE: CLEANING DEPENDENT VARIABLES    *
********************************************
* This step was not asked of you and is sort of optional for this assignment.
* In theory, however, it's probably a good idea to do this first rather than
* jumping straight into the flag. However, since we know we are just going to drop
* these missings anyways, it may be fine to skip this (as in the original version
* of this answer key)

recode sfis52a (6/9=.), gen(sfis52a_clean) //clean: change to system missing
lab values sfis52a_clean SFIS52A // apply labels to new variable
tab sfis52a sfis52a_clean, m // check variable creation--looks good

*repeat for other variables:
recode sfis52b (6/9=.), gen(sfis52b_clean)
lab values sfis52b_clean SFIS52B
tab sfis52b sfis52b_clean, m

recode sfis52c (6/9=.), gen(sfis52c_clean)
lab values sfis52c_clean SFIS52C
tab sfis52c sfis52c_clean, m

recode sfis52d (6/9=.), gen(sfis52d_clean)
lab values sfis52d_clean SFIS52D
tab sfis52d sfis52d_clean, m

recode sfis52e (6/9=.), gen(sfis52e_clean)
lab values sfis52e_clean SFIS52E
tab sfis52e sfis52e_clean, m

recode sfis52f (6/9=.), gen(sfis52f_clean)
lab values sfis52f_clean SFIS52F
tab sfis52f sfis52f_clean, m

recode sfis52g (6/9=.), gen(sfis52g_clean)
lab values sfis52g_clean SFIS52G
tab sfis52g sfis52g_clean, m

recode sfis52h (6/9=.), gen(sfis52h_clean)
lab values sfis52h_clean SFIS52H
tab sfis52h sfis52h_clean, m

recode sfis52i (6/9=.), gen(sfis52i_clean)
lab values sfis52i_clean SFIS52I
tab sfis52i sfis52i_clean, m

recode sfis52j (6/9=.), gen(sfis52j_clean)
lab values sfis52j_clean SFIS52J
tab sfis52j sfis52j_clean, m

recode sfis52k (6/9=.), gen(sfis52k_clean)
lab values sfis52k_clean SFIS52K
tab sfis52k sfis52k_clean, m

recode sfis52l (6/9=.), gen(sfis52l_clean)
lab values sfis52l_clean SFIS52L
tab sfis52l sfis52l_clean, m

* Now that you have cleaned versions of these variables, you could use them to construct the dummy below

**************
* QUESTION 7 *
**************


gen miss=sfis52a>3 | sfis52b>3 | sfis52c>3 | sfis52d>3 | sfis52e>3 | sfis52f>3 | sfis52g>3 | sfis52h>3 | sfis52i>3 | sfis52j>3 | sfis52k>3 | sfis52l>3

*check the variable creation
list miss sfis52a-sfis52l in 1/5 /*these are all missings*/
list miss sfis52a-sfis52l in 65/70 /*look further into the file*/


tab miss sfis52a, miss
tab miss sfis52b, miss
tab miss sfis52c, miss
tab miss sfis52d, miss
tab miss sfis52e, miss
tab miss sfis52f, miss
tab miss sfis52g, miss
tab miss sfis52h, miss
tab miss sfis52i, miss
tab miss sfis52j, miss
tab miss sfis52k, miss
tab miss sfis52l, miss
*variable creation looks correct

tab miss, miss

*ANSWER: Almost 63% of respondents are missing on at least one of these variables

**************
* QUESTION 8 *
**************

drop if miss == 1

*Check the drop - looks good
tab miss, m

*Do I still have missing values for my other variables of interst (race, gender, grade)?
*Or did dropping missing on sfis52a-sfis52l fix the problem

tab miss_3, m

* I see that I still have 54 missings for race/gender/grade. I will drop these  
* as well so that my sample size remains consistent across the final analysis
drop if miss_3 == 1

*check:
tab miss_3, m


*save modified data file with dropped observations
save "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Modified data/sysd_limited.dta", replace

**************
* QUESTION 9 *
**************

*What are the most important characteristics of colleges for students, by student characteristic?

*gender/sex
bysort gender: sum sfis52a-sfis52l

*ANSWER the highest value for both boys and girls is for sfis52c (specific courses) 

*By race 
bysort race: sum sfis52a-sfis52l
  
*ANSWER:
	*The highest value for Hispanic/Latino students is sfis52b (Financial aid)
	*The highest value for white and black students is sfis52c (specific courses)
	*The highest value for Native Americans is sfis52k (reputation of college) 
		*But note very small number of observations for native americans
		*I wouldn't feel comfortable reporting this given small sample size

* NOTE that the sample size for both analyses was the same: 311
		
		
log close
exit
