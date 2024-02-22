capture log close
clear all 
set more off
cd ~/desktop/SOC365sp22
log using ./do/Lecture10, text replace 

/* task: discuss ways of calculating group-level information
   author: Griffin JM Bur, 2022-04-11
   SOC 365, Spring 2022, Lecture 10.*/
   
* STRUCTURE. 
	* 0. Introduction/big idea. 
	* I. Useful techniques in sub-group analysis generally. 
		* I.i. -bysort- as main technique, but also some alternatives. 
		* I.ii. -by- and -sort- individually: conceptualizing data.
		* I.iii. Some more-advanced techniques, esp. calling elements of columns.
	* II. Useful techniques in basic time-series analysis.  
		* II.i. Some complexities and nuances in means for subgroups.
		* II.ii. Running sums. 
   
/* 0. BIG IDEA: we will often want to "process observations across subgroups". 
What does this mean? It means that we will frequently want to compute statistics
for groups of our data, which can be anything from "big groups" in the way that
you might conventionally think of them (say, race or gender groups) to groups
in a smaller sense (say, families, or even the same individual over time).

Let's consider, in particular, three scenarios that are very common; they are 
really the same scenario, but they appear different at first. 
	
	1. You're investigating group-level differences between demographic groups.
	2. You have panel data (observations are a subset of "true units"; e.g.,
		the real units you care about are years or countries, but your obs. 
		are country years). 
	3. You have hierarchical data: kids in families, workers in firms, etc. 
   
Mitchell shows a lot of details here, and the code is generally pretty simple,
and we have seen a lot of it before, though I do want to discuss some of the way
in which the code differs from the most-basic forms of using Stata. But, the 
main question that we should ask is "why would we use these techniques?". 

Today we'll talk about the first two scenarios and examine various ways of 
calculating the same thing; the unifying theme is that, in every case, we're 
computing the value of observations across groups or "sub-groups". */ 

/* I. Various ways of computing across big demographic groups. The important 
prefix -bysort- and its component parts (-by- and -sort-). 

Let's begin with an example where we are interested in computing means and other
summary statistics across big demographic groups (here, races). 

I.i. -bysort- as main technique, but also some alternatives. */ 

use ./original_data/cps2019, clear

	// Let's suppose that we want to calculate mean wages across racial groups.
	// gSo, let's begin with the -bysort- command, of which I'll explain the 
	// nuances later on. For now, you can just know that this prefix repeats the
	// commands that follow across values of the group. We can follow it with 
	// -egen- which gives us access to more-advanced functions such as mean(). 

	bysort wbhaom: egen wage_by_race = mean(wage1) 
		* What this does is make a new vector that has just a few distinct pieces
		* of information: the means for each group. 
		
	* If we just needed this info for non-calculative purposes, we can obtain it
	* by prefixing -sum- with -bysort-.
	bysort wbhaom: sum wage1
		* There is also a very similar functionality offered by tab [catvar], sum 
		* [contvar] and it displays in a slightly nicer way. 
		tab wbhaom, sum(wage1)

	* But, we can accomplish this in various other ways, e.g. by separating the 
	* wage variable across values of race. The main command is -separate-, and 
	* in the (necessary) "by" option, we put the variable over which we want to 
	* calculate it.
	separate wage1, by(wbhaom)
		// This preserves the distributional information, but the means, when we
		// summarize the set of variables made, agrees with "wage_by_race" above.
	sum wage1?
	tab wage_by_race

	* We can also use a loop here, although as Nick Cox has frequently noted, we 
	* might want to avoid actually writing a loop if a command will do it for us. 
	forvalues i = 1/6 {
		sum wage1 if wbhaom == `i'
		}

* I.ii. -by- and -sort- individually: conceptualizing data.
	
	* But, we won't always have quite as many options. In general, bysort is pretty
	* flexible and useful. It actually combines two commands, and it may be helpful
	* to see how it combines two commands; in fact, you've seen me use them 
	* separately before, but they often need to be used in tandem. Let's spend 
	* some time going over these important components of bysort: -by- and -sort-. 

	* -sort- just puts the data in order of values of that variable.

	* It might be useful to use a smaller data-set here for the sake of visualization.
	* I want to quickly show somewhat silly example using the helpful auto.dta data, 
	* which ship with Stata and which are very useful when you hope to perform some 
	* basic numeric operations just to see what happens. Here I sort the data twice 
	* over; Stata will sort on the values of the first variable, and within those
	* groups, then on values of the second. 

	sysuse auto, clear
	* If describe the data, we'll see that the default sort order is by foreign.
	d
	* Let's just list the data out so that we can see this. 
	list foreign price mpg rep78, sepby(foreign)
	* Note that we can change the sort order to sort by, say, repair record.
	sort rep78 
	list foreign price mpg rep78, sepby(rep78)
	list rep78 mpg
	* And note also that we can sort by multiple variables: so, for example, we can
	* sort first by import status, then repair record with import status...
	sort foreign rep78
	list foreign price mpg rep78, sepby(foreign rep78)
	* ... or vice versa.
	sort rep78 foreign
	list foreign price mpg rep78, sepby(rep78 foreign)
		* Note that we again encounter the fact that Stata sometimes processes 
		* system MVs as arbitrarily-large numbers. Obs. with missing values on rep78 
		* come after the largest observed values on reo78. 

	* Let's now examine our data for more realism, if less-easy visualization.
	use ./original_data/cps2019, clear
	d // OK, so, the existing sort order is uniqueID. 
	* As we see below, the first 20 observations are just people with IDs 1-20. 
	list uniqueID wage1 wbhaom in 1/20

	* If we sort by some other variable, we can see a different order, e.g. wage1.
	sort wage1
	list uniqueID wage1 wbhaom in 1/20
	* We can also sort in reverse order, which is sometimes useful. We need to use
	* the -gsort- command and then add a minus sign ("-") in front of our variable 
	* if we wish to do so.  
	gsort -wage1
	list uniqueID wage1 wbhaom in 1/20

	* We can also sort by a variable we want to use as a subgroup, say, state. 
	sort state
	list uniqueID wage1 wbhaom state in 1/20
		* Note the weird fact that Maine happens to be the numerically first state
		* in this coding scheme. 
		
	* Importantly, we can now easily calculate, say, group means. "by [var]" just 
	* tells Stata to iterate this procedure over the groups defined by the values
	* of [var]. Again, it's like a less programming-intensive loop in that sense. 
	by state: egen mean_wage_state = mean(wage1)
	tab mean_wage_state
	inspect mean_wage_state // so, we have 51 unique values, the same as for "state".

	* And, equally importantly, if the data aren't sorted, we get an error message. 

* I.iii. Some more-advanced techniques, especially calling elements of columns.

	* In this section, I want to show you some more-advanced techniques that make
	* for a more realistic project. Here, we'll review some techniques we've 
	* already seen -- such as generating brackets and crafting appropriate 
	* graphical representations of our analysis -- but also look at some useful 
	* techniques for calling specific elements (i.e., values of particular
	* individuals on particular variables, or numbers in a column vector), which
	* we've have seen in passing but which deserves a bit more study. 
	
	* Let's try to get means for some age-brackets, a technique we've seen a few
	* times before. 
	gen age_bkt = autocode(age, 13, 20, 85)
		* See L5 on autocode(). 
	version 16: table age_bkt, c(min age max age) // check work
		* We'd probably want to change the value-labels if we were working with this
		* to reflect what this variable actually represents. 
	* We can see the problems that arise if our data aren't sorted, BTW. 
	* by age_bkt: egen mean_wage_age = mean(wage1) // remove comment and run!
	* So, we need to sort the data by age_bkt. Let's show another method of doing
	* so which you might see at times. 
	by age_bkt, sort: egen mean_wage_age = mean(wage1)

	* Again, when would this be helpful? Well, it's a lot faster and foolproof
	* than calculating by hand. We can also use this to take all kinds of summary
	* stats, or to condition on multiple grouping variables. E.g., here, we condition
	* on state and age-bracket. 
	bysort state age_bkt: egen mean_wage_state_age = mean(wage1)
	graph dot mean_wage_state_age if state == 34 | state == 35 ///
		, over(state) over(age_bkt) scale(0.8) b1title("wage") ///
		title("Distributions of wage by age and state")
		
	* Again, you might want to explore other methods: separating the variables can
	* provide more tractable information at times. 

	separate wage1 if state == 34 | state == 35, by(state)
	set scheme lean2
	graph dot wage134 wage135 if state == 34 | state == 35, ///
		over(age_bkt) marker(1, msymbol(oh)) marker(2, msymbol(dh)) legend( ///
		order(1 "Michigan" 2 "Wisconsin")) b1title ("Wage") ytitle ///
		("Age bracket") title("Wage differences by age-bracket and state")
		
	* Other functions we could use include total, min, max, sd. Some of these are
	* most useful when the groups are small; usually, the min/max won't vary too 
	* much across big groups like state, and counting total instances is also 
	* something that should be done thoughtfully. 

	* What can we do with what you might call "element functions"? (Functions that
	* use information about a specific element of a given vector of data; remember, 
	* a vector is just a list that can also be thought of as the coordinates of a 
	* line in n-dimensional space if you like). 

	* Let's look at a few practical examples. First, suppose we lost the ID var. 
	* Then, we could remake a reasonable ID variable using "_n", which keeps 
	* track of which row a given observation is. 
	gen id = _n
	sum id uniqueID

	* Now, let's look at another use, combined with bysort. What if we wanted to, 
	* say, generate income rankings for each state? Inference on rank-orderings
	* is a bit tricky, but for the sake of showing these techniques, we can assume 
	* that these are population-level data. 

	use ./original_data/cps2019, clear
	gsort state -wage4 // Here, we sort by state, then income (highest to lowest).
	list state wage4 in 1/20 // checking our work
	list state wage4 in 25000/25020 // again checking our work at random
	by state: gen inc_rank = _n if ~missing(wage4) // now we make an income-rank.
		* Why does this work? We've sorted by state and, within state, from lowest
		* to highest income. So, the person's within-state number in the list 
		* (element of the column vector) has to be their income rank. 
	* Let's spot check with Wisconsin, first looking at the higher end of the 
	* ranks and then at the lower end. The lower end should have a lot of MVs. 
	list wage4 inc_rank if state == 35 & inc_rank <101
	list wage4 inc_rank if state == 35
	list wage4 state if inc_rank == 1
		* Here we examine the highest earner's actual earnings for each state. 

	* We can also create a variable indicating a crude measure of an income gap; 
	* this is perhaps less interesting here since the real minimum hourly income 
	* should presumably be,for working persons, the minimum wage, but if people 
	* report that they are paid below this--and it does happen!--or they give 
	* their total income, which unlike hourly has no legal lower bound (since 
	* someone might just work part-time), this is not useless. 

	* Here, it is easier to drop missing values since sometimes the syntax can be
	* tricky with elements. 
	drop if missing(wage4)
	by state: gen incgap = wage4[1] - wage4[_N]
	* This basically just gives you the same information as the maximum income in 
	* that state, whether we take zero hourly income at face-value or omit it, but
	* this won't always be true. 
	version 16: table state, contents(mean incgap max wage4)

/* II. More exmaples using time-series analysis. */ 

* Many of these commands are especially useful when in the case of time-series
* or panel data, and since--as I mentioned last week--the analysis of time is a 
* topic that is usually intuitively of great interest to many students ... but
* not formally covered in 360 or 361, and only see in passing in 362... I'd like
* to again show you some of the basics. You won't be tested on this per se, but
* since it is both interesting to many students and also a good way to show how
* to use advanced -egen- commands, we'll examine it. Estimation is hard, but the 
* data-management side of things, though also challenging, is by no means 
* impossible and provides good practice for us. 

* So, let's revisit the COVID example that I showed once before but which we
* did not have time for. Let's pick some data that you might realistically want
* to use--say, data about an ongoing, unprecedented period of social change,
* where data come to us "dirty" and where sleek data management is imperative.

* Let's suppose we're interested in Chile's excess mortality during this peoch. 
* I decided to pick Chile because it is a country I studied closely in my MS and
* my sister lived there pre-COVID. Interestingly, and not totally-unrelated to
* its unique political and economic history, Chile is one of the most developed,
* most-vaccinated, and during the height of COVID, most locked-down countries. 
* This makes them an interesting outlier (sometimes you want outliers!). 
	
* In the interest of time, we'll just examine data on mortality, but I tried
* merging these data with data on public health interventions, and it was pretty
* straightforward, so you may wish to do this as practice. 

* II.i. Some complexities and nuances in means for subgroups.

* Let's get the data on basic mortality, from which point we will use our new
* techniques to calculate simple demographic-epidemiological measures. The main
* such measure we'll use is excess mortality. Conceptually, excess mortality is
* simply deaths over some baseline; we use this measure because the measurement
* of COVID deaths depends on rates of testing and clinical assessment of a novel
* disease, both of which are less-than-fully reliable. Excess mortality also has
* the benefit of capturing the most-relevant outcome: social welfare. For example,
* even if COVID deaths were genuinely minimized by some intervention, if this
* intervention also caused deaths in its own right, this tradeoff would be 
* captured by excess mortality figures, but not COVID death rates. 

	* We'll get our data from the Our World In Data (OWID) project, which posts
	* basic mortality information for all countries for the last five to 10 years 
	* to Github, making the import process quite simple. 

	import delimited https://tinyurl.com/OWIDChile, ///
		delimiter(",") varnames(1) asdouble clear
		
		* varnames tells Stata to treat the first row as variable names, while 
		* "asdouble" instructs it to import data with a lot of precision (a good 
		* idea with time-series data). 

	* First, basic cleaning. We'll keep only Chile, drop uneeded vars and rename
	* for convenience. 
		keep if iso3c == "CHL"
		drop iso time_unit
		rename time cyclicalweeks
		rename deaths weeklydeaths

	* Now let's get some baselines for mortality prior to 2020. We'll first take 
	* a yearly baseline, and then we'll take a weekly baseline. Excess mortality
	* can be calculated in more-complex ways that adjust for changes in the age
	* structure over time, but this is less necessary when the baseline years
	* are very recent; population age-structure takes a long time to change in 
	* the absence of catastrophic events, and there aren't many I can think of
	* in the immediate pre-COVID eyars. 

	* First, I want to remind you of a useful workaround. This trick is one that
	* Mitchell has not really shown much, but you might notice that I show it
	* often: if you're comfortable with things like regression or even just things
	* such as simple means, you'll know that to produce certain statistics--say,
	* a mean--we need to produce intermediate stats such as a summation or to find
	* the number of observations. Stata gives you access to those with the r()
	* function; all commands list, at the very bottom of their help-file, those
	* intermediate quanta which they compute. Be creative! Some things in Stata
	* e.g. the sum of all observations of a var.; outliers) are not immediately  
	* accessible for unclear reasons, but b/c many commands either directly use 
	* these or make the needed ingredients in order to do something else with 
	* them, you can then access those intermediate results yourself, for your 
	* own purposes. 

		sum weeklydeaths if year <2020
		* If you're just running a command to get return scalars/vectors, you can
		* use the prefix "quietly" (abbreviate-able as "qui") to suppress output. 
		scalar baseline_mortality_perweek = r(sum)/r(N)
			* Remember: -scalar- is nice when you just want to store a number as
			* number rather than a vector. There is no big downside to the latter,
			* and many -egen- functions store summary statistics as a vector of
			* identical observations on some variable...but 1) this can clog the
			* variable list and 2) it can cause confusion if you try to use the 
			* jargon of mathematics consistently. So, I like scalars because they
			* are also literally the correct term for "some member of the real 
			* numbers" and not "a column representing observations on variable". 
			
			
			* I want to also call attention to one complexity that we see here,
			* which is kind of specific but the general lesson is not. -sum [var]-
			* is a _command_ that tells Stata to perform an action. The _function_ 
			* sum() is an operation that is more narrowly a mathematical quantity. 
			* The former just prints summary statistics. It also, potentially 
			* confusingly, calculates the literal sum of the var, probably b/c
			* Stata needs this summation in order to find a mean, which it _does_
			* print in the sum [var] output. So, we can access the literal sum of
			* a variable which is produced by, but not reported by, the command 
			* -sum- using the syntax of return. I know, it's confusing!
			
	* Let's briefly check out the results. 
	
		di baseline_mortality_perweek
		sum weeklydeaths if year>2019
		* So, weekly deaths were significantly elevated on average from 2020 on.
		
	/* Now, let's do something interesting. Let's say that we don't just
	want a baseline of death for the entire year; let's say that we want a
	baseline of mortality for each week of the year so that we can see when the
	excess mortality of the past two years and change--where excess just means
	deaths above some baseline, here conceived of as the mean of recent deaths--
	is happening. Is high death in one period high because it's always high, or
	is it the real "place" in which excess death is happening? 
		
	Let's calculate the mean for years before 2020 for the same "cyclical
	week" (technically these are called "numeric weeks", but that's not an 
	evocative name): the same week with respect to its time within the year.*/
		
		bysort cyclicalweeks: egen weekly_baseline = mean(weeklydeaths) ///
			if year<2020
			* Here, we de-seasonalize the data. We take the mean of each cyclical
			* week's deaths prior to COVID. Let's spot check a couple weeks.
		list weekly_baseline weeklydeaths year ///
			if cyclicalweeks == 10, sepby(weekly_baseline) // arbitrary choice
		di (1795 +  1870 +  1739 +  1753)/4 // Average the four years before 2020. 
			* Spot-check looks good. 
			
		list weekly_baseline weeklydeaths year /// 
			if cyclicalweeks == 42, sepby(weekly_baseline) // arbitrary choice
		di (1965 + 2002 + 1891 + 2067)/4
			* Again, all good. 

	* Now, the next task is paste in this baseline for the COVID-years. We 
	* intentionally left those years out before so that we could get an 
	* independent reference point but computationally, we need to copy that 
	* reference vector for  years all the way down the columns for years 2020, 
	* 2021, 2022. 
		
	* I realized last week that I don't know if it's always as easy for newer
	* users of Stata to visualize the underlying spreadsheet/matrix of data, 
	* so let's suppose we do that here. We can literally browse or just print
	* some parts of it on the screen. Let's do the latter.
		
		sort cyclicalweeks year
		list cyclicalweeks weekly_baseline year if cyclicalweeks <10, ///
			sepby(cyclicalweeks)
			
		* What's going on here? We print a subset of the underlying matrix
		* with some vectors omitted. I also sorted by cyclical weeks -- i.e.,
		* what "numbered week" of the year it is, which is a common way that
		* epidemiologists (and few others, ha!) conceive of time and, w/in
		* that, year. Then, we list the baseline deaths. Remember: we actually
		* _wanted_ the missing values for 2020-present because we can't well
		* have a "baseline" for the period that includes the period itself! 
		* _But_ for computational reasons, we now want to put those baseline 
		* values in those rows represented by the years 2020 onward. 
			
		* (I listed only obs. in an arbitrary manageable number of weeks, btw).
	
	* So, let's fill in the baseline that we computed using only years 2016-19 
	* for years 2020-22. After all, it is still the baseline for those years. 
		bysort cyclicalweeks: replace /// 
			weekly_baseline=weekly_baseline[1] if year >2019
		* What this does is say "going by the repeating weeks of any year", 
		* replace the weekly-baseline for 2020 onwards with the mean we just got 
		* for 2016-19. The [1] just tells Stata to pull the first element of the
		* subset of the "baseline death" vector within these groups; elements 2,
		* 3, or 4 would also work. But not element 5, because that is 2020. If 
		* you start over and re-run the code, but then change [1] to [5], you'll
		* see no real changes made b/c you would replace a MV with ... a MV. 
		
	* Let's check our work. 
		list cyclicalweeks weekly_baseline year if cyclicalweeks <10, ///
			sepby(cyclicalweeks)
		
	* Finally, we can calculate weekly excess deaths. We'll first calculate raw
	* deaths and then we'll calculate the rate. 
		
		bysort cyclicalweeks: gen seasonal_excess_death = ///
			(weeklydeaths-weekly_baseline)
		
		bysort cyclicalweeks: gen seasonal_excess_rate = ///
			((weeklydeaths-weekly_baseline)/weekly_baseline)*100 
	
	* And let's check our work for, say, 2021.  
		list weekly_baseline weeklydeaths year seasonal_excess_rate if ///
			cyclicalweeks == 10
		di ((2656 -  1789.25)/1789.25)*100
			* Our spot-check looks good. 

	* Let's also quickly extract "real" weekly data. There are a bunch of ways to
	* do this; I picked a bit of a silly but easy method where I send year and week
	* to strings to quickly combine them in a familiar format, then extract that 
	* with a string-to-number function -weekly- which is necessary because weeks
	* here are "cyclical weeks".
	
		tostring(year), gen(stringyear)
		tostring(cyclicalweeks), gen(stringweek)
		gen yw = stringyear + "-" + stringweek
		gen realweeks = weekly(yw, "YW")
		* Now we can drop the string vars. 
		drop stringyear stringweek

	* Let's also make a moving average to smooth the data, which lets us again 
	* use our element functions. 
		sort realweeks
		gen seasonal_excess_rate_ma = (seasonal_excess_rate[_n] ///
			+  seasonal_excess_rate[_n-1] +  seasonal_excess_rate[_n+1])/3
		
	* Finally, let's label the data since, again, the sources and methods could be
	* confusing. 

		label data "Chile mortality data pulled 2022-03-31 from OWID" 
		
		note: We obtained this from the website listed below on 2022-04-11 /// 
		https://tinyurl.com/OWIDChile
		
	* BTW, note that the time-series syntax lets us calculate moving averages
	* as well, which lets us check our work. First, we need to declare that we
	* have time-series data with -tsset-. 
		
		tsset realweeks, weekly
			* General syntax is "tsset [identifying variable[s]], [periodicity]"
		
		* We'll make a moving average using the previous, current, and next obs.
		tssmooth ma EDRma = ///
			100*((weeklydeaths/weekly_baseline)-1),window(1 1 1)
			
			* Then, we'll take a moving average of the data w/o respect to seasons. 
		tssmooth ma EDRmads = ///
			100*((weekly deaths/weekly_baseline)-1), window(1 1 1)
		
		* And, let's check our work for, say, the most recent 20 obs. 
		
		gsort -realweeks
		list realweeks EDRmads seasonal_excess_rate_ma in 1/20
	
	* OK, finally, let's get to the interesting stuff: plotting these!
	
	tsline seasonal_excess_rate_ma, ylab(0(10)100) ytitle("Percent") ///
		xtitle("") xlab(2925(30)3232, alt) title( ///
		"Excess mortality in Chile (percent diff. to mean CDR from 2016-19)", ///
		size(medium))
		* Graph looks good. Human toll looks extraordinarily bad. 
		* "ylab" syntax: ylab(A(B)C) says label every Bth x-value from A to C.
		* "alt" tells Stata to alternate the placement of labels of the x-axis
		* so that they don't overlap too badly. The lack of any characters in
		* xtitle means that Stata omits the title, which is often useful for
		* the sake of economy in presentation if the label would be obvious.
		
* II.ii. Running sums. 
	
	* Finally, note that Mitchell shows that we can compute running sums across
	* groups, too: here, we could compute cumulative excess deaths by week and 
	* then overlay the years, which provides a different way of visualizing the
	* data that lets us more-directly compare the same cycle-week across years.
		
		sort year realweeks
		bysort year: gen running_excess_deaths = sum(seasonal_excess_death)
			* What this does is compute the running total for any given year of
			* excess death (adjusted for the week of the year) up until that 
			* point. 
		* We can now check our work. A really simple way to do this here is to
		* ensure that, generally, these values are not very large at the end of
		* the year for the pre-COVID years and that they should generally be
		* nearly-monotonic functions for the COVID years, both of which are true.
		list year cyclicalweeks running_excess_deaths
		
		* Now, we'll use our -separate- trick to get the cumulative excess death
		* for each year; if we don't, we get the below graph, which doesn't 
		* overlay the deaths, and which is a bit confusing at first because it
		* "snaps back" to zero at the start of each year (which makes sense, but
		* visually, it can take a second to figure out). 
		tsline running_excess_deaths
			* So, this is not that helpful. Let's separate. 
			
		separate running_excess_deaths, by(year)
		
		* Since the names of these variables are very bulky, let's go ahead and
		* store them in a local called "yearlyexcessdeaths" for easy access. 
		* Remember to run delimiter changes and locals with the lines to which
		* they apply as these commands only work locally. 
		local yearlycumudeaths running_excess_deaths2016 ///
			running_excess_deaths2017 running_excess_deaths2018 /// 
			running_excess_deaths2019 running_excess_deaths2020 /// 
			running_excess_deaths2021 running_excess_deaths2022
		set scheme neon 
		#delimit ; // Definitely helpful here to turn off carriage return.
		twoway line `yearlycumudeaths' cyclicalweeks, 
			legend(order(1 "2016" 2 "2017" 3 "2018" 4 "2019" 5 "2020" 6 "2021" 
			7 "2022") col(2) size(small) ring(0) pos(11)) 
			ytitle("Cumulative excess mortality") xtitle("Week of year") 
			title("Excess mortality in Chile by year", size(medium)) scale(1.2);
		#delimit cr
			
			/* The reason that the years 2016-2019 appear to balance exactly is 
			that we used them as the baseline. These lines plot a running sum of 
			weekly deviations from a multi-year average for that week of the year.
			
			Since we defined seasonal_excess_death as deaths less weekly_baseline, 
			we can write the summation for a year as Σ(deaths - weekly_baseline). 
			Then, we break that up into Σ(deaths) - Σ(baseline) for a given year,
			which is equal to a sum of deaths for a given week minus the mean for a
			given week of the year. If we repeat this across weeks, we end up w/
			the total number of actual deaths for that year minus (mean week 1
			+ ... + mean week 52). If we repeat across all four years, we get the 
			total deaths for all four years minus [4*Σ(mean week 1 + ... + mean 
			week 52)]. Since these are all means for a set of four weeks,
			multiplying by four just gives the total for all for weeks across 
			the four years.  So, we end up with total deaths - total deaths = 0. 
			
			You can check this for yourself in Stata. */ 
			
			sum seasonal_excess_death if year <2020 
				// If the mean is zero, Σ = 0. QED. 
			
			/* This might seem like a bit of a detour, but making sure you know what
			exactly is happening when you run complicated sums is important. */
	
