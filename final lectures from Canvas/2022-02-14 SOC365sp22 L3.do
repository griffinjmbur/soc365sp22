capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
/* By the way, notice that, throughout this lecture, we're going to again learn
another Stata shortcut, that of setting an overall working directory, then 
using the ./subfolder shortcut. I held off on doing this initially since showing
too many shortcuts early on can sometimes occlude what's really going on with
folders, which is an important thing to learn, but this should save you time in
the future -- and it occurred to me that while the tilde shortcut should
obviate the need for different Mac/Windows syntax in general, that is not true
when you are using WinStat specifically (I don't use WinStat much myself outside 
of teaching, so this didn't immediately occur to me). 

Conversely, this should work for everyone *as long as you manually set the 
correct "parent folder" above. If you are WinStat, use "copy address as text" and
paste that into the quotation marks above. */ 
log using ./do/Lecture3, text replace 

/* task: explore some basic techniques in data-cleaning
   author: Griffin JM Bur, 2022-02-07 
   SOC 365, Spring 2022, Lecture 3.*/ 

* 3.1: Introduction

	/* Setting aside some of Mitchell's unfortunately narrow-minded
	language about gender, the point he is making here is largely reasonable: 
	some of the time, dirty data are going to be complex, in that they might 
	involve subtle errors, such as someone having zero years of post-secondary 
	education but also holding a PhD. 

	It is imortant to do this sort of thing early on rather than to begin the 
	analysis prematurely, get excited about some odd results, start writing them
	up or dunking on the existing literature, and then find an error. */ 

* 3.2: Double-data entry

	/* We honestly won't do much direct data entry in this course, but this 
	isn't a bad thing to know. 

	Here's how Mitchell's suggestion about manually assigning a sequence
	number to observations might look like. The idea here is that we can 
	quickly check and see whether or not we've omitted an ID or counted
	one of them twice. */ 

	// We'll use the dentists data-set for simplicity since it's small. 
	use ./original_data/book_data/dentists, clear
	
	// Now we make an ID variable in Stata. This might well be useful to you
	// later if you have a data-set that doesn't include an ID variable.  
	gen seqid = _n
	
	// We can then sort the data by this variable... 
	sort seqid
	
	// ... and then simulating omitting a name 
	drop if name == "Ruth Canaale" 
	// Note that quotations are necessary for Stata to read a string.
	// You can see a typical error by running "drop if name == Ruth Canaale"
	
	// ... see what this looks like in the data-set ... 
	list
	
	// ... and then tell Stata to tell us if this has happend. 
	list seqid if seqid ~= (seqid[_n-1]+1) in 2/L
	
	// Here it has found the error we introduced (BTW, 2/L means 'from item
	// two until the end of the list'). 

	/* We can also investigate the method of comparing these two separately-
	entered data-sets. */ 
	
	use ./original_data/book_data/survey1, clear
	sort id 
	// note that the data have a slightly diff. set of variables than the text
	save survey1, replace
	// This is a rare case where it's probably fine to save over the data
	// because we're just re-ordering them, not really changing them. 
	
	* repeat the process
	use ./original_data/book_data/survey2, clear
	sort id
	save survey2, replace
	
	* and now try to see if they match
	use ./original_data/book_data/survey1, clear
	cf id using survey2, verbose all 
	// Note that you might need to add "all" in your version of Stata to
	// display the match outcome. 
	
	// What would this look like if they ID variable did not match? 
	
	drop if id == 5
	* cf id using survey2, verbose all 
	* This command yields an error, so I put it as a comment. 
	
	/* I won't get into the details here about what to do next since it will 
	vary from data-set to data-set, and thiis is not a focus for our course, but
	you will need to in some way return to the original data-sets and see if you
	can figure out why this happened. */ 
	
// 3.3: Checking individual variables 

	/* This section shows us how to look for implausible values of variables. 
	The first part is pretty straightforward. If we know that college graduate
	is supposed to be a dummy variable -- I'll talk about what that means in a
	bit, but for now, just think "binary variable" -- we should only see values
	of 0/1, which we do. If we knew from the codebook that race should take on
	values of 1-3, we shouldn't see other values, which in this case we do.*/

	use ./original_data/book_data/wws, clear
	tab collgrad, missing
	tab race, missing
	
	/* Now we come to a bit of a subtler problem. What if we encounter values
	that just seem implausible but which aren't disallowed? The book suggests a
	scenario where, perhaps for legal/political reasons, UI is capped at 300. */ 
	
	sum/*arize*/ unempins // Note that we don't need to include the "-arize"

	// Here, we find some very large values of unempins...let's list the obs.
	list idcode wage if wage>300
	
	// So, it's just two observations that have gone awry. We could now go 
	// consult the codebook or the original data. If we have neither, it is 
	// probably best to drop them, keeping a record of what we did (or, you
	// could save new data, though that's probably not the best strategy). 
	
	// The same procedure can be done with age. The book is somewhat tedious
	// here; this example doesn't differ in essentials so I'll omit commentary.
	tab age if age >=45
	list idcode age if age>=45
	
	// Let's also examine some implausible values on the CPS. 

	use "./original_data/CPS2019", clear
	// Let's say the maximum *likely* hours someone could work is probably 12
	// hours a day, every day of the week. Indeed, for most of human history,
	// both before and shortly after the high point of the Industrial Revolution,
	// people work(ed) far less -- on this see Sahlins, The Original Affluent
	// Society. 
	
	scalar likelymaxhrs = 12*7 
	// Remember: scalars just assign English-language names to numbers. 
	// It's basically like a value-label for a constant. And we can just tell
	// Stata to store the results of some calculation, eg 12*7, as a scalar. 
	
	tab hourslw if hourslw >likelymaxhrs
	// OK, this is a problem. Lots of people appear to work hours in the US that
	// approach the hours worked by people in the cruelest period of capitalist
	// development. Still, the US has no formal prohibition on maximum hours of
	// work. So, maybe these are plausible. 
	
	/* Maybe what we should do instead is to only eliminate observations where
	the person works, say, more than 16 hours a day, 7 days a week -- this would
	leave no time for transportation, personal care, exercise, or cooking, which
	seems unrealistic.*/
	
	// So, that would mean our max weekly hours are 16*7 hours/week. 
	scalar maxweeklyhrs = 16*7
	tab hourslw if hourslw >maxweeklyhrs
	
	// And we still find 47 observations that exceed this limit. 
	
	// Here's an example of how these change the results, using not drop but
	// isntead a conditional command -- though using cond. commands to avoid
	// outliers very many times is tedious until you learn programming. 
	
	// First, put a regression line on a scatterplot of weekly pay on hours.
	scatter weekpay hourslw || lfit weekpay hourslw
	
	// I'll show this now with likely-outliers dropped to make the point clear. 
	
	scatter weekpay hourslw if hourslw<likelymaxhrs ///
	|| lfit weekpay hourslw if hourslw<likelymaxhrs 
	
	// So, not a huge difference -- we can quantify it with summary statistics 
	// and see the effective using a bivariate regression -- but worth noting. 
	
	sum hourslw
	sum hourslw if hourslw<likelymaxhrs 
	reg weekpay hourslw
	reg weekpay hourslw if hourslw<likelymaxhrs 
	
	// So, let's drop them. Here we can be more conservative. 
	
	drop if hourslw>maxweeklyhrs 
	// Wait! Uh-oh! 124,000 observations dropped! We've surely made a mistake.
	
	/* This is instructive. It turns out, after some investigation that hours
	is a missing variable for many people in the CPS. Let's now only drop people
	who are not missing and exceed 112 hours. 
	
	First, we'll just re-load the data-set, clearing out the old data. */ 
	
	use "./original_data/CPS2019", clear
	scalar maxweeklyhrs = 16*7
	tab hourslw if hourslw >maxweeklyhrs
	drop if hourslw>maxweeklyhrs  & ~missing(hourslw)
	
// Brief interlude on dummy variables. 

	view browse https://tinyurl.com/dummyvarlecture
	
// 3.4: checking categorical by categorical variables

	/* Now we come to the somewhat-more-complex situation of comparing the 
	values of two categorical variables which should agree. First, we can see
	if people who live in a city center also live in a metro area. In theory,
	at a minimum (depending on how these terms are interpreted), if you live in
	a city center, you should live in a metro area. */ 
	
	use "./original_data/book_data/wws", clear 
	tab metro ccity, missing
	// And, indeed, no woman who lives in a city center fails to live in a metro.
	
	// We can also check and see whether there is any overlap between people who
	// are married and who have never married. Obviously, by definition, these
	// should not overlap. 
	
	tab married nevermarried, missing
	// Here we come to our first problem. Two people are "yes" to both married
	// and nevermarried. 
	
	// We can list them out like this
	list idcode married nevermarried if married==1 & nevermarried==1, abb (20)
	
	* Here's another example, now using the table command, which works much
	* like tab in this circumstance. 
		*(for the differences, see Nick Cox, "Speaking Stata: 
		* Problems with tables, Part I", available at... 
		* https://journals.sagepub.com/doi/pdf/10.1177/1536867X0300300308). 
		
	table collgrad yrschool
	tab collgrad yrschool
	// Note that in this case, the output from table is much more readable. 
	// But, by flipping rows and columns, there isn't much difference. One 
	// benefit of tab is that it can easily be used to calculated tests of 
	// association between categorical vars. such as a chi-square test. It 
	// also displays zeros by default, whereas table's default is just a blank.
	
	table yrschool collgrad
	tab yrschool collgrad
	
	/* OK, so, this presents some interesting challenges of interpretation. 
	Are the people with 15 years of education and a college degree errors? 
	Probably not: not all degree require four years, some people might do a 
	four year degree in three years, etc. Even 13 years might indicate a 
	technical degree, although most are two-year programs. But, we should 
	probably discount values <= 12.*/  
	
	drop if yrschool < 12 & collgrad == 1 
	// Only one observation fits these criteria and thus has been dropped. 

// 3.5: checking categorical by continuous variables. 

	/* we can also frequently check for implausible values of variables by 
	checking whether certain categorical variables -- often dummies -- are 
	consistent with a zero or non-zero values of a continuous variable. 
	
	This book's example may seem somewhat unfamiliar, but in case you're not
	familiar with the way that trade or labor unions typically work, people who
	are not members do not pay dues. So, the mean dues paid for non-members 
	should be zero. Yet, as we'll see, here it is not quite. */ 
	bysort union: sum uniondues
	
	// We can again try to manually list out the offending observations.
	list idcode uniondues if union == 0 & uniondues ~=0
	
	// Some of these cases are missing values, but others have non-zero values.
	tabstat uniondues, by(union) statistics(n mean sd min max) missing

	/* We can create a dummy variable that records whether a person paid 
	any dues at all. There are a couple of ways to do this; the book shows
	one (slightly more-complex) way to do so, but I show a simpler method here
	as well. */ 

	// First, we inspect the "parent" variable, uniondues
	tab uniondues // Looks safe to assume 0 means no union dues
	
	// Next, let's make an shell for our new variable
	gen unionduesdummy = .
	
	// And fill in the details. We want the variable to return the value "1" if
	// woman j pays dues at all and "0" if she pays no dues. 
	
	replace unionduesdummy = 1 if uniondues >0 & !missing(uniondues)
	replace unionduesdummy = 0 if uniondues == 0
	tab unionduesdummy
	// N.b. that we don't need to include !missing in the above case because
	// there is no way that a value can be both missing and exactly equal to 0.
	
	// Now let's make a value label for this new variable -- and the old one
	// while we are at it -- so that it is easier to read. 
	
	// First, we make the value label. 
	label define ud 0 "no dues" 1 "pays dues"
	
	// Then we past it onto our variable. 
	label values unionduesdummy ud
	
	// Let's do the same for the union variable since that will make it easier 
	// to use. 
	label define qwerty 0 "non-union" 1 "union"
	label values union qwerty
	
	// Let's see what the results look like -- more readable, I think!
	tab unionduesdummy
	tab union
	tab union unionduesdummy
	
	// Finally, here is the book's method. We'll go over this later; the basic
	// syntax is:
	// recode parentvar (rule 1) ... (rule n), gen(newvar)
	recode uniondues (0=0) (1/max=1), gen(paydues)
	
	// These produce the same result.
	tab paydues unionduesdummy
	
	// Now we can check the values of either (or both) dummies by union status,
	// expecting to see a mean of exactly zero for non-union workers. 
	tabstat unionduesdummy paydues, by(union)
	
	// Note that apparently not all union members pay dues, according to this,
	// either, which might mean that some people are simply miscoded, but not
	// necessarily -- it is more likely that some members are exempted from dues
	// than that some non-members pay dues. 
	
	tab union unionduesdummy, missing

	// And we can isolate these workers' ID-codes and go investigate, along with
	// some other information that might be useful (e.g., their dues level). 
	
	// Note that the syntax says, translated to English, "list the ID code and
	// level of union dues as well as union status if someone's union dues 
	// exceed zero, they don't have a missing value on this variable, and they
	// are not a union member. 
	list idcode uniondues union if uniondues >0 & ~missing(uniondues) ///
	& union == 0, abb(20)

	// The book shows a couple more examples, again, somewhat tediously, so I
	// will breeze through them. 

	/* Total years married should be zero for all women with a 0 on the
	marriage dummy, though some women who are a 1 on the dummy might also have
	zero years marriage if they only married recently. This appears to be true.*/
	
	tabstat marriedyrs, by(married) statistics(n mean sd min max) missing
	
	/* Is this same true if we check years of experience at one's current job
	by whether they have ever worked? */ 
	tabstat currexp, by(everworked) statistics(n mean sd min max) missing
	
	* Looks good!

	// What if we factor in total years of experience? Note that we are here
	// making a new variable again, which is one of those "bits and pieces"
	// things that I have shown before and which you can pick up in like fashion.

	gen totalexp = currexp + prevexp
	tabstat totalexp, by (everworked) statistics (n mean sd min max) missing
	* No problems here. 

// 3.6: Checking continuous-by-continuous variables. 
	
	// The book shows an example involving unemployment insurance. 
	
	* First we investigate the variable. Here, I limit the range of the 
	* conditional command to <30 hours worked. Why? It might be misleading to
	* include people who shouldn't, theoretically, be eligible! 
	
	sum unempins if hours <30 & !missing(hours)
	
	/* Now, let's check whether we have any problems among, say, people who are
	theoretically ineligible for UI under most countries' laws. 
	
	Here, we seem to encounter some problems. First, the amount of UI rec'd
	by people who are working more than 30 hours a week -- which should in 
	theory disqualify you from UI -- is not zero. */ 

	summarize unempins if hours>30 & ~missing(hours)
	
	graph box unempins if hours>30 & !missing(hours)
	
	// We might want an actual count of the number of ppl that have this unusual
	// value on this variable. 
	
	count if hours>30 & !mi(hours) & unempins > 0  & !mi(unempins) 
	// This is pretty substantial. We can list out the observations once again.
	// Note again that "///" carries commands across multiple lines. 
	
	list idcode hours unempins ///
	if hours>30 & !mi(hours) & unempins > 0  & !mi(unempins) 
	
	/* Here's another example of creating a variable that allows us to exploit
	the fact that many surveys ask the same kind of information in multiple 
	ways. Logically, "age when married" should equal one's current age minus
	the years one has been married, barring some technicalities (e.g., maybe
	the date of the survey is June 1, you got married Jan 1 of ~10.5 years ago,
	but your birthday is Dec 1.
	
	The book actually focuses more here on the investigated of implausible 
	values per se in a sociological sense -- "do some of these marriage ages 
	seem too low?", in other words. And indeed, some do. */ 

	gen agewhenmarried = age - marriedyrs
	tab agewhenmarried if agewhenmarried<18

	
	// We can carry out the same analysis for the age when one started working.
	gen agewhenstartwk = age - (currexp+prevexp)
	tab agewhenstartwk if agewhenstartwk<18
	
	// We can also check for logical impossibilities, such as one's third
	// child being older than one's second. All good here. 

	table kidage2 kidage3 if numkids == 3
	table kidage2 kidage3

	// The book shows another case of investigating unlikely values that mixes
	// the improbable -- it is biologically possible for some people to bear 
	// children at 13, though we have strong social strictures against that, but
	// a child at age 8 or 9 is very likely impossible or extremely unlikely. 
	
	gen firstbirthage = age - kidage1
	tab firstbirthage if firstbirthage<18
	
	* Note that many of these analyses can be replicated with the GSS or CPS. 
	
	/* For example, here I create a variable called "kids" which adds up the 
	number of children one has who are 0-2, 3-5, 6-13, and 14-17. Then, I compare
	it to a variable that just asks for the total number of children one has,
	which is "ownchild" on the CPS. 
	
	Of course, one might have children older than 17, so ownchild might exceed
	kids, but kids should never exceed ownchild, since one logically cannot 
	have some children aged below 17 but also have no children of any age. */ 
		
	use "./original_data/cps2019", clear
	gen kids = ch02+ ch35 + ch613 + ch1417
	tab ownchild kids 
	
	// This checks out--we have a lower-triangular matrix (all entries above
	// the diagonal, where diagonals are those elements Xij where i=j, are 0).
	
	// We can also use the GSS to, say, check that birth years and ages line
	// up, using the fact that we know when the survey was recorded. 		

	use "./original_data/GSS2018", clear
	gen agecheck = 2018 - cohort // cohort is the name on GSS for birth year
	list id agecheck age if agecheck != age
	// Interestingly, only missing values fail our test. Again, in theory, we
	// should actually see some minor gaps here since someone could well be born
	// on 1988-12-31, interviewed 2018-01-01, and thus the year minus their birth
	// year is 30, while their age is just barely 29. The GSS is a pretty clean
	// data-set, though, so interviewers may have cleaned up such discrepancies;
	// or, the question about age might include this kind of harmonization.

// 3.7: correcting errors in data 

	/* This section is somewhat hard to show in Stata; it basically suggests 
	how we might document corrections we make to mistakes that we find. */ 

	use ./original_data/book_data/wws, clear
	list id if race >3
	replace race = 1 if idcode == 543
	note race: we presumably checked the codebook to make this fix
	notes // This loads all notes for any data-set. 
	
	// Let's look at the notes for, say, the CPS. 
	use "./original_data/CPS2019", clear
	notes
	// We might pull up the problematic variable from before. This note is a bit
	// cryptic; consulting the codebook is probably wisest here. 
	notes hourslw 

// 3.8: Identifying duplicates

	/* This section is really long; Mitchell has a bad tendency to spend the
	most time on the things that are most esoteric (perhaps they just need more
	explanation, but arguably, some of the techniques are also just not-so-
	useful. */ 
	
	use "./original_data/book_data/dentists_dups"
	
	// Let's just examine the data-set first. 
	list
	
	// Let's now manually list out all duplicates. 
	
	duplicates list
	
	* ... and see some examples. 
	duplicates examples 
	// be careful: this literally just gives examples, not a full report. 
	
	// This is kind of like summary statistics for duplicates. 
	duplicates report 
	// Four observations are unique; four have a twin; three have two twins.

	// We can try these basic techniques on a couple of data-sets we've 
	// been using. 
	use "./original_data/CPS2019", clear
	duplicates list
	use "./original_data/GSS2018", clear
	duplicates list
	
	// None here! But we can see what it might look like. 
	
	expand 2 in 1/5
	duplicates report 
	// I don't recommend listing these; the massive number of possible questions
	// on the GSS means that your entire results window will be swarmed. 

	// We also might want to actually identify these observations. 

	duplicates tag, gen(dup)
	list id age educ dup in 1/10
	save ./modified_data/GSSdup, replace
	// Above, I just listed a few variables of interest and a few observations
	// or else there would be far too much to look at. 
	
	// We can also sort the duplicates by name and then years, allowing us to
	// see if, for example, observations that appear to be duplicates, such as
	// two people with the same name, really are duplicates (here, there is one
	// case of two people just sharing a name: Mary Smith. We can tell because
	// the dup var is zero for both Marys and they differ on some variables. 
	
	// (Note that this implies that you should consider whether there aren't 
	// duplicate observations that also have some slight data-entry errors!)
	use ./original_data/book_data/dentists_dups, clear
	duplicates tag, gen(dup)
	sort name years
	list
	duplicates drop
	list // note that Mary is not dropped. 

	// For more complex data-sets, we can try to run a command asking whether
	// a variable *is* an ID variable. 
	use ./original_data/book_data/wws, clear
	isid idcode // Good news: no duplicates
	duplicates list idcode
	
	// Let's try this with our two data-sets. They are clean enough to lack dupes.
	use "./original_data/CPS2019", clear
	isid uniqueID
	use "./original_data/GSS2018", clear
	isid id
	use "./modified_data/GSSdup", clear
	* isid id 
	* now this variable will yield an error message b/c the condition is false.
	

	use ./original_data/book_data/wws_dups, clear
	* isid idcode again, this is a comment b/c this generates an error message. 
	// We can see which observations are purely id duplicates
	duplicates report idcode
	duplicates list idcode, sepby(idcode)

	// But are some of these possibly *just* ID duplicates? 
	duplicates report 
	// It looks like it: we have fewer overall duplicates
	
	// Let's tag both sets of duplicates. 
	duplicates tag idcode, generate(iddup)
	duplicates tag, generate(alldup)
	
	// We can use a two-way table to show this: Nb that two observations are
	// duplicates on just the ID variable. 
	tab iddup alldup
	
	// And we can now examine those directly. 
	list idcode age race yrschool occupation wage if iddup==1 & alldup==0, ///
	abb(20) // OK, these are clearly different people. 
	
	// We can now give one of them a new ID. Let's first find out what the 
	// total number of IDs is. 
	sum idcode
	
	// OK, it is 5159. Let's make one of the duplicates person 5160, then.  
	replace idcode = 5160 if idcode==3905 & age==41
	
	// Let's re-run our procedure. 

	duplicates tag idcode, generate(iddup1)
	duplicates tag, generate(alldup1)
	tab iddup1 alldup1
	
	// Now we just have a couple of pure duplicates, which we can drop. 
	duplicates drop
	
	// Notice that we'll still have a couple of observations tagged with a 1 on
	// the duplicate variable -- that's just a number assigned to them now. 
	tab iddup1 alldup1
	
	// But we can confirm that we have no duplicates if run a report or 
	// re-run our procedure. 
	duplicates report 
	duplicates tag idcode, generate(iddup2)
	duplicates tag, generate(alldup2)
	tab iddup2 alldup2

log close 
