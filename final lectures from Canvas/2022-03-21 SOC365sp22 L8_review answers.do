capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
log using ./do/Lecture8, text replace 

/* task: discuss treatment of missing values and prepare for the midterm
   author: Griffin JM Bur, 2022-03-21
   SOC 365, Spring 2022, Lecture 8 [1].*/
   
   * 1. Nb that I am following the number of actual weeks in the semester for 
   * the sake of keeping things clear. We did not have a "Lecture 7". 

/* This do-file shows how you can approach the analysis of missing values in a 
Stata data-set. The upshot is that listwise deletion is typically the best 
policy, it is the Stata default, and you can use it for our course even when it
is not appropriate because all other simple methods are more-problematic. In your
papers, I would like you to think about whether missing data are likely MCAR,
MAR, or MNAR/NMAR, but you should just mention this -- you do not need to do 
anything too sophisticated unless you are really interested in it (in which case,
contact me). As you'll see, the material for this week specifically is quite 
short. 

Most of this do-file consists in an answer key of material for the exam; the 
blank version is available on the Canvas if you want to try that. So, what is
on the exam and how is it structured? It will be an in-class examination. I will
ask you to load in two data-sets and perform a basic set of operations on them. 
These will be _substantially_ similar to the review below. I have not re-used an
exam from a past instructor but have instead written a brand new exam that more
closely tracks what we actually spent time on. You will be asked to submit the
examination in the same way that you have submitted the exercises. 

In addition to this review, you should consider things that I mentioned in 
multiple lectures (there may be some items that I have actually shown in every
lecture--obviously, that stuff is much more important than something I tagged  
with "bonus, might be useful, looks cool, use this only if you have to deal with
time-series data" and so on. As I have mentioned before, I don't do "surprises" 
on exams, and I do not see much value in forcing you to figure out what is most
likely to appear: the relative frequency of topics in our course is roughly the
relative frequency of topics on the exam. But, I also have high standards and 
expect you all to try to actualize your potential.  

I will curve the exam if it is necessary. 

What is allowed on the exam? 
	0) Anything you copy/paste mutatis mutandis from the Stata -help- files. 
	1) Copying/pasting from my do-files with the right variables switched in. 
	2) Anything you find on Statalist, StackExchange, r/Stata, and so on. 
	3) Any example code you find on the SSCC's help pages, the UCLA help pages,
	anything you find from Germán Rodriguez, Oscar Torres-Reyna, Nick Cox, Sharyn
	O'Halloran, or other people who are prolific writers with lots of code posted
	to the internet. 
	4) In general, any code that gets the job done. 
	
What isn't allowed? 
	1) Direct collaboration with other people in real-time. Why not? Two reasons.
		i) An unfortunate part of university education is that it has a tacit 
		function of reproducing intra- and inter-class hierarchies (though the 
		nice thing is that many other aspects of university erode those hierarchies) 
		and it is effectively illegal for me to not assign semi-individual grades. 
		I let you collaborate on everything else as long as your answers are 
		your own.
		
		ii) In a real world setting, you are unlikely to be able to have constant
		aid from other people; other folks will be busy working on their own 
		tasks, and a lot of coding is, unfortunately, something that you do solo
		and discuss later with others. The most help you will get from other people
		will *very* likely be from their written words (or the written words of
		people who aren't even alive anymore!). So, it's good to get into the 
		habit. You'll be shocked at how generous people are with their time on
		Statalist, StackExchange, the Stata Reddit, etc. */

* PART I: MISSING DATA. 

* In this lecture, to keep things concise, I am going to refer to probability
* in a basic way without expecting you to master the exact meaning. 
* If you would like a better grasp on what "p(A|B)" means exactly, you can see
* the last part of my supplemental lecture from last week, which I believe is
* a pretty nice introduction. 

* 1.0). What to do when data are missing completely at random (MCAR) and how to
	* understand basic probability notation (redux). 
	
	/* If data are MCAR, the probability of B being missing is unrelated to the 
	_values_ of B or any other variables A1, A2, etc.: P(B = . | B, Ai) = p(B=.)
	
	In general, if p(B|A) = p(B), then by def knowing A or "living in a world" in
	which A has occurred does not change p(B). If you visualize a rectangle as 
	the sample space S in which all outcomes occur, this means that the size of
	B relative to S is the same ratio as the intersection of B & A (B ∩ A) to A. 
	And, the same is true for the ratio of A to S: it must be identical to the
	ratio of (B ∩ A) to B. This is illustrated below. */
	
	view browse https://tinyurl.com/independenceprobability 
	
	/* Note that independence only means that p(B|A) = p(B) and p(A|B) = p(A),
	not that p(A) = p(B). Independence is also mutually inclusive; A is
	not independent of B unless B is independent of A (be careful here
	since this is *NOT* true of how we use the word colloquially; you 
	can depend on me while I do not depend on you. Statistically, this
	is not possible, however).  
	
* 1.1) Missing completely at random: the upshot. 

	In other words, if data are MCAR, the probability that we are missing, say,
	the outcome Y is totally unrelated to its (crucially, unobserved) value
	or the values of other predictors Xi -- though it is allowed for the prob. 
	of missing values of Y to be related to the probability of being missing
	on some other variable. 
	
	So, the probability of a person having a missing value on Y is just the 
	probability of anyone having a missing value): 
		p(Y = . | Y, Xi) = p(Y = .)
		
		E.g: everyone who is missing a value of the predictor "value of home"
		is also missing information on "difference between value of home and
		that of neighborhood average"... but this missingness isn't actually
		a function of the value of the home, their age, or their income. 
		The "correlated missingness" is benign because it makes sense that if you 
		forgot to check your home's value, you probably don't also know how it 
		compares to area homes. This also cannot be related to other variables' 
		value, e.g. your income. 
	
	This is the best case scenario: our data is simply a smaller simple random
	sample than we originally had, but there is nothing more troubling than the
	loss of sample size/power. 

2) Missing at random (MAR)

	This implies that p(Y = . | Y, Xi) = p(Y = missing | Xi). In other words, 
	the probability of Y being missing is explainable by values of Xi, which is 
	a predictor. So, e.g., the probability of missing the value of your home *is* 
	related to its value, but once we control for age, it is unrelated: within
	a given age (possibly a bracket), the value of your home is unrelated to it
	being missing. What does that mean? Well, a plausible explanation would be
	that age predicts both your home's value and your propensity to, say, forget
	to bring paperwork to a survey (not picking on younger people here; just
	poking fun at myself, really). So, if being younger makes you both more prob.
	both to have a cheaper house and forgetful of paperwork, maybe once we adjust 
	for that by comparing like-age with like-age (or using multiple regression), 
	an association is not observed between value of home and missing data. 
	
	2a) Ignorability. 
	
	Allison's organization here is misleading. Ignorability is a subset of MAR,
	and it just means that the mechanisms governing missingness and the outcome
	itself aren't the same. 

3) Not missing at random (NMAR) / missing not at random (MNAR)
	
	So, predictably, if the mechanism producing missingness is a function of the
	unobserved values themselves, then we have some trouble. To use our running
	example, now we would say that even after controlling for the effect of age
	on your income and thus one source of your home's probable value, it turns
	out that either some other cause of your home's value -- or just unexplained
	variance thereof -- affects your probability of being missing. 
	
	This is the most problematic situation. 
	
* Diagnosing MCAR, MAR, and NMAR. 
	This is intrinsically tough to do! It is largely speculative because, by
	definition, you lack information about the values of the outcome variable
	for people who are missing. Still, one rough indication is whether the model
	that you choose -- assuming it works for observed values -- predicts a dummy
	indicating missing values on that variable. For more, see here:
	https://www.stata.com/meeting/italy12/abstracts/materials/it12_bartlett.pdf
	*/

sysuse dir // Let's look at other default data-sets besides auto.dta.
sysuse nlsw88, clear 
* Let's say I plan to use information on Y= union status, Xi = {hours, race, 
* tenure}. I'm going to run a very simple model and assuming that there are no
* interactions between these variables. 
reg union hours i.race tenure
* Let's store this model for later use, which is convenient. 
local model hours i.race tenure
	* OK, the model seems to do OK--not worthless. 
gen missing_union = missing(union) // Make a variable for missing union
reg missing_union `model' // Regress union on our model
	* Some relationship here: probably cannot conclude MCAR. But, it may be the
	* case that the effect is minimal (an example is shown shortly). 
	
	* N.b. (relevant to later) that we are not actually observing MAR here. It
	* might seem like we are: we show that missingness is related to the levels
	* of the covariates. But, what we would need to know in addition is that
	* once we control for these variables, p(union = . | union) = p(union = .). 
	* We don't know that since we don't know the union status of the missings.
	
/* PART II: WHAT TO DO ABOUT MISSING DATA IN PRACTICE. 

4) Listwise deletion. 

Well, this part is mostly good news. Stata uses listwise deletion, meaning that
it temporarily omits MVs from *most* numeric analyses (if not all tables), and
this is often the best approach!! "Deletion" can just mean "omission from analysis",
rather than actually dropping them (though this is fine if you are saving a copy
of the original data and are sure that you will use these variables). 

In fact, the reading could be somewhat clearer here. Listwise deletion is often
the only option. For bivariate regression, the only kind that I expect you to do,
the slope is given by COV(X, Y)/(SDx*SDy) * (SDy/SDx). Cancelling and 
simplifying gives COV(X, Y)/VAR(X). Recall that COV is just the average
product of deviations: Σ(Xi-X̄)(Yi-Ȳ)/(n-1). So, if some individual is missing an 
observation on one variable, this is clearly just undefined; Stata's only other
option would be to understand "." in a very "literal" way (recall that in some
settings, Stata thinks of this as a really big number), but it is programmed to
be more user-friendly than that. 

It also turns out that listwise deletion is unbiased even if you have selection
on the independent variables, i.e., missingness is related to the value of the
predictors. The proof is technical -- footnote 1 in the full book has it. Note
the important caveat that if you don't think you can model this relationship
linearly, this is a problem -- but then, so is a simple model in the first place 
problematic. Solution: include more variables. 

So, Stata uses listwise deletion, which is what you should use for your projects.
In general, you should check and see if your variables' summary statistics 
differ significantly when you drop all cases that are not-missing for all of
your variables; report any significant differences! One way to quickly do this is
to make a variable that indicates missing on any variable you play to use, then
run multiple summary statistics with and without a condition on that value. */ 

ssc install missings 
// This is a helpful tool that lets us look at the distribution of MVs overall
// which is slightly unreasonably-difficult in Stata.  
missings report
missings list 
gen missing_key_var = missing(hours) | missing(race) ///
	| missing(union) | missing(tenure)
tab missing_key_var
sum hours race union tenure 
sum hours race union tenure if missing_key_var == 0
	* OK, so, some differences here, but remarkably little difference except for
	* possibly tenure. 

/* ALTERNATIVES TO LISTWISE DELETION

5) What are the alternatives? This we will run through very quickly. You don't 
have to know about these in much detail at all; I just want to give some context.
Some useful things that will very likely come up later for CAR students are gently 
introduced below. 

	5a). Pairwise deletion.
	
	This will only make much sense if you know multiple regression. Let me give
	an intuition that you can still appreciate if not. Imagine a matrix that has
	the same set of variables on the rows and columns. Any given element is the
	covariance between that row and the column. You can get something like this
	in Stata (though not the exact version I'm referring to here) by just
	writing "corr X1 X2 X3" and so on. We'll see this in a moment. 
	
	Stata will report the covariances using all cases that exist for THAT pair
	of variables. So, if there are a ton of missing cases on X1, a few on X2, and
	just a few on X3, the covariance between X1 and X2 will be based on just a
	few cases, as will that between X1 and X3. But, X2 and X3's correlation or
	covariance (difference is just scaling by SDx*SDy) will be based on a large
	number of cases. OK, not too heady so far. 
	
	So, if you do multiple regression -- Y = B0 + B1X1 + B2X2 + ... B3X3 + u -- 
	to get the estimates of the coefficients, you at one point calculate the 
	scary-looking quantity (X'X)^-1 * X'Y. Actually, this is basically just like
	bivariate regression. 
	
	BUT, here is the point. X'X is basically a matrix of those covariances 
	between all variables. Stata's default is to omit all cases missing for any
	variable. Let's see that quickly. */ 
	
	use ./original_data/gss2018, clear
	drop if missing(educ) // I drop cases that are missing on the outcome so that
	// missingness in regression just depends on predictors
	corr paeduc maeduc pasei10 masei10 
	reg educ paeduc maeduc pasei10 masei10 
		// here, n is the same as it was for the correlation matrix
	pwcorr paeduc maeduc pasei10 masei10, obs
		// but, pairwise correlation allows different numbers of ns. 
	
	/* What's wrong with substituting in something like this PW correlation? 
	Cohen and Cohen (1985) give a good description of the problem: basically, 
	you can end up with nonsensical results.
	
	5b). Dummy variable adjustment. 
	
	The idea is appealing: basically, you code a dummy variable D indicating 
	missingness on X1 and a modified variable giving the value of X1 if it is
	missing and *any* constant if it is not and only the estimate on D will change
	with the change of the value of the constant (the reason is complicated;
	it has to do with a trick often used in psychology where predictors are 
	re-coded so that the essential elements are kept but the variables are not
	related linearly or are orthogonal; this makes the estimate of each one
	independent of the others. Here's a quick, more general example of using
	orthogonal predictors. */ 
	
	drop if missing(paeduc) | missing(maeduc) 
		// We don't want to worry about MVs to show the general case. 
	orthog paeduc maeduc, generate(opaed omaed)
		// Stata will automatically produce orthogonal predictors for you :) 
	corr opaed omaed
		// Verify that they are unrelated
	reg educ opaed omaed
		// Try multiple regression with both
	matrix multiplereg = e(b) // store est
	reg educ opaed // Try regression with just opaed
	matrix opaed = e(b) // store est 
	reg educ omaed // Try regression with just omaed
	matrix omaed = e(b) // store est
	mat compare_est = (multiplereg \ opaed, . \ omaed, .)
		// Put them in a matrix (add a col. for the second and third estimates
		// so the matrices have the same dimensions
	mat list compare_est
		// Compare. Voila!
	
	/* Problem? This produces bias when it is done to handle missing values in
	the way described above (Jones 1996).
	
	5c). Imputation. 
	
	This is by far the most common. Some people are very into it. There is
	a wide variety of methods here. 
	
		5c.i) Mean substitution. you can just substitute in the mean, though
		this is trickier than it might seem! The idea is that this does not change  
		the mean because you can write the sum of all the non-imputed variables 
		as (n*xbar), to which you add (xbar), say, j times in the numerator 
		while turning the denominator into (n+j): (n*xbar) + j*xbar / (n+J).
		
		Factor the top and (n+j)*x-bar/(n+j) = x-bar, i.e. the mean is the same.
		
		The problem is that this *does* reduce the variance of the variable which
		creates a big source of bias. Why? VAR(X) = Σ(Xi-X̄)^2)/(n-1) in the sample. 
		So, if you're adding a bunch of zeros to the denominator (b/c the dev.
		for the imputed values is zero of course) while making n larger, this is 
		going to reduce variance. In general, this is the problem. */ 
		
		sum mntlhlth
		replace mntlhlth = r(mean) if missing(mntlhlth)
		sum mntlhlth

		/* Other forms of imputation that are more used but also harder to explain
		
		Hot deck imputation:
		
		Within strata formed by age, sex, etc., sub in missing values w/ a 
		value randomly drawn (with replacement) from the observed values.
		
			Good?: preserves multivariate distribution of the observed data
			Bad? Performs poorly when large number of cases have missing data

		Multiple imputation: 
		For each variable with missing data, form a reg. equation from other 
		variables in the data set. For the missing values, substitute values 
		at random from the conditional distribution of predicted values. 
		
		Repeat the process several times, cycling through the prediction equations 
		and using updated values for the predictor variables.
		
		The result is a complete data set; in this way, create several complete 
		data sets (the convention is 5). Analyze each data set in the usual way
		Average or combine the results using set of rules (Nb that this 
		procedures assumes MAR).  

			Good? We get some variability in our imputation rather than subbing
			a single value, problematic for the reasons given above. 
			Bad? We still have to assume MAR, which is unverifiable because we 
			don't actually observe this. 
				See Sterne et al. (2009) in the BMJ. */
		
* PART III: review. 

* For testing yourself, I recommend trying to get the blank version from Canvas!
* I'll show results as we go along. 
	
* 1. Load the International Survey of Attitudes on Inequality (2009) data from
* your original data folder. 
	use ./original_data/ISSP09_extract_rev.dta, clear

* 2. Give the data set a label describing its contents. “describe” the data to 
	* make sure that data label appears correctly. Make all variable names 
	* lowercase for convenience. 
	
	label data "International Survey of Attitudes on Inequality (2009)"
	d
	rename *, lower
	
* 3. How many observations are in your data?
	
	// There are 10,644 observations, though this is not the number of 
	// distinct individuals: an observation is just a specific datum or set
	// of data recorded at some point in space-time; one person or country can be
	// observed twice or more. Even if that's not true, we should check for 
	// duplicates. 

/* 4. Are there any duplicates in your data (cases that were listed twice)?
	Use the duplicates command to generate a variable that flags duplicate
	observations. Check to make sure that the code identifies dupes. Then,
	if there are duplicates, drop them. Check to make sure that the correct
	observations were deleted. */ 

	duplicates report id 
		// It often makes sense to start with a minimalist approach: does anyone
		// accidentally have a duplicated ID? That's typically bad even if no 
		// other information is duplicated. 
	duplicates report
		// OK, it looks like these are outright duplicates. 
	duplicates tag, gen(IsDupe)
		// Tag them. 
	list if IsDupe == 1
		// Investigate since the number of cases and vars. is small. 
	duplicates drop // drop
	duplicates report // check work 

/* 5. Using the codebook in your data folder, (a) rename V4 to something that 
	makes sense given its content, (b) label the var, & (c) assign value labels.
	“tab” the variable to make sure that the labels and values were assigned
	correctly. */ 
	
	* a) 
		codebook v4 // Not very helpful; let's try the actual codebook. 
		rename v4 country
	* b) 
		label variable country "r's country" 
	* c 
	#delimit ;
	label def ctrylab 156 "156:China" 380 "380:Italy" 392 "392:Japan"
	410 "410:South Korea" 554 "554: New Zealand" 752 "752:Sweden"
    840 "840:United States"; #delimit cr
		* It is sometimes useful to preserve the original numbers from the
		* scheme. Remember that -#delimit- changes the character that tells 
		* Stata where a command ends. It is useful to switch delimiters if you
		* plan to write a few lines, but you might prefer "///". Aesthetic, really.
	label val country ctrylab
	
/* 6. Create a dummy variable called mom_worked that equals 1 if r's mom worked
	when respondents were 14-16 years old and 0 if she did not. Give the var. a
	label. Check its creation. */ 
	
	d v58 // let's get the value label
	tab v58, mis // and look at the full distro, incl. missing values
	label list V58 // list the values
	gen mom_worked = v58 == 1 // We use "truth syntax" to quickly make a dummy. 
	tab mom_worked v58, mis // We check our work; we need to deal with MVs. 
	replace mom_worked = . if v58 >8 // Use original var to handle MVs.
	tab mom_worked v58, mis // Now this looks good. 
	label define mw 0 "mom did not work" 1 "mom worked"
	label values mom_worked mw
	label variable mom_worked "Mother worked when r was 14-16 y.o."
	tab mom_worked
	
/* 7. “tab” the social class variable, V66.  Note that very few people reported  
	being “upper class". Perhaps, because of SDRB, people are loathe to report
	that they are too high or too low on the class ladder. So, let's create a 
	new class variable called class that combines “upper middle class” and 
	“upper class” into one group and all other classes into another. 
	Be sure that all missing values are handled correctly. Attach value labels 
	to this new variable. Check its creation. */ 
	
	d v66 // Get general info and value label
	tab v66, mis // check out var 
	label list V66 // Let's see what numeric values go with what ordinal vals. 
	tab v66, gen(class) // Let's use this method of making a set of dummies. 
	replace class6 = 1 if class5 == 1 
		// Here, we use the dummy for class6 -- upper class -- and make people
		// who are also 1s on class5 (r is "upper middle class") 1s. Now class6
		// represents upper class + upper middle class. Let's rename this. 
	rename class6 upperclass
	label define uclass 0 "popular classes" 1 "upper class"
	label values upperclass uclass
	tab v66 upperclass, mis // Again, we need to deal with MVs. 
	replace upperclass = . if v66 == 9 // So we do. 
	tab v66 upperclass, mis // And now this looks good. 
	drop class?
		/* This drops all variables that start with class and have at least one
		character after them*/ 
	
/* 8. Next, create a table that displays mean values of mom_worked by country and 
	class. Format mom_worked so it does not have an excess precision. 
	
	Interpret your results.*/ 
	
	format mom_worked %6.4f // 
	tab country upperclass, sum(mom_worked) nost nofreq
	version 
		// For whatever reason, -table- got kind of weird with Stata 17; but
		// above I show an alternative. This shows you how to use version 
		// commands, by the way.
	version 16: table country upperclass, c(mean mom_worked)
		// This is an alternative. 
		// -table- is superior to -tabulate- in that we have to spell out the
		// summary stats we want, which prevents stats we don't realy care
		// about from being included automatically. but we may want to see 
		// the Ns. 
	
	* Interp: diff. is generally tilted towards popular class women working
	* more, with the exception of Sweden and NZ (possibly the stronger safety
	* nets there? Maybe a culturally-conservative WC? Hard to say). 
	* The mean is highest in the PRC in both columns, but it is lowest in Italy,
	* so there is no clear connection with relative poverty here (Italy is a 
	* relatively poor European country). 
	
	* By the way, although I won't expect this on the exam, if you want to record
	* a group level property for all members of a given country that indicates
	* the class difference in proportion of moms working, we can do that with
	* the basic tools we have. 
	egen ctry = group(country) 
		// Let's make the numeric values more rational for ease of writing a 
		// forvalues loop. This just assigns the unique j groups of "country" 
		// to the first j natural numbers. 
	tab ctry // examine results
	forvalues j = 1/7 {
		prtest mom_worked if ctry == `j', by(upperclass)
		gen classdiff`j' = . 
		replace classdiff`j' = r(P_diff) if ctry == `j'
		}
		// This loop goes through each value of ctry, does a proportion test for
		// equality of moms working by class which leaves as a result the raw
		// diff. Using the empty shell variable we create in the second step, 
		// we fill in this variable with the raw difference if that country is
		// the one we are testing. We end up with a bunch of pseudo-dummy vars 
		// that are defined only for people in the country we are "on". This 
		// seems pointless, but you will see the point in a second. 
	egen class_momwork_diff = rowmax(classdiff?)
		// Now we get every person in the data set a value of the maximum they
		// had on this set of dummies. That is going to be the value of the only
		// variable that they had _value_ on, their country's diff. in props. 
		// The point of this is that we now encode this information on a single
		// variable, and we can add it into a table. 
	version 16: table country upperclass, c(mean mom_worked mean class_momwork_diff)
	// We can make this even a little bit better with some useless variables
	// that just make the table prettier. 
	separate mom_worked, by(upperclass)
	rename mom_worked0 pop_class_MW
	rename mom_worked1 upper_class_MW
	version 16: table country, c(mean pop_class_MW mean upper_class_MW ///
		mean class_momwork_diff)
		// You can mess with the titles as needed. 

/* 9. Now generate a variable that identifies individuals who completed “above 
	higher secondary level, other qualification” or higher degree versus those  
	who have completed less than this amount of schooling. Call this variable 
	gtsecondary. Check your variable creation. */
	
	d degree
	label list DEGREE
	gen gtsecondary = degree >3 & ~missing(degree)
	replace gtsecondary = . if missing(degree)
	tab gtsecondary degree, mis
	label define gts 0 "no more than secondary" 1 "post-secondary"
	label values gtsecondary gts
	
/* 10. Next, create a table that displays means on gtsecondary by country and 
	class. Format your table appropriately. Use this table to determine which 
	country sees the smallest differences in social class identification by 
	education. Again, consider formatting variables for readability. */ 
	
	format upperclass gtsecondary %6.4f
	version 16: table country upperclass, c(mean gtsecondary freq)
		// So, there are not a ton of people in any of the upper class groups. 
		// We may want to quickly take CIs a quick spot check makes it clear
		// that the PRC has the lowest difference. 
	proportion gtsecondary, over(country upperclass) percent citype(wald)
		// So, we have super big standard errors (as we must with these Ns) and 
		// the estimates are very imprecise for numerically small classes. 
		// We might even want to run a series of proportion tests. 
	bysort country: prtest gtsecondary, by(upperclass)
		* In the PRC, there is only weak evidence that there even is a difference.
	
	* Bonus: You do NOT have to do this for the exame, but this is somewhat 
	* interesting. In fact, we can do this even a bit more suavely using Stata 
	* 17 to see how  significant these differences are. Some of Stata's changes
	* to "table" in SE 17 are somewhat annoying, but this new set of commands is 
	* quite useful and I taught myself it over break, so I figured I would share.
	
	collect clear
	sort country
	collect label levels result lb_diff "LB diff" ub_diff "UB diff", modify
	collect label save newlabels, replace
	collect label use newlabels, replace
	collect style cell, nformat(%4.2f)
	collect r(P_diff) r(lb_diff) r(ub_diff): quietly bysort country: ///
	prtest gtsecondary, by(class)
	collect layout (country) (result)

	putpdf clear
	putpdf begin
	putpdf paragraph, font("Arial",26) halign(center)
	putpdf text ("Differences in education across class and country")
	putpdf paragraph, font("Arial",14) halign(left)
	putpdf text ("International Survey of Attitudes on Inequality (2009)")
	collect style putpdf, width(60%) indent(1 in) ///
	title("Diff. in proportion of higher-ed. grads. across two classes")
	putpdf collect
	putpdf save ./figures/CIsClass.pdf, replace

* 11. Load the CPS 2019 and construct a variable indicating whether someone has
	* any children. 

	use ./original_data/cps2019, clear
	
	* Two methods. First, the simpler. 
	gen haskids = ownchild>0 & ~missing(ownchild)
	replace haskids = . if missing(ownchild)
	tab ownchild haskids, mis
	label define hk 0 "no children" 1 "has children"
	label values haskids hk

	* But what if we just had the indirect information encoded in the set of 
	* variables ch*, indicating whether someone has any children or not in a 
	* certain bracket? This is quite realistic; I just helped one of you
	* with a non-365 question of this general type. 
	lookfor child
	egen isparent = rowmax(ch*)
	tab isparent haskids, mis
		/* This is kind of a funny method. Let's reflect on what it does. We tell
		Stata to take the maximum value of a set of similarly-named vars that
		start with "ch" (and we check that no other variables start this way);
		since these are all dummies, this returns a 1 if *any* var == 1, which is
		what we want: a "yes" on our new var if they have any kids of any age. 
		If all vars ==0 or missing, rowmax returns 0/missing, respectively. */ 
	label values isparent hk
	tab isparent haskids, mis
		* The two methods agree. 

* 12. How does the gender wage gap for hourly workers relate to parental status? 
	
	label define sex 0 "male" 1 "female" 
	label values female sex
		* Annoyingly, this is not labeled in the CPS. 
	
	* Since all of our predictors are dummies, we can do this with a table
	* pretty easily although we don't has the ability to do inference (that said, 
	* w/ a really big data-set, unless you have a massive sample SD, usually any
	* observed difference is significant. This is all you need to show on the 
	* exam, though regression is great if you can do it. 
	
	tab female isparent, summarize(wage1) nofreq nost
		* This is easier to do with table, but the syntax changed significantly
		* between Version 16 and 17, so be careful. 
	version 16: table female isparent, c(mean wage1) row col
		* Very interesting! Being a parent overall has little effect on your wage
		* but that masks the fact that it shows a small but real boost for men
		* and a small but real penalty for women. 

	* Here's how we do it with regression. 
	reg wage1 female##isparent	
	margins female##isparent
	* N.b. that the bottom four terms--which are the only ones that correspond
	* to any actual individual predictions since everyone has to have zero or
	* more than zero kids if they are included in the regression--are the same
	* as from the table above. 
	marginsplot, xdimension(isparent)

* 13. Does the effect of education on wages differ between non-white & white 
	* workers? Try to show this graphically. 
	
	* The simple way: use the existing race variable and conditional commands. 
	d wbho
	label list wbho
	reg wage1 educ92 if wbho == 1 
	reg wage1 educ92 if wbho ~= 1
	* Yes, slopes are different in "common-sense" terms: $1/hour. 
	* This is fine for the test. 
	
	* The fancy way: create a set of dummy variables; use the one that corresponds
	* to white/non-white; quickly drop the other unnecessary dummies with a loop
	* and then run a fully-interacted multiple regression. 
	
	* Consider what follows if you know or would like to know multiple regression. 
	
	tab wbho, gen(white)
	d white?
	rename white1 iswhite
	tab iswhite wbho, mis
	label define iw 0 "non-white" 1 "white"
	label values iswhite iw
	forvalues i = 2/4 {
		drop white`i'
		}
	reg wage1 iswhite##c.educ92
	margins iswhite, at(c.educ92=(0(1)16))
	
	test 0.iswhite#c.educ92 = 1.iswhite#c.educ92
		* This tests the equality of the slopes
	contrast iswhite iswhite#c.educ92,  overall
		* This is another method (note that I can include the intercept). 
		* For more, see this nice article:
		* https://www.stata.com/support/faqs/statistics/chow-tests/
	
	* Technical point since this type of thing often comes up. Not necessary for
	* test. 
	* Note the funny fact that whites are predicted here to have wages that
	* are much lower than non-white people at lower levels of education. How is
	* that possible considering that a simple table of conditional means shows
	* that whites always have higher wages, though the gap does grow with ed.?
	version 16: table educ92 iswhite, c(mean wage1)
	
		* The answer is that in OLS, the residuals must sum to zero globally and
		* are zero by construction (the normal equations or first order conditions
		* start with this assumption, which is much weightier than many realize!)
		* _But_, that does not restrict _regions_ of the observed data's residuals 
		* from having net positive or negative sums. Indeed, if you really think
		* about it, any two variables' correlation is really just the fundamental
		* summed deviation-product with a bunch of weighting: Σ(Xi-X̄)(Yi-Ȳ).
		* There is no reason, even if the variables have absolutely zero corr.,
		* for this sum to be zero for absolutely every i, right? That would be
		* totally weird. So, regions with relatively few observations which are,
		* however, not especially far from the mean (meaning, they exercise
		* little influence on the total), are especially prone to having net-
		* negative (positive) residuals, which can cause the predictions for
		* those values. 
		
		* Let's see that in action. The regression equation gives strange
		* predictions for whites/non-whites under educ92 = 6 (which really means
		* 10th grade -- I'm cheating a bit and treating educ92 like it is really
		* quantitative). Let's look at the residuals for this partitioning of the
		* reals. 
		reg wage1 educ92 if iswhite == 1
		predict whiteresiduals, resid
		replace whiteresiduals = . if iswhite ~= 1
		sum whiteresiduals if educ92 <=6
		scalar SRwhiteslowered = r(sum)
		sum whiteresiduals if educ92 >6
		scalar SRwhiteshighered = r(sum)
		di SRwhiteslowered
		di SRwhiteshighered
			* So, the partioned sums are (necessarily) equal to zero but they
			* are individually fairly far off: there are large outliers in the
			* case of the higher-ed individuals, but the mean residual is a full
			* $2.50 in the case of lower-education whites, meaning that the 
			* regression equation significantly under-predicts their wages. 
	
	* Graphically: this is a lot of code, but I just want you to be able to 
	* understand what's going on here; remember that you can absolutely just copy
	* relevant portions of my code on the exam. So: do not memorize this. Bookmark
	* it and make sure you understand why I punch stuff in where I do. 
	
	* First, here is the basic syntax, with minimal cleaning up. This is fine
	* for the exam, though you should try to add some of the easier 
	* modifications (jitter, a title, etc.) since I expect that on the paper.
	
	scatter wage1 educ92 if iswhite == 1 || ///
	scatter wage1 educ92 if iswhite==0 || ///
	lfit wage1 educ92 if iswhite == 0 || ///
	lfit wage1 educ92 if iswhite == 1
	
	* Now, let's make this code messier but the graph much cleaner.
	#delimit ; 
	scatter wage1 educ92 if iswhite == 1, color("red%25") jitter(5) msymbol(oh)|| 
	scatter wage1 educ92 if iswhite==0, jitter(5) color("blue%25") msymbol(th) ||
	lfit wage1 educ92 if iswhite == 0, lpattern(shortdash_dot) lcolor(black) ||
	lfit wage1 educ92 if iswhite == 1, lpattern(longdash_dot) lcolor(black)
	legend(order(1 "white" 2 "non-white" 3 "non-white" 4 "white")) 
	title("Effects of education upon wages for hourly workers") 
	xtitle("Education") ytitle("Hourly wage");
	#delimit cr
		
		/* All of what I did there is review in principle, though I show some new 
		options here, but I want to spell this out one more time since some of
		you might be more prone to use this document for reference than a lecture 
		(which is fine). 
		
		First, we need two conditional scatterplots, which we join with the
		pipes. We add a jitter or else this will look a bit "columny" because 
		education cannot take non-integer values in this data-set. We also use
		the legend to name the elements; you should always double-check the order,
		but the general rule is that the order is just the order of the commands;
		this is another reason to use the "color" option (the first reason is
		that it is fun, and you should take some ownership of the aesthetic side
		of things: use a style *you* like): you can more easily check that all
		parts are correctly labeled rather than memorizing the way that Stata
		automatically assigns colors, which is a bit obscure (see below). We also
		change the symbols for visibility, though part of the messiness here is
		just the data themselves; "oh" is "hollow circle" and "th" is hollow 
		triangle; you can see more below. I also generally put the scatter plot
		with less overall variance on top (here, that is for non-white workers)
		so that it is easier to see the difference in variation. 
		
		We also need two lines of best fit (-lfit-) that are also conditional, 
		and it is often more effective to make these lines black but give them
		different patterns to distinguish them. These appear in order on the 
		legend as well. Finally, we give the various axes different titles. 
		
		One last thing worth noting is that I have also made the symbols only 
		25 percent opaque to make them a bit easier to see. This is a type of
		graph that is common to see in products of R. */
		
		* 1. Color scheme command: 
			viewsource scheme-s2color.scheme
		* 2. Symbol help file: 
			help symbolstyle 
		* 3. Line pattern help file:
			help linepatternstyle 
		* 4. Color options:
			help colorstyle 
	
* 14. Create a dummy for Scandinavian birth. Use the restricted definition
	* (Norway, Sweden, Denmark) for the sake of time. Check your work!
	
	d penatvty 
	label list cob
	gen scandi_birth = penatvty == 106 | penatvty == 136 | penatvty == 127
	label define sb 0 "born elsewhere" 1 "born in Scandinavia" 
	label values scandi_birth sb
	bysort scandi_birth: tabstat penatvty, stat(p1 p25 p50 p75 p99 ) varwidth(25)
	
	* Tricky things to note: value label does not follow pattern we've usually
	* seen; check this with "describe"! Also, the order of these countries is
	* in some places rational, in other places seemingly random. Use CTRL+f to 
	* efficiently look them up if the codebook isn't handy. Finally, it is tough
	* to check our work here since a twoway table would be massive. So, we try a
	* trick we've seen before. These percentiles aren't statistically meaningful
	* because this is a qualitative variable, but it does give us a sense of the
	* range of values.
	
* 15. Turn weekly pay into a dummy (so, meaning that someone has any weekly
	* income) and compare that to wage1. Are there any surprising results?
	
	gen ispaidweekly = weekpay>0
	label define ipw 0 "no weekly pay" 1 "receives weekly pay"
	label values ispaidweekly ipw
	tab ispaidweekly, sum(wage1)
	tab wage1 if ispaidweekly==0
		* There are some improbable values here. It seems like the plurality of
		* people misinterpreted the question and wrote (somewhat correctly) that
		* their hourly wage was zero. The other people are probably mistakes.
		* That is OK -- it's a huge data-set, so this many people having typos
		* is probably to be expected. 

* 16. Finally, visualize the overall difference in distributions for white and 
	* non-white individuals.
	
	* There are a bunch of ways to do this. Here are a few simple ones that 
	* you can use on the exam. By the way, note the use of -local- again. 
	local T The distribution of wages among white and non-white US residents
	graph box wage1, over(iswhite) title(`T',size(medium)) name(box, replace)
	
	* vioplot also works, but it is a little slow with such a large dataset. 
	
	separate wage1, by(iswhite)
	#delimit ;
	qqplot wage1?, rlopt(lcolor(black)) msymbol(dh) mcolor(red%25) 
		title(`T', size(medium)) xtitle("White wages", size(medium))  
		ytitle("Non-whitewages", size(medium)) 
		note("Note: straight line is a reference line for white wages;" 
	"red diamonds are coord.-pairs. Xi=quantile Qi for white wages" 
	"and Yi=quantile Qi for non-white wages") name(qqplot, replace);
	#delimit cr
		* I added a note here because these graphs are difficult to interpret
		* and you cannot add grids with qqplot AFAICT (just qnorm), which would
		* make things clearer. This is especially tricky to interpret because the
		* bounds for wage1 happen to be [0, 100]. 
	
	* Here are a couple of fancier ways to try for your projects. 
	
	twoway (histogram wage1 if iswhite == 0, color(red%30) ///
	title(`T', ///
		size(medium))) (histogram wage1 if iswhite == 1, color(green%30)), ///
		legend( order(1 "non-white" 2 "white")) name(hist, replace)
		
		/* So, what's going on here? Basically, we plot two histograms on top
		of each other, using the same transparency trick from before (the %number
		business). We also add a title and modify the size so that it's not
		too large, which in this case is the default; we also label the legend
		in the way that we've done. */ 
	
	* Here's another way to do this: 
	
	kdensity wage1 if iswhite == 0, generate(p1  q1)
	kdensity wage1 if iswhite == 1, generate(p2  q2)
	gen zero = 0 
	twoway rarea q1 zero p1, color(red%35*.8) || rarea q2 zero p2, ///
		color(midblue%35) title(`T', size(medium)) ytitle("Smoothed density") ///
		legend(ring(0) pos(2) col(1) order(1 "non-white wages" 2 "white wages")) ///
		name(kdens, replace)
		
	
