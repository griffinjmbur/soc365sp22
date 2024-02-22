capture log close
clear all 
set more off
* cd "/Users/gjmb/Desktop/SOC365sp22/do" // change this to a folder on your pc
// N.b. that this shortcut also works by replacing the home dir. w/ ~
cd "~/desktop/SOC365sp22/do"
pwd // note that this worked correctly. also, this allows you to potentially
// not need to replace every folder here with a folder on your computer, if you
// follow my example and just make a folder on your desktop called SOC365sp22 
log using Lecture2, text replace 

/* task: go over means of loading data into Stata
   author: Griffin JM Bur, 2022-02-07 
   SOC 365, Spring 2022, Lecture 2.*/ 

* Ch. 1 

/* Big idea for this chapter: we want to go over some ways of displaying
data after loading data onto our hard drive, then into Stata,
from the book's website, by working *within* Stata. */ 

	cd "~/desktop/SOC365sp22/original_data/book_data" /* Note that you
	do not have make a subfolder like this, but I though it was clearer */ 
	pwd // let's check the directory just to be sure.
	net from http://www.stata-press.com/data/dmus
	net get dmus1
	net get dmus2
	use wws, clear /* Note that the period in front of each command in the book 
	is meant to mimic the output of the program; it's not a necessary part of the 
	INput (i.e., the code we're writing), hence why it does not appear here. */ 

	list idcode age hours wage in 1/5 /* This lists the first five obs. on these 
	vars. Note that we won't actually use this command terribly often; it basically
	produces the matrix of observations in Stata's output ("list" on its own with
	no options or variables specified does just that). */
	
	/* list //I'm putting this as a comment b/c the output for this is a bit
	annoying as it takes up the whole results window and more */ 
	
	/*An alternative is just to pull up the spreadsheet where Stata stores data. 
	You can do this with...*/

	browse // Just close this window whenever you're done. 
	
	describe // We can also describe all variables, which is handy. 

	* Let's list some other variables

	list idcode married marriedyrs nevermarried in 1/5 // Note the abbreviation.

	* We can also insist that Stata not abbreviate names. Not super common.

	list idcode age hours wage in 1/5, abb(20) 
	// But, we do see here another example of an option, a qualifier that 
	// follows a command and a comma, which
	// we'll use a lot; most of you probably have used this before, albeit perhaps 
	// without knowing exactly what was going on. 

	* We can also suppress the list of IDs if we so choose. 

	list idcode age hours wage in 1/5, abb(20) noobs /* This is particularly 
	convenient here because we are asking Stata to report the "idcode" anyways,
	which uniquely identifies subjects. */ 

	* Time to load a new data-set to look at the separator bar. 

	use tv1, clear /* A little bit more about the "clear" option. This basically
	forces Stata to drop the old data (here, wws.dta). This isn't necessary if we 
	have not changed those old data, which is the case here: we haven't created 
	a new variable, dropped any observations, etc. But, if we have, Stata will 
	object to us changing the data-set, and we'll get an error message that can
	be confusing. Here's an example.*/ 
	
	use wws.dta // all good here since we didn't change TV1 yet. But let's drop
	// an outlier. 
	
	// First, a bit of background math: define an upper-tail outlier on variable
	// Z as any observation whose value > Q3+(1.5*IQR), Tukey's rule.  
	
	/* Also, here's a useful thing Stata can do -- it can store the vectors it
	creates in the background when it runs certain commands; these are the things
	we can call with "r(such-and-such)". We can also give names to these numbers,
	which in the language of linear algebra are called *scalars* (emphasizing that
	they are numbers, not columns or rows, i.e. vectors). Stata uses the word 
	scalar to mean "name given to a scalar", which more typically just means 
	literally "some real number". 
	
	This just makes it easier to avoid copying/pasting numbers. So, let's define 
	an outlier and then drop it.*/ 
	
	graph box currexp // We seem to have some outliers. 
	sum currexp, d
	scalar Q3 = r(p75) // This assigns the 75th percentile to the label Q3. 
	scalar Q1 = r(p25) // same for the 25th percentile
	scalar IQR = Q3-Q1 // this assigns their diff. to "IQR"
	scalar upperbound = Q3+(1.5*IQR) // this assigns the Tukey rule to "upperbound"
	// BTW, we can display all of these. "display" also works for basic calculation
	display Q1
	di Q3 
	di IQR 
	di upperbound
	drop if currexp>upperbound // this drops outliers
	
	/* Now we return to the new data-set. If we try <<use tv1.dta>>, we will 
	get the following message:
	"no; dataset in memory has changed since last saved". I'm putting this wrong
	command as a comment so that you don't get an error message when running this
	file, but you may want to past it into the command window to see what 
	happens */ 
	
	use tv1.dta, clear // this is necessary, now.
	
	/* Why the heck would we ever want to clear a data-set we've modified?! Because
	you should *always* make changes to any data-set in a do-file you've saved. 
	You should NEVER, EVER EVER in my class (and probably never in life) make
	changes to a data-set that aren't assiduously recorded. Dropping and adding 
	variables in the command window, then just saving the data, leaves NO RECORD 
	of what you did. It is a classic no-no. 
	
	You should get in the habit of *NOT-saving* your data, and leaving changes 
	in the do-file, or at least saving a new dataset, though you need a forensic 
	record of how that was done. 
	
	Back to the main theme of looking at variables. */ 

	list // Here we can just list all observations since the data-set is so small. 

	list, separator(0) // We can omit the separator bar if we insist...
	list, sepby(kidid) // ... or separate by a meaningful value
	
	/* By the way, we'll come back to this way of storing data, which is not
	always ideal, where we have the same entity -- here, kids -- on which 
	multiple observations are made and those are recorded as separate rows, 
	called long data. We can reshape such data, but that would take us too far
	afield here (there is a related problem that most individuals do not have 
	observations on most dates here). */

* Ch. 2

// Now we want to work on reading a wide variety of data-sets into Stata. 
// 2.1: Introduction 

	* We'll begin with a comma-separated-values file (csv). 
	* CSVs are a common form of exporting spreadsheet data. They look like this:
	
	type dentists1.txt /* Notice that the variable "recom" is coded as either a zero
	or a one even though it is not a quantitative variable -- we'll talk about that
	later on since this is as much of a conceptual issue as a coding issue */ 

	// We might also encounter a tab-separated-values file (tsv), where elements
	// of each row are separated by an indent. They look like this: 
	type dentists2.txt
	
		// we can see the tabs directly like this
		type dentists2.txt, showtabs

	*... or a space-delimited file (delimited means, in this context, separated, so
	* this is a file where elements of a row are separated by a space. 
	type dentists5.txt

	/* Or, finally, a fixed-width file, which basically is like an file with 
	invisible columns that impose a maximum length for the possible-outcomes of 
	a variable; columns vary in width according to the possibile realizations of
	each variable. These are the hardest to deal with and are also rare. */ 

	type dentists7.txt

	// 2.2: reading Stata dat-sets

	// By contrast, loading Stata-formatted data-sets is easy. E.g.

	use "dentists.dta", clear 
		
		// Nb that we don't even need a .dta extension here or quotes for that
		// matter
		
		use dentists, clear

	// Though not often necessary, sometimes with very large datasets, just loading
	// some variables in it might be useful. This is actually a semi-rare occasion 
	// where you might want to think about making a new data-set because you aren't 
	// really modifying the data -- just omitting some information.  

	use name years using dentists

	// Here's how to save this data-set

	save ~/desktop/SOC365sp22/modified_data/shorterdentists, replace

	// Note that I changed the filepath s.t. this went to our modified data subfolder.

	// We can also read in data only on some condition:

	use name years using dentists if years >= 10

		**** interlude on conditional commands ****

		/* Next the book also introduces conditional commands, i.e. those using 
		"if".  We'll learn this in bits and pieces over the semester, "as needed", 
		but you've already seen this before, and we might as well spell it out a 
		bit more. You do not need to master this yet by any means, but I just 
		want to show a bit of this now. 
		
		Simply put, adding "if" to a Stata command runs the command 
		only over certain  "regions" where the condition is true. For example, 
		let's use a more realistic  case, the GSS. Say that, as part of a 
		health evaluation, I want to compare my weight to that of other men my age 
		rather than the entire population, which might be misleading. 
		
		I write... */

		cd "~/desktop/SOC365sp22/original_data"
		use GSS2018 

		codebook sex 

		// I look up the numeric codes that identify men (well, males; many older
		// data-sets do not cleanly distinguish sex/gender). This can often 
		// be accessed through the codebook command, but sometimes consulting 
		// the actual codebook (usually a PDF from the website where you got the data) 
		// is necessary. 

		sum weight if sex == 1 

		// Note that the double-equals sign is necessary here. It
		// helps distinguish assignment (things we want to make true, such as "make 
		// a variable that equals 1 if a person is married""), which uses the single 
		// equals sign in Stata, from a case where we want to know if some 
		// condition *is* true or not. I.e., note that this command that follows,
		// if you run it instead of leaving it as a comment, generates a bit of
		// a cryptic error message. 
		
		* sum weight if sex = 1

		// OK, so, this is pretty useful, but what if I want to further stratify this
		// on height and age? Here's how we can stack conditions in Stata

		sum weight if sex == 1 & height >72 & height< 75 & age >26 & age<32, d

		/* Now, from an inference standpoint, this is not a very large n, and 
		the standard error is huge, but the point is that we were able to zero in 
		on a specific subset of our sample using conditional commands. 

		We can also use if-statements to set up and/or-type conditions. E.g., 
		suppose I want to summarize someone's days of poor mental health if they 
		are unmarried for any reason. */ 

		codebook marital // We learn what numbers mean someone is somehow unmarried

		sum mntlhlth if marital == 2 | marital == 3 | marital == 4 | marital == 5

		// Of coures, in many cases, there is a shortcut

		sum mntlhlth if marital >1 

		* N.b. that, here, the following syntax is identical in effect. But, you 
		* should always really think through the basic algebra of inequalities when 
		* setting up  conditions is what I typed going to give me what I want? 
		* More on this down the road.

		sum mntlhlth if marital >=2
		
		// Here's a bit more on all this: 			
		// https://www.stata.com/support/faqs/data-management/true-and-false/

// 2.3: saving Stata data-sets

	/* OK, let's now save some data-sets, remembering that this is optional in the
	sense that any changes we want to make to a public-access file can be made in a
	do-file and then re-run each time.

	One possible case where saving data makes sense is if the data are simply in a
	non-Stata format and we want to save them to a .dta file. */ 

	cd "~/desktop/soc365sp22/original_data/book_data"
	insheet using dentists1.txt, clear
	save "~/desktop/soc365sp22/modified_data/mydentists", replace 
	// Note that the replace option saves over old files with the same names
	// so...be really careful!! 
	
	// Note that "save if" does not work...you can run what's below, but I am
	// putting it as a comment so that this do-file can be executed w/o error. 

	*save if years < 25 

	*...so if you want to just save some subset of obs, just drop the others. 
	* Again, be really careful with this. Usually dropping obs. is not necessary 
	* unless you have a robust social theory of why data should be excluded!

	keep if years <25
	list
	save "~/desktop/soc365sp22/modified_data/shorterdentists2", replace
	
	// Notice that we can still re-load the original dataset since we saved the
	// modified data under a new name. 
	
	use ~/desktop/soc365sp22/modified_data/mydentists, clear
	list years
	
	/* Note that "keep if" and "drop if" are basically inverse commands. Let's reload
	the original data-set and show this. First note that "keep if" above yielded
	four dentists, "Don", "Olive, "Ruth", and "Mike". */ 

	insheet using dentists1.txt, clear
	drop if years >= 25
	list // and the result is the same.  

	/* We can also read files directly from the web. This isn't always that useful--
	I got the link for these data by going to the CPS website, at which point it 
	would just be easier to download them directly and move them into the right
	folder--but if you want to just give someone a do-file without having to send
	them a separate .dta file, locating or hosting the file online and then calling 
	it with "use" is not a bad idea. */ 

	use https://data.nber.org/cps-basic2/dta/cpsb202111.dta, clear 

	// These are (fairly messy) CPS data and will take a while to load, beware!
	
	// Last note: saveold is not a super important command to know about. 

// 2.4: loading in csv and tsv files 
	
	// We've already done some of this, but let's look at some subtleties
	// What if we have a CSV file without names attached? 
	
	insheet using dentists3.txt, clear
	list 
	
	// A simple solution is to rename the variables
	
	rename v1 name
	rename v2 years
	rename v3 fulltime
	rename v4 recom
	list
	
	// But we can also just tell Stata to assign them 
	
	insheet name years fulltime recom using dentists3.txt, clear
	
	/* Also, technically, insheet is an outdated command, though it still works
	You can instead use ... */  
	
	import delimited name years fulltime recom using dentists3.txt, clear
	
	/* Let's look at a more realistic example using GSS 2012 data in TSV format.
	
	I put this up on my GitHub since some of the data I want to show you would 
	otherwise require you to be a member of ICPSR in order to access these data. 
	I recommend considering membership and in the project proposal assignment I
	lay out how to apply. You can determine whether this is worth it -- it's not 
	a big time investment and it should be free to you -- by looking around and 
	seeing if ICPSR has anything you might want to obtain. */ 
	
	insheet using ///
	"https://github.com/gjmbur/365example/raw/main/35478-0001-Data.tsv", clear
	
	/* One thing to note here that I have not yet mentioned to you is that when 
	we want to run multiple line commands -- the purpose of which is largely
	readability, since Stata can understand long lines just fine -- we can use 
	the three forward slashes to do so. 
	
	Note that if we use import delimited, we need to declare TSV data since its 
	default is CSV. */  
	
	import delimited  ///
	"https://github.com/gjmbur/365example/raw/main/35478-0001-Data.tsv", ///
	delimiters(tab) clear
	
	// Let's show that this gives the same results as if we had a .dta. file. 
	
	// First, let's run an analyis in Stata. 
	
	// Note that in this earlier version of the GSS, missing values take on large
	// numbers, which is something we'll talk about later. Be careful about this
	// sort of thing!
	
	sum educ speduc, d 
	sum educ speduc if speduc <90 & educ <90, d // this looks better
	reg speduc educ if speduc <90 & educ <90 
	// store regression results in a matrix for easy access later
	matrix tsvreg = r(table)
	
	// Now we load the .dta file 
	
	use  ///
	"https://github.com/gjmbur/365example/raw/main/35478-0001-Data.dta", ///
	clear
	
	reg SPEDUC EDUC if SPEDUC <90 & EDUC <90 
	// Note that Stata is often case-sensitive and that the case changes 
	// in the different formats!!
	matrix tsvreg2 = r(table)
	
	// the results are the same 
	matrix list tsvreg 
	matrix list tsvreg2
	
/* Now we come up to the more-esoteric material. In general, this is not a 
"memorization course", but this section, in particular, goes into some rather 
thorny details. I cover this because it is possible that it will come up with
your data project, but I don't expect you to have these methods mastered. There
is also some overlap between these methods, and our book is somewhat outdated 
here -- nothing it describes won't work, but there are some more-general commands
that can handle the same duties as what our book suggests. 

Here is the Stata manual [1] summary of these techniques, which is slightly 
clearer than our book:

"Stata has various commands for importing data. 

"The three main commands for reading non–Stata datasets in plain text (ASCII) are

	"• import delimited, which is made for reading text files created by 
		spreadsheet or database programs or, more generally, for reading text 
		files  with clearly defined column delimiters such as commas, tabs, 
		semicolons, or spaces;
	
	"• infile, which is made for reading simple data that are separated by spaces 
		or rigidly formatted data aligned in columns; and
	
	"• infix, which is made for data aligned in columns but possibly split 
		across rows" 
		
Note that import delimited supersedes insheet, though insheet still works. 

If we use infile and infix with fixed column data, they must both have a 
dictionary, and they do basically the same thing [2], while if we have space-
delimited data, infile is the best suited command for the job. 

This section presents something of an oversimplification. Should you ever need to
figure out a truly complex case, which is pretty unlikely, the flowchart in Stata
User's Guide 16, Section 22.2: "Determining Which Method To Use" is as definitive
a source as I've found.*/
	
// 2.5: space-separated values

	// These are rare these days. We have to be careful in importing them. 
	// Here is what they look like...
	
	type dentists5.txt
	
	/* Can we just infile them directly? Again, I'll put the command as a comment
	so that the entire do-file will run, but you should remove the asterisk and
	then try and run this and see what happens */ 
	
	* infile using dentists5.txt, clear
	
	/* So, we lack a dictionary. As Baum puts it [3], infile "must assign names
	(and if necessary, data types) to the variables" when it is is working
	in what we call "free format" mode, i.e. the variables are separated by 
	some kind of delimiter, whether a space, a comma, a tab, a semicolon, or
	really anything; this can be distinguished from "fixed format" mode, 
	where the variables do not need to have any space between them (e.g., 
	1632 could represent someone's age and their score on the ACT); 
	instead, the variables can be told apart by the fact that a given variable 
	is only ever represented by characters that are, say, between 15 and 18 
	spaces into the row. 
	
	So, we have free format data here, with space-delimiters. And, with the 
	infile command, we need to specify what variables we are importing. This 
	information is assumed to be known here, but you would want to look it up in 
	the codebook in practice. */ 
	
	* infile name years full rec using dentists5.txt, clear
	
	/* Again, if we try that command above, we still get an error message -- 
	what has gone wrong? We forgot to write down the fact that the name
	variable is a string, or a set of letters */ 
	
	infile str17 name years full rec using dentists5.txt, clear
	
	// We also don't need to bother with naming the variables right away
	
	infile str17 v1 v2-v4 using dentists5.txt, clear
	list
	
	// and this ends up being equivalent to the more up-to-date...
	
	import delimited dentists5.txt, clear delimiters(" ")
	list
	
	// Let's look at a slightly more realistic example. Here, I have made this
	// file, so I "am my own codebook" and know that the variables are these.
	
	// This is a good example of the power of infile because the spaces between
	// the variables are not consistent, which is a type of "space delimited" data,
	// but one that can't be entered simply into the import delimited command.

	infile educ maeduc paeduc str5 race using ///
	"https://raw.githubusercontent.com/gjmbur/365example/main/gss2018SDF.raw" ///
	, clear
	
	// Notice that imported delimited produces funny results in this case. 
	
	import delimited educ maeduc paeduc race using /// 
	"https://raw.githubusercontent.com/gjmbur/365example/main/gss2018SDF.raw" ///
	, delimiters(" ") clear
	
	// That is because, if we examine the raw data, we see that the variables are
	// separated by more than one space -- and not always the same number
	
	type /// 
	"https://raw.githubusercontent.com/gjmbur/365example/main/gss2018SDF.raw", ///
	lines(20)

	/* If we happen to have data that already include the variable names, we'll
	need to use a slightly different command to get the data loaded in. */ 
	
	type dentists6.txt
	
	insheet using dentists6.txt, delimiter(" ") clear
	list
	
	// We can also use the more-universal command ... 
	
	import delimited dentists6.txt, delimiters(" ") clear
	list

// 2.6 and 2.7: fixed-column files (with or without row spillover)

	// It is rare to find these. You can get most data-sets on ICPSR to download
	// in this format, but it is rare to find sets that only have this option.
	// It is often instructive to download the Stata set-up that ICPSR provides
	// for such files -- it is typically very extensive. Defining a dictionary
	// by hand is usually impractical. That said, our book shows some examples.
	
	// First we examine some fixed-column data.
	
	type dentists7.txt
	
	// Now we infix it using a hand-written dictionary. 

	infix str name 1-17 years 18-22 fulltime 23 recom 24 ///
	using dentists7.txt, clear
	
	// Let's look at dictionary files, which are an alternative to handwriting
	// the dictionary. 
	
	clear all
	
	// Dictionary file looks like this, although note that this dictionary file
	// is complex and includes the infix command; as I mentioned above, these
	// details can get a little wonky. No need to follow the details too closely,
	// though notice that this makes it difficult to use "infile" (otherwise,
	// infile and infix for fixed-format data are basically identical [4].
	
	type dentists1.dct
	
	// And we can use it to read data in.
	infix using dentists1.dct, using(dentists7.txt)
	list 

	// Some dictionary files are written so that they refer to the dataset to
	// imported, which is a handy shortcut. 

	type dentists2.dct
	infix using dentists2.dct, clear 
	list
	
	// Let's also consider infile dictionaries, which we'll use in a second. 
	// This gives considerably more information about the variables and allows
	// simple commands for loading the data
	type dentists3.dct
	clear
	infile using dentists3.dct
	
	/* More likely than directly working out a program for such files, you will
	just want to be comfortable running them if you encounter them. For example,
	this highly interesting data-set on ICPSR about post-Emancipation Southern
	semi-feudalism <<https://www.icpsr.umich.edu/web/ICPSR/studies/9430#>> which
	technically has a "Stata download" option, but there is no .dta file, just
	a fixed-column. 
	
	Let's try something more realistic, where we have a dictionary provided
	to us and we just need to run the fixed-column data through it. */ 
	
	clear all
	type ///
	"https://raw.githubusercontent.com/gjmbur/365example/main/SouthernAgCensusDCT.dct"
	type ///
	"https://raw.githubusercontent.com/gjmbur/365example/main/SouthernAgCensusfixedwithdata.txt"
	infile using ///
	"https://raw.githubusercontent.com/gjmbur/365example/main/SouthernAgCensusDCT.dct" ///
	, using ///
	("https://raw.githubusercontent.com/gjmbur/365example/main/SouthernAgCensusfixedwithdata.txt")
	
	// In many cases, even though infix and infile are theoretically the same 
	// thing, dictionaries might be formatted slightly differently. Generally,
	// you are unlikely to encounter these; seek advice if you do. 
	
	// Typically we'll just want to save these data in Stata format ASAP. 
	// Let's put this in our "modified_data" folder.
	
	save ~/Desktop/SOC365sp22/modified_data/SouthernAgCensus1880, ///
	replace
		
	/* Note that this is an example of what our book discusses in section 2.7, 
	a fixed-column file that spills over multiple lines. Here's the book e.g.*/
	
	type dentists8.txt
	infix using dentists4.dct, clear

	// We can also use infile in the same way as we saw above, where a dct file
	// might specify a data-set to be used. 
	
	type dentists5.dct
	infile using dentists5.dct, clear
	
// 2.8: SAS files

	/* Hooray! This section is a lot easier. SAS is just a (slightly antiquated,
	no offense meant) piece of software that is a lot more like Stata than a 
	program, or indeed a hand-procedure, that will produce the type of files 
	seen above. 
	
	SAS files are exported with their own extension, just like Stata, and we can
	quickly read them in using ... */ 
	
	fdause dentists, clear
	
	/* and we can put in value-labels, which are bits of qualitative information 
	about variables, written with words. */
	
	fdause dentlab, clear
	
	// No need, BTW, to know how to use SAS to export data to Stata. 
	
// 2.9: common errors

	/* Most of this I have implicitly gone over above. The use of "clear" in many
	commands gets around the annoying error message that "data in memory would
	be lost", and I put it as a default whether or not the error message is
	sure to occur. 
	
	Again, this is actually safe to do as long as you are making sure to record 
	changes to your data-set in a do-file or, at a minimum, if you are using 
	the command window and will later copy the commands to a do-file. 
	
	As you probably noticed above, "clear" also clears data if issued as its
	own command. There's really no difference; it's stylistic, and barely so.
	
	Another interesting quirk is that whether or not you have changed the data 
	that you have in Stata's working memory at any point, you cannot load in a
	non-Stata data-set -- like we did above with CSVs, e.g. That's what gives 
	the comparable "must start with an empty dataset" error. Again, use clear. 
	
	The memory management stuff is now almost entirely archaic. Stata does have
	a default maximum variable limit that, on the rarest of occasions, could be 
	breached, which you can increase in the following way with SE (this is the
	maximum number for SE; for MP, it's higher). */  
	
	clear
	set maxvar 32767
	
	/* Stata's memory management is otherwise now fairly automatic. */ 
	
// 2.10: Entering data directly into the Stata Data Editor

	// We'll omit this for now -- there is more on it later in our book
	// and at this point, it is a bit of a detour. 
	
// 2.11: Saving CSV and TSV files

	/* First, why do this? It produces files that can be read by other programs, 
	including Excel, which is in even more common use than Stata, though more 
	limited and harder to use in some ways, at least if you're doing anything very
	complex statistically.
	
	That said, the next couple of sections are perhaps a bit tedious, and 
	just knowing that this information can be accessed here is good enough. */ 

	/* Let's use the book's example. We load a data-set with value-labels and 
	then export it as a TSV...*/
	
	use dentlab, clear 
	outsheet using ///
	~/Desktop/SOC365sp22/modified_data/dentistsTSV, replace
	
	// Let's see what this looks like. 
	type ~/desktop/SOC365sp22/modified_data/dentistsTSV.out
	
	// We can also export CSVs with outsheet
	
	outsheet using ///
	~/Desktop/SOC365sp22/modified_data/dentistsCSV, replace comma
	
	// Again, outsheet -- like insheet -- is a bit antiquated, so we can use...
	export delimited ///
	~/Desktop/SOC365sp22/modified_data/dentlabcsv, replace 
	
	// Now, the default is a CSV. I put "CSV" in the name because the extension will
	// be the same for both CSV and TSV so that I can tell them apart. 
	// Excel can directly open this, BTW. 
	
	// export delimited can also export TSVs.
	
	export delimited ///
	~/Desktop/SOC365sp22/modified_data/dentlabtsv, ///
	delimiter(tab) replace
	
	// Let's view them in Stata and observe that they are different
	cd ~/Desktop/SOC365sp22/modified_data/
	type dentlabcsv.csv
	type dentlabtsv.csv
	
	// We can also remove the labels, just leaving the numeric values for 
	// qualitative variables. 
	
	export delimited ///
	~/Desktop/SOC365sp22/modified_data/dentnolabcsv ///
	, replace nolabel
	
	// Let's examine our work 
	type dentnolabcsv.csv
	
	// There is also the option to remove the quotation marks from the string
	// entries as well as the names of variables. 
	export delimited ///
	~/Desktop/SOC365sp22/modified_data/dentnolabnoquotecsv ///
	, replace nolabel noquote
	
	export delimited ///
	~/Desktop/SOC365sp22/modified_data/dentnolabnolabnoquotenovarcsv ///
	, replace nolabel noquote novar 
	
	type dentnolabnoquotecsv.csv
	type dentnolabnolabnoquotenovarcsv.csv
	
	// But outsheet also works. Its default is a tab-separated file.
	outsheet using dentists_tab.csv, replace
	outsheet using dentists_com.csv, replace comma // This produces a true CSV
	outsheet using dentists_comnolab.csv, comma replace nolabel // remove labels 
	outsheet using dentists_comnolabnoquote.csv, comma ///
	replace nolabel noquote // removes quotation marks as well
	outsheet using dentists_comnolabnoquotenoname.csv, comma replace  ///
	nolabel noquote nonames // removes variable names

// 2.12: exporting space-separated files

	cd "~/desktop/soc365sp22/original_data/book_data"
	use dentlab, clear
	list
	outfile using dentists_space, replace
	type dentists_space.raw
	export delimited using "dentists spaced", delimiter(" ") replace
	outfile using dentists_space, nolabel replace
	
	use dentlab, clear
	list
	outfile using dentists_space, replace
	type dentists_space.raw
	export delimited using "dentists spaced", delimiter(" ") replace
	outfile using dentists_space, nolabel replace
	
// 2.13: saving SAS XPORT files

	// No need to pay too close attention to this since our focus is getting
	// things into Stata or exporting universal formats. 
	
	
// Appendix: some commentary on quotation marks

// By the way, the quotation marks around file and folder names
// are superfluous unless we have spaces in the name of our files or folders, 
// but it is one of several Stata reflexes that you will get in the habit of.
// To see this in action, try making a new folder from within Stata w/ a space.


cd ~/documents 
mkdir "example folder I"
* Note: this will give an error after the first time you run this file b/c
* Stata won't overwrite folders
* cd example folder will yield "invalid syntax as an error, hence why I have
* left this as a comment. remove the asterisk and pop it into the command 
* window to see this problem. 
cd "example folder I" // by contrast, this should work 

/* The same is true for files. Let's make a new file first */ 
save ///
	"~/documents/example folder I/a whole bunch of spaces", replace
	
/* Now let's try to call the file two ways. First, the wrong way: */

* use a whole bunch of spaces.dta

* Now, the right way

use "a whole bunch of spaces.dta"	

// [1] Getting Started with Stata for Mac (Stata Press 2021), Ch. 8
// [2] See Stata User's Guide, Release 16, Ch. 22 and Stata Data Management 
// Reference Manual, Release 16, remarks on -import- 
// [3] Baum, C. 2016. An Introduction to Stata Programming. 
// [4] As the SDMRM puts it, "[m]ost people think that infix is easier to use 
// for reading fixed-format data, but infile has more features". See -infix-.

log close 
