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
	
	So, once upon a time, I was a starry-eyed PhD student in 361 carrying out an
	investigation of the role of class in explaining income variation. I was
	using the GSS, and I was a bit baffled to realize how bad the race variable
	is on the GSS. "White, Black, and 'other'?", I said. "This is awfully 
	chauvinist and also poses a research problem for me". Don't Latino people 
	count? And while it might be hard to list out every possible group ID on
	this variable -- and that would confuse race/nation
	with ethnicity [0] -- surely we could include "West Asian", "East Asian" in
	the mix since those peoples are often held to experience distinct forms of
	group oppression in the US. 
	
		[0] People disagree on what exactly makes these different, but one
		approach is to use ethnicity to refer to someone's actually, semi-
		voluntary participation in a "people", while race is the 
		socially-objectiive assignment of people into pseudo-ethnic groups 
		whether people like that or not. 
	
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
		
// 5.3: functions

	/* This material is extremely fun, but this lecture/chapter is already too 
	long so I have relegated this to an appendix. Throughout, I show functions
	-- which are not commands in Stata, BTW (commands you issue to Stata, 
	functions are just maps from some set to some other set that can be put 
	into commands) -- only as they are necessary or convenient. */ 

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
		(18/67 = 1 "ineligible"), gen(retiregrp)
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
		
	// Finally, we come to autocode. Why would you use autocode? Well, the book's
	// example kind of lacks motivation, but what if you, say, just quickly wanted
	// five year age-bands? You could do this tediously with Boolean expressions
	// but let's do something faster. 
	
	/* What exactly does autocode do? It "partitions the interval from x0 to x1 
	into n equal-length intervals and returns the upper bound of the interval 
	that contains x or the upper bound of the first or last interval if x < x0 
	or x > x1, respectively" (Stata help file for autocode). */ 

	
	// First, we need to figure out how many bands there are. 
	sum age
	scalar agerange = r(max) - r(min) + 1
		* why plus 1? The number of numbers between n and n +k is
		* (n+k) - (n + 1), or in other words, the difference -k- with one added.
	gen agebands = autocode(age, agerange/5, r(min), r(max))
		* Notice how scalars and stored values do a ton of work for us! (The
		* r(min) and r(max) are post-estimation stored values that Stata had
		* handy, so to speak, after running "sum age"). 
	tab agebands
	tabstat age, by(agebands) stat(min max)
	
	// OK, this looks good -- although the names are annoying. Plus, I don't 
	// want to type out all of those decimals. Wait, now I remember...
	gen agebandsint = int(agebands)
	tab agebandsint // nice. 
	label define brkts 22 "18-22" 27 "23-27" 32 "28-32" 37 "33-37" ///
		42 "38-42" 47 "43-47" 52 "48-52" 57 "53-57" 62 "58-62" ///
		67 "63-67" 72 "68-72" 77 "73-77" 82 "78-82" 89 "83-89"
		* N.b. that the last interval has the upperbound as the max. 
	label values agebandsint brkts
	tabstat age, by(agebandsint) stat(min max)
	
	// Finally, we can also create brackets of equal ns, which is basically
	// taking a quantile. 
	
	// Actually, the quantile function proper is a little strange. Stata
	// (apparently) assigns the percentile values to a variable which it then 
	// gives to the first n-1 observations, where n is the number of quantiles. 
	
	pctile heightpctilevalue = height, nq(100)
	list id heightpctilevalue in 1/115
	
	/* So, one advantage of the book's method is that it computes quantiles and
	then assigns all people a quantile value. */ 
	
	egen heightpct = cut(height), group(100)
	tab heightpct
	/* As you can see here, there aren't 100 unique values of heighpct because
	many people share the same percentile. That's still not the most ideal way
	of computing percentiles--it would be best to just define 100 percentiles,
	possibly repeating numbers, rather than basically saying "if the 45th and 
	50th percentile would be the same value, just call people in the 50th
	percentile the 45th--but this is a bit easier to work with because the values
	are given to individuals. We can improve this a bit by also asking Stata to
	value-label the percentiles */ 
	
	egen heightpercentile = cut(height), group(100) label
	tab heightpercentile
	
	/* This is of somewhat limited utility unless we can actually see the true
	percentiles, but we can do a few things with this, e.g. easily simulate the
	CDF for height. */ 
	
	scatter heightpercentile height, jitter(5)
		* Height is more-or-less Normally-distributed. 
	
	* We can also simulate the PDF. 
	
	dydx heightpercentile height, gen(heightpdf)
	scatter heightpdf height, jitter(10)
	
	
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
	
// 5.8: date variables. 

	// This section will probably be skipped over quickly in lecture. It is 
	// practical in the real world, but it is only relevant to those of you
	// working with time-series data. 
	
	// Still, I'll briefly comment on what's going on. First, we load some data
	// which I've collected about excess death and frequency of social-physical 
	// contact during the pandemic period. I was interested to see whether it was
	// true that the incidence of excess mortality could be reduced by physical
	// isolation, which was the dominant theory at the time, but which my own
	// understanding of epidemiology led me to question. 
	
	import delimited using ///
	https://raw.githubusercontent.com/gjmbur/365example/main/COVIDcsv.csv, ///
		delimiters(",") clear
	
	// First, let's look at the date variable. I just entered this using an Excel
	// shortcut, so it's not well-formatted for Stata. 
	d realdate
		* OK, it's a string. Let's examine some examples.
	list realdate in 1/5
	
	// Let's make this numeric for convenience. 
	gen elapsedate = date(realdate, "MDY")
	list elapsedate in 1/5 
		* As weird as this looks, Stata actualy like this because these are just
		* numbers. We'll tell Stata how to display them better soon. 
	order elapsedate, after(realdate)
		* Might as well bring this to the front so it's easier to find. 
	label variable elapsedate "date in Stata format"
		* Let's also remember why we made this new variable. 
	* Now we want to get this looking nicer. 
	format elapsedate %td
		list elapsedate in 1/5
		* Personally, I like this format, but YMMV. 
	* Let's also just call this variable "date" while we're at it for convenience.
	rename elapsedate date
	* We can also get this looking like we had it before, only now formatted 
	* correctly for Stata. 
	format date %tdnn/dd/YY
		list date in 1/5
	* Or we can get it in this explicit, rather lengthy format. 
	format date %tdDayname_Month_dd,_ccYY
		list date in 1/5
	
	// Before going further, let's see some interesting stuff in this dataset
	
	* First, we need to declare that we have time-series data, measured daily
	* and we'll want a shorter format for the date so that the figures aren't too
	* messy. 
	tsset date, daily
	format date %td
	
	// UK excess death and mobility data (Google)
	tsline ukexcess ukretailrecg ukgrocerypharmag uktransitg ukworkg, ///
	ylabel(0(25)200) ytitle("UK excess mortality") xtitle("date") /// 
	xlabel(21926(30)22280, alternate) legend( label(1 "UK excess") /// 
	label(2 "UK retail and rec") label(3 "UK grocery") ///
	label(4 "UK transit") label(5 "UK workplace")) 
	
	// US excess death and mobility data (Google)
	
	tsline usexcess usrr usgp ustr uswork, ylabel(0(25)200) ///
	ytitle("US excess mortality") xtitle("date") xlabel(21926(30)22280, ///
	alternate) legend( label(1 "US excess") /// 
	label(2 "US retail and rec") label(3 "US grocery") ///
	label(4 "US transit") label(5 "US workplace"))
	
	// Comparing US, UK, NZ, and OZ mobility data
	
	tsline uktransit ustransit nztransit oztransit, ///
	ylabel(0(25)200) ytitle("change in mobility (baseline=100)") ///
	xtitle("date") xlabel(21926(30)22280, alternate) ///
	legend( label(1 "UK transit") label(2 "US transit") label(3 "NZ transit") ///
	label(4 "OZ transit"))
	
	// Wow! Very similar policies (you can explore this with many more variables)
	// but very different outcomes. 
	
	// OK, down to business. 

		
	/* "No matter how you change the display format of a date, this does not 
	"change the way the dates are stored internally". Here's an example of using
	dates in arithmetic calculations. */ 
	
	sum date, d
	scalar timerange = (r(max) - r(min))/365.25
	di timerange
	* so this data-set covers just about a year -- makes sense. 
	
	// How out-of-date are these data?
	sum date, d
	di (td(28Feb2022) - r(max))/365.25 
		* About 1 and 1/6 years. Yikes!
	
	// Let's say that it becomes convenient for some reason to have the days,
	// month, and year separated. This is actually useful for a huge range of
	// applications. 
	
	generate day = day(date)
	generate month = month(date)
	generate year = year(date)
	order day month year, after(date)
	list date year month day in 1/5
	
	// What if I just want the last two digits of the year variable? 
	gen year2 = mod(year, 100)
		* See appendix for "mod[ulus]". I'm doing this to get the last two digits 
		* of the year so that these data resemble the book's example. 
	list year2 in 1/5
		
	save ./modified_data/COVIDimproved, replace
	clear all 
	use ./modified_data/COVIDimproved
	
	/* Let's look at the problems the book shows with dates that just have two
	digits representing the year. First, we look at the date broken up into
	three separate variables. */ 
	
	gen date2 = mdy(month, day, year2)
	list date2 in 1/5
	// Uh-oh! Something's gone awry here. Stata interpreted year2 as literally
	// the year 20, which is too early for Stata to even understand. 
	// Let's try a version of the book's fix by adding 2000.
	replace date2 = mdy(month, day, year2+2000)
	list date2 in 1/5
	format date2 %td
		list date2 in 1/5
	
	/* Now we'll look at the date represented as one string. */ 
	d shortdate
	
	/* Here, the book raises the problem of days spread across centuries. We don't
	have that problem here, but it doesn't hurt to pretend as though we did. 
	
	The full syntax here is date(string, [some permutation of MDY], cutoff), 
	and it will return the largest year that does not exceed the cutoff). So, 
	since our data are too simple to really need this, let's show how we might
	misuse this syntax. */ 
	
	gen date3 = date(shortdate, "MDY", 1963)
	format date3 %td
	list date3 in 1/5
		/* Jinkies! Since the cutoff year was before 2020 (I arbitrarily picked
		the year my mother was born), Stata thought we meant "20" as in
		"the 1920s". 
		
		You can see how this would be useful, in general, though. Suppose I 
		had excess death data stretching back to 1992. Then, I would have years
		from "92" to "20". By setting my cutoff as 2020, I would force 92-99 to
		be rendered as 1992 - 1999 because all of {2092 ... 2099} > 2020.  
		Let's fix that really quickly.*/
	replace date3 = date3+(365.25*100)
		* As the book notes, this is slightly imprecise but OK. 
	
	/* If you have data with a two-digit year where the year is a separate
	variable, and the data are spread across centuries, you can handle that
	with conditional commands. First, let's arbitrarily make some of these data
	from 1992. */ 
	
		gen obs = _n
		sum obs 
		gen year3 = year2+72 if obs >200
		replace year3 = year2 if obs<201
		list year3 in 201/205
	
	// Now, we replicate the book's analysis. 
	
	gen date4 = mdy(month, day, year3+1900) if year3 >20
	replace date4 = mdy(month, day, year3+2000) if year3 <21
	format date4 %td
	list date4 if obs <6 | (obs <206 & obs>200)
	
	// Finally, we look at all of our dates
	
	list date date2 date3 date4 in 1/5

// 5.9: date and time

	/* This section is very practical; there are times when I was doing data 
	entry for the Service Employees' International Union (SEIU) where some of
	these tools would have been extremely useful in quickly extracting info
	that was entered haphazardly by field organizers. It almost certainly has 
	some commercial applications as well -- for example, it allows you to get
	time information in virtually any format without requiring the survey to be
	formatted in exactly this or that way. */ 

	* First, let's all fill out this simple survey
	
	view browse https://forms.gle/9DiHcBXEtabVo5N88
	
	* then let's use the results
	
	view browse https://tinyurl.com/SOC365classSVYresults
	
	clear
	
	/* Here, we'll need to put in the results. I'm putting this whole section in
	comment mode so that it doesn't generate an error. I suggest 1) copy/pasting
	the data from Sheets using Data Editor (this works very well with sheets;
	no need to bother with a more complicated strategy usually); 2) saving the
	data *exactly* as follows so that you can just remove the next secton from
	comment mode: save using ./original_data/28febclassSVY, replace*/ 
	
	/* This is the opening "parenthesis" of the comment. Delete this line when
	you have data downloaded and loaded into Stata. 
	
	* First, let's get the variables looking a bit cleaner. 
	rename areyoulefthandedrighthandedoramb dominanthand
	rename doyouconsideryourselfaworrierrel worrier
	
	* Now, let's look at the time-stamp variable produced by Google Forms. 
	d timestamp
		
	// Note that timestamp is just a string, currently. But we can make
	// it numeric if we want. 
		
	// First, let's extract the different parts of the stamp using a tool from 
	// before. Let's separate them into date and time. 
	
	list timestamp 
	gen calendardate = word(timestamp, 1)
		* This generates a new variable which pulls the first word of timestamp.
	list calendardate, abb(20)
	gen time = word(timestamp, 2)
		* See above. 
	list time
	
	// These are still just strings, but now they are separated. Let's move on.
	// First, we'll turn the day into a numeric variable.  
	gen day = date(calendardate, "MDY")
	d day 
	// Let's store this in the "programmer's friend" format. This allows
	// easy sorting in chronological order if you only have a simple sorting
	// algorithm available (e.g., that of Google Sheets). 
	format day %tdCCYY.NN.DD
	list day
	
	// Now, we'll do the same for the time. 
	gen double exacttime = clock(time, "hms")
		* See appendix on double precision. 
	// We'll get the format looking nice. 
	format exacttime %tchh:MMam
	list exacttime, abb(10)
	
	* Let's do a bit of house-keeping, dropping unnecessary variables. 
	keep exacttime day dominanthand worrier
	rename exacttime time
	order day time dominanthand worrier
	save ./modified_data/classsurveycleaned, replace
	
	* And we might try a basic statistical analysis. 
	tab dominanthand worrier, row chi2 
	
	This is the closing parenthesis of the comment. Delete this line when you 
	have the data downloaded. */ 
	
	/* Mitchell really indulges himself in the rest of this section. I would 
	say you should return to the other material as needed. Much of this just
	shows extensions of this basic material. */ 
	
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
	
	* We could identify potential problem cases if the subject has, e.g., 
	* no values that are extreme but a high SD. 
	
	egen DBPsd = rowsd(RA4P1F*D)
	egen SBPsd = rowsd(RA4P1F*S)
	graph box DBPsd SBPsd
		sum DBPsd, d
		scalar Q3d = r(p75) // This assigns the 75th percentile to the label Q3. 
		scalar Q1d = r(p25) // same for the 25th percentile
		scalar IQRd = Q3d-Q1d // this assigns their diff. to "IQR"
		scalar UBd = Q3d+(1.5*IQRd)
		scalar LBd = Q1d-(1.5*IQRd) // assigns the Tukey rule to "upperbound"
		sum SBPsd, d
		scalar Q3s = r(p75)
		scalar Q1s = r(p25) 
		scalar IQRs = Q3s-Q1s 
		scalar UBs = Q3s+(1.5*IQRs)
		scalar LBs = Q1s-(1.5*IQRs) 
		gen doubleoutlier = MRID if (DBPsd > UBd | DBPsd < LBd) & ///
			(SBPsd>UBs | SBPsd < LBs)
		list MRID if ~missing(doubleoutlier)
	
// 5.11: computations across observations.  

	/* We can also carry out computations across observations. This is a bit of
	a niche technique since it basically produces summary statistics.
	
	For example, we can give everyone the mean of some variable X as the value of
	some new variable Q.*/ 
	egen SBPmean = mean(SBPmeanr)
	list SBPmean in 1/5 
	// Note that everyone has the same value and that it is just the group mean.
	sum SBPmeanr
	
	// Let's get BP across sex. 
	lookfor sex
	rename RA1PRSEX sex
	bysort sex: egen SBPmean_sex = mean(SBPmeanr)
	sort MRID // if we don't re-sort, these will remain sorted by sex. 
	list sex SBPmeanr SBPmean SBPmean_sex in 1/20, abb(20) sepby(sex)	

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
	
	// If we were, say, matching on the ID variable, we'd write
	tostring id, gen(ID_uniform) format (%0004.0f)
	list ID_uniform in 1/5
	list ID_uniform in 100/105
	list ID_uniform in 2000/2005
	
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

// Appendices. These are entirely optional. 

	* A. Material from 5.1: logical expressions 
	
	// N.b. that *this* new syntax creates a dummy variable! 
	// It evaluates a logic expression -- whether educ exceeds 15 -- and then
	// spits out an answer in binary, creating a dummy. 
	use ./original_data/gss2018, clear
	gen probcollgrad = educ > 15
	tab probcollgrad
		
	// We can do the same thing more patiently on our own. You can use either
	// but be careful as the syntax we just met is a bit tricky.
	gen maybecollgrad = 1 if educ >15 & ~missing(educ)
	replace maybecollgrad = 0 if educ <16 & ~missing(educ)
	tab probcollgrad maybecollgrad
		
	// Note that the logical expression syntax is **NOT** the same as this.  
	gen yearspostgrad = educ if educ > 15
	tab yearspostgrad, mis
	// This just gives people the value of educ if educ is greater 
	// than 16 and missing otherwise 
	// -- which is what you might expect the first syntax to do. 
	
	* B. Material from 5.3: functions in Stata. 
	
	* Here's what the Standard Normal curve looks like. Neat!
	
	twoway function y=normalden(x), range(-1.96 1.96) color(dknavy) || ///
	function y=normalden(x), range(-4 -1.96) recast(area) color(dknavy) || ///
	function y=normalden(x), range(1.96 4) recast(area) color(dknavy) ///
	xtitle("{it: x}") ///
	ytitle("Density") title("Critial Values for Standard Normal") ///
	subtitle("Two-tailed test and {&alpha}=.05") ///
	legend(off) xlabel(-1.96 0 1.96)
		
	/* Here's how we can represent the results of a statistical test and the
	central limit theorem. */ 
	
	use ./original_data/cps2019, clear
	labelbook state
	labelbook marstat 
	
	// Suppose we want to test the claim that the gender wage gap in WI is $2/hr
	// among married people. First we generate the outcome var. 
	gen marriedwageWI = wage1 if marstat ==1 & state ==35
	// Then run the test. Stata doesn't let you easily run tests where H0=/=0
	// so we need to make a variable representing the wage gap. We give men
	// two bucks more an hour on this variable, then see if there is evidence
	// against the null that there is no difference on this var. for men/women.
	// If the gap really is $2, we should fail to rejec the null. 
	gen MWWIdiff = wage1 if marstat == 1 & state == 35 & female == 0
	replace MWWIdiff = (wage1+2) if marstat == 1 & state == 35 & female == 1
	// Now we run the test
	ttest MWWIdiff, by(female) unequal
	// Store the SE
	scalar SE=r(se)
	// And find our critical value for this df which we need to manually input.
	scalar tstar= invttail(694.738, 0.01)
	// We find our margin of error and it to our null to find our critical value
	// on the scale of the actual variable. This is a one-tailed test, so we
	// just need to add it to one side. 
	di (tstar*SE)+2
	scalar criticalvalue = 3.8325557 // and store it for convenience

	twoway function y=tden(694.738, (x-2)/0.785992), range(-2 6) ///
	color(dknavy) || function y=tden(694.738, (x-2)/0.785992), ///
	range(2.9884 3.8326) recast(area) color(dknavy) || ///
	function y=tden(694.738, (x-2)/0.785992), range(3.8326 6) recast(area) /// 
	color(red) xtitle("{it: {&mu}}{sub:1} -{it: {&mu}}{sub:2}") ///
	ytitle("Density") title("") yscale(range(0 0.4)) ///
	subtitle("One-tailed test and{it: {&alpha}}=0.01") ///
	legend(off) xlabel(-1 0 1 2 2.99 3.83) saving(difftwo1, replace)
	* the 2.9884 is the actual diff. between the two modified variables plus 2.
	
	// The book mentions some other useful functions. 
		* Type << help mathematical functions >> and hit << enter >> for more. 
	
	* C. Material from 5.7: interaction terms. 
	
	/* HERE BEGINS MY DISCUSSION OF FACTOR VARIABLE NOTATION. YOU MIGHT FIND THIS
	USEFUL IF YOU HAVE TAKEN 361 AND FELT CONFUSED BY PARTS, OR IF YOU ARE EAGER
	TO LEARN MULTIPLE REGRESSION. IF NOT, YOU *NEED NOT WORRY ABOUT THIS* !! 
	Why include it, then? I wrote this while tutoring someone in 361, it is 
	relevant and shows you some cool stuff in Stata, and otherwise it's just
	laying around my computer. */
	
	/* Also I am making this a very long comment because it will take about 10
	minutes to run or so -- the CPS is a big data-set. You can remove this and 
	the closing "parenthesis" if you want to see it. 
	
	// Factor variable notation also makes interactions very simple. 
	// Let's look at an example from the CPS. 
	
	use ./original_data/cps2019, clear
	// Let's make a dummy indicating parenthood
	gen haskids = 1 if ownchild >0 & !missing(ownchild) 
	replace haskids = 0 if ownchild == 0
	// Now let's run a simple, uninteracted regression
	reg wage1 i.female educ i.haskids uhoursi
	
	reg wage1 female##educ##haskids uhoursi 
		
	margins, over(educ female haskids)

	/* What this does, since these are all coded as indicator variables, is to 
	calculate a bunch of conditional means for all possible combinations of the 
	three variables, adjusting for hours worked (technically, wages are already 
	rates so this in theory shouldn't matter, but hours worked is still a good 
	predictor of pay/hour, so I include it as a control). */
	
	marginsplot 

	/* We can see the results on this figure. There is evidence of some 
	significant non-linearities in the effect of education. Childless men 
	generally benefit (statistically-)significantly less from additional 
	education than do men with kids after high school, and at each level of 
	education they do the same or much better than childless men. Conversely, 
	childless women generally do better than women with kids, or at least the 
	same, at each level until post-graduate education. 

	Each individual conditional mean here is calculated by plugging in the 
	values for each of three dummies (several levels of education, whether one 
	has kids, and gender). 

	For example, a man with children and no HS diploma is predicted to have a
	wage just a bit less on balance to that of a woman who has some college 
	and some kids, which is what we see in the margins output 
	(LTHS #0 #1 ≈ some college #1 #1, though the education does leave
	women a bit better off. */ 

	/* Now we can look at a dummy-quant interaction */ 
	reg wage2 c.educ92##wbho /* This treats education as quantitative, 
	although it is also coded in the CPS so that it could be used as a 
	"dense ordinal" variable */ 
	
	margins wbho, at(educ=(1(1)16)) /* we calculate the conditional means of
	being each race at each level of education. You can test this on your own. 
	For example, suppose that I want to find the effect of being Black at 14
	on the education variable. I do this by hand first: 

	Y = 0.3816 + 2.7677educ + -7.1841Black + 4.01Hispanic - 9.86Other 
	+ 0.2480BlackEduc -0.59Hispanic + 0.89Other  */ 

	* E(Y | educ = 14, Black = 1) = 0.3816 + 2.7677*14 + -7.1841*1 + 0.2480*14*1 

	di 0.3816 + 2.7677*14 + -7.1841*1 + 0.2480*14*1 

	margins wbho, at(educ=14) /* Checks out.*/ 

	/* Now, let's show all the predictions for each race at each level of ed. 
	We first re-run margins more generally, then run margins-plot, a 
	post-est. command.  */ 

	margins wbho, at(educ=(1(1)16))
	marginsplot, xlabel(, nolabels) xtitle("education") ///
		legend(position(0) bplacement(nwest))

	/* Notably, again, the way that this estimation works causes there to be an 
	estimated *benefit* to being Black on income, which is not necessarily 
	realistic, but rather a function of the fact that the data seem to point to 
	1) a large penalty overall for being Black that is 2) counterbalanced by 
	higher returns to education, meaning that there (Richard Williams, 
	frequent Statlist contributor, has written about this on his website: 
	"People often get confused by the following: If lines are not parallel, at 
	some point the group that seems to be “behind” has to have a predicted edge 
	over the other group – although that point may never actually occur 
	within the observed or even any possible data". It's just a peril of linearly
	modeling a non-linear reality)". */ 
		
		
	/* Here's another case just for illustration using a quantitative version 
	of education. 
	
	This one is simpler, with slopes that clearly don't cross unless education
	were negative.*/ 
	reg wage2 c.educ92##female
	margins female, at(educ=(1(1)16))
	marginsplot, xlabel(, nolabels) xtitle("education") ///
		legend(position(0) bplacement(nwest))

	/* Finally, here's a quant-quant interaction, using centered variables so 
	that the main effects aren't silly (if they aren't centered, the main 
	effect of hours,  say, would be the effect of an increase in education 
	worked when one has no age.
	
	Now, we can interpret the main effects below as "the marginal effect of
	education when someone has the mean age. */

	sum hourslw
	gen centeredhours = hourslw-r(mean)
	sum age
	gen centeredage = age-r(mean)
	sum educ
	gen centerededuc = educ92-r(mean)
	reg wage2 c.centerededuc##c.centeredage
	margins, dydx(centerededuc) at(centeredage=(-32(10)36))
	marginsplot
	reg wage2 c.centerededuc##c.centeredhours
	margins, dydx(centerededuc) at(centeredhours=(-34(10)41))
	marginsplot

	/* The story that each individual margins plot tells us is that the marginal
	effect of education tends to increase as the individual in question gets 
	older and works less. 

	We can make this even more complex by interacting each term and seeing how 
	all three variables combine.*/ 

	reg wage2 c.centerededuc##c.centeredhours##c.centeredage
	margins, dydx(centerededuc) at(centeredage=(-32(10)36) ///
	centeredhours=(-34(10)41))
	marginsplot

	/* Notably, the difference in the impact of education is most for older 
	workers who work different amounts of hours -- those who work the least at 
	the end of their lives stand the most to gain from a unit increase in 
	education. 

	We see the same thing differently below when we run this in reverse order. 
	
	Now, the largest slope as hours change is on the oldest centered age and 
	the smallest slope is on the youngest workers.*/ 

	reg wage2 c.centeredage##c.centerededuc##c.centeredhours
	margins, dydx(centerededuc) at(centeredhours=(-34(10)41) ///
		centeredage=(-32(10)36))
	marginsplot
	
	Here ends the really long comment*/ 
	
	* D. Modulus
	
	/* The modulus of an integer P wrt Q is the remainder of P/Q. For example, 
	12 modulo 5 is 2; 67 modulo 8 is 3; etc. 
	
	P modulo 100 always returns the last two digits of P because for all numbers
	three digits or larger, you can get to the nearest multiple of 100 (assuming
	that P =/= 100 in which case this is trivial) and then the remainder is just
	the last two digits; interestingly this holds true even for numbers smaller
	than three digits. That is, for all numbers with two or one digit ...
	P/100 = 0.XYZ... and the remainder is just the number itself. 
	
	You can extend this logic. To get the last k digits of any integer P, find
	P modulo 10^k. For example, if I wanted to get the last four digits of a set
	of social security numbers for a customer verification program, and suppose
	someone happened to have SSN = 123 45 6789, a program that pulls the last 
	four and shows it to a customer service rep, without giving that person the
	full number, might be... */ 
	
	scalar customerXnumber = mod(123456789, (10^4))
	di customerXnumber
	
	* E. Some more date functions
	
	* I encourage you try this with your own birthday! 
		* Please don't laugh at how old I am or commit fraud with this info.
	scalar mybday = date("04/22/1992", "MDY")
	scalar mybdayDOW = dow(mybday)
	scalar mybdaydoy = doy(mybday)
	sca mybdayweek = week(mybday)
	sca mybdayqrtr = quarter(mybday)
	matrix birthday = (mybdayDOW, mybdaydoy, mybdayweek, mybdayqrtr)
	matrix colnames birthday = "DOW" "Day" "Week" "Quarter"
	matrix rownames birthday = "Bur, GJM"
	matrix list birthday
	* You can try to check your results here: 
		* https://www.timeanddate.com/date/weekday.html
	
	* F. Double precision.
	
	* Why "double"? Long story that goes into some fundamentals of CS.
		* Harvard makes their intro CS class for non-majors available free
		* on Youtube; at the very end of the second lecture (called L1 b/c 
		* that's how CS people count), Prof. David Malan has a nice discussion
		* see here: https://www.youtube.com/watch?v=zYierUhIFNQ&t=7711s
		* It's also in the Stata manual, but I figured I would give you some
		* variety and link to a short video clip. 
		
		* Also, the IEEE Standards page is good: https://archive.ph/zmRLu
		
		* Finally, let me suggest searching "NIST" + "query". Even a lot of high-
		* level math textbooks will punt on certain things that people disagree
		* on because it can be embarrassing to admit that experts never agree
		* (to pick an example from before, "what exactly is a quantile?")
		* Since NIST is a government agency providing practical advice, it is
		* usually more fortright about that unresolved issues. Intro stats 
		* textbooks often regard this as a case where a white lie is "best".
		* NIST: https://archive.ph/CuQNz. 

log close 
