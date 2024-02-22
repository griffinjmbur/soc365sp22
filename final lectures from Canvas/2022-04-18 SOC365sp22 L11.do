capture log close
clear all 
set more off
cd ~/desktop/SOC365sp22
log using ./do/Lecture11, text replace 

/* task: discuss ways of structuring the same information 
   author: Griffin JM Bur, 2022-04-18
   SOC 365, Spring 2022, Lecture 11.*/
   
* STRUCTURE. 
	* 0. Introduction/big idea. 
	* I. Inspecting long and wide data.  
		* I.i. Dis/advantages of each kind of data. 
			* I.i.i. Similarities.
		* I.ii. Deciding between the two: generally go for long data. 
	* II. Reshaping from wide to long: an example with time-series data.   
		* II.i. Evaluating the existing structure of the data: an example.
		* II.ii. The -reshape- command. An example with a couple of sources of 
			* data and a graph. 
		* II.iii. An alternative route where we merge first/review of merge. 
	* III. Reshaping from long to wide. 
	* IV. A very practical example with some discussion of -collapse-, a review
		* of merging
/* 0. Introduction/big idea. 

The question of long vs. wide data is a one of the _structure_ of information, 
which is not something that we have extensively discussed, though I have 
mentioned it often in passing. 

The basic idea is that any time we have repeated observations that correspond to
the same conceptual unit -- a country, a year, a person, a family, etc. -- we can
represent that variation within the unit as different rows or different columns.

Almost any set of information could, in theory, be represented as long or wide,
though in many cases, it would be somewhat perverse to convert from one form to
the other (discussed below): some data-sets really just have information about
individuals at one time where all variables are measuring really-different
properties (these are intrinsically wide, let's say) and others where it might
seem really silly to represent the variation as different variables (let's say
the measurement of the S&P 500 every day for three years). 

I. Getting a tactile feel for long vs. wide data. 

This distinction only really has force when we have panel data since this is 
the only time we really have "repeat measurements". Why? Consider two scenarios. 

	First, what if we tried to make the GSS even "wider" than it is? 

		How would this even be possible? We would need to somehow change rows to
		columns. This would be illegitimate in a crude sense: with simple random 
		sampling, the observations are independent. 
		
		The only thing that would really make sense is if we wanted to make a 
		data-set of, say, regions and then represent individual measurements as 
		properties of variable (e.g., the income of person 1 in the Midwest).
		That's a form of collapsing our data-set, though, which we'll come back 
		to. It's not the same data-set.

		In conclusion, this doesn't make a lot of sense. 
	
	Second, what if we tried to make, say, a single wave of the GSS "long"?

		Well, we would need to change columns into rows. This, too, seems a bit
		nonsensical in context. We would need to, for example, represent a r's
		score on mental-health, religion, and educ. as some kind of repeated test
		but these are not forms of the same var. Arguably, on a survey as long
		the GSS, a couple of variable do indeed represent what are effectively
		are repeat measurements, but that is not true of most cross-sectional 
		surveys, and it is not true of the variables we've examined. 
		
		With more parsimonious data, where no questions can be really considered
		to be recording the exact same kind of information, this would require us 
		to merge variables that really aren't the same thing...or just have a
		bunch of rows per person, with one person's variable per row--silly!
	
What makes panel data different? By definition, true panel data involves a kind
of situation with multiple observations. Let's look at a couple of examples using
the book, then a more realistic example which we'll reshape. */ 

	* These data are _long_. We will generally prefer them; see below.
	* For now, just focus on the structure: we have repeat observations for the
	* same person if we list the data, and these are represented as different 
	* observations on the same variable: they are differentiated by time (or, at
	* least, with reference to soemthing temporal, such as different trials). 
	use ./original_data/book_data/cardio_long, clear
	list
		
	* ... while in this case, we have wide data: for each measurement, we have
	* a new variable, even if this variable is fundamentally the same thing. 
	use ./original_data/book_data/cardio_wide, clear
	list
	
* I.i What are the main advantages of each type of data? Here are several. 
	
	* Long data
		
		* 1. Required by Stata for time-series analysis beyond the most basic 
			* and generally easier to take correlations of entire variables. 
			
			* The use of time-series analysis is, in my experience, much more 
			* common for sociologists than the techniques that are better-suited 
			* by wide data. 
			
		* 2. We can quickly recode a variable that was recorded multiple times
			* because the information is just included in one column. 
			
		* 3. With many trials or dates or repeat observations--many panels, in
			* short--long data are easier to manage. 
	
	* Wide data

		* 1. They require less data-entry 
			* This is not really a huge concern in most cases. 
		* 2. They are more useful with techniques that psychologists use
			* Examples include -mvreg- and -factor-. 
		* 3. Merging is perhaps easier, though this is not reason enough to
			* choose between types of data-shape. 
	
	* I.i.i. Similarities
	
		* I.i.i.a. Correlations between variables at any point in time. 
		
		* Note: Mitchell strains a bit to make a point about the differences
		* that is not quite accurate--e.g., he says that it is easier to take the
		* correlation between, say, two different measurements at any one point 
		* in time with long data, using -bysort-, but this is hardly less work 
		* than with wide data. We just need to write a loop because there is not
		* a group variable for trial in the case of wide data. 
	
		use ./original_data/book_data/cardio_long, clear
		bysort trial: corr bp pl
		
		use ./original_data/book_data/cardio_wide, clear
		forvalues i = 1/5 {
			corr bp`i' pl`i'
			}
		
		* I.i.i.b. Calculating across time-periods. 
		
		* Similarly, although he does mention this, some other tasks are pretty
		* similar across the types. E.g., calculating means across time-periods
		* can be accomplished with -egen newvar = rowmean([trialvars])- in wide
		* data, while in long-data, we just use -bysort-. These have slightly
		* different properties because in the case of -bysort- we have a new
		* variable with 30 observations (so, the mean does not change, but the
		* variance will be smaller, as we discussed before wrt imputation using
		* means), but the means will be the same. 
		
		use ./original_data/book_data/cardio_long, clear
		
		bysort id: egen maxbp = max(bp)
		sum maxbp
		list
		
		use ./original_data/book_data/cardio_wide, clear
		egen maxbp = rowmax(bp*)
		sum maxbp
		list
		
		* I.i.i.c. Differences between adjacent observations. 
		
		* Finally, operations such as taking differences between adjacent obs. 
		* in time can be handled in different ways by each set. With wide data
		* a loop will work ... Mitchell does not show the loop but here I have. 
		
		forvalues i = 2/5 {
			local j = `i' - 1
			gen pulse_diff`i' = pl`i' - pl`j'
			}
		list id pulse_diff?
			
		* ... and with long data, -bysort- is again useful since we have turned
		* the trial information into a variable. 
		use ./original_data/book_data/cardio_long, clear
		bysort id (trial): gen pulse_diff = pl[_n] - pl[_n-1]
		list id trial pl pulse_diff* 
		
* I.ii. Deciding between the two: generally go for long data. 
	
		/* As noted above, long data turn out to generally be a little bit easier
		to work with, in addition to their being required by Stata for the suite
		of commands that you are most likely to use on them: panel analysis. 
		
		The main consideration here is the addition of data: when we add data, 
		how hard is it? If we have wide data, we need to add a new variable every
		time we have a new observation, but if we have, say, some individuals in
		the data-set who are measured much more often, or the measurements aren't 
		at the same exact time, wide data force us to make lots of columns that
		have missing values for many people. The same missingness with long data
		is just represented as the absence of a row--NBD.
		
		So, in general, we should look to secure our data in the long format.*/ 
		
/* II. Reshaping from wide to long data -- and examples of how to do time-series
analysis with long data in Stata. 

Let's begin with what is more likely to be useful to you: going from wide to long
data. We'll import data from a source that commonly uses wide data: the state. 
	
	Go get the most recent data from here. */ 

	view browse https://research.stlouisfed.org/data/owyang/fred-sd/ 
	
	import excel using ./original_data/Series_2021-09, sheet("UR") firstrow clear
	rename A date
		* This gives us some good practice remembering our import commands. Here,
		* we use "firstrow" again to get variable names and we use a cell-range 
		* to avoid some extraneous information contained in the top of the file. 

* II.i. Evaluating the existing structure of the data: an example. 

	* So, let's examine these data. Are they long or wide? Why? 
	
	d
	list date KS MO NC WI in 1/20
		
		* Answer: these are wide data because, whether we conceive of the basic
		* unit of analysis as days, with states as the grouping variable, or 
		* states, with days as the grouping variable, we have panel data...but
		* information on one of the two identifier variables (states) is encoded
		* not as different observations but different variables. 
		
/* II.ii. OK, so, what we'd like to be able to do is to get these into long 
	format for the easiest analysis. The key command here is -reshape- and the 
	general syntax is ...
		
		* reshape long [stub name], i(ID variable) j(new variable)
		
		* OK, that's a lot. What does it mean? So, first, a "stub" is just what
		* it sounds like: a short bit. For this command to make sense to Stata,
		* we need to have the variables that we want to split into a variable
		* part and an observation part named in a clear way. That is to say, we
		* want to change the variability across states (in this case) that is 
		* currently represented, for any time period (any row), as different cols
		* as additional rows, leaving behind just a single unemployment variable.
		* So, the stub should just be something like "unemployment". We'll rename
		* the variables in a moment. 
		
		* OK, so, what about i(identity) and j(new variable)? Well, the variable
		* that identifies our observations currently is just the date, which is
		* rendered as a month. The new variable that we want to create should
		* probably just be called something simple, such as "state". 
		
		* If you do not have an ID variable, you can make one easily using an
		* element command: gen ID = _n
		
	* Now, in our case, we do need to make a stub, which we can do pretty easily
	* with the -rename- command. */ 
	
	rename AL-WY UR=
		* To add a prefix to a set of variables, we simply put the set of vars
		* as the first input to the command and for the second input, we have
		* [the prefix]=. For a suffix, we'd do the same thing but reversed, i.e.
		* "rename [vars] =[the suffix]". 
		
		* Some stubs might be found inside of the names of variables, in which
		* case, we can use the general syntax that follows:
			* reshape long abc@def, i(id) j(new variable)

	* Finally, we are ready to issue the -reshape- command. Lastly, we need to
	* add the "string" option to j() because our information on states is a 
	* string (the USPS two-character abbreviation). 
	
	reshape long UR, i(date) j(state, string) 
		* Note that the number of observations increases here to 51*548, which is
		* the old number of observations (just dates) times the number of cols.
		* minus one (which is just the ID variable, which stays where it is). 

	* And, for the sake of ease-of-use, let's order the variables so that they 
	* are more rational, with IDs first...
	order date state UR
	
	* And now we can sort in a couple of ways, with either of the two perspectives
	* enumerated above serving as our organizing scheme. 
	sort date state
	br
	
	* Let's also merge these with some other data for more realism. First, save.
	save ./modified_data/state_UR, replace
	
	* ...and also, note in passing that once you've reshaped, as long as you
	* don't then modify your data too much, getting them back into the original
	* shape is pretty easy, too. 
	reshape wide
	
	* We'll just import another sheet from our same Excel file. 
	
	import excel using ./original_data/Series_2021-09, sheet("OTOT") firstrow clear
	* Do a bit of basic data cleaning...
	rename A date
	rename AL-WY inc=
	
	* And now it's time to reshape. Remember, the general syntax is 
		* reshape long [stub name], i(ID variable) j(new variable)
	reshape long inc, i(date) j(state, string) 
	
	merge 1:1 date state using ./modified_data/state_UR
	
	sort date state
	order date state inc UR
	br
	keep if _merge == 3 // Let's only keep merged observations for simplicity.
	drop _merge
	br
	
	* Finally, let's declare that we have time-series data and make some lines.
	* First, let's encode "state". We didn't do this before because the best 
	* way to encode a string requires making a new variable, but Stata can get
	* confused about the shape of your data if you change identifying variables
	* before merging or reshaping. 
	encode state, gen(state_num)
	xtset state_num date, daily
		
	#delimit ; 	
	set scheme tufte; 
	xtline UR if state == "WI" | state == "IL" | state == "MN" | state == "MI", 
		overlay ytitle("Percent") xtitle("") 
		title("Unemployment rates in select Midwestern states")
		xlab(5844(1400)22493, alternate angle(45)) legend(ring(0) pos(11) col(1));
	#delimit cr
	
	save ./modified_data/state_UR_inc, replace
	
* II.ii. Review of merging and an alternate route. 
	
	* Note also that we could have merged our data in wide format first, and as
	* the book notes, this might be a good reason to provisionally use wide
	* data before converting to long because we only need to reshape once and
	* merging the data should be pretty easy conceptually and computationally. 
	
	* First, let's import the sheet with unemployment data, do a quick bit of 
	* cleaning and save. 
	import excel using ./original_data/Series_2021-09, sheet("UR") firstrow clear
	rename A date
	rename AL-WY UR=
	save ./modified_data/wide_UR, replace
	
	* We'll clear and then do the same thing for the income sheet. 
	import excel using ./original_data/Series_2021-09, sheet("OTOT") firstrow clear
	rename A date
	rename AL-WY inc=
	save ./modified_data/wide_inc, replace
	
	* Then, we'll do a simple merge of these two data-sets. 
	merge 1:1 date using ./modified_data/wide_UR
	keep if _merge == 3
	br
		* For simplicity, we'll only keep matched observations
	
	* Now, it's easy to simply issue one -reshape- command. 
	reshape long UR inc, i(date) j(state, string)
	br
	
/* III. Reshaping from long to wide. */ 

* We can also use -reshape wide- if we need to. 
	
	* I'm honestly not aware of a ton of examples when this would be necessary, 
	* apart from those Mitchell gives -- GIS is one. 
	
* Let's continue with the data-set with which we were working prior. 
	
	* Here, we need to account for the fact that we have panel data and changed
	* the structure. Let's drop our numeric state variable for simplicity--it is 
	* the less convenient of the two for this purpose. This is a common problem
	* that might arise: if we do not do this, we will get an error message to the
	* effect that state_num is not constant within values of date. There really
	* isn't much use in having two separate ID variables converted to columns. 

	use ./modified_data/state_UR_inc, clear
	drop state_num
	* Note that the syntax here is pretty similar to that above. We generally 
	* write ... 
	
		* reshape wide [varlist], i(identity var.) j(panel var whose values we 
		* want to become a prefix in front of the members of [varlist]
	reshape wide inc UR, i(date) j(state, string)
	br
	
	* We could also reshape our data in the opposite way, though be warned that
	* this will produce a somewhat unwieldy dataset! Note that here we do not
	* need to worry about "state_num".
	
	use ./modified_data/state_UR_inc, clear
	reshape wide inc UR, i(state) j(date)
	order state_num, after(state)
	br

* I won't spend too much longer on this because this technique is generally much
* less commonly needed. I do want to mention one other points, though: Make sure 
* to mention all variables after "reshape wide". If you do not do so, Stata will 
* assume that this variable is constant within obs. 

/* IV. Another example, and some uses of collapse (plus, an interesting graph).*/
	
/* Let's look at another example of reshaping from wide to long. As I mentioned
above, this is a common case because most government-produced data-sets in my
experience are in wide format. Let's look at some state-level unemployment and 
population data from a different source in the government. This time, we're going
to use data that have FIPS (Federal Information Processing Standards) tags, which
makes them compatible with a wide variety of sources, particular maps. */ 

view browse https://archive.ph/9RkwG
	* We'll use data from the Economic Research Service, a branch of the Dept. 
	* of Ag.. Download the population estimates and unemployment and income 
	* estimates (the latter two are in a single file) and put in "original_data".
import excel using ./original_data/populationestimates.xlsx, ///
	cellra(A2:H3282) firstrow clear
rename *, lower
destring fipstxt, gen(fips)
	* So, "fipstxt" is a string but it's really numeric. In that case, -destring-
	* is best for getting the numeric strings transferred correctly--be careful
	* that you don't run another command that might display the correct (slightly
	* weird) FIPS numbering system as a value-label with slightly different 
	* numeric values -- this can be very confusing. 

* Let's hand check a few of these. Does anyone know Madison's FIPS code?
list areaname fips if areaname == "Dane County" | ///
	areaname == "Mecklenburg County" | areaname == "Guilford County" 
	* We can check with this website: 
	view browse ////
	https://transition.fcc.gov/oet/info/maps/census/fips/fips.txt
	* Note that I picked the county names of some places I've lived that are 
	* unique. Don't fret if you pick one that's not unique; some counties have
	* the same name! (For example, Orange County, where Chapel Hill is, would
	* appear to have a mistake because, somewhat predictably, it is not a 
	* unique county name). 
	
* Let's also get a numeric version of state. 
egen states = group(state), label
drop ruralurb fipstxt state // we can drop some variables we don't need

* Now, let's do the reshape. These data are wide. Why? Because we have panel
* data -- counties and years uniquely identify observations -- but part of the 
* variability that defines observations (across years) is parceled into columns.
br

* Here, the data already come with a stub, which is convenient: "population". 
* Then, "fips" identifies the variables, and we want to make a new variable out
* of the part of the column vars "population[number]" called "year", which is the
* bits of information after the prefix "population". 
reshape long population, i(fips) j(year)
br

* For simplicity, let's drop years that won't match in our other data-set, save,
* and then move on. 
drop if (year ~= 2000 & year ~=2010)
save ./modified_data/state_pops_00-10_long, replace

* Now, let's get employment information from the same source. I won't comment on
* any steps here that are identical to those above.
import excel using ./original_data/unemployment.xlsx, ///
	cellra(A5:cH3280) sheet("Unemployment Med HH Income") firstrow clear
rename *, lower
drop rural urban metro
destring(fips_code), gen(fips)
reshape long civilian_labor_force_ employed_ unemployed_ unemployment_rate_ ///
	, i(fips) j(year)
	* Note that here we have several patterned variables that we might want to 
	* keep, so we need to put in several stubs. Why have I left the underscore
	* after? Because now all that is left is a number, which Stata finds easier
	* to process. If we don't do that, we'll need to take a couple of intermediate
	* steps, such as declaring our j() variable a string, removing parts of the 
	* string, and so on. 
rename *_ *
	* This is a pretty hilarious looking bit of code, but what it does is remove
	* the suffix "_" from any variable that has it. 
drop if (year ~= 2000 & year ~=2010)
save ./modified_data/state_unemp_00-10_long, replace

* Now let's merge these. This should be a 1:1 merge even though we have two vars.
* Why is that the case? And what is the syntax? 
merge 1:1 fips year using ./modified_data/state_pops_00-10_long
	* This is a 1:1 merge because we have the same observations; they simply 
	* happen to be defined by two variables, year and county (FIPS). 

* We do have a handful of unmatched observations; let's check them out. 
list areaname fips year if _merge == 2
	* OK, so, we have some Census areas, which might be irregular in various
	* ways. Also, notably, every unmatched unit is unmatched for both years. They
	* is probably just missing for one set; we would want to investigate more in
	* a real project, but for now, we can just move on. 

* Now, let's make some variables of interest: how about the change in population
* and the change in the unemployment rate? We'll make the change in population
* a rate, but we'll leave unemployment as a simple different--percentaging 
* percentages is can cause interpretative trouble among people who are not very
* fluent in math (always consider your audience), so in many settings, one might
* consider using percentage points.

* Let's use our techniques from last week since those are extremely useful. I 
* often like to -sort- first, then use -by-. Why? -bysort- can require you to
* compress a lot of thoughts into one line of code, and it does not give you a
* way to check your work before proceeding. So, let's sort our observations by
* county and year first.
sort fips year
browse

* Now, for every county, let's make a change in the unemployment rate, a 
* population change rate, and a percentage point change variable for UE. 

by fips: gen pop100 = ((population[_N] - population[1])/population[1])*100
by fips: gen unemp100 = ((unemployment_rate[_N] - unemployment_rate[1]) ///
	/(unemployment_rate[1]))*100
* But, per my last e-mail to you all, note that the following also works: we can
* sort by fips and year but only iterate this over fips and not year (why do
* we not want to iterate over year? Because fips and year uniquely identify 
* observations, so we do not want to take the difference over groups defined by
* fips and year: there logically cannot be a change "between" one observation!
sort pop100
	* I just randomly sorted these in a different order to prove the point.
bysort fips (year): gen unemp_point = (unemployment_rate[_N] - unemployment_rate[1])

* Let's also account for the fact that this data-set has summaries at the state
* level in it. We actually do _not_ want to include those, because it would be
* misleading. So, we can use a clever trick (if I say so myself): we'll get rid
* of all observations that end in three zeros. 
drop if substr((fips_code), -3, 3) == "000"
	* syntax here in this specific case is this: substr(variable, -N1, N2) looks
	* N1 places backward from the end of the string for a length of N2. Since all
	* of the state-level FIPS codes are just two initial numbers and then a set
	* of zeros, this drops all state-level observations. 
save ./modified_data/merged_pop_UE_00-10_long, replace

* Now we can -collapse- the data, meaning that we get rid of individual obs,
* taking the mean (or another summary stat.) at the level of the variable 
* specified in by(var), which leaves a data-set with values of the variable in
* by() as the observations -- here, we collapse two years of data into a mean of
* the county. Note that all of our variables besides population have the same 
* value for all observations, so all that we're really doing here is getting
* rid of the time-series information, the point of which you'll see in a moment.
collapse (mean) population pop100 unemp100 unemp_point, by(fips)
save ./modified_data/merged_pop_UE_00-10_collapsed, replace

* Now, let's make some cool graphs! This part we're going to go over loosely
* since it's just a fun application, but not something you need to do on a test. 
* The tricky part of it is using maps. I am taking the next small chunk of code
* from Chuck Huber of StataCorp: https://archive.ph/DewR9

clear
cd ./original_data // Changing our directory will be useful here
copy https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip ///
     cb_2018_us_county_500k.zip, replace
	 * This step pulls the map information from a Census website. If this part
	 * does not work, you can just directly download it from here: 
	 * https://www2.census.gov/geo/tiger/GENZ2018/shp/cb_2018_us_county_500k.zip
	 * and place it into your original_data folder
unzipfile cb_2018_us_county_500k.zip, replace
	* This step unzips a compressed file
spshape2dta cb_2018_us_county_500k.shp, saving(usacounties) replace
	* Here, we put the "shape data" given by the Census into Stata format.
use usacounties.dta, clear
	* Now, we load our data and make a FIPS variable that identifies each of the
	* rows of map information.
generate fips = real(GEOID)
save usacounties.dta, replace

* Now, let's merge this map file with the collapsed data. The reason for using 
* this collapsed data is that it makes mapping the idea much simpler. 
merge 1:1 fips ///
	using ~/desktop/SOC365sp22/modified_data/merged_pop_UE_00-10_collapsed

* OK, we have just a bit more housekeeping. First, we turn on the map tool. 
grmap, activate
drop if missing(_ID)
	* Next, we drop a handful of missing IDs. Let's assume this is unproblematic
	* because the number of cases is small; in reality, you'd want to give this
	* a closer look. 
spset, modify shpfile(usacounties_shp)
	* Now, we set the spatial characteristics of our data. 

* Finally, let's drop non-continguous territories -- sorry to AK, HI, and the 
* various colonies (de jure and de facto) of the US -- their distance from the
* "lower 48" makes the map render very badly if they are included. 
drop if fips>= 60000
drop if STATEFP == "15" | STATEFP == "02"
save ~/desktop/SOC365sp22/modified_data/unemp_pop_map, replace
set scheme white_tableau
* And, finally, we can map the population and unemployment data. 
grmap pop100, ///
	 title("Percent change in population between 2000 and 2010") ///
	 clnumber(9)
grmap unemp100, ///
	 title("Percent change in unemployment between 2000 and 2010") ///
	 clnumber(9)

* I also want to mention a more user-friendly way to do this, which is, however,
* much more limited in its scope. But, if you're using US data, this is probably
* a bit easier and more aesthetically appealing. Actually, both -grmap- and the
* command we are about to see are "wrappers" (simplified versions) of -spmap-, 
* but -maptile- is much simpler than -grmap-. 
cd ~/desktop/SOC365sp22
use ./modified_data/unemp_pop_map, clear
ssc install maptile // install program
view browse https://michaelstepner.com/maptile/geographies/
	* This command requires us to manually install the geographical files
maptile_install using "http://files.michaelstepner.com/geo_county2010.zip", replace
	* Let's get the 2010 county-level shapes. 
gen county = fips
	* The data in our file need to match the names in Stepner's files; he called
	* counties "county", so we duplicate our "fips" variable with that name.
save ~/desktop/SOC365sp22/modified_data/unemp_pop_map, replace
	* let's same this map file. 
maptile unemp_point, geog(county2010) fcolor(Heat) conus nquantiles(10) /// 
	twopt(title("Percentage point change in unemployment, 2000-2010"))
	* OK, cool! Lots going on here. The syntax is this: "maptile [outcome var],
	* geog[shape file's name] fcolor[color scheme] conus [means only include the
	* lower 48, again for visibility] nquantiles([number of quantiles])

* Finally, just for fun, let's look at how we can make a graph that is quite 
* common in glossy magazines and "legacy media" for whatever reason. BTW, any
* time I show you how you can make a map exactly like NPR or The Economist, I'm
* not saying that those are Objective, Unbiased Defenders Of The Science From 
* Misinformation--it's just fun to see a very obvious payoff of all of this 
* code (publication-quality graphics that clearly communicate information).

* First, we'll get a couple more shapes from Stepner's website. 
maptile_install using  "http://files.michaelstepner.com/geo_statehex.zip", replace
maptile_install using "http://files.michaelstepner.com/geo_state.zip", replace
* Then, we pull our original merged data up again. 
use ./modified_data/merged_pop_UE_00-10_long, clear
* And, now let's collapse by state rather than FIPS since the hexagonal data are
* for states and not counties. 
collapse (mean) population pop100 unemp100 unemployment_rate unemp_point, by(state)
* And re-run maptile. 
maptile unemp_point, geog(statehex) fcolor(Heat) nquantiles(10)
