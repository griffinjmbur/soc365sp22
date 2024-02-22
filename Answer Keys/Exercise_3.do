capture log close
clear
set more off

log using "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Do/Exercise_3.log", replace

*FILE:    Exercise_3.do
*PURPOSE: Answer Key to Exercise 3


*This should be the path to your Original data folder, where you have saved the raw data file you just created.
cd "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Original data"

*Stata data
use S365students_raw.dta, clear

describe
codebook

***QUESTION 6***

*Label the data set
label data "Soc 365 7 Student Survey Responses"

*Add variable names (if not already entered into Stata directly) -- I did this directly 
/*
rename var1 name
rename var2 undergrad
rename var3 car
rename var4 soc357  
rename var5 soc360  
rename var6 soc361  
rename var7 soc362  
rename var8 interest   
rename var9 stata
rename var10 feet
rename var11 inches   
rename var12 id
*/


*Variable labels

lab var id        "Identifier" // note that I added an id variable
lab var name      "name"
lab var undergrad "Undergraduate = 1, Graduate = 0"
lab var car       "CAR student?"
lab var soc357    "Has taken Soc 357 or equivalent"
lab var soc360    "Has taken Soc 360 or equivalent"
lab var soc361    "Has taken Soc 361"
lab var soc362    "Has taken Soc 362"
lab var interest  "Type of research interested in"
lab var stata     "Previous stata experience"   
lab var feet      "Height - feet"
lab var feet      "Height - inches"


*Assign value labels

* here, i create a yes/no label that can be applied to many variables
* notice that I made "not applicable" values .n so I could label them as such
* when I input the data in the Stata data editor, I put .n for the two grad students
* who left the CAR variable blank
lab define yesno_lbl 1 "1:Yes" 0 "0:No" .n "not applicable"
lab val car soc357 soc360 soc361 soc362 stata yesno_lbl 

note car: only undergrads can be CAR students. not applicable for grads. // added a note to "car" variable

lab define undergrad_lbl 1 "1:Undergrad Student" 2 "2:Graduate Student"


lab def interest_lbl 1 "1:academic" 2 "2:policy"  3 "3:business"
lab val interest interest_lbl


***QUESTION 7***

*Describe content of data

describe
codebook


***QUESTION 8***

*Check contents of data. We want to see if there are missing and/or unexpected values
tab undergrad, miss
tab car, miss
tab soc357, miss
tab soc360, miss
tab soc361, miss
tab soc362, miss
tab interest, miss
tab stata, miss
tab id, miss
summarize feet, detail
tab feet if feet==. // see if there are any missing values for this continuous variable
summarize inches, detail
tab inches if inches==. // see if there are any missing values for this continuous variable


* I notice that I have one unexpected value in the variable soc361.
* this is a dummy variable, so the only values should be 1 or 0, but there is
* one observation of 2. this could be a typo from when I entered the data.
* step 1 is to see who this person is:
list name id soc361 if soc361==2

* I go back to my original surveys and check what value this should be
* I see that I made a typo. This should be a 1.
* I can fix it with "replace"

replace soc361=1 if id==5
* note that I have specified that I only want to fix the one row of my data with id=5
* check my data:
list name id soc361 if id==5
*good, now Chimamanda is corrected. In this case, it's fine to use non-universal logic because its fixing a single random typo.
*let's make sure I didn't mess anything else up the process:
tab soc361, miss
*good, when I compare this table to the table I made a few commands back (I can look in my
* stata window or my log file), this looks correct.
*I can even add a note:
note soc361: one typo identified and corrected. soc361=1 for observation id=5.

*There are two missing values on the variable "car". I chose to add them as a sepcific
*kind of missing by adding them as .n
*This allowed me to label them as "not applicable" and I added a note.
*If you just have them  missing values, you could recode this to 0
*or leave it as missing, both would be reasonable.

tab undergrad car, miss


***QUESTION 9***

*What percentage of obs are 5'6" or taller?
*There are a few ways you could do this, but I found this to be the most straight-forward

*Create a height in inches variable

gen height = (feet*12) + inches

*Check the variable creation by listing cases

list id feet inches height
* looks good!

*now let's label it properly so we know what it is
lab var height "total height in inches"

*5 foot 6 is 66 inches
* now let's create a dummy for whether each person if 66 inches or taller
gen height_5_6 = (height >= 66)

*Check the creation of this variable.
* I can see it works by looking at the min and max values in each of the categories
bysort height_5_6: summarize height

*now let's label it properly so we know what it is
lab var height_5_6 "5ft6inches or taller=1, shorter than 5ft6inches=0'"

*See what percentage are over 5'6"

tab height_5_6


*ANSWER: 42.86% are over 5'6"

***QUESTION 10***

tab soc362, miss

*28.57% have taken Soc 362.

*
* you should save this to your "modified data" folder. My path to that folder is:

save "/Users/sarahelizabethfarr/Box/Academic/Teaching/Soc 365 Spring21/Soc365/Class and exercises/Modified data/Exercise3_Farr.dta", replace


log close

