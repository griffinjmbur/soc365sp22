/* 1. Write a do file to conduct this assignment and save it as
exercise5_YourLastName.do in your “Do” folder. In your do file, specify that your
log file should be called exercise5_YourLastName.log. Use the standard do file
header that we’ve been using in class.*/ 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise5 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-03-20
	   SOC 365, Spring 2022.*/ 

	use ./original_data/NHANES.dta, clear

/* 2. Use describe to describe the contents of the data. You will see that all 
of the variables are in upper case. This is fine, but it is often a hassle to 
switch from typing commands in lower case and variable names in upper case, so 
let’s change all variable names to lower case. This is very easy to do – just 
type rename *, lower (* is shorthand for all the variables in the data set, which 
is convenient so that you don’t have to type out every single variable name). 
Type describe again to verify that all variables are now in lower case. */ 

	*Rename all variables to lower case
	rename *, lower

	*describe data
	d
	
/* 3. This is a survey of the health of Americans of all ages. So, it is necessary 
for somebody in the household – typically a parent – to respond for young 
children. This is called a proxy interview. Let’s look first at variable pad200 
(Vigorous activity over past 30 days). Tabulate pad200 and answer the following 
questions. (In your do file please label your answers as 3a., 3b., etc so that I 
can easily find them.) 
	
	a. If you were going to do any recoding of the the variable, what might you 
	do? Once you have determined the best course of action, create a new recoded 
	version of the variable. */ 

		* In terms of recoding, it probably makes sense to recode 
		* "unable to do activity" as "no" and to recode the "refused"
		* and "don't know" responses as missing.
		
		tab pad200
		
		* We've been using label list, but we can also use the numlabel command.
		numlabel, add 
			// this adds number category prefixes to all value labels in the set
		tab pad200, miss

		* Now, let's generate a new variable before recoding
		generate exercise = pad200
		recode exercise (3=2) (7/9 = .)

		* Let us tabulate the new and original variable to make sure that this
		* worked as intended. 
		tab pad200 exercise, miss
		
		* And make a quick value label for convenience. 
		label define e 1 "no vigorous activity" 2 "vigorous activity" 
		label values exercise e
	
	/* b. How many cases have missing data for this variable (common examples of
	missing data include “don’t know,” “refused,” “not applicable,” or “.”)? */
		
		* Missing data - there are 2,273 missing on the original 
		* variable (.) and an additional two missing on the newly constructed var.
		* given that I've recoded the DKs and Refused to .s 
	
	/* c. Based on a careful reading of the pdf codebook, speculate about the 
	reason for missing data. Hint: think about the characteristics of the people 
	in this data set.*/

		* Based on careful examination of the codebook, it seems likely that the 
		* missing values are for cases where the SP - sample person - is 
		* outside the age range of 12-150 yrs.

		* Nb that the codebook for pad2000 says "Target: B(12 to 150 Yrs.)"

	/* d. Using other variable(s) in the codebook, try to confirm your speculation 
	about the reason for so much missing data on this question. That is, do one 
	or two crosstabs between pad200 and other variables in the data to show 
	whether your speculation for the reason for the missing values was correct.*/
		
		* Let's check this by tabulating age when pad2000 is missing. 
		tab ridageyr if pad200==.
		
		* or this works:
		gen missing_exercise = pad200 == .  // we make a var indicating missing
		tab missing_exercise, sum(ridageyr) 
			// then run a conditional table of summary stats. 
			
			// first command shows that almost all MVs are people with under 12
			// and all 15 or younger
			
			// second command shows mean age of missings is much lower. 

/* 4. Next, let’s look at variable pad590 (hours watch TV or videos past 30 days). 
Calculate a mean number of hours watched for the entire sample. Note that this 
will require you to make an assumption about the number of hours watched by people 
in the “open ended” category of “5 hours or more.” You may also wish to use the 
midpoint number of hours for some categories. You are transforming the categories 
of this variable to your best guess of the actual hours of TV individuals watched 
in each category. (See additional clarification on this below.) Comment on your 
assumptions in the do file, i.e., why you made the decisions you did. Also, don’t 
forget to do something about the missing values.*/ 

	* First, let's look at hours of TV watched.
	tab pad590, miss

	* Then, let's generate a new variable prior to recoding. 
	gen tv = pad590

	* Now, let's recode in a way that seems to make sense and err on the side of
	* cuation: "none" coded as 0 hours, less than 1 hour coded as 0.5 hours, five
	* or more semi-arbitrarily capped as 7 hours, and missing codes assigned "."
	* Note that these recodes reflect assumptions about values for range 
	* categories (less than 1 and 5 or more). 
	
	recode tv (0 = .5) (6 = 0) (5=7) (77 99 = .)

	* Now, let's check the variable recode. 
	tab pad590 tv, miss

	* This gives a mean hours of TV watching measure for the entire sample
	* of roughly 2.6 hours per day.
	sum tv

/* 5. Next, let’s see if hours of TV differs by age. The variable that gives the 
selected person’s age is ridageyr. First, comment on the distribution of this 
variable, referring to its mean, max, and min. 

Next, determine a reasonable recode strategy to transform the continuous measure 
of age into a categorical variable so that you can meaningfully compare hours of 
TV watched across age groups. Again, there is no right or wrong answer – as the 
researcher, you can determine the most appropriate strategy. One possibility might 
be to create  categories for young children, adolescents, young adults, 
middle age, and older individuals. 

After recoding age and appropriately labeling your new variable and its values, 
compare the mean hours of TV watched across age groups. 

What do you find? */ 

	* Let's first examine the distribution of respondent's age.
	summarize ridageyr, detail
	tab ridageyr, mis
		// Huh, no missings! Let's double- and triple-check that since it's rare.
	count if ridageyr == . // looks good
	ssc install missings
	missings report ridageyr
		
	* Now, let's work on the recode. The youngest person in the sample is 2 and 
	* the oldest is 85 years or older. The mean age is 30.6

	* We might try to use categories that correspond to children, teenagers, 
	* young adults, middle age, older. 

	gen agec = ridageyr
	recode agec (0/12 = 1) (13/19 = 2) (20/35 = 3) (36/64 = 4) (65/85 = 5)
	* An alternative method is irecode. 
	gen age_cat = irecode(ridageyr, -1, 12, 19, 35, 64, 85)  
		* I use "-1" as the first number since that won't catch anyone in the
		* sample and because I don't want the first value of age_cat to be "0",
		* which is the default of irecode. 
	tab age_cat agec, mis

	* Now, let's check the creation of this variable. 
	tab ridageyr agec, miss 
		// This method produces a lot of output, Nb. We can try other methods. 
		// Let's also go ahead and label our variable. Usually, this is best to
		// do only after verifying that it has been created correctly, but at 
		// times it can be hard to check the creation without a value-label. 
	label variable agec "Age Category (based on ridageyr)"
	label define agec 1 "0-12" 2 "13-19" 3 "20-35" 4 "36-64" 5 "65-85"
	label values agec agec
	version 16: table agec, c(min ridageyr max ridageyr)	

	* Analysis: do tv hours vary by age?
	format tv %10.2f
	tab agec, sum(tv)
	* this shows that not surprisingly, retirees watch the most TV, followed by
	* teenagers

/* 6. Now let’s see whether males and females differ in the number of hours of 
TV they watch, conditional on age. So, within each of the age groups you have 
created above, you want to examine the mean number of hours of TV watched by 
males and females. Format your table with 2 decimal places and do not display  
thefrequency counts or standard deviations. Comment on your results. */

	* Firt, construct a table of mean tv hours by age group and sex. 

	tab agec riagendr, sum(tv) nost nof

	* The table shows that there are not really any noticeable differences in 
	* the number of hours of TV that men and women watch (by age). We could run
	* a set of t-tests to see this. 
	
	ttest tv, by(riagendr)
		// First, there really isn't much evidence that there is any difference
		// across gender overall. 
	bysort agec: ttest tv, by(riagendr)
		// No age-bracket has a significant difference either. 
		
		* General comment about controlling that might be helpful: 
		
		// This makes sense since age is probably not a confounder of gender and
		// TV-watching: age doesn't really influence gender except in specific
		// circumstances (e.g., generations of missing men due to wars). When 
		// would we instead find such effects? If something were spuriously
		// associated with age. 
		
		// A very interesting parallel example can be seen on the GSS. 
		use ./original_data/gss2018, clear
		reg educ height
			* Woah! Is this an example of height being a form of privilege? This
			* association has stat. sig. But it seems hard to figure out
			* why. Height is associated with biological sex, but educational
			* attainment is one area in which gender differences are close
			* to being ended (which is great news). And it's not clear what else
			* could be happening here. Hm...what if we try...
		reg educ height paeduc
			* Interestingly, the association vanishes. Why? Height is not purely
			* genetic but is also the result of class background. If you aren't
			* too keen on multiple regression, just use a categorical form of 
			* father's ed. to see the same thing. 
		bysort padeg: reg educ height
			* Now we see that the association within broad levels of father's
			* education has gone away; in other words, if you are much taller than
			* your buddy but you both have dads who just finished HS, you probably
			* aren't at a real advantage. The only reason that it might seem like
			* you are is if we compare a tall and short person chosen at random
			* because it is (slightly) more likely that the tall person is from 
			* a family with slightly higher educational attainment (and family
			* educational attainment predicts individual attainment pretty
			* well). 
		
log close
exit
