capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
log using ./do/Lecture9, text replace 

/* task: discuss the combination of data: appending and merging
   author: Griffin JM Bur, 2022-03-21
   SOC 365, Spring 2022, Lecture 9 [1].*/
   
   * 1. Again note that I am following the number of actual weeks in the semester  
   * for the sake of keeping things clear. We did not have a "Lecture 7". */ 
   
* STRUCTURE. 
	* 0. Introduction/big idea. 
	* I. Appending.
		* Example A using GSS data.
		* Appending problems
	* II. Merging.
		* II.i. 1:1 merges
			* Example B using NHANES data. 
		* II.ii. m:1 or 1:m merges
			* Example C using OWID COVID data. 
	* III. Common problems and odds and ends. 
   
/* 0. BIG IDEA: merging data and appending data are two important techniques for
combining data, i.e., somehow meaningfully putting together separate datasets, 
of which you will often want to make use. 

APPENDING DATA means we are adding observations. If your data are organized in 
the way we typically think of data--observations on the rows, variables on the
columns--this means "adding rows". You'll probably want at least some overlap
with the type of variables in each set, but you generally don't need to worry 
about how individuals relate to one another. You're just increasing N. 

MERGING DATA means we are adding variables. Again, if, using the conventional
notation N = number of observations and K = number of variables, your data matrix 
is NxK (which is both more common in Stata and also how we generally assume 
matrices to be organized in statistical theory), this means "adding columns". 

In the case of one-to-one (1:1) merging, we generally add data-sets with different
variables for the same observations to make one set. The key thing is that you 
have some "link" variable that uniquely identifies observation in both sets. You
can have more-complex cases, where you have multiple ID variables, both of which  
are unique identifiers, or perhaps you have multiple-key merges, but this is the 
basic idea in any case: you are putting together multiple variables that pertain 
to the same unique unit that can be found in each set. 

In the case of many-to-one or one-to-many (1:m, m:1) merging, the key var. is 
the actual unique identifier for one set of data. If it didn't exist, it would
be easy to recreate by just numbering the rows. But, for the other data-set, it
is just a variable, albeit an important one (probably). For example, if you are
merging basketball player-level and team-level data (for a single year for the
sake of simplicity), your link variable would be teams. The team-level data is 
_the_ ID variable for the teams data; again, it would "exist" in Stata even if
we didn't write it down because Stata knows that rows are different obs. But, if 
we delete it from the player-level data, it would be more like losing a key var.
On the back-end--which our book doesn't show very clearly but which I will show
you today--merging in this case looks like taking the data with more granularity 
and copying group-level information for each observation. The result looks a lot 
like a typical -egen- procedure where one takes group-level means which are copied 
identically for all observations in that group.

The key thing with merging is to make sure that you have at least one key variable
on which you can match observations in one set to another, whether or not the
variable uniquely identifies observations in both groups. 

	Quick but important note on the assumption that adding individuals means more
	rows and adding variables means more "columns": it is not always correct! 
	There are merely strong conventions about data shape -- NxK is much more 
	common -- and related conventions about language here (e.g. "vector" is 
	assumed to be a column vector, though it could well be used to mean a 
	row--it's ambiguous).
	
	Importantly, we'll also discuss later on the fact that, although this 
	distinction is simple when you have just one cross-section of data, as on the 
	GSS or CPS, this can be more complex when we have panel data. That is what 
	will preoccupy us during our study of (re-)shaping data. 
	
	The key difference is that you might have repeat observations on the same 
	individual represented as different variables on one unique record for
	them...or as different observations with unique IDs which are nested within
	a group ID for all observations on some "fundamental unit". So, for example, 
	the true observations might be country-years in time-series cross-sectional 
	data, and we often want these to be represented as separate rows: each unique 
	combination of country and year is its own row.
		
		Stata prefers the method just mentioned but these *could* be represented   
		in a different way: each row could be a single time-period or single
		country, and the "panel" information -- the fact that each country and
		each time period appears more than once -- is represented as columns. This
		is how many government data-sets come, for example; you can get data on
		unemployment across states from the Fed with months as observations and
		the state-level information represented as a set of 50 variables. 
		For now, just note these are both possbilities. The data are "long" when
		the same unit is represented by multiple rows and distinct observations 
		and "wide" when these repeat observations become different vars. */ 
		
* Visual guide to merging and appending:
* Appending vs. merging
view browse https://archive.ph/trGh2
* Types of merging
view browse https://archive.ph/PzlJw 

/* PART I. APPENDING DATA. 

Let's begin with an example of appending data. But first, let's discuss some 
hypothetical scenarios (non-exhaustive ones, of course): whe would we want to 
_append_ as opposed to _merge_ data? 

	Discuss with a peer the following situations: 
		i) You have data on unemployment rates in a handful of cities in WI, but
		then you find data on cities in MN and want to put them together. 
		ii) You have data on unemployment rates in cities in WI, and then you
		find Census-tract level information on unemployment rates for some cities.
		iii) iii) You have two sets of economic data for different US cities as  
		well as on the regions in which those cities lie, which overlap. 
		iv) You have two days of blood pressure readings from a health clinic 
		with demographic information for analysis, but patient IDs are missing. 
		
		(Possible answers are given at the end of this .do-file). 

So, let's say that, for whatever reason, I'm willing to regard the 2012 GSS and  
2018 GSS as basically samples from the same population (dodgy but that's OK). If
I so choose, I can simply -append- the new observations. What this means is that
I am just adding more observations without trying to match them to existing 
observations in any way. We'll get there; that's merging. 

Appending is very easy to do in Stata, and it is often easy to do without Stata, 
(though less efficient: do what you can in one program) in Excel. The key thing 
in the material in this lecture is (for the most part) less the vagaries of code 
and more about the need to consider carefully what you're doing and why. Again,
think about why an append makes more sense here. 

So, let's do this merger quickly and naïvely and then discuss some problems. We
will make the 2012 GSS the "master" data-set and the 2018 GSS the "using" set. 
These terms have no meaning apart from the fact that we start with master and use
using. It's not actually hierarchical. Let's also just keep a small set of 
variables for simplicity. _This is generally a good strategy!_

	EXAMPLE A. */ 
	
	/* I'm going to switch the working directory to the original data folder for  
	the sake of concision here, BTW. */ 

	cd ./original_data
	
	use gss2012, clear
	* Let's only keep a few variables that we really need here. 
	keep educ maeduc paeduc race sex year rincom06
	d, short // Let's note how the dimensions our data matrix change (or don't).
	* The code itself is fortunately quite simple. 
	append using gss2018, keep(educ maeduc paeduc race ///
		sex year rincom16) // Don't worry about massive output; we'll get there.
	d, short 
		// OK, so have one variable that does not overlap, but the number of vars
		// is more-or-less the same, as intended; the number of obs is the same
		// as the sume of the individual Ns. 
	bysort year: sum * 
		// We can get a brief sense of the relative contributions of each set to
		// the appended set in this way. 

/* Appending: what problems did, or could we, we encounter? 

	1. We might not know which set the data came from. 
	
	Here, that is not a problem because we included "year". But, how would we go
	about fixing this if it were? 
	
	1a. Fixing missing source information. */ 
	use gss2012, clear
	keep educ maeduc paeduc race sex year rincom06
	qui append using gss2018, keep(educ maeduc paeduc race ///
		sex year rincom16) gen(survey_year) // Key step is to include gen() opt.
	label define sy 0 "2012" 1 "2018"
	label values survey_year sy
	tab survey_year year, mis
		/* So, this duplicates what we already had just through retaining the
		included GSS variable "year", but it may not always be so simple. 

	2. Variables might have different names. 
	
	Here, that *is* a problem. Let's see which observations are defined on 
	rincom06 and the other income variable we've worked with in the case of the 
	2018 wave, rincom16. */
	tab survey_year, sum(rincom06)
	tab survey_year, sum(rincom16)
		/* so, this is a case where the same information was recorded in different
		variables across sets.
	
		2a. Fixing conflicting variable names.
	
		There are a few ways to do this. The book gives a slightly roundabout way,
		but I think you can do this more quickly: rename var_master to some new 
		name you want to use for both sets. Then, append, and ...
			replace new_name = [var_using] if missing(new_name). */ 
		
		use gss2012, clear
		keep educ maeduc paeduc race sex year rincom06
		gen personalinc = rincom06 
			// We pick a new name for the 2012 income var. We'll keep the
			// original variable as well for comparison. Let's also get the 
			// number of obs. for later. 
		qui append using gss2018, keep(educ maeduc paeduc race ///
			sex year rincom16)
		sum personalinc 
			// OK, so, only people from master (2012) are defined on this b/c the
			// number of defined observations for the appended data didn't change.
		replace personalinc = rincom16 if missing(personalinc)
			* Note that this is a bit crude and changes over _all_ forms of MVs to
			* simple system missings. 
		* It's always important to check your work; here's one way. 
		version 16: table year, c(mean personalinc mean rincom06 mean rincom16)
	
	/* 3. Variables might have different coding schema.
 
	So, income is a great example of a case where the nominal value of a var.--
	i.e., the "face-value" of the thing--might change in terms of its meaning
	over time. You might know this concept by its punchier street name of 
	"inflation" (ha). Beyond the problem of inflation -- which also obtains with
	non-economic variables, e.g. the number of deaths in a population has a very
	different contextual meaning when population changes significantly--it is also 
	possible that the meaning of numeric coding might change. Let's observe. */ 
	
	d personalinc rincom16
	label list LABAT RINCOM16
		* There are ways to automate this, but they are a bit clunky. We can
		* see from hand-inspection, e.g., that 26 is a missing response for
		* earlier observations but corresponds to "$170,000" for newer. 
		
	* Solution? We probably need to do some serious re-coding that I won't 
	* address here. In general, this way of recording income is, to put it
	* mildly, a bit shortsighted. A more common problem is taking exact but 
	* nominal values of income and converting them to constant dollars. That is
	* easier if you know basic econometrics: just adjust for inflation. 
	
	* This might seem like a cop-out, but I actually do not recommend using the
	* GSS for serious econometric work for this reason. Usually this will only
	* be a problem with variables whose numeric values are not intrinsically
	* meaningful--that is almost always going to be variables that are "really"
	* qualitative, if not in this case--and the number of possible-values is 
	* generally going to be smaller and more tractable. 
	
	/* 4. Variable and value labels might differ. 
	
	This is less severe so I don't touch on it here; it's only a problem if the
	variable label for one data-set would be seriously misleading, and not just
	a bit different, if applied to the other. If your value-labels are misleading
	you may well have a coding scheme problem  in reality (Cf above). 
	
	The general solution is to harmonize them before merging; this can require
	a lot of typing, but the basic idea is intuitive. By the way, we saw a lot
	of repeats with our variable labels above (this makes sense: we're basically
	appending identical data-sets); in practice, you might only be using a couple
	variables from each set. Let's see how big a problem this really is. */ 
	
	keep educ maeduc paeduc race sex year personalinc
	
	* So, we probably would want to hand-check these values. By going to the 
	* relevant section of the codebook, we can do that. 
	
	view browse ///
		https://gss.norc.org/documents/codebook/GSS_Codebook_mainbody.pdf
	
	* So, it turns out that the GSS documents such changes in a special appendix.
	* Perfect--we can just review that. We can also see, by going to any var.'s
	* page, that the coding scheme appears to be consistent across years. 
	
	view browse ///
		https://gss.norc.org/documents/codebook/GSS_Codebook_AppendixN.pdf
	
	/* 5. Variable types might differ. 
	
	Good news: if you just have conflicts between different types of qualitative 
	and quantitative variables, Stata will fix these automatically for you: e.g.,
	it will change the length of strings to accommodate the longer string and it
	will change the format of quantitative variables to accommodate the more 
	precisely-measured data. 
	
	You can run into problems if the variables are of *different* types, but the
	trick is just to harmonize those types; L5 goes into great detail on changing
	between these two types, so I omit that here. */

/* PART II. MERGING DATA. 

II.i. One-to-one ("1:1") merges. 
	
	These are most useful when we have subjects who are split across data-sets
	for whatever reason. It is not wildly common in most fields of research to
	encounter situations where you'll have _person-level_ data split-up into 
	two sets unless you are the person preparing the data and you made both
	files. But, it is common enough in some fields. Let's look at a simple 
	example using the National Health And Nutrition Examination Survey that
	we have seen before (also called NHANES). This is based on an actual bit of
	personal research I did a couple years ago, so this is a practical example. 
	
	EXAMPLE A. 1:1 merging with two, or multiple, sets
	
	Conceptual problem that calls for merging: the body measurement data are not
	in the same file as other data of obvious importance such as biological sex.
	Let's first pull the demographic data, then the body measurement data. */ 
	
	cd ~/desktop/SOC365sp22 
		// Now we need to hop between subfolders so it is easiest to switch
	
	view browse https://tinyurl.com/NHANES365i 
	
		/* Get this part of the data, put it in your original_data folder, and
		we'll practice importing other file formats. */ 
	
	import sasxport5 ./original_data/DEMO_J.xpt, clear
	
		* It can be hard to remember where we got stuff if we plan to rename
		* the data-set to a better name and ditch the original file, so let's
		* do that now (this is not just a formality: I pulled these data a few
		* months ago, and I remembered that I did this while I was prepping the
		* lecture notes...and forgot exactly where I got the data and spent 15 
		* minutes tracking the exact source down :( . 
		
		label data "NHANES 2017-18 Demographic Data" 
		
		note: Original source is CDC website, SAS XPORT file DEMO_J.xpt ///
			https://tinyurl.com/NHANES365i 
		
	* Let's also manually make a source variable as this will help us later. 
	gen from_demog = 1
	
	* Let's check what seems to be the ID variable based on this page: 
	* https://wwwn.cdc.gov/Nchs/Nhanes/2017-2018/DEMO_J.htm
	
	isid seqn // remember this command? 
		
	duplicates report seqn // and this one? all of this is cumulative!
	
		* Let's note the number of unique obs. for later
		 scalar demog_N = r(unique_value) 
		 
	* And keep just a few variables for simplicity 
	keep seqn riagendr ridageyr from_demog
	
	d, short 
		* Let's check out the matrix of data. Look like we have a matrix of
		* dimensions 9254x4 (9,254 rows and four columns). 
	save ./modified_data/NHANES17_demog_short, replace
	* That looks good. So, now let's get the measurement data-set loaded. 
	
	view browse https://tinyurl.com/NHANES365ii
	
	import sasxport5 ./original_data/DXX_J.xpt, clear
	
		label da "NHANES 2017-18 Dual-Energy X-ray Absorptiometry - Whole Body" 
	
		note: Original source is CDC website, SAS XPORT file DXX_J.xpt at ///
		https://tinyurl.com/NHANES365ii
		
	* Let's again manually make a source variable. 
	gen from_xray = 1
	save ./modified_data/NHANES_2017_whole_body_xray, replace
	
	* Let's verify that "seqn" identifies obs. uniquely here, too.
	
	isid seqn
	duplicates report seqn
	scalar exam_N = r(unique_value) 
		* OK, so, we have fewer observations, but that may not be problematic and
		* we're in the same ballpark; we would expect fewer people to have full
		* body exam. data than to have basic demographic data. Let's finally 
		* examine the dimensions of our data matrix and then try the merge.
	
	* And again just drop most variables
	keep seqn dxdtopf from_xray
	save ./modified_data/NHANES17_xray_short, replace
	
	d, short // Note that we have a 5114x3 matrix this time. 
		* So, we should expect a merger with a matrix of dim. 9254x4 to result
		* in a matrix with no more than 9254 rows and seven columns (you might
		* expect six since one variable must be shared, but -merge- automatically
		* makes a "_merge" variable). 
	browse // Sometimes it is helpful to see this to get a tactile sense.
	
	merge 1:1 seqn using ./modified_data/NHANES17_demog_short
		* OK, great! We have matches on about half the IDs. 
		* Note that all unmatched people came from the "using" data-set, indicating
		* that everyone who was found in the body examination set had their basic
		* demographic variables collected, but the reverse was not true. 
	
	* We can also check out who might have been absent in one set vs the other. 
	tab _merge, sum(ridageyr) nost nofre
		* Looks like the mean age in the basic data-set is significantly older. 
	
	* And of course, it is helpful to check the dimensions of the matrix we 
	* made and then examine the data directly. 
	d, short 
	br
	
	* Let's just briefly enjoy the fruits of our labor and do something fun. 
	* Content warning for discussion of weight/body-fat. 
	
	replace riagendr = riagendr-1 // recode to conventional dummy var. 
		label define sx 0 "male" 1 "female" // make value label
		label values riagendr sx // apply 
	rename dxdtopf percentfat // convenience 
	separate percentfat, by(riagendr) // make percentfat into two separate vars. 
	rename percentfat0 male_pct_fat // give catchy names
	rename percentfat1 female_pct_fat // ibid. 
	kdensity male_pct_fat, gen(q0) at (p) // store coordinates of kdensity est. 
	kdensity female_pct_fat, gen(q1) at (p) // ibid. 
	ssc install scheme_tufte
	set scheme tufte // change scheme to nice minimalist style (also close to CDC
		// house-style; whatever else is true of it, MMWR has nice aesthetics).
	line q0 q1 p, sort ytitle(Density) xlabel(10(5)60) legend(order(1 "male" ///
		2 "female")) title(Percent body fat by biological sex)
		* This is a simple way to get around the problem of kdensity only taking
		* one variable; there are others.
	
	* We can also merge multiple data-sets; this isn't too much of a stretch, 
	* though as Mitchell notes there are some tricky bits with keeping track of
	* where things come from. 

	save ./modified_data/NHANES_body_demog, replace
	
	* First, let's load the body measurement data. Go grab these from the CDC
	* website as well and place into the relevant directory. 
	import sasxport5 ./original_data/BMX_J.xpt, clear
	keep seqn bmxbmi bmxht // again just keep a couple vars of interest.
	gen from_measurement = 1 // make a from_ var. 
	save ./modified_data/NHANES_mx, replace // Save to Stata format. 
	merge 1:1 seqn using ./modified_data/NHANES_body_demog, nogen 
		* Here, if we don't suppress "_merge", we'll get an error message. 
	* Let's now label all the from_* variables using a loop. 
	label define from_ds 0 "not in data-set" 1 "in data-set" 
		foreach j of varlist from* {
			replace `j' = 0 if missing(`j')
			label values `j' from_ds
			}
	* Make sure you have tablist installed; use -findit tablist- (for some reason,
	* Mitchell has apparently not posted this to the SSC). 
	tablist from*
		* So, we can see that most of the people who were missing on the x-ray
		* data-set were actually in the basic measurement data-set (the first 
		* row here is the number of people in all three data-sets; the second 
		* two rows will combine to yield the number of observations that, in  
		* some way failed to match in all three sets. Notably, a lot of people
		* who are missing on the x-ray data-set were still present in the others.
	
	* BTW, Mitchell spends a lot of time on merging options here. For the most
	* part, this is not necessary. -keepusing- would be more useful if we could
	* guess what variables we want from the "using" data-set without looking...
	* which, unlike with appending, we probably can't, at least without doing 
	* some prior preparatory work. It is probably easier to go prepare a short
	* version of the using data and merge. I _do_ think that -nogen- is useful 
	* for the reason that reason Mitchell notes: it is necessary to avoid errors
	* with more than one successive merge. -keep- and -assert- are less useful;
	* we can get the same information from "_merge" or a cross-tabulation of 
	* the "from*" variables, and it is safer to keep all observations before
	* dropping any. 
	
	* Final thought on 1:1 merging: some of Mitchell's examples (e.g. merging
	* moms1 and dads1) are a bit artificial, and it is probably better to try
	* appending (e.g., if you didn't have parents' age split into separate vars.
	* but instead had the more-probable case that both were just called "age"; 
	* you basically need to rename any variables that you don't want merged, but
	* it might be the case that you just want to append data--you could then merge
	* with a family-level data-set, and in some cases, the family level info. 
	* (e.g., HH income) should be recoverable with -egen- functions and bysort
	* rather than requiring any merging (e.g. if you had individual income). 
	* Think about what you're doing and why, as always. 
	
* II.ii. One-to-many (1:m) and many-to-one (m:1) merges. 
	
	* This type of merging is often done for you when individual-to-household
	* merging is necessary--a common type of data you may wish to analyze. I 
	* thought about showing an example involving the PSID where we _do_ merge by
	* hand ... but the PSID actually does this for you unless you ask it not to,
	* so it seemed too artificial. Let's look at a much more common use of this
	* technique: merging individual-level data with data from higher hierarchical
	* levels than the family, or merging individuals which are not people but
	* instead "low-level" institutions, or more-specific time periods. 
	
	* Why are the latter more common? Well, because, it is typically the case that
	* if you have the same _individual_ in two samples or the same _HH_, they 
	* were probably collected by the same researcher...what is the probability of
	* any individual out of hundreds of millions of US adults showing up in two 
	* surveys? And anyways, you would not know who the person is since the ID
	* numbers are anonymized. In other words, if you're merging individual or 
	* HH data, the same group probably collected the data, and with some notable
	* exceptions (the NHANES data are used by many people in tutorials for this 
	* reason, as I was amused to note while preparing), the data are often merged. 
	
	* But! It is extremely probable that different agencies will collect data on
	* the same units _above_ the HH-level without coordinating. For example, tons
	* of data-sets include UW-Madison, our Census tract, city of Madison, the
	* state of Wisconsin, and so on. There's not much of a privacy issue or a
	* probability issue here, so you might very well get separate data on the
	* same basic set of entitities, or a case where some of these entitities are
	* sub-sets of the others and want to merge them. This is especially 
	* relevant with data being made available in real-time and which researchers 
	* don't have time to clean -- for example, COVID data (see L5). 
	
	* EXAMPLE C. 
	
	* Let's look at an example using a neat tool that I have been meaning to 
	* show you all: the fact that you can directly import data collected by
	* the Fed (Federal Reserve Bank, the US central bank) through its St. Louis
	* regional Reserve Bank, referred to as Federal Reserve Economic Data (FRED).
	* You've probably seen their graphs before or ended up on their website; 
	* the frontpage is here: https://fred.stlouisfed.org/. 
	
	* All you need to know is the name of the series you want to import; this
	* can be done by searching Stata (-fredsearch [keyword]-) or by looking on
	* the website and looking up the name of the series there. 
	
	* You _do_ need a "FRED key", which takes a couple minutes to set up and 
	* which you can permanently set with Stata. 
	
	* set fredkey [your key here], permanently
	
	* Let's look at some daily data on, say, the S&P 500, which is a stock market
	* index that tracks the market capitalization of the 500 largest US firms. 
	
	import fred SP500, clear
	
	* If you didn't get a chance to get a FRED account, get the data from the
	* course_data folder and place it into your original_data folder, then load it.
	* use ./original_data/SP500, clear
	
	// Back to the main theme. 	
	d 
		* OK, so we have a 2610x3 matrix with just one column vector of actual
		* data (SP500). Let's also note the time-line here: 
	sum daten, format 
		// the format option lets you keep the time-formatting, without which 
		// this is hard to interpret. We have data from April 2012 to April 2022.
		
	* For the sake of showing you some date functions and also making what we are
	* up to clearer, let's extract the month from these data. 

	gen month = mofd(daten)
	format month %tm
	list in 1/20
	* Let's rename date to something more intuitive and drop the string version.
	rename daten date
	drop datestr
		
	save ./modified_data/SP500_cleaned, replace

	* Let us now examine some _monthly_ data. You can think about this as like
	* the problem of merging individuals to families: individual dates exist in
	* the span of some specific month, but the reverse is not true. So, what 
	* kind of merging do we want to use? Read on to find out. 
	
	import fred U6RATE, clear
	
	* Again, if you didn't get a chance to make a FRED account, go grab the 
	* data from the course_data folder, and then run this: 
	* use ./original_data/U6rate, clear
	d
	
	* Again, note the simple structure of data -- this can get more complex, but
	* both because FRED data are often not in the right "shape" when we make 
	* things more complex and interesting, and because we'll discuss this soon,
	* I want to keep things light and just used one national-level variable. 
	
	* If you want a preview of what we'll discuss in a couple of weeks, note that
	* FRED data, like many government data-sets, are in wide format, meaning that
	* if I added a bunch of state-level unemployment data, these would be turned
	* into columns, i.e. they would be rendered as variables associated with the
	* observations, which are months. It is better for Stata to have them be
	* long, i.e. for unique observations to be, say, state-months, i.e. for the
	* information about state to be recorded as a row-property or sample size
	* property than a column-property or variable-number property. We'll look at
	* examples of this when we discuss -reshape-, an important command. This would
	* also make -merge- much more complex. 
	
	* Let's again get the month from these data. Technically, these are monthly 
	* data which just happen to be listed as months, but you'll run into cases 
	* often enough where you have months, and I want to show you how you can 
	* do a m:1 or 1:m merge. Plus, these functions are useful and we've seen them
	* before, so we can now apply them in a concrete setting. 
	
	gen month = mofd(daten)
	drop daten
	format month %tm 
	
	* Finally, let's again look at the span here. 
	sum month, format 
		* OK, notably, these go back much further to 1994, and they are, of course,
		* not complete for April. 
	save ./modified_data/U6_cleaned, replace
	
	* So, now the correct form of the merge is to do a 1:many because here we have
	* one month for multiple days in the "using" data-set. 
	merge 1:m month using ./modified_data/SP500_cleaned

	* Alright, let's examine the merge. First, we have a lot of matches, though
	* some from the master and just one from the using didn't appear. We can 
	* look at the outcomes and summarize years and weeks. Here, we can again 
	* use -table- in the same we have been using it--not just for analysis proper 
	* but also to keep an eye on data-management tasks by seeing what conditions 
	* are associated with potentially problematic outcomes such as missingness 
	* or non-matching. 
	
	version 16: table _merge, c(min date max date min month max month)
		* OK, this looks good: data from the master data-set on unemployment which
		* weren't matched were all too old to have matches in the S&P data-set. 
		* Conversely, the one observation with just an instance in the "using"
		* is April 2022...which makes sense since we _do_ have some valid 
		* daily observations here but a monthly observation is unlikely to have
		* been published as we're just a few days in. 
	
	* Let's also examine how the data themselves changed shape before we run
	* some simple descriptive statistics. 
	
	d
	br
		* If you scroll down to the part of the data-set where there are 
		* observations on both variables, you'll see what the merger actually
		* "looks like": the group-level information is just copied over. So,
		* note that -merge- is *different from, say, -collapse-, which is useful
		* when you just don't need a certain granularity of data and want to,
		* say, turn a daily data-set into a set of monthly means. 
 	
	tsset date, daily 
	// This tells Stata how to understand the time-series; it's not necessary 
	// to know about this for our course. 
	
	ssc install schemepack 
	set scheme neon // Let's play around with a new scheme. 
	graph query, scheme // here's how you can see all those avaialbe to you. 
	
	* BTW, these variables don't have anything like a common scale, so let's 
	* make one; this is a simple arithmetic technique that you might find useful
	* in your projects. 
	
	* First, we need to find the first non-missing date for the S&P 500 in the 
	* data, which lets us examine some useful functions in Stata; here, we're
	* going to first make a variable indicating whether the S&P info is missing. 
	gen present = ~missing(SP500)
	tab present
	egen firsttime = min(cond(present == 1, date, .))
		* syntax: cond(x,a,b[,c]) returns a if x is true and nonmissing, b if x 
		* is false, and c if x is missing; a if c is not specified and x is mis. 
		* min finds the minimum value. 
	di firsttime // Let's find out that "first time"
	list if date == 19085 // and, since this number is formatted in Stata'
		* unique way of rendering dates, let's just see the observation for
		* that day and grab the value of the S&P from that date. 
	gen SP500index = (SP500- 1419.04)/ 1419.04

	#delimit ;
		tsline U6RATE SP500index if ~missing(SP500index),
			legend(order(1 "U6-unemployment rate" 
			2 "S&P 500 percent change on April 2012") pos(0) 
			bplacement(nwest) size(small) col(1)) 
			ytitle("Percent") ylabel(0(5)25) xtitle("") 
			title("S&P 500 and U-5 Unemployment", size(med));	
		#delimit cr
		* What's going on in this graph? Ylab tells Stata where to start marking
		* ticks (0), how often to do it (every 5), and where to end (25).
		* The legend suboptions "size" and "col" tell Stata how big to make it
		* (the default is often too large) and how many columns to use in the
		* legend itself (the box which explains what the lines are). 
		 
		* Note that legend takes numbered arguments starting with the natural
		* numbers, not the values of the variable (so, no need to use a 0, as 
		* some people sometimes do). The location suboptions (pos, bplacement)
		* are complex; see -help legend_options-. 
		
		* The titles are self-explanatory (you can use quotes or not...I kind of 
		* like that it makes them stand out with color). But perhaps xtitle is
		* not self-explanatory...why did I do that? It's a quick way to suppress 
		* a title should you not want one. Here, it's maybe too obvious.
		
/* PART III. common problems with merging and odd and ends. */ 

* Common problems. 
	
	* Mitchell mentions a few worth exploring. 
	
	* 1. Common variable names. 
		* This is potentially the most problematic because it is likely the
		* most insidious ... because it is common (probably more common than value
		* label problems since people pick all kinds of weird label-names and 
		* those are less likely to coincide). 
		
		* When would this occur and what happens? Well, this is bad news. The
		* master data-set values take precedence. This would happen if we had
		* information about the same variable in both sets but it really encoded
		* different information. 
		
			* When would this be problematic? If, say, "peduc" referred in one
			* data-set to person's education and in another set to father's. This
			* would replace father's education with the person's or vice-versa,
			* depending on which data-set is the master. 
			
			* When might it be OK? An example is if the two variables should be
			* identical anyways. For example, above, if we extracted yearly 
			* information using a date function in Stata and called both vars.
			* "year", they shouldn't ever disagree since no day or month can
			* straddle two years. 
		
	* 2. Same value-labels. 
		* This is somewhat unlikely to occur, but it is worth checking. My 
		* general tip -- only include variables you actually want to use -- is
		* applicable here: just -describe- both data-sets, note the labels, and
		* follow up if you need to. (If you're merging data-sets that have partially
		* overlapping information, I would drop it from one data-set once you 
		* check that there are no big differences). 
		
	* 3. Conflicts in key variables. 
		* This does happen, but it is a simple fix: just harmonize the type and
		* name of the linking variable. 
		
* Odds n ends: what can you basically ignore, following my tip from last Monday? 

	* Update merging. 
		/* This might be a bit antiquated; there is often no reason not to just
		replace the data… as Mitchell notes, it is perhaps easiest if we ourselves 
		are making updates to the data, but if you’re just getting the data from 
		someone else, you’ll probably just a fixed data-set, not an updates-only 
		file that needs to be merged. */ 
		
	* m:m merging
		/* This is kind of rare, and what you should use, as the text notes, 
		is -joinby- rather than a merge command. As Stata Tip 142 puts it,
		"joinby is the real merge m:m". 
		
		Why would you ever use this? If you have two data-sets that can be 
		considered "cross-hierarchical" in some way -- maybe parents are nested
		within the level of "kid" (this might sound silly, but if you have data
		on, say, a classroom, and then you collect parental information for each
		kid, the linking variable is the kid) ... but then maybe you have multiple
		kids, who could also be considered to be nested within the level of
		parent (of which there are multiple). 
		
		I would generally proceed with caution here. Another way to think about
		-joinby- is that it forms all possible pairs between two sets, possibly
		within levels of particular variable. Note that the outcome of such a merge
		is different to simply matching on some larger nesting variable, e.g. the
		family ID: -joinby- produces pairs of parents and kids in Mitchell's eg, 
		which is more complex than giving everyone the same family-level info.
		What would happen if, say, using regions on the GSS, we did an m:m merge?
		We would have data that has every unique pairing of people in regions.*/ 
	
	* Crossing 
		* You will probably not have much reason to use this. 

* Bonus. Frames (not tested). 
	
	* Frames basically let us hold multiple data-sets in Stata at once, which is
	* in a way not too far from merging. 
	
	* This won't appear on any exam, and its utility is situational (Stata's 
	* documentation points out that merge is often more apposite). That said, 
	* since it is a big difference to other comparable software, especially R,
	* it seems worth pointing out, and it can be useful if you're doing something
	* destructive to data, such as -collapse- mentioned above. 
	
	* This has changed in later editions of Stata -- we all have that capability
	* (unless you've been here several years and haven't updated Stata), but at
	* the time of Mitchell's writing, Stata 12 was still yet to come out. As of
	* Stata 16, the -frames- syntax lets you work with multiple data-sets at once.
	
	* Contact me if you're interested in this; I prepared some notes on this and
	* decided to just leave them out entirely for the sake of concision. This guide
	* is also pretty useful: https://archive.ph/WM5qA. 

/* 	Possible answers to peer discussion questions. 
		i) You have data on unemployment rates in a handful of cities in WI, but
		then you find data on cities in MN and want to put them together. 
			- This calls for appending; these are basically the same kind of 
			theoretical object (albeit with a different value on the grouping
			variable "state") and we have the same variable.
		ii) You have data on unemployment rates in cities in WI, and then you
		find Census-tract level information on unemployment rates for some cities.
			- This calls for 1:m merging with cities as the master data-set; the
			data are not at the same level, so direct appending would require us
			to say that tracts and cities are both, say, locations...but we'd also
			be repeating some information since tracts are part of cities. So,
			we want to merge here. 
		iii) You have two sets of economic data for different US cities as well 
		as on the regions in which those cities lie, which overlap. 
			- This one is tricky. The answer really is "we need more information".
			This might seem roughly akin to the moms/dads merge of families, but 
			the problem is that cities don't overlap, and regions likely don't 
			uniquely ID observations. It may be best to append and use -egen- to 
			calculate or copy down region-level data. 
		iv) You get two days' worth of blood pressure readings from a health clinic 
		with demographic information for analysis, but patient IDs are missing. 
			- Another tricky one. Appending sounds nice, but what if some people
			are repeats? That can violate our normal statistical assumptions. In
			this case, you want to be careful about combining in the first place.
			On the other hand, a merge would require some key or link variable,
			which appears to also be absent. These may not be suitable to combine.
