/* 1. Write a do file to conduct this assignment and save it as 
Exercise4_YourLastName.do in your “do” folder. In your do file, specify that
your log file should be called “Exercise4_YourLastName.log”. Use the standard 
do file header that we’ve been using in this class. */ 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise4 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-02-24 
	   SOC 365, Spring 2022.*/ 


	use ./original_data/mtf_data.dta, clear

/* 2. Use the information in the codebook (the pdf file mtf_codebook.pdf, which 
also should be in your “original_data” folder) to apply a variable label and 
value labels to V1152 (the type and size of the area in which the respondent 
lives). Values for all the other variables in the extract file are clearly 
labeled as in the codebook. */ 

	d

	tab V1152, miss
	
	label define V1152lab 0 "Can't say; mixed; nonresponse" 1 "farm" ///
		2 "country, non-farm" 3 "small (<50k)" 4 "medium (50-100k)" ///
		5 "suburb, medium city" 6 "large city (100-500k)" ///
		7 "suburb,large city" 8 "very large city (>500k)" ///
		9 "suburb,very large city"
				   
	label values V1152 V1152lab
	label variable V1152 "size of r's residence"
	tab V1152, miss

/* 3. After labeling values of the variable V1152, use recoding procedures to 
create a four-category variable (places with fewer than 50 thousand people, 
places with 50 to 100 thousand people, places with more than 100 thousand ppl,
and those who said “don’t know” or “mixed.”) Use the codebook to determine what 
values of V1152 are associated with these population sizes. Assign value labels
to your new variable. Check the creation of your new variable. */ 

	*Recode V1152 to create a new 4-category variable
	recode V1152 1/3=1 4/5=2 6/9=3, gen(res_size)

	label define res 0 "Can't say; mixed and nonresponse" ///
				 1 "Small (under 50,000)" ///
				 2 "Medium (50-100k)" ///
				 3 "Large (over 100k)" 

	label values res_size res

	* note some assumptions here - that farm/country have 
	* populations less than 50,000 and that suburbs should be 
	* linked with the urban area, regardless of suburbs' own population sizes

	*check to make sure that the recode is as expected
	tab V1152 res_size, miss

* 4. Is population size related to expectations of completing college?
	* A naïve and uninformed guess is that it is highest in largest cities.

	/* (4a)Investigate this question by using the variable V1183. Recode 
	V1183 into a dummy variable contrasting those who definitely/probably won’t  
	& those who definitely/prob. will complete a four-year college degree. 
	Pay attention to missing values. Check the new variable you created and 
	comment on this in your do-file. */ 
			
			* first, I look at V1183
			tab V1183, miss

		* Now I create my new dummy variable
		* I want 1 & 2 together (generally no) and 3 & 4 together (generally yes)
		* I will make a dummy variable called "yes_coll" so I want 3 & 4 == 1
		gen yes_coll=(V1183>=3)
			* Note the use of the truth syntax here. 

		/* There are many other ways you could have constructed this var.-- 
		some of which we have discussed in class. You could use the "old school" 
		method and -generate YEScollege = 1 if ...- then -replace YEScollege = 0
		if...-; you could also try the recode command with -gen- appended, etc.
		
		By the way, note that those with missing values (-9) on the expectations 
		question will be included with "don't expect" - I don't want this so will 
		recode missing cases as missing. */ 
		replace yes_coll=. if V1183==-9

		*label new variable
		label variable yes_coll "Expect to complete college"
		label define yesno 0 "No" 1 "Yes"
		label values yes_coll yesno

		*Tabulate new and original variable to check recode;
		tab V1183 yes_coll, miss

	/* (4b) A two-way table can give information about the relationship b/n area 
	of residence and college expectations (make sure you calculate percentages 
	in the right direction – use context clues to figure this out). */ 
		tab res_size yes_coll 
		// with just a simple two-way tab it's hard to tell--I need percentages!
			* note that the missing cases are not included in this tabulation
		tab res_size yes_coll, row 
		//I can add row-wise percentages
		tab res_size yes_coll, row nofreq 
		// I can even remove the frequencies because I don't need them

	/* (4c) Interpret the results of your cross-tabulation. How is (or isn’t) pop 
	size associated with college completion expectations? 
		
		-->People living in big cities are most likely of all to expect to go to
		college. As population size decreases, so does the percent of people 
		who expect to go to college.*/ 

// 5. Is population size related to experience of binge drinking?
	* Again, my naïve expectation is that binge drinking will be more common 
	* in larger areas
	tab V1108, miss

	/*(5a) Investigate this question by using the variable V1108. Do this by 
	constructing a dummy variable that distinguishes those who report any binge 
	drinking episodes from those who report none. Again, be careful to pay 
	attention to missing values. Check the new variable you created and comment 
	in your do file on your success in constructing it.*/ 
	gen binge=(V1108>1)

	*again treat missing values as missing - i.e., exclude from analysis
	replace binge=. if V1108==-9

	label variable binge "Any binge drinking within the past 2 weeks" 
	label values binge yesno

	*tabulate new and original variable to check recode
	tab V1108 binge, miss

	*(5b) Again, a simple cross-tabulation is fine to investigate whether pop.
	* size is related to binge drinking. Interpret your results.
		tab res_size binge, row nofreq 

		* INTERPRETATION: Interestingly, there is not much of a relationship
		* between size of residence and binge drinking. About 20% binge drink 
		* across sizes of places. However, it seems that people who live in 
		* medium-sized cities are least likely to binge drink.

			* note that the missing cases are not included in this tabulation

* 6) Are college expecations and binge drinking experiences related to 
* parents' educational attainment?

	*(6c) (Sorry for the out-of-alphabetical-ordering on the assignment sheet). 
	/* Let’s check this by first constructing a variable that indicates the 
	educational level of the parent with the higher level of education. 
	Variables V1163 and V1164 represent father’s and mother’s educational 
	attainment, respectively. The constructed variable should measure 
	the educational attainment of the more highly educated parent. If ed. 
	attainment is missing for one parent, use the value for the other parent. 
	If educational attainment is the same, it doesn't matter which parent you 
	use. If educational attainment is missing for both parents, let’s treat this 
	variable as missing. Be sure to check your variable to make sure it worked 
	and comment on the results of your check in your do file.*/ 
	
	* First step is to construct a measure for highest educational attainment
	*This is a bit more challenging than variables constructed above.
	tab V1163, miss
	tab V1164, miss

	* There are many different ways that you could do this -- important thing
	* is to check that you got it right. Is your distribution the same as mine?

	* Here's one way. 
	* First, let's code both parental education variables to eliminate MVs that
	* are confusingly marked with numbers here. I'm showing an unnecessary step
	* here that, nevertheless, can help you keep variables straight--I'm 
	* duplicating V1163 and V1164 before proceeding (a secondary purpose of this
	* is that it also helps me more easily run your do-files for grading). 
	
	gen daded = V1163
	gen momed = V1164
	replace daded = . if daded==-9
	replace momed = . if momed==-9
	replace daded = .d if daded == 7
	replace momed = .d if momed == 7
	
	* Now, since we'll need to be very careful about MVs here, let's make a kind
	* of meta-variable indicating whether someone has MVs on either parents' 
	* educ or both. 
	gen highestpaed = . 
	gen hasparented = (~missing(daded) & ~missing(momed))
	replace hasparented = 2 if (~missing(daded) & missing(momed))
	replace hasparented = 3 if (missing(daded) & ~missing(momed))
	label define HPE 1 "neither missing" 2 "only mom mis." 3 "only dad mis." ///
		0 "both missing" 
	label values hasparented HPE
	tab daded hasparented, mis
	tab momed hasparented, mis
	
	* Now, we can simply write a few conditional statements and we are good!
	
	* First, let's deal with the three cases where neither parent is missing.
	replace highestpaed = daded if daded>momed & hasparented == 1
		* We give this var the same value as mom's ed should her ed. be more
	replace highestpaed = momed if momed>daded & hasparented == 1
		* We give this var the same value as dad's ed should his ed. be more
	replace highestpaed = momed if momed==daded & hasparented == 1
		* We give this var the same value as mom's ed should both parents have
		* same ed. Some people did a really excellent job but got tripped up
		* by this part and tried to say "assign highestpaed the value of mom's
		* OR dad's ed. if they are equal" -- but unfortunately, Stata and other
		* computing programs get fussy about ambiguity. So, we can just pick 
		* one -- the difference is irrelevant. 
	* Now we'll deal with the case where only mom's ed. is missing...
	replace highestpaed = daded if hasparented == 2
	* ...and, the case where only mom's ed. is missing...
	replace highestpaed = momed if hasparented == 3
	* ... and, finally, the case where both are missing ... 
	replace highestpaed = . if hasparented == 0
	
	
	* Here are a few ways to check this. 
		* First, you could also make a fancy table...
		table daded momed, miss c(mean highestpaed)
		// this makes a two-way table between mom's and dad's ed and fills it w/
		// mean value for obs. with a given combination. There are a lot of ways
		// to verify using this table -- lots of interesting patterns. 
	
		* Another, simpler way to check this is to note that a two-way table
		* with mom's or dad's ed. on the rows and highest educ on the columns
		* should be upper-triangular when we don't includ MV: it does not make 
		* sense for mother's or father's education to be *higher than* "highest 
		* parental ed."
		tab daded highestpaed
		tab momed highestpaed
		
		* And you can just try a good old spotcheck. 
			* Here, we look at different types of cases to make sure this worked. 
			* First, we'll just look generally. 
			list daded momed highestpaed in 1/50

			* All of the above cases worked correctly, but what about 
			* rare cases in which either the father's ed or mother's ed is 
			* missing and the other is not missing? ;
			list daded momed highestpaed  if missing(daded) & ~missing(momed)
			list daded momed highestpaed  if missing(momed) & ~missing(daded)
		
		* Finally, another way to check this -- especially if this were a real 
		* project where you'd want to be certain you did this right -- would be
		* to simply try to make it two ways. Here's one more using a function. 
		
			* cond(var1>var2, P, Q , R) is function that returns P if statement
			* is true and nonmissing, Q if it is false, and R if the expression 
			* evalutes to missing.

		gen maxparentsed =cond(daded>momed, daded, momed, .)
			* This says "return dad's ed. if dad's ed. is larger than mom's ed
			* and mom's ed. if this is false". This takes care of cases where 
			* dad's ed. is larger, where dad's ed. is smaller, *and* cases where
			* they are tied (because the statement is false when they are tied,
			* so it just returns mom's ed... which is fine, since mom's ed == 
			* dad's ed == highest parent ed in that case, by definition). 
			replace maxparentsed = momed if missing(daded) & ~missing(momed)
				* Now we just sub in mom's ed. iff ONLY dad's ed is missing
			replace maxparentsed = daded if missing(momed) & ~missing(daded)
				* Now we just sub in dad's ed. iff ONLY mom's ed is missing
			replace maxparentsed = . if missing(momed) & missing(daded)
		
		* Now we can check this quickly. 
		tab maxparentsed highestpaed, mis
			* Checks out -- we only have a diagonal matrix. 
			
		* Here's yet one more way to do this. This is the quickest, if the
		* most advanced, method. 
		egen parentalmaxed = rowmax(daded-momed)
		tab parentalmaxed highestpaed, mis
			* rowmax is a powerful command. Not only will it quickly pull the
			* maximum value from this list of columns, but it will also "ignore"
			* missing values. Now, the documentation on rowmax is not very
			* extensive in the -egen- help file, so it is important to check
			* -- "ignore" is not totally unambiguous. But, it appears that what
			* happens here is that "ignore" probably means that if only one value
			* is missing, it will just take the other value as the max, which is
			* just what we want. Here we can check that. 
		list parentalmaxed momed daded if missing(daded) & ~missing(momed)
			* One complexity is that this method generates two distinct types
			* of missing values, so it appears to be preserving something like
			* the original _form_ of the MV. But mom's ed. and dad's ed. might
			* be different kinds of missing. Ultimately, this is really not a
			* huge deal unless we plan to do heavy duty analysis of missing data,
			* but it is worth nothing. Here, when there is a conflict, a quick
			* check seems to indicate that Stata takes the "type of missingness"
			* from mom's ed. That could be because it is the second column, but
			* the documentation isn't clear enough to tell. At any rate, my
			* alternative methods above don't distinguish between types of MV,
			* so this is probably fine. We might just want to convert all MVs
			* to a simple, unpretentious "." to avoid putting down information
			* that might be misleading. 
		
		* Time to label the successfully created variable. 
		label variable highestpaed ///
			"Highest educational level achieved by parents"
		codebook V1163 // Let's get the value label 
		label values highestpaed V1164

	/*(6b) Once you have constructed this variable, cross-tabulate (a) parents’ 
	highest level of ed. w/ college completion expectations and (b) parents’ 
	highest level of ed. with binge drinking. You may also find it helpful to 
	recode parental ed. into a smaller number of categories – e.g., college 
	degree or not (I will let you decide whether to do this and if so, how). 
	Interpret the results.*/ 
		tab highestpaed yes_coll, row nofreq
		tab highestpaed binge, row nofreq

		/* People w/ more highly educated parents are more likely to expect to go 
		to college. Interestingly, they are also  somewhat more likely to binge 
		drink. Perhaps because they can better afford it? */ 

log close

