capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_4.log", replace

*FILE:    Exercise_4.do
*PURPOSE: Answer key to Exercise 4


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"


use mtf_data.dta, clear

*describe data;
describe

**************
* QUESTION 2 *
**************

*Assign value labels to V1152
*follow the codebook
tab V1152, miss

#delimit ; // I will be changing the delimiter back and forth to accomodate these long lines of code
label define V1152 0 "0:Can't say; mixed; nonresponse" 
				   1 "1:farm" 
				   2 "2:country, non-farm" 
				   3 "3:small city or town (<50,000)" 
				   4 "4:medium-sized city (50,000-100,000)" 
				   5 "5:suburb,medium-sized city" 
				   6 "6:large city (100,000-500,000)" 
				   7 "7:suburb,large city" 
				   8 "8:very large city (>500,000)" 
				   9 "9:suburb,very large city";
				   
#delimit cr
				   
label values V1152 V1152
tab V1152, miss
*these value labels are probably too long - 
*you might be better off with shorter labels 
*that will not get truncated to such a degree;

**************
* QUESTION 3 *
************** ;

*Recode V1152 to create a new 4-category variable;
recode V1152 1/3=1 4/5=2 6/9=3, gen(res_size)

#delimit ;
label define res 0 "0:Can't say; mixed and nonresponse" 
				 1 "1:Small (under 50,000)" 
				 2 "2:Medium (50,000-100,000)" 
				 3 "3:Large  (over 100,000)";
#delimit cr

label values res_size res

*note some assumptions here - that farm/country have 
*populations less than 50,000 and that suburbs should be 
*linked with the urban area, regardless of suburbs' own population sizes

*check to make sure that the recode is as expected
tab V1152 res_size, miss


**************
* QUESTION 4 *
**************

*Is population size related to expectations of completing college?
*My uninformed guess is that it is highest in largest cities

*(4a) Begin by constructing college expectations dichotomy
* first, I look at V1183
tab V1183, miss

* Now I create my new dichotomous variable
* I want 1 & 2 together (generally no) and 3 & 4 together (generally yes)
* I will make a dummy variable called "yes_coll" so I want 3 & 4 to be == 1
gen yes_coll=(V1183>=3)


*note that there are many other ways you could have constructed this variable - 
*some of which we have discussed in class
*recognize that those with missing values (-9) on the expectations 
*question will be included with "don't expect" - I don't want this 
*so will recode missing cases as missing
replace yes_coll=. if V1183==-9


*label new variable
label variable yes_coll "Expect to complete college"
label define yesno 0 "0:No" 1 "1:Yes"
label values yes_coll yesno

*Tabulate new and original variable to check recode;
tab V1183 yes_coll, miss

*(4b) now tabluate size of area of residence with 0-1 dichtomy for 
*college completion expecations;
tab res_size yes_coll // with just a simple two-way tab it's hard to tell--I need percentages!
tab res_size yes_coll, row //I can add row-wise percentages
tab res_size yes_coll, row nofreq // i can even remove the frequencies because I don't need them

*(4c) INTERPRETATION: People living in big cities are most likely of all categories to
*						expect to go to college. As population size decreases, so does the
*						percent of people who expect to go to college.

*note that the missing cases are not included in this tabulation;


**************
* QUESTION 5 *
**************

*Is population size related to experience of binge drinking?
*Again, my naive expectation is that binge drinking will be more common 
*in larger areas
tab V1108, miss

*(5a) First create the binge driking dichotomy - yes or no
gen binge=(V1108>1)

*again treat missing values as missing - i.e., exclude from analysis
replace binge=. if V1108==-9

label variable binge "Any binge drinking within the past 2 weeks" // qw LEWs
label values binge yesno

*tabulate new and original variable to check recode
tab V1108 binge, miss


*(5b) now tabluate size of area of residence with 0-1 dichtomy for 
*binge drinking experience
tab res_size binge, row nofreq

*INTERPRETATION: Interestingly, there is not much of a relationship
*			 	 between size of residence and binge drinking. 
*				 About 20% binge drink across sizes of places.
*				 However, it seems that people who live in medium-sized cities
*				 are least likely to binge drink.

*note that the missing cases are not included in this tabulation;

**************
* QUESTION 6 *
************** ;

*Are college expecations and binge drinking experiences related to 
*parents' educational attainment?

*(6a) First step is to construct a measure for highest educational attainment
*This is a bit more challenging than variables constructed above.
tab V1163, miss
tab V1164, miss

*There are many different ways that you could do this -- Important thing
*is to check that you got it right. Is your distribution the same as mine?

*Recode both parental education variables so that missing or don't know 
*are system missing in Stata (.)
recode V1163 -9=. 7=.
recode V1164 -9=. 7=.

*Rename variables so that they're easier to work with ;
rename V1163 faed
rename V1164 maed

*Create new variable that equals parent's highest ed ;

/*Father has higher*/
gen hiedu=faed if faed > maed & faed != .
*		this code creates a "hiedu" variable equal to father's education if
*		father's education is greater than mother's education and also not missing
*       It generated missing values for all cases that DON'T fit those conditions.
*		You can check by using "list faed maed hiedu in 1/50" to see that hiedu is
*		missing for rows where maed is higher, where maed and faed are equal,
*		or where faedu is missing.

/* Now we replace those missings when maedu is higher than faedu: */
replace hiedu=maed if maed > faed & maed != .

/*When they are equal, could be either*/
replace hiedu=faed if faed==maed & faed != .

/*If mother's is missing and father's isn't*/
replace hiedu=faed if maed == .   & faed != .
 
/*If father's is missing and mother's isn't*/
replace hiedu=maed if faed == .   & maed != . 

*labels
label variable hiedu "Highest educational level achieved by parents"
codebook maed // here I see that the value labels for maed is called V1164
// so I can apply those same vale labels to my new hiedu variable
label values hiedu V1164

*Look at different types of cases to make sure this worked;
list faed maed hiedu in 1/20


*All of the above cases worked correctly, but what about 
*cases in which either the father's ed or mother's ed is 
*missing and the other is not missing? ;
list faed maed hiedu if faed == . & maed ~= . in 1/100
list faed maed hiedu if faed ~= . & maed == . in 1/100

*Great it seems like it's working.


*You could also use a three-way table to make sure the
*code works ;
bysort hiedu: tab maed faed, miss


*You could also make a table to ascertain that 
*recode worked as planned;
table maed faed, miss c(mean hiedu)
// this makes a two-way table between maed and faed and fills it with the mean 
// hiedu value for people in each conditional category


*(6b) Now examine relationship between parents' education and 
*both college completion expectations and binge drinking experience;
tab hiedu yes_coll, row nofreq
tab hiedu binge, row nofreq


*INTERPRETATION: People with more highly educated parents 
*				 are more likely to expect to go to 
*				 college. Interestingly, they are also 
*				 somewhat more likely to binge drink.
*				 Perhaps because they can better afford it? ;


log close

