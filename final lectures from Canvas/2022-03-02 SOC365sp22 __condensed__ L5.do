capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
log using ./do/Lecture5, text replace 

/* task: explore some basic techniques in generating new variables
   author: Griffin JM Bur, 2022-02-28
   SOC 365, Spring 2022, Lecture 5.*/ 
   
/* A general map for this lecture. Making new variables is a critical
part of the research process. *Almost never* will you come across a data-set 
where the variables that you'll want for the most interesting sort of analyses
exist in the data-set exactly as how you'd hope. 

This lecture has a substantial side to it -- I start by showing something that 
is easy in terms of Stata but requires being rather careful about the logic (5.2)
of dummy variables, factor variables, and sociological reasoning. My hope is that
this should be useful for thinking about your project. I also try to
generally show a wider variety of data-sets than I have show so far since you 
have until this evening to submit a first proposal for your project -- and you 
are free to change it up after that point, even ,though you should let me know
if you choose to do so. 

There are also some technical Stata skills I hope to leave you with.

For example, I demonstrate how to manipulate strings efficiently, recode in a 
faster way than we've learned up until this point, quickly rename variables, 
code missing values, use the helpful "extensions to generate" command, use 
factor variables, and even program a little bit in Stata. 

The material on functions (5.3) is relegated to an appendix since it useful but 
more advanced; I did not do the same with the date/time material, but you can
also generally give that a fairly quick skim. I also note some other places 
where the techniques used are somewhat obscure or particular. */ 
   
// 5.1: introduction
	use ./original_data/gss2018, clear
// 5.2: creating and changing variables

	/* So, we've seen a lot of variable creation so far, with increasingly-more
	examples drawn from my own research, but it is time to focus on the creation
	of variables per se, and I think I owe you all a clear reason to learn this. 
	
	Let's suppose that we want to create a race variable that incorporates,
	at a minimum, information about whether someone is Hispanic/Latino. In
	principle this procedure can be extended to many other group, but showing
	this in one lectuer would require too much time and it is easy to see how
	you might extend this. 
	
	Also, I will consider it an acceptable project to extend my analysis in 
	some way. I had help from a couple of Stata wizards myself when I came up
	with this code, so I will pay that forward. 
	
	Let's begin by checking out the race variable--I notice that it does not 
	include many catgories. On a tip from Prof. John A Logan, I looked at 
	the "hispanic" variable. */ 

		codebook race
		lookfor hispanic
		codebook hispanic, note
		
	// OK, the codebook is not very helpful. Let's try the value label 
	
		labelbook HISPANIC
		
		// Looks like all but hispanic == 1 are people who might, on some 
		// definition of the word, be Hispanic. Note that this is (inevitably)
		// a contested question. We should try avoid reifying race, so maybe
		// we are best off just using the GSS's definition -- even if people
		// who are Filipino might more often be socially-coded as Asian-American.
		// By "not-reifying", I mean that we should accept that race is a 
		// construct and arbitrary no matter what; saying that some ethnic group
		// "really should be" considered "race Y" misunderstands that race is
		// itself a biologized misunderstanding of ethnic/national relationships. 
	
	// Let's also drop missing values here for the sake of convenience so
	// that we don't need to put it in every command. This is generally not
	// a good idea *until* you know that you absolutely want to work with
	// these variables -- but if you do, then this is fine as they will make
	// no appearance in the analysis anyways (or shouldn't, at least). 
	
		drop if missing(race) | missing(hispanic) 
	
	/* My approach here is to make a dummmy variable for each race group to 
	first see what kinds of questions might arise before coding a factor variable
	for use later on; the factor variable can be treated like a set of dummies
	where appropriate (e.g., multiple regression) so what I now do is more to 
	make sure that my logic is clear rather than for Stata purposes. */ 
		
		// First, let's generate a dummy for Black individuals. 
		gen Black = 1 if race == 2
		replace Black = 0 if race ~=2
		label define AfAm 0 "not Black" 1 "Black" 
		label values Black AfAm
		label variable Black "respondent identifies as Black"

		// Now we make a new variable for Hispanic respondents
		// Nb that this has the same name as the old variable with just one
		// letter capitalized -- this is not best practice, but I wrote this
		// code in 2017 and don't want to change all instances. It's also a 
		// good lesson in being careful with cases! 
		
		gen Hispanic =1 if hispanic ~=1
		replace Hispanic = 0 if hispanic == 1
		label define HispAm 0 "not Hispanic" 1 "Hispanic"
		label values Hispanic HispAm
		label variable Hispanic "respondent identifies as Hispanic"
		
		// Let's  check for overlap with Black respondents.

		tab Black Hispanic
		
		/* We do have some overlapping categories here--some people code 
		themselves as Black  and Hispanic. Since race as a social relation
		operates according to a "one-drop" rule in the US in the opinion of many
		who study such phenomena, we'll go ahead and code the eight overlapping 
		cases as "Black" since they will likely be "socially coded" in this way. 
		
		I'll talk in a moment about why we actually do not want any overlap even
		though that might seem like a simple solution to the phenomena of real-
		world data saying that people can be multiracial. */ 
		
		replace Hispanic = 0 if Black ==1 & Hispanic ==1
		
		// Let's check our work. 
		
		tab Black Hispanic
		// Good--we have no one with a "1" value on both
		// Black and Hispanic and those 14 people were added to the 
		// tally of Black respondents. 
		
		/* Let's carry out the same check for white respondents. */ 

		gen white =1 if race ==1		
		replace white = 0 if race ~=1
		label define wt 0 "non-white" 1 "white" 
		label values white wt
		label variable white "respondent identifies as white" 
		
		// It's time to check this variable for overlap
		// with respondents who self-identify as Hispanic
		tab white Hispanic
		// So, there is quite a bit of overlap. Here the social 
		// scientist faces a problem: how do we code people without
		// "racializing" them ourselves?
		
		/* Note that, as the book shows, we can also look at this problem
		using table, which lets us enter three variables -- unlike tabulate. */ 
		
		table Black Hispanic white
		/* So, we can see that Black respondents are only Black -- as intended --
		and we also have some non-Black non-white non-Hispanic people, whom we'll
		discuss soon. We also have non-white non-Black Hispanic ppl -- again, 
		as intended -- but we also have non-Black white Hispanic people, which is
		of course a *reality* -- but without making things excessively complex, 
		there are some mathematical reasons that we might want people to be 
		uniquely identified on the set of race dummies we're making. 
		
		What  would the *ideal* way to treat such people be? Perhaps to have a 
		long list of mixed-race identifications. But if your interest is
		in looking at big lines of racial inequality, you're basically 
		already committing to the idea that Black, white, and Hispanic are 
		meaningful large-group differences. So this is problematic, yes, but it
		is part of the whole enterprise -- and, again, part of the flatenning
		of difference that constitutes race itself! */ 
		
		// Anyways..., social theory suggests that white Hispanics might 
		// benefit from "whiteness", if not as a rule, 
		// so let's make white Hispanics "white" in this schema.
		
		// We should expect to see the toal number of Hispanic people
		// decrease by 185 and the total number of white people to increase by
		// the same. Above, we had 338 Hispanic people and 1504 white people. 
		
		replace Hispanic = 0 if Hispanic ==1 & white ==1
		
		// Let's check our work. 
		tab white Hispanic
		//Looks good -- no overlap. Also, 
		
		di 338 - 185 // This checks out
		di 1504+185 // as does this
	
		
		// Now we have to create a dummy for people who
		// answered that their race was neither Black nor white.
		// We could try to recover some of the heterogeneity in this category
		// by also incorporating information about, say, origin on the continent
		// of Asia, but this would take us beyond the scope of this example. 
		gen otherrace =1 if race ==3
		replace otherrace = 0 if race ~=3
		label variable otherrace "respondent identifies as 'other race'"
		label define or 0 "WBH" 1 "'other race'"
		label values otherrace or

		// Let's again look for overlap.
		table otherrace white Black
		table otherrace white Hispanic
		// It turns out that there is a lot of overlap here,
		// too, since the GSS method of coding is far from ideal.
		// To try to make the "other" category as small as possible
		// since it is so unsatisfactory, let's assign all of the 
		// overlapping individuals to "Hispanic".
		replace otherrace = 0 if otherrace ==1 & Hispanic ==1
		
		// Finally, let's code a factor variable for convenience 
		// of use later on. We'll see what use this has later. We could
		// have done this directly, but making dummies first a) was useful
		// in forcing us to think clearly about hard questions but also b) 
		// makes this part simple in Stata.
		
		gen racenew = 0 if white == 1
		replace racenew = 1 if Black == 1
		replace racenew = 2 if Hispanic ==1
		replace racenew = 3 if otherrace == 1
		
		label define rn 0 "white"  1 "Black" 2 "Hispanic" 3 "'other'"
		
		label values racenew rn
		
		// We can check our work this way as well. 
		tab racenew
		tab racenew white
		tab racenew Black
		tab racenew Hispanic
		tab racenew otherrace
		
		/* Since we did a lot of work here, we can save these data, but again,
		it may be safer to avoid this while you're still learning since it is
		easy to misplace the do-file where you actualy create the modified dta.*/
		save ./modified_data/GSSbetterrace, replace
		
// 5.4: strings

	/* In generating new variables, we have occasion to work sometimes with 
	string variables, which are variables that are rendered as non-numeric
	characters in Stata's "mind" -- even if they are actually numeric in our
	sense, e.g. dates (we'll look at this soon). 
	
	Strings take some special kinds of commands, and they are worth examining 
	since you may well come across them in less-common data-sets. */ 
	
	// Let's get some interesting data. I found this on art auctions on ICPSR,
	// one point of which is to get you thinking about some interesting data-sets
	// if you are still toying around with your project. You can change your
	// project as need--but check in with me if you do, please!--and of course
	// you still have until 11:59pm tonight to submit a rough idea to me. 
	
	import delimited using https://tinyurl.com/auctiondata, ///
	delimiters(tab) clear
	
	/* Let's look at the artists' names. */ 
	d
	lookfor name
	// This looks right, but can we confirm? 
	
	tab aname // OK, I recognize some of these. looks good. 
	// The all caps is annoying, though. Can we get rid of that? 
	gen artistname1 = proper(aname)
	
	tab artistname1
	
	// Cool. But, what if we want to split the name? Well, that's harder
	// because the surnames are of different lengths. But, think practically:
	// what can you "hit with a hammer" (i.e., what is tedious but fast enough)
	// and what do you need to program? Since it's pretty easy to tell, even for
	// a non-Francophone, where most of these names start and end, we could just
	// export these data, quickly add the spaces (we don't need to waste time
	// even moving the names into different columns) and then do the rest in 
	// Stata (not shown, but this is pretty easy to Google; just giving an idea
	// of how you might go about this). 
	
	// There is also a large enough literature on matching out there that this
	// would not be too intractable. e.g., ssc install matchit + a list of 
	// well-known impressionist artists would probably take care of this. 
	
	// Let's try a simpler task with the other data-set in the file, which 
	// refers to auctions of contemporary artists' work. 
	
	import delimited using https://tinyurl.com/contempauction /// 
	, delimiters(",") clear
	
	d
	
	list artist in 1/20
	
	// Let's left-justify and properly capitalize this
	gen artistname = proper(artist)
	list artistname in 1/20
	format artistname %-17s
	list artistname in 1/20
	
	// Let's check for duplicates now that we're at it since we're seeing a lot
	// of the same names. That's not necessarily a problem because the same
	// artists probably show up more than once. So, we'll look for duplicates
	// overall and on the id var. 
	duplicates report // This looks good -- we probably have no true duplicates.
	duplicates report id // but this does not. 
	// There's some weird stuff going on here; if this were my project, I'd look
	// into why every ID seems to be duplicated at least once. 
	
	// The stuff the book does next is pretty cool, but it was hard to quickly
	// find a data-set with this exact sort of problem. So, let's use the book
	// to examine some more-advanced string commands and functions.
	
	use ./original_data/book_data/dentlab2, clear
	
	* First we should make the names a bit more uniform. Note that we can just
	* stack these functions.*/ 
	
	gen name3 = ltrim(proper(name)) // Trims left dead-space and capitalizes.
	format name3 %-17s // we can left-justify as well 
	list name3 in 1/5
	
	/* Let's extract the second character from these names. First, we make
	the variable that contains the second character. The generic syntax, which
	our book fails to mention, is...
	substr(varname,beginning of substring,length of substring). This will extract
	the specified character from a string. */ 
	gen secondchar = substr(name3,2,1)
	list secondchar
	
	// Now we look for spaces by creating a dummy variable indicating whether
	// someone has a middle initial or not. The book uses the truth expression 
	// syntax here. I put that in the appendix. Here's a simpler version where
	// we mark someone as having an initial if the second character in their
	// name is a period or a space. 
	
	gen firstinitial = 1 if (secondchar == " " | secondchar == ".") ///
		& ~missing(secondchar)
	replace firstinitial = 0 if (secondchar ~= " " & secondchar ~= ".") ///
		& ~missing(secondchar)
	
	/* Note that, to write the opposite of (A u B), we write (~A ^ ~B). This is
	one of DeMorgan's Laws. I've shown this before, and it's intuitive -- if I 
	will be happy iff [1] I run OR walk my dog today, I will be unhappy only iff
	I don't run AND don't walk my dog -- but I wanted to spell it out. 
		
		[1] in logic, "iff" is an acronym for "if and ONLY if". */ 
	
	list name3 secondchar firstinitial, abb(20)
	
	// Now we get the count of names
	gen namecount = wordcount(name3)
		list namecount, abb(20)
	
	// And tell Stata that the person's first name is the first word in name3
	gen personalname = word(name3, 1)
	
	// .. and their middle-name is the second *if* they have three names. 
	gen middlename = word(name3,2) if namecount ==3
		list middlename
		* Why the condition? B/c if they have no middle name, this tags their
		* last name by mistake. E.g.,
		* replace middlename = word(name3,2)
		* list name3 middlename 
			// Clearly, there are some mistakes here. 

	* ... now we  tag the final name, whatever it is. 
	gen surname = word(name3,namecount) 
	list personalname middlename surname

	/* Let's also add periods after initials as is customary in US English, if
	not other varieties. */ 
	
	replace personalname = personalname + "." if length(personalname) == 1
		// Note the length function
	replace middlename = middlename + "." if length(middlename) == 1
	list personalname middlename surname
	
	* Finally, let's make the full name.
	gen fullname = personalname +  " " + surname ///
		if namecount ==2
	replace fullname = personalname + " " + middlename + " " + surname ///
		if namecount ==3
	list fullname
	/* By the way, the empty quotation marks tell Stata to insert spaces and the
	conditional commands tell Stata to avoid putting too many or too few spaces
	into names if they are of different lengths. */ 

// 5.5: recoding. 

	/* In this section, I want to show you some ways to quickly re-code 
	variables that we have previously learned to re-code in "slow" ways.  
	I also show you the useful "autocode" function. */ 
	
	use ./original_data/gss2018, clear
	
	/* Let's revisit our religion variable. I'm sorry if you took 360 with me
	and are sick of this variable. It is very useful for showing technique
	with dummy variables and qualitative variables. */ 
	
	tab relig
	
	* Let's make a var. that says whether someone is a christian of any sort.
	* Here we'll also drop missing for simplicity.
	drop if missing(relig)
	
	
	* Let's look at the codebook. 
	labelbook RELIG

	* Here's the old-fashioned way:
	
	gen christian = 0 if (relig > 2 & relig <10) | (relig>11) 
	replace christian = 1 if ~(relig > 2 & relig <10) & ~(relig>11) 
		* N.b. that there are many, many ways to do this; this was the fastest
		* to me. You can go the simpler way and write out each value, e.g. ...
		* gen christian = 1 if relig == 1
		* gen christian = 1 if relig == 2
		* gen christian = 0 if relig == 3
	tab relig christian
	label define xian 0 "other relig." 1 "Christian"
	label values christian xian
	
	* ... and here's the faster way: 
	recode relig (1/2 10/11=1 "Christian") (3/9 12/13 =0 "other relig") ///
		, gen(chretien)
	tab chretien christian
	
	// It is also often useful to turn quantitative variables into categorical
	// variables. Here, I show a variety of examples of ways that you can do this
	// in Stata, starting with the -recode- command. I just show the trickier
	// of two ways it can be used, using closed intervals of the quant. var. 
	// (Open intervals are just like the syntax with the qualitative variable 
	// above). 
	
	tab age
	// Let's put people into Social Security buckets
	recode age (67/max = 3 "full retirement") (62/67 = 2 "early retirement") ///
		(18/62 = 1 "ineligible"), gen(retiregrp)
	tabstat age, by(retiregrp) stat(min max)
		* N.b. that we do this rather than crosstab the variables because twoway
		* tables get very messy  with more than about 25 total cells, which this
		* would easily produce. 
		* I.e., do *not* do this in almost all cases: tab age retiregrp
		
		* BTW, why does this work? Because we made 67 part of "full retirement"
		* first. 
	
	// We can also do this more-simply with irecode. The book fails to give the
	// general syntax, though, which you might want:
		/* irecode(var, x1, ..., xn) returns 0 if var ≤ x1; 1 if x1 < var ≤ x2;
		2 if x2 < var ≤ x3; . . . ; n if var > xn */
	
	gen pensioner = irecode(age, 61, 66)
	tab pensioner 
	// This looks good, but how can we get it to match retiregrp's numbering?
	replace pensioner = pensioner + 1
	tab pensioner retiregrp, nolab 
		* I was too lazy to make a value-label, so I just suppressed the
		* value-label from retiregrp to make it obvious that this produces
		* the same thing. 
		
	
// 5.6: coding missing values

	/* Now we'll turn to a fuller discussion of missing values, which are 
	important to get right, as we know. Stata, for instance, will omit missing
	values from some commands but not others...and many older data-sets use
	numeric values for missing values. Let's now look at that problem more
	closely than we have, although I showed an example of this last week. */ 
		
	/* Let's use the Midlife in the United States (MIDUS Refresher) Biomarker 
	Project (2012-2016) to look at some cases of numeric values being given for 
	missing values. 
		
		Fun fact: one of the PIs on this massive project is Carol Ryff over in
		the Psychology Dept. */ 
		
	/* I didn't put these up on Github because there are so many variables with
	so many unusual names that I wanted value labels, which can be hard to 
	preserve in CSV format. So, let's get them from the course Drive. */ 
	
	view browse ///
	https://drive.google.com/drive/folders/1Cgyp_3B6nDzD1PurzFf9WTriT63hI7aZ
	
	use ./original_data/MIDUS_biomarker_2012-16, clear
	
	/* Let's look at variable RA4Q10A1, which reads in the codebook: 
	
	"The following questions are about positive experiences you may have had 
	"over the past month. Please indicate how often you had each experience and 
	"whether it was pleasant, enjoyable or rewarding.
	"Over the past month how often did you spend time - APPRECIATING NATURE."

	So, here we have three kinds of missing values. We should make each one
	a distinct value. Note, however, that not every kind of MV is present here. 
	We should still do this for the sake of procedure, though. */ 
	
	d RA4Q10A1
	label list RA4Q10A1  
	tab RA4Q10A1, mis
	tab RA4Q10A1, mis nolab
	// N.b. that although the value label correctly specifies numeric value 8 as
	// missing, it will be treated as numeric if we don't fix this. Here, we see
	// that Stata knows it is "really" 8 at present. 
	sum RA4Q10A1, d
	sum RA4Q10A1 if RA4Q10A1<8, d // These are definitely not the same. 
	
	// So, the first thing we might do differently here to what we have done is
	// to use the shortcut mvdecode. 
	mvdecode RA4Q10A1, mv(7 = .d \ 8 = . \ 9 = .i)
	// I use "d" for don't know, "." for generically missing, which is how Stata
	// understands the full-stop, and ".i" for inapplicable
	tab RA4Q10A1, mis nolab
	// Good -- now "." is really understood as missing. We still have to be 
	// careful!! For many purposes, "." is understood as an arbitrarily-large
	// scalar, but in many commands, e.g. sum, Stata will omit it. E.g.:
	
	sum RA4Q10A1, d // all good
	// But, be careful...
	gen natureisawesome = 1 if RA4Q10A1 > 10000
	tab natureisawesome
		// This is bad news ^. We have *no* observations that actually exceed
		// 10,000, but Stata sometimes understands "." as "very large number".
	gen natureiscool = 1 if RA4Q10A1 > 10000 & !missing(RA4Q10A1)
	tab natureiscool // much better. 
	
	* BTW, let's suppose we notice that all questions beginning RA4Q10 have the
	* same missing value pattern. Let's pick a couple of random examples to see
	* what they look like first. 
	labelbook RA4Q10O1
	tab RA4Q10O1, mis // These have the right value label ... 
	tab RA4Q10O1, mis nolab // ... but a numeric value that we dislike usually
	labelbook RA4Q10O2
	tab RA4Q10O2, mis
	tab RA4Q10O2, mis nolab // same story here
	
	* Then, following the book, we may write:
	mvdecode RA4Q10*, mv(7 = .d \ 8 = . \ 9 = .i)
	
	* Let's check our work 
	tab RA4Q10O1, mis nolab // all good 
	tab RA4Q10O2, mis nolab 
	// good here as well and we now see the variety of mv codes at work. 
	
// 5.7: dummy variables again

	/* OK, we've already seen dummy variables...but we might want to use certain
	shortcuts in working with them that we have not yet seen. Let's go now to 
	investigate those shortcuts, one of which is known as factor variable 
	notation. Factor variables are just categorical variables; the trick really
	is in the Stata notation, which lets us quickly treat categorical variables
	which are polytomous (here meaning three of more possibly categories) as
	sets of dummy variables for each possible value of the outcome. 
	
	Let's suppose that we wish to model stress as a function of one's score on 
	the good work index and one's gender. These data actually have few qual. 
	variables, unfortunately, which is a rare problem in sociology. But, since 
	these offer a nice example of how to clean data, let's keep using them. */ 
	
	lookfor gender 
	// hm, no luck. let's remember that older data-sets might only have sex info
	lookfor sex // OK, we're stuck with RA1PRSEX  
	lookfor stress // we'll use RA4QPS_PS  
	lookfor work // we'll use RA4QSO_GW 
	
	sum RA4QPS_PS, d
		* Looks like 98 might be a missing value. Let's check
	labelbook RA4QPS_PS
		* and so it is. 
	replace RA4QPS_PS = .n if RA4QPS_PS == 98
	
	sum RA4QSO_GW, d
	labelbook RA4QSO_GW 
		* OK, 8 is a missing value
	replace RA4QSO_GW = .m if RA4QSO_GW  == 8
	
	sum RA1PRSEX, d
	tab RA1PRSEX, mis nolab
	// OK, good. Even in dirty datasets, the bio-sex is typically clean.
	
	// So, now we can introduce the factor variable notation
	reg RA4QPS_PS i.RA1PRSEX RA4QSO_GW 
	
	/* What this does is include a dummy variable representing sex in this
	multiple regression. Now, admittedly, we did not need to do this since 
	RA1PRSEX is already a dummy...but a) this will become handy later and b) 
	this lets us quickly change the omitted category. */ 
 
	// Above, the default was to make male the omitted category, so the 
	// coefficient here  gives the effect of being a woman on stress. 
	// But we can also quickly make female the omitted category. 
	
	reg RA4QPS_PS b2.RA1PRSEX RA4QSO_GW 
	
	// Let's return to our new data-set for the GSS to show some more tricks.
	
	use ./modified_data/gssbetterrace, clear
	
	tab racenew
	label list rn
	
	// Note that we can quickly get summary statistics using tab/sum and our
	// factor variable. 
	tab racenew, sum(sei10)
	
	// Also, suppose we just had this variable to begin with and wanted to 
	// "back out" our race dummies from before. That's not shown in our book, but
	// it is as simple as...
	
	tab racenew, gen(racedummy)
	sum racedummy* 
	/* This way of creating dummies just names them all the same way with a
	number after the basename. So, adding the wildcard operator shows all of
	the variables with this beginning. */ 
	tab racedummy1 white
	tab racedummy2 Black
	tab racedummy3 Hispanic
	tab racedummy4 otherrace
	// These all check out. 
	
	/* Ok, back to the main point. Factor variable notation is handier than a 
	set of dummy variables when we have lots of categories and may not need to
	use the dummies on their own. 
	
	BTW, if you have not yet studied multiple regression and feel lost by my talk
	of "omitted categories" or why we would need such a thing, don't worry and
	either come talk to me to learn more or don't try it in your project. 
	
	First, note that factor variable notation is necessary here or else we will
	accidentally calculate something nonsensical. */ 
	
	reg educ racenew paeduc
	* This seems to make sense, and it's even statistically significant....
	* but is it?? No! Race is not even ordinal. This is nonsensical. 
	
	reg educ i.racenew paeduc
	* This, by contrast, makes much more sense -- we look at the impact of race
	* and father's education on r's education. This is equivalent to including
	* a bunch of dummies as controls. Stata's default here is to make the 
	* omitted category the lowest value of the factor variable, so omit white. 
	
	reg educ Black Hispanic otherrace paeduc
	
	// We can quickly sub out the omitted categories with factor variable notation. 
	
	// Here, I quickly other race the omitted category, just
	// for the sake of showing something different. 
	
	reg educ ib3.racenew paeduc
	
	// In the appendix, I show how and why you would use the interaction 
	// notation given in our book. This won't make much sense without 361
	// or equivalent under your belt; don't sweat it if so. If you have taken
	// 361, you will probably find this a useful review. 
	
// 5.10. computations across variables. 
	
	/* In this section, I want to show you how how we can use the "extensions to
	generate" command (-egen- for short) to compute across variables or "across
	columns", as you will sometimes see it written (because in most matrices of
	data -spreadsheets if you like- a single row represents a single obs. and a
	single column represents all observatoins on a variable. 
	
	These are sort of diffuse techniques, but they are all generally pretty 
	useful. */ 
	
	use ./original_data/MIDUS_biomarker_2012-16, clear
	* Let's go back to our biomarker data-set, which is a good example of an
	* interesting, but somewhat messay data-set. 
	* This data-set has an average of various BP readings, but let's suppose 
	* that it didn't and try to create such a mean. 
	
	lookfor "blood pressure" 
	* Note that all the systolic blood pressure variables have a pattern but it
	* is complex. Fortunately, we just use a wildcard character (?) to sum across
	* these three variables which differ by their penultimate alphanumeric
	* character. I show that this is equivalent to the hand method. 
	
		* Note that not all commands use the same wildcard system; some only
		* take an asterisk, but others will interpret an asterisk as specifically
		* meaning "this character and all following are wildcards", in which case
		* a question mark becomes the single character operator. This is a bit
		* of an annoying feature in Stata. 
		
			* For more on this, see Stata Data Management Reference Manual, 
			* Release 15, -rename group-. 
	
	// egen method
	egen SBPmeanr = rowmean(RA4P1F?S)
	
	// hand method 
	gen SBPmean1r = (RA4P1F1S + RA4P1F2S + RA4P1F3S)/3
	
	// Now we compare
	list SBPmeanr SBPmean1r  in 1/5
	
	// We can systematically check that there are no discrepancies
	count if SBPmeanr ~= SBPmean1r
	
	* Let's also see that we could find the smallest and largest observations
	* in this set of variables. 
	egen DBPmin = rowmin(RA4P1F?D)
	egen DBPmax = rowmax(RA4P1F?D)
	list DBPmin DBPmax in 1/5
	
// 5.12: some more useful egen commands
	
	/* Here I want to show something that is arguably more useful, being able to
	quickly conduct operations across variables, especially similarly named ones
	which is a common real-world occurrence. 
	
	Let's find out how often someone uses sleeping pills using a set of
	variables that record whether they used one a given day. */ 
	
	d RA4AD?7
	/* Notably, this is a case where the asterisk wildcard operator doesn't
	work as easily here because in this case, Stata ignores anything after 
	it. I show that below. This is also true of some functions we'll examine
	below. Let's show this with an non-transformative command just to make it
	clear.*/
	d RA4AD*7
		* So, this capture anything beginning RA4AD...and ending with a 7.
		* but we just want variables that have a single character there. 
		
	// Now we count the number of times 1 appears across this set of vars. 
	egen numpills = anycount(RA4AD?7), values(1)	 
	tab numpills
	
	/* We can also see if anyone *ever* uses sleeping pills */ 
	egen everusepills = anymatch(RA4AD?7), values(1)
		* This determines where any variable in the set equals 1. 
	label define EUP 0 "never used pills" 1 "used pills"
	label values everusepills EUP
	tab numpills everusepills

// 5.13: string variables --> numeric variables 
	/* Let's now look at how we can generally encode string variables. We saw 
	this above for dates in the optional date/time material, but it is worth 
	some more explicit discussion. */ 
	
	use ./modified_data/classsurveycleaned, clear
	d dominanthand
	// Stata has rendered this as a string, but, somewhat confusingly
	// -destring- works best for encoding numeric characters rendered as strings. 
	// Instead, we want -encode-. 
		/* How do you even get numeric characters rendered as strings? It 
		tends to happen when converting between complicated matrices in non-
		Stata programs and Stata. If you don't ever need -destring-, so much
		the better. */ 
	encode dominanthand, gen(domhand)
	* Now let's see what this looks like
	d domhand
		* domhand is a long variable now.
		
	* We can also obviously value-label it. Let's make it a true dummy
	* while we're at it. 
	labelbook domhand
	gen handpref = domhand - 1
	tab handpref
	label define HANDPREF 0 "left-handed" 1 "right-handed"
	label values handpref HANDPREF
	tab handpref domhand
	
	// Let's briefly examine the complications given in the book. 
	
	use ./original_data/book_data/cardio1str, clear
	destring pl3, replace // uh oh, we have non-numeric characters here. 
	destring pl3, gen(pl3num) force // we force Stata to destring this var.
	list pl3 pl3num if missing(pl3num) // and see what the MV is. 
		* OK, so, pl3's missing values in the original are Xs. So, we can say..
	destring pl3, replace ignore(X)
	list pl3
		// We can add additional characters to -ignore(...)- as appropriate
	
	// Let's also see how we can get numeric variables to render as strings. 
	// So, one problem with tostring is that it does not preserve value labels
	// by default. 
	use ./original_data/GSS2018, clear
	tostring class, gen(classstring0)
	list classstring in 1/5
	
	// ... and this is also not the default of the generate command. 
	gen classstring1 = string(class)
	list classstring1 in 1/5
	
	// For that, we want "decode". 
	
	decode class, gen(classstring2)
	list class classstring0 classstring1 classstring2 in 1/5, abb(15)

	
// 5.14: renaming variables

	* Finally, we might want to mass rename variables, and this brings us to our
	* first taste of programming in Stata. I'll explain this later at length.
	
	* The basic idea is that "foreach" tells Stata some index (here i), some 
	* command (here just gen), and some domain over which to execute it (here, 
	* for k = {1, 2, 3}). 

	use ./original_data/MIDUS_biomarker_2012-16, clear
	foreach k of numlist 1/3 {
		gen systolicBP`k' = RA4P1F`k'S 
		}
	list RA4P1F1S systolicBP1 in 1/5, abb(20)
	list if RA4P1F1S ~=systolicBP1
	
	// The book recommends using renpfix and rename here, so let's see those. 
	// The downside is that, as the name of the command suggests, it is geared
	// towards getting rid old variable names, but you might prefer to keep them
	// for various reasons. 
	
	rename RA4P1F?S sysBP?
	list sysBP1 systolicBP1 in 1/5
		* Note that if you now try to tab RA4P1F1S, it will not be found
	
	// foreach is also an easy way around remembering how the wildcard operators
	// work because it is a very precise command. 
	
	// Let's make a set of sleeping pills varaibles that are easier on the eye.
	foreach t of numlist 1/7 {
		gen sleepingpills`t' = RA4AD`t'7
		label values sleepingpills`t' RA4AD17 // all value labels are same here
		}
	list sleepingpills5 RA4AD57 in 1/5, abb(20)
	
	// We can now order our new variables somewhat more rationally, here
	// after the last original sleeping pills question
	
	order sleepingpills*, after(RA4AD77) alphabetic
	/* and now that they're in order, we can use this nice shortcut. Any time 
	that you can order the variables like this, using a hyphen between two vars
	will include all columns between those two variables. */ 
	d RA4AD77-sleepingpills7

