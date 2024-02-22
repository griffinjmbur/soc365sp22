
capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
log using ./do/Lecture13, text replace 

/* task: review of descriptive statistics and inference
   author: Griffin JM Bur, 2022-05-02
   SOC 365, Spring 2022, Lecture 13.*/ 

/* STRUCTURE. 
	0. Intro/big idea. 
	I. Realistic example: building a state-/county-level economic welfare dataset
	II. Review of basic statistical analysis 
   
0. Intro/big idea. 

This do-file reviews one fairly extended example that builds on the examples
from several previous weeks to touch on all the major post-midterm topics before
going on to review descriptive and inferential statistics as well as graphs. 
Although our book's examples can seem somewhat artificial at times, it turns out
that even something as simple as get a panel data-set of county-level unemployment
rates, poverty rates, and a rural/urban score is a _much_ smoother task if we 
make use of each technique we've discussed since the mid-term -- merging and 
appending, making group-level variables, reshaping data, and programming. 

The second half of the lecture goes over the logic of basic descriptive and then
inferential statistics; this part of the lecture is abbreviated and contains 
significantly less commentary than usual from me, in part because Lecture Six is
a very good resource on these topics and, in part, because this material should
in theory be review and simply can't be explained in toto over the course of an
hour -- but I did want to review the key ideas for your benefit. These will be 
required on the final exam (which, very much like the midterm, will ask you to 
both manage data but also analyze data) and are, of course, required for the
final project.  

Two important practical notes before going further. First,  we won't have time
to get to weights. I say a little bit about that in this do-file because it is
hard to avoid entirely, but it would require a lecture of its own, and we do not
really have time, unfortunately. Second, when you export tables for your final
projects, you can just copy/paste into Excel and format them reasonably nicely.
There are better ways using Stata, but they are more complicated than you'd 
expect and could probably use a lecture of their own. Graphs can be exported as
PNG or JPEG files and then copy/pasted into the paper. 

I. A realistic example: building a state-/county-level economic welfare dataset

Let's suppose we want to take our county-level data exercise a bit further. This
is going to be, in many respects, an example that is quite similar to the past 
few weeks, but an interesting fact about this kind of data--"bread and butter" 
variables that are collected by a dizzying array of state agencies--is that we 
can obtain the data in many different ways and in many different shapes, which
makes this sort of theme (also a theme of my research) a great example. 
Last time, we had to go through a somewhat tedious process of downloading data
stored in multiple different files. Let's practice appending with looping (and
for that matter importing non-.dta files). 

Suppose I come across a website with county-level unemployment data going back 
many years, but they are all stored in separate yearly Excel files. How can I do
a bit of web-scraping to quickly turn them into an appended data-set? 

Let's get the first data-set loaded in without a loop, inspect it, and see what
changes might make this feel a bit more user-friendly. Here is a permanent link
to the site since many state agencies constantly change link paths: 		
	https://web.archive.org/web/20220427182622/https://www.bls.gov/lau/ */ 

import excel using https://www.bls.gov/lau/laucnty21.xlsx, ///
	cellrange(B5:J3148) firstrow clear

	rename Code fips_state // this just makes the name a bit more exact
	// In these next three lines, we fix the auto-imported varnames.
	rename C fips_county 
	rename Force labor_force 
	rename J county_unemp
	drop F // empy in the Excel file
	replace county_unemp = 0.01*county_unemp // Let's make UE rates decimals. 
	rename *, lower // This is usually easier, as we've seen.
	gen fips_full = fips_state + fips_county 
	// Finally, we'll create a merged state/county FIPS code. 

save ./modified_data/2021_emp_county, replace
	// Here I save the dataset on its own... 
save ./modified_data/2010_21_emp_county, replace
	// ... but I also make this the first part of a fused data-set. 
		
* I.i. Loops review.
		
	/* Now, while I was preparing this lecture, I noticed something about the URLs
	for all of the data-sets: they all follow the same pattern, which is this:
		https://www.bls.gov/lau/laucnty??.xlsx, 
	...where ?? are the final two digits of the year. Can you write a loop to get 
	them into Stata using -import Excel-? And, how should we combine these sets? 
	You may want to go inspect the website and even download a couple of the 
	data-sets to get a feel for this. */ 

	forvalues i = 10(1)20 { 
		import excel using https://www.bls.gov/lau/laucnty`i'.xlsx, ///
			cellrange(B5:J3148) firstrow clear

		rename Code fips_state
		rename C fips_county
		drop F
		rename Force labor_force
		rename J county_unemp
		replace county_unemp = 0.01*county_unemp
		rename *, lower
		gen fips_full = fips_state + fips_county
		
		save ./modified_data/20`i'_emp_county, replace
		
		append using ./modified_data/2010_21_emp_county 
			// So, we should -append- rather than merge because we're just adding
			// observations (assume for simplicity that we want long data). 
		save ./modified_data/2010_21_emp_county, replace
		}

		// We can inspect our data now, just to make sure this shape feels "right".
		destring year, replace
		order year fips_full, before(fips_state)
		sort year fips_full
		br
		save ./modified_data/2010_21_emp_county, replace

		
* I.ii. Importing non-.dta files review. 

		* Let's suppose that I now want to import some state-level data using a 
		* different source; this might seem haphazard, but part of this is 
		* because these data are kept by many different state agencies, and their
		* completeness and ease of handling will vary. Let's use the data from 
		* this site: https://archive.ph/T7OGn. 

		import excel using ///
			https://www.icip.iastate.edu/sites/default/files/uploads/tables/employment/emp-unemployment.xls ///
			, cellra(A6:AO58) firstrow sheet("States") clear
			
		* Now we have an interesting dilemma. The data have been imported 
		* correctly in a broad sense, but the variable names are just the names 
		* of Excel columns, and the value-labels ended up having the correct year 
		* information. Can we somehow fix this with a loop? Consider that the 
		* "extended macro function" called "variable label [var]" will pull the 
		* variable label from any variable. 

		foreach Xj of varlist C-AO {
				local current_var_label: variable label `Xj'
				local new_name = lower(strtoname("`current_var_label'"))
				rename `Xj' unemp_`new_name'
			}

		* You might also note that these data are in a different shape than our
		* other data-set. Which shape? Why? 
			
			* These data are wide because we have panel data where the variation 
			* in one of the variables -- typically year, but it can be the 
			* location -- is given in the form of more variables rather than more
			* observations. 

* I.iii. Reshape review. 
			
	* So, how can we reshape these? We've seen this once before, but it is good
	* practice. Fortunately, above, we've been basically forced to make stubs.

		* Recall the general syntax here: 
			* reshape long stubname, i(current ID) j(new variable we extract)
	reshape long unemp__, i(Fips) j(year)
		* You don't have to add the string option unless Stata gets confused
		* and refuses to make the new variable; my suggestion is to try this 
		* without the string option first because it saves you a bit of code later, 
		* and then only do it if needed. Here, by making the underscore part of 
		* the stub, I was able to get Stata to recongize it as numeric. Then, 
		* fixing the name of unemp is as simple as ... 
		rename unemp state_unemp
		* and let's make it a decimal as well
		replace state_unemp = 0.01*state_unemp 
		
* I.iv. Combining data-sets review. 

		* Now let's combine the two data-sets. Should we append or merge? Why? 

			* Here, we should merge: we have a group-level variable that we want 
			* to add to our list of existing variables. 

		* Here, I notice that state-level FIPS codes in this data set have all 
		* the zeros after them. Since we need to rename Fips to match the 
		* state-level FIPS code in the other data-set anyways (fips_state), we 
		* might as well make sure they match.
		
		* Does anyone remember how to extract substrings? 
		gen fips_state = substr(Fips, 1, 2)
			// Syntax: substr(var, position, length). 
		drop Fips // Usually much less confusing to drop extra vars. when merging.

		* Now we can proceed with the merge. The syntax is fortunately pretty 
		* simple, but what kind of merge do we want? 

		* [I.iv.i. Review of identifier variables.]

		* We want a 1:m merge because one state has >one county associated with
		* it. What are our unique identifying variables? Just fips_state? 
			* No--since we have panel data, this will _not_ uniquely identify 
			* obs in the master data-set (it does not need to uniquely ID 
			* variables in the using data-set if the merge is 1:m). So, we simply
			* put the two variables that uniquely identify the observations. 
		capture isid fips_state
			* We haven't seen capture much outside our header, but it is a way 
			* to force Stata to keep working through errors. I include it here 
			* because I know that this error is harmless, but it should be used 
			* with great caution.
		isid fips_state year 
	
		* [Resume merge discussion] 
		
		* Now we can proceed with the merge!
		merge 1:m fips_state year using ./modified_data/2010_21_emp_county
		sort Area year fips_county
		* Let's check a few of these informally. 
		list year Area fips_state fips_county fips_full ///
			countynamestateabbreviation state_unemp county_unemp if ///
			Area == "Wisconsin" & year == 2013
			
		list year fips_state fips_county fips_full countynamestateabbreviation ///
			state_unemp county_unemp if Area == "North Carolina" & year == 2013

		* Things look good. Before a formal investigation of _merge, we might want to
		* drop non-overlapping years since those will produce a _lot_ of mismatches that
		* could be misleading. 
		drop if year < 2010 | year >2018 
		tab _merge
			* OK, we have a tiny number of non-matches--probably bound to happen. Let's
			* go investigate those. 
		list Area countynamestateabbreviation _merge if _merge ~= 3
			* One is the US-level data in the master set; another is from a non-US state,
			* which, as we've seen, is a liminal situation that often is behind non-
			* matches in the case of FIPS. Solution? End US imperialism ;) But more
			* prosaically, let's just drop these. 
		drop if _merge ~= 3

* I.v. Group-level variables review. 		

		* Let's now use -by- and -sort- to check and make sure that our state- 
		* and county-level unemployment variables are consistent with one another. 
		* Arguably, this defeats the purpose of importing those state-level 
		* variables, but a) this is a data-exercise and b) this is a nice way to 
		* check those variables. 

		* Try doing this by first sorting your data. 
		sort year fips_state fips_county 
		list year Area fips_state fips_county unemp Are countynamestateabbreviation ///
			state_unemp if fips_state == "55" & year == 2010
			// Now let's check Wisconsin just to make sure this looks right. 
			
		* We want to loop over year and state now that the data are sorted. How
		* can we do so? Recall that we have data on the number of persons e
		* employed and unemployed in each county. 
		by year fips_state: egen state_unemp_check = mean(unemployed/labor_force)
		sum state_unemp state_unemp_check
		bysort year: sum state_unemp state_unemp_check
		list year fips_county countynamestateabbreviation county_unemp state_unemp ///
			state_unemp_check if fips_state == "55", sepby(year)
			* Cool--these are generally in the same ballpark. 
		drop _merge 
			// the _merge from this next one will be more useful. two can't coexist, 
			// so let's drop the old one. 
		save ./modified_data/2010_21_emp_county_state, replace

		* Now let's get some information on poverty and rurality of the place. 
		* We'll go use the same data-set we used last time in order to get these;
		* here is the direct link to the website. This also gives county data. 

		import excel using /// 
			"https://www.ers.usda.gov/webdocs/DataFiles/48747/PovertyEstimates.xls?v=6485.2" ///
			, sheet("Poverty Data 2019") cellra(A5:AB3198) firstrow clear
			
			gen year = 2018 // we need to make a year
			rename FIPStxt fips_full // harmonize our variable names
			rename Ruralurban_Continuum_Code_2013 rural_urban // or improve them
			rename POVALL_2019 people_in_poverty
			keep fips_full year rural_urban people_in_poverty
			
			* Here, let's try re-coding rural and urban areas as we've done before.
			* How would you best do this, do you think? 
			recode rural_urban (1 = 1) (2 = 2) (3 5 = 3) (4 6 8 = 4) ///
				(7 9 = 5), gen(rurb) 
			label define rurb 1 "major metro" 2 "midsize city" 3 "small city" ///
				4 "very small suburb" 5 "rural"
			label values rurb rurb
			tab rurb

* I.vi. One more merge example. 
			
		* We need one more merge using ./modified_data/2010_21_emp_county_state. 
		* See if you can figure out which variables we should merge on and why. 
		merge 1:m fips_full year using ./modified_data/2010_21_emp_county_state
		save ./modified_data/2010_21_emp_pov_county_state, replace
		* We're going to have a lot of mismatches here, but that's largely a 
		* function of the fact that poverty estimates only come from one year. 
		tab year _merge
		list fips_full if _merge == 1 & year == 2018
			* The unmatched all come from the master and are all state-level codes, 
			* because we don't have state-level observations in the using. 

* I.vii. Additional new variables with -egen- review. 	
				
		// For the sake of time, let's just estimate population from labor force.
		gen population_county = labor_force*1.62

		// Brief comment on inference and weights. 
			
			* We won't do inference here for a couple of reasons; the main one is
			* would need to talk about survey weighting, and this is not even a  
			* typical case of weighting. Here's one way to see the problem. 
			* Compare the following two bar graphs. 
			graph bar, over(rurb)
			graph bar [pweight=population_county], over(rurb) 

		// Let's turn uenmployment into rough quintiles using -egen-. 
		egen unemp_quintile = cut(unemp), group(5)
		label define unemp_cat 0 "first" 1 "second" 2 "third" 3 "fourth" 4 "fifth"
		label values unemp_quintile unemp_cat
		tab unemp_quintile
			* OK, these aren't perfect quintiles, but getting those is pretty 
			* hard in Stata for a variety of reasons (in part, quantiles are 
			* surprisingly under-defined in theoretical literature, which seems 
			* bizarre for such a simple measure, but it makes more sense the more
			* you read about it). 
			
		* And let's make rates for poverty. 
		gen poverty_rate_county = people_in_poverty/population_county

* I.viii. Some simple analysis. 
		
		tab rurb unemp_quintile, row
			* *important* -- please watch my supplemental lecture on two-way tables
			* if you still have trouble with this; I made it because it is an issue
			* that tends to be a persisent source of confusion:
	
		view browse ///
			"https://www.youtube.com/watch?v=XkOkjZ0Vivw&ab_channel=SOC365%28UW-Madison%29"	

		tab rurb unemp_quintile, row exp chi2 
			// This adds inference. To make this extremely simple, low p-value
			// means evidence of a population-level relationship. 
		drop _merge // spineplot for some reason needs to make a variable like this
		spineplot unemp_quintile rurb, xti("", axis(1)) xti("", axis(2)) ///
			xlabel(, angle(45) axis(2)) /// 
			title("Relationship between place and unemployment", size(medium))
		// Sidenote: the weighting problem isn't as severe here because population
		// size may not be super relevant to the locale/UE relationship. It is more
		// of a problem in trying to actually estimate the population level UE rate
		// because in that case, we don't want to count Pepin County and Dane County
		// equally: there are more people in the latter, and if we just average the
		// two, we're going to get misleading results. In other cases, however, we've
		// already been brushing this aside because it may not be quite as misleading:
		// for example, when we've calculated tables of conditional means, we have
		// not typically investigated the frequencies for each "conditional status"
		// of the predictor variable, but we really should -- in fact, that is one
		// thing that makes regression different (though the techniques are similar):
		// regression automatically "weights" observations in this sense. 
		
	reg poverty_rate county_unemp
		// Another caution: this is an ecological regression and such ecological
		// associations sometimes switch direction, as those of you who took 360
		// with me will certainly know. That we can't check for here (though it'd
		// be almost absurd for it to switch direction), but I note that I checked
		// to see if weighting causes the relationship to change much; it doesn't.
	bysort rurb: reg poverty_rate county_unemp

	vers 16: table rurb, c(mean poverty_rate)
	vers 16: table unemp_quintile, c(mean poverty_rate)
	vers 16: table rurb unemp_quintile, c(mean poverty_rate)
	graph dot poverty_rate, over(rurb) over(unemp_quintile)
	graph dot poverty_rate, over(unemp_quintile) over(rurb)
		
	// A note on exporting stuff: there are a lot of ways to get figures exported 
	// in pretty fashion, but that probably deserves a whole lecture of its own:
	// many of the commands (outreg2, tabout) are strange at first. For this class,
	// I'd like you to just make tables in Excel or Sheets and then copy/paste to
	// Word or Docs. Contact me if you need help; but, don't just screenshot Stata
	// output (screenshotting graphs is fine since it makes no difference).

	// Map (just for fun)
	egen poverty_quintile = cut(poverty_rate), group(5) 
	gen poverty_unemp_scale = poverty_quintile+unemp_quintile
	gen county = real(fips_full)
	maptile poverty_unemp_scale if year == 2018, geog(county2010) fcolor(Heat) ///
		conus cutp(poverty_unemp_scale) stateoutline(vthin) /// 
		twopt(title("Summed poverty + unemployment quintile 2018"))

		
* II. Review of basic statistical analysis. 

// Let's review a bit of basic inference using a simpler data-set. I'm not
// going to be a huge stickler about this on the final exam/in the papers, but it
// is, in theory, necessary to say anything useful about most data-sets that are
// not censuses--between people who haven't actually taken the prerequisite for
// our class (360 or equivalent) and people who feel a bit rusty, I am guessing
// that this will be a welcome review for at least half the class. 

* First, a reminder that this is a convenient place to get the short story on 
* how inference works: my summary lecture from 360...

view browse https://tinyurl.com/360inonelecture

* And here is my quick guide to which technique to select ... 

view browse https://tinyurl.com/analysistypes

use ./original_data/cps2019, clear

* Univariate descriptive (non-inferential) stats, inference and graphs. This 
* part is going to be pretty light because we've been over this in great detail
* in L6, and I don't want this lecture to be intimidatingly long. 

* Quant. 
sum wage1 // non-inferential
ci mean wage1, level(92) 
	// Using a method that works 92 percent of the time, we believe the true
	// population mean hourly wage for hourly workers from 2019 to be between...
set scheme tufte
hist wage1, percent ///
	title("Distribution of wages in sample of US hourly workers [n=291,390]", ///
	size(med)) // histogram for quant var
graph box age if ~missing(wage1), /// 
	title("Distribution of wage in sample of US hourly workers [n=291,390]", ///
	size(med)) // box plot is a good alternative for quant vars
vioplot age // vioplots also work well for quant vars
* Cat. 
tab female // non-inferential
label define sex 0 "male" 1 "female" 
label values female sex
ci prop female if ~missing(wage1), wald // CI proportion for a dummy
graph bar if ~missing(wage1), over(female) ///
	title("Distribution of sex in sample of US hourly workers [n=89,883]", ///
	size(med)) // bar graph works well 
proportion wbhaom if ~missing(wage1), citype(wald) 
	// Proportion command gives CI props for all values of a polytomous
graph hbar if ~missing(wage1), over(wbhaom)  ///
	title("Distribution of race in sample of US hourly workers [n=89,883]", ///
	size(med)) // Horizontal bar graph often best for polytomous vars

* Bi and multivariate descriptive (non-inferential) stats, inference and graphs

* Bivariate 

* Quant outcome, categorical preds. 
vers 16: table female, c(mean wage1) format (%4.2f) // non-inferential 
ttest wage1, by(female)
	// If the difference in pop is zero, we'd see results this extreme or more
	// about zero percent of the time; w/ 95 percent confidence, difference is
	// between 2.35 and 2.62
vers 16: table wbhaom, c(mean wage1) format (%4.2f) // non-inferential
reg wage1 i.wbhaom
	* Coefficients represent differences of each race to the excluded category
	* (here, whites). To get actual predictions, use margins i.wbahom or just
	* add the coefficients to the constant (which represents whites here). 

* Quant outcome, quant preds. 
corr wage1 age // non-inferential 
reg wage1 age 
	// if pop. relationship were zero, we'd see results this extreme or more 
	// about zero percent of the time; coefficient likely lies between .14 and
	// .15 dollar increase for each year lived. 

scatter wage1 age || lfit wage1 age // graphical 

* Multivariate

* Quant outcome, categorical preds. 

vers 16: table female wbhaom, c(mean wage1) format (%4.2f) // non-inferential
set scheme tufte
graph dot wage1, over(female) over(wbhaom) ytitle("wages") ///
		title( "Wages by race and gender, 2019 [source: CPS]", size(medlarge))
graph dot wage1, over(wbhaom) over(female) ytitle("wages") ///
		title( "Wages by race and gender, 2019 [source: CPS]", size(medlarge))

set scheme neon
ssc install palettes, replace 
ssc install colrspace, replace
ssc install heatplot
heatplot wage1 i.female i.wbhaom, colors(hcl heat, reverse) ramp ///
	title( "Wages by race and gender, 2019 [source: CPS]", size(medlarge)) ///
	ramp(subtitle("wages") lab(15.50(1.5)21.5)) scale(0.85)
	* We haven't talked a ton about heatplots but hopefully pretty intuitive
	* which is why they are so widely used. 

reg wage1 female##wbhaom // Advanced technique
	margins, over(female wbhaom)
	marginsplot
	margins, over(wbhaom female)
	marginsplot

* Quant outcome, one categorical pred., one quant. 
bysort female: reg wage1 age // non-inferential 
set scheme tufte
drop if age>70
scatter wage1 age if female==0, mcolor(red%30) || /// // graphical
		scatter wage1 age if female==1, mcolor(green%30) ///
		, legend(order(1 "Males" 2 "Females" 3 "Males" 4 "Females")) || ///
		lfit wage1 age if female==0, lpattern(dash_dot) || ///
		lfit wage1 age if female==1, lpattern(solid) /// 
		ytitle("wages") title("Relationship between wages and age, by sex")
		
		* Note that this overlay works best with relatively few observations and
		* relatively few categories of the cat. predictor, so if that does not 
		* apply to your situation, you can just use -gr combine-. More or less
		* the exact way to do that is show in L12. 

reg wage1 i.female##c.age // advanced technique/inference
margins i.female, at(age=(15(5)65))
marginsplot

* Quant outcome, quant. preds. 

* There's not a really obvious way to do this without inference. Let's center
* our variables for ease of interpretation. 
foreach Xi of varlist age educ92 { 
		qui sum `Xi' 
		// we can suppress output--we just run this to get the return list
		gen c_`Xi' = `Xi' - r(mean) 
		// we subtract out the mean, stored in the return output as "r(mean)"
		}
reg wage1 c.c_educ92##c.c_age 
margins, dydx(c.c_educ92) at(c.c_age=(-15 -10 -5 0 5 10 15))
marginsplot
margins, dydx(c.c_age) at(c.c_educ92=(-8 -6 -4 -2 0 2 4 6 8))
marginsplot
hexplot wage1 educ92 age, discrete colors(hcl heat, reverse) ramp ///
	title( "Wages by age and education, 2019 [source: CPS]", size(medlarge)) ///
	ramp(subtitle("wages") lab(@min (10) @max)) scale(0.85) ylab(0(2)16)
