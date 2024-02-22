capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_8.log", replace

*FILE:    Exercise_8.do
*PURPOSE: Answer key to Exercise 8


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*

* PART 1

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*

use hsb.dta, clear
describe

*Add numbers to value labels
numlabel, add

**************
* QUESTION 2 *
**************

*2A) - is father's education related to homework monitoring?

	*First look at the variables
	tab BB039, miss
	tab BB046B, miss
	
	
	*Change na's, dk's, and no fathers to missing. You can just set to . like this:
	*recode BB039 11=. 1=., gen(fed)
	*recode BB046B 3= ., gen(monitor)
	
	*OR you can set to specific kinds of missing and label them.
	*This is probably not necessary for this assignment, but I wanted to give it
	*to you in a do file so you can have it for reference!
	recode BB039 11=.d 1=.n, gen(fed)
	recode BB046B 3= .n, gen(monitor)
	
	*we can copy the original value labels and add categories:
	label copy BB039 fed_label
	label define fed_label .d "Don't Know" .n "NA", add
	label list fed_label
	label values fed fed_label
	tab fed, miss
	
	lab copy LABV monitor_lab
	lab def monitor_lab .n "NA", add
	lab list monitor_lab
	lab val monitor monitor_lab
	tab monitor, m
	
	*Check
	tab BB039 fed, miss
	tab BB046B monitor, miss

	
tab fed monitor, row

*ANSWER: we see that the proportion reporting that fathers do monitor 
*homework is higher for those with more highly educated fathers. You could
*have also tested whether this relationship was significant with a chisquare
*test. The code would be:
*    tab fed monitor, row chi2


*2B) Is student's test score related to whether father monitors homework or not?

tab monitor, sum(bbmathfs)

*On average, students whose fathers monitor their homework scored about one 
*point higher on the math test than students whose fathers do not monitor 
*homework.

*Whether or not this is a significant difference (either in substantive or 
*statistical terms) is an importnat question that you would probably want 
*to pursue using techniques like t-test or simple bivariate regression

*You could look at this with a t-test as follows:
ttest bbmathfs, by(monitor) unequal

*The ttest shows that this difference is significant at p<.01.


*2C) Is school level test score associated with the proportion of fathers 
*who monitor homework?

*first create school mean value of the math test sore
bysort schoolid: egen mmath=mean(bbmathfs)

*Next, to create school-specific proportion of fathers who monitor 
*children's homework it is useful to first create a 0-1 indicator of monitoring.
*The simple reason is that the mean value of a 0-1 variable is the proportion 
*with a value of 1 (i.e., the proportion of fathers who monitor children's 
*homework in this case)

*recode monitor from 1/2 variable to 0/1 variable
*first drop original variable 
drop monitor
gen monitor=(BB046B==1)
replace monitor = . if BB046B == . | BB046B == 3


label define yn 0 "0:No" 1 "1:Yes"
label values monitor yn

*tabulate new and original variables to confirm that recode is as you intended
tab BB046B monitor, miss
*looks good

bysort schoolid: egen mmonitor=mean(monitor)


*To answer this question, I will just look at the correlation coefficient - 
*is the average test score positively/negatively associated with the 
*proportion of fathers in the school who monitor children's homework?;

corr mmonitor mmath

/*ANSWER: Clearly, and perhaps not surprisingly, the correlation is positive 
*and of moderate size.

*You could have used techniques other than correlation - e.g., regression:

regress mmath mmonitor

*/


**************
* QUESTION 3 *
**************

*3A-3B) Now let's turn to the question on the test score gap;
*first drop all students with missing values on the math test score - 
*They will not contribute to the calcluation and could actually cause some 
*difficulties (i.e., because Stata treats missing as the largest value)
count if bbmathfs==.
drop if bbmathfs==.
count if bbmathfs==.

*Within each school generate a variable that is equal the score of the 
*student who got the highest score and lowest score
by schoolid: egen himath=max(bbmathfs)
by schoolid: egen lomath=min(bbmathfs)

*create measure of the gap in test scores
by schoolid: gen difmath=himath-lomath

*check
list schoolid difmath himath lomath bbmathfs in 1/20
list schoolid difmath himath lomath bbmathfs in 301/320
*looks good


*summarize this new variable;
sum difmath

*ANSWER: We see from this that the largest difference is 24 and the smallest difference
*is 1.33

*3C) Is the student's race associated with the size of the test score gap in 
*the school they attend?
*Simple comparison of mean values of the gap score across racial/ethnic 
*categories

tab BB089, sum(difmath)
*ANSWER: Not much difference apparent - black students appear to attend schools that, 
*on average, have a slightly lower gap in test scores but the differences is 
*not that large




*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*

* PART 2

*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*
*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*



use nlsy_excerpt_79_81.dta, clear
describe

**************
* QUESTION 4 *
**************

*tabulate value of redu
tab redu, miss

sort id year
by id: gen edchange = redu[_N]-redu[1]

*check to see what values this new variable takes
tab edchange, miss

*There are a couple of cases where people's education goes down
*Investigate these

list id year redu if edchange < 0
list id year redu edchange if id == 8032

*This person reported that their education went down which is not possible. Replace
*with missing values

replace edchange = . if edchange < 0

*Check variable creation
list id year edchange redu in 1/30

*Check missing values, when the first or last case is missing, ed change 
*is also missing. That's fine, although we could change the code so that we
*use the last non-missing value.
list id year edchange redu if edchange == . in 1/1000

*Finally, I'm not sure if it will matter that not all respondents stayed in the study
*for the same length of time (some respondents have only one survey year, some have 2, and some have 3)
*if this is completely at random, it shouldn't be a problem. But I don't know. I want to conduct
*a robustness check. I will do this by also creating an "average ed change per year" variable:

*average ed change per year
sort id year
by id: gen yrcount = _N // how many years was R in the study?
by id: gen avgedchange = edchange/yrcount
*check:
list id year yrcount edchange avgedchange in 1/30

**************
* QUESTION 5 *
**************

tab rsex, sum(edchange)
tab rsex, sum(avgedchange)
*Men's education appears to have increased more--true for both methods

*ttest for significance
ttest edchange, by(rsex) unequal
ttest avgedchange, by(rsex) unequal
*both methods suggest a statistically significant difference between males and females

**************
* QUESTION 6 *
**************
tab MARTLD, miss

gen marstatus = 1 if MARTLD == 1
replace marstatus = 0 if MARTLD == 0

*check
tab MARTLD marstatus, miss


**************
* QUESTION 7 *
**************
sort id year
by id: gen nvm_to_m = marstatus - marstatus[_n-1]

*Check - the variable is working
list id year nvm_to_m marstatus MARTLD in 1/50

*Average education level of newlywed women in these data -- 11.9 years
sum redu if nvm_to_m == 1 & rsex == 2


log close 
exit



