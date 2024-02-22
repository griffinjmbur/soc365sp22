capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
/* By the way, notice that, throughout this lecture, we're going to continue 
using our new Stata shortcut, that of setting an overall working directory, then 
using the ./subfolder shortcut. I held off on doing this initially since showing
too many shortcuts early on can sometimes occlude what's really going on with
folders, which is an important thing to learn, but this should save you time in
the future -- and it occurred to me that while the tilde shortcut should
obviate the need for different Mac/Windows syntax in general, that is not true
when you are using WinStat specifically (I don't use WinStat myself outside of 
teaching, so this didn't immediately occur to me). 

Conversely, this should work for everyone *as long as you manually set the 
correct "parent folder" above. If you are using WinStat, use "copy address as 
text" and paste that into the quotation marks above. */ 
log using ./do/Lecture4, text replace 

/* task: explore some basic techniques in labeling
   author: Griffin JM Bur, 2022-02-21
   SOC 365, Spring 2022, Lecture 4.*/ 
   
// 4.2: describing datasets
	
	use ./original_data/cps2019, clear
	
	// Let's first examine the overall description of the dataset given by
	// describe, which can be abbreviated "d". 
	
	describe // = 
	d
	
	/* "The header portion of the output gives overall information about the 
	dataset and is broken up into two columns (groups). The first (left) column 
	tells us the name of the dataset, the number of observations and variables 
	in the dataset, and its size." (Note that it does not always show the size). 
	
	The second (right) column shows the label for 
	the dataset, displays the last time it was saved, and mentions that the 
	overall dataset has notes associated with it. The body of the output shows 
	the name of each variable, how the variable is stored ..., 
	the format for displaying the variable (see section 4.8 for more 
	information), the value label used for displaying the values 
	(see section 4.4 for more information), and a variable label that describes 
	the variable (see section 4.3 for more information). Variables with asterisks 
	have notes associated with them (see section 4.7 for more information). */
	
	d, short // This just gives the header
	
	// We can also describe specific variables
	d wage1 wage2
	
	// This command pulls up a shorter version of the actual codebook for this
	// variable, which might give you what you need -- basic information about 
	// the var. -- without needing to consult the PDF or physical codebook. 
	
	codebook wage1 
	codebook occ12
	
	// We can also view all the notes in a data-set, which includes similar 
	// information but typically more technical. 
	
	notes
	
	// ...or we can get a combination of the two ... 
	codebook wage1, notes 
	codebook occ12, notes
	
	// and we can see if there is any pattern to, say, missing values. 
	
	* Example 1.
	codebook wage1, notes mv
	* Example 2. 
	codebook educ92, notes mv
	* Example 3. 
	codebook occ12, notes mv
	
	// We can also check the language of the data-set, but this may not be 
	// relevant if you're using a data-set in English -- even if the data-set
	// concerns countries where English is not the majority language. 
	
	// Here's the CPS, which does interview Spanish speakers
	label language 
	
	// and the GSS (same)
	use ./original_data/gss2018, clear
	label language
	
	// and some data from Russia during the period of the abolition of serfdom
	import delimited ///
		https://tinyurl.com/russiadata, ///
		delimiters(tab) clear
	label language
	desc
	
	// We can also search to find interesting variables, which works just like 
	// the variable window. 
	use ./original_data/gss2018, clear
	
	// Suppose we have an interest in a project about spousal relationships. 
	lookfor spouse
	
	// And search for notes if that's necessary at any time. 
	notes search spouse // here, Stata finds nothing. 

// 4.3: labeling variables

	/* So, it's useful to label both values of a variable as we've seen once
	before (and we'll see it again today) but also just the variable in general.*/ 
	use ./original_data/book_data/survey1, clear
	d
	label variable id "Identifier"
	label variable gender "student's gender"
	d

/* The book goes ahead and labels all of the other variables. */ 
	label variable race "Race of student"
	label variable havechild "Given birth to a child?"
	label variable ksex "Sex of child"
	label variable bdays "Birthday of student"
	label variable income "Income of student"
	label variable kbdays "Birthday of child"
	label variable kidname "Name of child"
	d
	
// ...and we can change the labels of a variable which already exist. 
	desc id
	label variable id "unique identification variable "
	desc id
	// or the entire data-set. 
	label data "survey of grad. students"
	d

	save ./modified_data/survey2, replace
	
// 4.4: labeling values of variables

	/* I've already shown you this in the last couple of do-files since it was
	convenient then, but let's see it once more. */ 
	
	use ./original_data/cps2019, clear
	tab female
	codebook female
	
	// By the way, suppose that we didn't know for sure whether "female" was
	// named in the conventional way for dummies. Let's use a technique from 
	// last week to check this: cross-checking categorical vars rather than
	// fetching the codebook. 
	
	// We can look at the reasons that people work part time. We would expect, 
	// if we create a two-way table, women to be absent more often for childcare
	// and family reasons, given the particular structure of gender ineq. in the
	// US, and men to be gone more often for seasonal labor reasons since such
	// jobs -- e.g. construction and farmwork -- are occupationally-segregated. 
	
	tab reason94 female, col 
	// Our intuition was correct. Female is very likely coded conventionally. 
	
	// We define the value-label...
	label define sxvar 0 "male" 1 "female" 
	
	* ... and paste it on.
	label values female sxvar
	
	/* ... then check our work */ 
	
	tab female
	
	// Let's practice adding a label. Note that, if we try to do this in parts,
	// problems ofcur. 
	
	tab schft
	label define sch1 0 "not a full-time student"
	label values schft sch1
	tab schft
	
	label define sch2 1 "full-time student"
	label values schft sch2
	tab schft
	// Rats -- we dropped the label for 0. Let's see how we *can* do this in 
	// parts with "add". 
	label values schft sch1
	label define sch1 1 "full-time student", add
	label values schft sch1
	tab schft // there we go. 
	
	// Modifications work the same way, though you can just write a new value
	// label as well. 
	label define sch1 0 "not FT", modify
	label list sch1 // now this looks better and we can past it on. 
	label values schft sch1
	tab schft
	
	// Here's how a new value label would look. 
	label define sch3 0 "not FT" 1 "full-time student"
	label values schft sch3
	tab schft
	
	// Let's save these data, along with the label
	
	label save sxvar using ./do/sxvar.do, replace
	// The way this saves is a bit weird, but the idea is that we have a do-file
	// that have the instructions for making this label. If we need to use it in
	// a new project, we can just copy that snippet of code from svar.do into
	// the new do-file. It looks like this:
	type ./do/sxvar.do
	// and we save the data: 
	save ./modified_data/cps2019improved, replace
	
	// Let's now label the variable for the biological sex of the respondent's
	// child, taking care to label missing values. 
	use ./original_data/book_data/survey1, clear
	codebook ksex
	label define mfkid 1 "Male" 2 "Female" .u "Unknown" .n "NA"
	label values ksex mfkid
	tab ksex
	codebook ksex

	// We can also add numeric labels, which lets us see the value of a particular
	// qualitative variable. 
	
	// Let's look at race on the GSS
	use ./original_data/gss2018, clear
	* and look at the value label. We can do this a couple of ways. let's do this
	* in the simpler way -- but this won't always work. 
	codebook race
	// Here we don't see the numeric-labels, though we can see the value-labels
	// on their own...
	tab race
	// ... or the numeric values on their own, but not both
	tab race, nolabel
	// We can also just list out the value label; I'll explain how to find this
	// kind of information in a little bit. 
	label list RACE
	// And we can add the numeric label now
	numlabel RACE, add
	// And see what it looks like 
	tab race
	list race in 1/20
	
	// We can also remove the numeric label...
	numlabel RACE, remove
	tab race
	// ... or add a mask (this is mostly an aesthetic thing)...
	numlabel RACE, add mask("#=")
	tab race
	// ... remove a mask ... 
	numlabel RACE, remove mask("#=")
	tab race
	// ... change up the form of a mask ... 
	numlabel RACE, add mask("#-->")
	tab race
	// ... and, finally, add masks for all variables 
	numlabel, add mask("#-->")
	tab1 race sex
	// by the way, tab1 just tabulates two variables' marginal distribution w/o 
	// their conditional distribution (as in a two-way table, which "tab" gives).
	
// 4.5: label utilities

	// Here's a really useful example of some of these utilities taken from a 
	// typical problem people encounter in their project for 360 which I usually
	// don't show how to do fix "the easy way" because it's a bit conceptual 
	// and it is simpler to look it up in the GSS codebook, though that is
	// an unwieldy ~4000 pages long. 
	
	// Say I want to create a dummy variable for whether someone practices Islam.
	
	use ./original_data/gss2018, clear
	tab relig 
	
	/* OK, these are probably labeled in numeric order, beginning with one, but
	a) what if they aren't?; b) it's annoying and error-prone to try to count all
	the way down. Well, I can sometimes find the value label by looking through
	the label directory, and then I can just print the label. */ 
	label dir
	
	/* We could also find this with describe. */ 
	desc
	
	// Quickly scrolling through the list, I see that the GSS just used ALLCAPS
	// versions of variables for value-labels, which is very useful. So...
	
	label list RELIG // Remember that Stata is case-sensitive! 
	* label list relig <-- thus, this doesn't work
	
	// So, I quickly see that Islam is given the numeric label of 9. Then, just
	// to practice making a value label and applying it...
	
	gen Muslim = . 
	replace Muslim = 1 if relig == 9
	replace Muslim = 0 if relig ~=9
	label define MUSLIM 0 "other relig." 1 "practices Islam"
	label values Muslim MUSLIM
	tab Muslim
	
	label save RELIG using ./do/GSSreliglab, replace
	
	// Let's also practice changing a value label. For example, now that we 
	// mention it, "moslem" is considered to be an outdated romanization by many 
	// people who practice this religion. So, let's update the GSS a bit. 
	
	label define RELIG 9 "Muslim", modify
	label values relig RELIG
	tab relig // good news. 
	
	* Sometimes it's helpful to just see all the information that exists for a 
	* certain label. 
	
	labelbook RACE
	labelbook RELIG 
	
	// note that, contrary to our book's warning about the abbrevation of 
	// value labels, some Stata commands will show the entire value label,
	// not just the underlined portion. e.g., 
	tab relig race, col 
	
	// Let's look at some typical problems. Here is the "same label up to 12
	// characters" problem. 
	
	labelbook PRAY, detail problems 
	
	// "several times a day [week]" are not different enough. 
	
	tab sex pray // so, this output is hard to read, for example
	
	// We can also use the "problems" option to spell out some common issues. 
	labelbook, problems
	
	// Let's take a look at one of these cases. For the variable hispanic, the
	// value label HISPANIC has some gaps. 
	labelbook HISPANIC
	
	// Here, there are some odd skips in the numbering 
		* (e.g., 11/honduran --> 15/dominican).
	
	// But, it might not be a big deal. Let's see if there are unlabeled obs.
	
	numlabel HISPANIC, add
	tab hispanic, missing 
	
	// So, here, no-one has been *assigned* those numbers, fortunately. 
	// This is what that might look like, though, in a trickier case. 
	
	label define hisp 1 "not hispanic" 2 "mexican"
	numlabel hisp, add
	label values hispanic hisp
	tab hispanic, missing

// 4.6: Labeling variables and values in different languages
	// I'll mostly leave this to you since this might not come up.
	// It is a case where Mitchell goes a bit too far into the weeds. 
	// As I mention above, many data-sets, for better or
	// worse, are written in English, and this is convenient if you plan to 
	// publish in English or work in an English-speaking firm -- even if the data
	// themselves are about a place that doesn't speak much or any English, the
	// language of the data-set might be English. 
	
	// That's an artifact of imperialism
	// and I don't mean to be blithe about it. But, whether or not you need to
	// change the language in Stata is something of a separate question. It's a
	// question of what's more work and at what point, if any, you want to 
	// translate in/out of English (or any other language that might be the 
	// default in a particular place). 
	// Also, not to be too pedantic, but Mitchell, in his admirable attempt to
	// be a bit more multicultural, uses a lot of Spanglish that perhaps doesn't 
	// sound as respectful as intended ("studenta" is...non-idiomatic...)
	
	label language
	
// 4.7: adding comments to your dataset using notes
	
	/* we've already seen this once before; adding notes is pretty simple. 
	But, let's use an interesting example that we saw before but which we did
	not fully know how to handle. */
	
	import delimited ///
	"https://github.com/gjmbur/365example/raw/main/35478-0001-Data.tsv", ///
	delimiters(tab) clear
	
	// Note that in this earlier version of the GSS, missing values take on large
	// numbers.
	
	sum educ, d 
	scalar edmean1 = r(mean) // I'll explain this in a second; it's NBD.
	sum speduc, d
	scalar spedmean1 = r(mean)
	
	// Let's fix that. 
	tab educ
	replace educ = . if educ == 98 | educ == 99
	replace speduc = . if speduc == 98 | speduc == 99
	// Now, this is instructive. Let's check our work!
	tab1 educ speduc, missing
	// Uh-oh. We missed "97". Let's add that in.
	replace speduc = . if speduc == 97
	tab1 educ speduc, missing
	// Much better. Let's compare the results. You don't have to follow this,
	// but it just shows some things you can do in Stata and proves what I've
	// just said in a way that teaches you some cool Stata features. 
	
		sum educ
		scalar edmean2 = r(mean) 
		/* we've covered scalars; scalars can also store the results of some 
		command that we've just run right before it. We basically tell Stata 
		"make edmean2 equal to the result of the part of 'sum' that computes 
		the mean". */ 
		sum speduc
		scalar spedmean2 = r(mean)
		matrix results = (edmean1, spedmean1 \ edmean2, spedmean2)
		// Here, we put the results of summary statistics for the un-modified 
		// variables into row 1 of a matrix and the fixed results in row 2
		matrix rownames results = "data errors" "no errors"
		matrix colnames results = "r's ed." "spouse's ed."
		// and name the columns/rows for readability
		matrix list results 
		// and view the results. 
		// Here, we can see that the results change marginally for respondent but
		// by a huge amount for spouse b/c of the many missing values. 
		
		// Here's how to do that with conditional commands. 
		sum educ if educ <21
		scalar edmean3 = r(mean)
		sum speduc if speduc <21
		scalar spedmean3 = r(mean)
		
		// Let's show that this is the same thing as making these into missing
		// values. 
		matrix results2 = (edmean2, spedmean2 \ edmean3, spedmean3)
		matrix rownames results2 = "missing values" "conditional commands"
		matrix colnames results2 = "r's ed." "spouse's ed."
		matrix list results2
		// These both fix the problem in the same way. 
	
	// Let's also record what we did. 
	note educ: missing values (98, 99) were converted to "." TS
	note speduc: missing values (97, 98, 99) were converted to "." TS
	notes educ speduc
	// TS timestamps the notes so that we have a record of when we did what
	// we did. 
	
	// Mitchell goes into quite a bit more detail here, but most of this is 
	// shown in L3 or is self-explanatory. I'm going to start being a bit briefer 
	// with these lecture notes when we have busier weeks with HW to review. 
	
// 4.8: the display of variables

	// We can also change the way that variables are displayed in Stata. This
	// can get really deep -- it goes right to the hard of how computers actually
	// work, which is basically that you can represent numbers and language in
	// binary, which you can think of as basically whether a switch is on or off.
	// That's actually how we can communicate to these seemingly-magic machines.
	// But, we'll keep things light and practical here. 
	
	// Let's use the CPS data again. 
	use ./original_data/CPS2019, clear
	// We'll sort our variables by wage for convenience. This just changes the 
	// order of observations (without, say, changing the ID variable). E.g.
	list wage1 in 1/20
	sort wage1
	list wage1 in 1/20 // Now these are the first 20 observations. 
	
	// Let's look at the display of wage1. 
	desc wage1 
	// OK, it's a float variable, which refers to how it's represented in binary.
	// We'll ignore that. Also of interest is the display format, which is in
	// this "general" format the bok mentions--i.e., the computer takes some
	// liberties in how to display the number. The "9" gives the overall width
	// of any possible value, and the .0 and g tell Stata it can be flexible.
	
	// We can also request that Stata show a specific number of digits past the
	// decimal in all cases. Note that with %9.0g, Stata decides how many to
	// show on the basis of how much useful information there was after it. 

	list wage1 in 950/1050
	
	// But now let's insist that it show two digits after the decimal and up to
	// 12 characters overall 
	format wage1 %12.2f
	list wage1 in 950/1050
	
	// Shortening the number of characters, by contrast, can force Stata to 
	// round according to our familiar rules.  
	format wage1 %2.0f
	list wage1 in 950/1050 
	
	// Let's look at putting commas into these long numbers. 
	use ./original_data/CPS2019, clear
	sort weekpay
	sum weekpay, d
	drop if missing(weekpay)
	// N.b. that the book's suggestion about including commas does not work if 
	// we try this. Why not? 
	format weekpay %6.2fc
	// The six is for the *characters*, not the numbers. So, if we insist that
	// Stata show, say, eight characters and a comma, we can get one. 
	list weekpay in 110000/110100
	format weekpay %8.2fc
	list weekpay in 110000/110100
	
	// The book now describes string variables. Note a few things. First, the GSS
	// and CPS actually do not have any string variables proper.
	
	d
	use ./original_data/gss2018, clear
	d
	
	// Instead, these are stored as numeric variables with value labels. E.g.,
	tab relig
	tab relig, nolab 
	// When we omit the value label, we have numeric values. 
	
	// To see a contrast, we can use the auto data-set. We haven't done much with
	// this "toy" data-set, but it is useful for this kind of quick investigation. 
	sysuse auto, clear
	d
	tab make
	tab make, nolab 
	// Now we see no difference. We'll talk about encoding these strings later. 
	
	// We can slightly modify our aesthetic preferences, e.g. taking left-aligned
	// data...
	list make in 1/10
	// ...and making them right-aligned. 
	format make %2s
	list make in 1/10
	
	// We can also change the formatting of dates, which is often convenient. 
	use ./original_data/book_data/survey5, clear
	list bdays kbday
	// These are actually currently stored as strings, despite looking "numeric"!
	// Let's encode them in a date format. 
	generate bday = date(bdays, "MDY")
	generate kbday = date(kbdays, "MDY")
	list id bdays bday kbdays kbday in 1/5
	// The strange format here is that, for Stata, time begins in the 1960s and
	// it stores data as the number of days since then. This is a quirk to keep
	// in mind if you work with time-series data -- it can cause some headaches
	// though it is an easy thing to troubleshoot. Let's do a bit of that now. 
	format bday kbday %td
	list id bdays bday kbdays kbday in 1/5
	// This now stores dates in the way it's colloquially done in Europe, though
	// not as common in the US. 
	
	// We can also get the more common US format in this way >. 
	format bday %tdNN/DD/YY
	list id bdays bday in 1/5
	
	// Or we can even ask Stata to display what looks like how we would write 
	// this were we not programming. 
	format kbday %tdMonth_DD,CCYY
	list id kbdays kbday in 1/5
	
	// Let's label our new variables like we learned to do earlier and drop
	// the original variables. 
	label variable bday "Date of birth of student"
	label variable kbday "Date of birth of child"
	drop bdays kbdays
	save ./modified_data/survey6, replace
	
// 4.9: changing the order of variables in a data-set
	
	// We've already seen how we might order the rows of our data ("sort") but
	// we can also order the variables
	use  ./modified_data/survey6, clear
	browse
	d
	order id gender race bday income havechild
	order kidname, before(ksex)
	d
	
	// The book's suggestion about ordering sets of variables may or may not
	// be worth the time; for our two example real-world data-sets, for instance,
	// it is is probably not. But, here's how it works. 
	
	gen STUDENTVARIABLES = . 
	gen KIDVARIABLES = . 
	order STUDENTVARIABLES, before(gender)
	order KIDVARIABLES, before(kidname)
	d
	
	save ./modified_data/survey7, replace
	
// Appendix A: Making a directory for the final project

	// Beware! This will only work once -- Stata will not let you overwrite
	// an old folder with the same name. 

	mkdir finalproject
	cd ./finalproject
	mkdir finalprojectdo
	mkdir finalprojectdta
	mkdir finalprojectgraphs
	mkdir finalprojecttabsfigs

log close
