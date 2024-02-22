capture log close
clear all 
set more off
version 16 
cd ~/desktop/SOC365sp22
log using ./do/Lecture12, text replace 

/* task: recall some important facts about project management/learn to program
   author: Griffin JM Bur, 2022-04-24
   SOC 365, Spring 2022, Lecture 12.*/
   
* STRUCTURE. 
	* I. Good reminders on project management from this chapter. 
	* II. Programming.
		* II.i. The big idea.
		* II.ii. Scalars and local macros. 
		* II.iii. The rules of local macros for strings and numbers. 
		* II.iv. A brief discussion of global macros. 
		* II.v. The use of macros in loops, some examples. 
			* II.v.a. Example 1. Looping over a numlist (revisited example). 
			* II.v.b. Example 2. Looping over a variable list. 
			* II.v.c. Example 3. Numlist + return lists make computations easy 1
			* II.v.d. Example 4. Numlist + return lists make computations easy 2 
			* II.v.e. Example 5. Getting around Stata's limitations with loops.  
			* II.v.f. Example 6. Loops let us speak simply and precisely.

/* I. Good reminders on project management from this chapter. 

I know that it's tough to keep up with the reading and this chapter was fairly
long, but much of it is actually just a good review of project management skills
that happens to be included in this chapter and does not have much to do with
programming proper. Let's review those tips. 

1. Make sure you are saving a README file in your project folders that lays out
where everything lives. 

2. Consider naming draft versions of your files in the way that I label files
for our class: beginning with the date in YYYYmmDD format, which automatically 
sorts your files for you if you just have alphabetical sorting. 

3. Back up your data! We talked about this during the first week a bit. You can
e-mail files to yourself, use cloud storage (e.g. Google Drive), buy an external
hard drive (my recommendation), etc. 

4. Start including version control in your do-files. We haven't done that much
for our class since most of you downloaded Stata around the same time and are
running similar versions, but even in our class, not all of use the same version
(I often work in Stata 16) and they are _not_ fully compatible (some commands
stop working or aren't available in later versions). You can set the version for
the session in the way that I did at the start of this document. 

5. -assert- is a good way to check your data for errors that forces you to stop
and pay attention to data-cleaning problems. If we're using the CPS, we can, say,
quickly check that all hourly workers are paid a non-negative wage...*/
use ./original_data/cps2019, clear
assert wage1 >=0
	* This is good news. But, let's see what would happen if we checked for a 
	* similar error. I'm leaving this as a comment because the whole point of
	* -assert- is to stop the .do-file in its tracks when a contradiction exists.
	* assert wage1>0
		* We've discussed this specific issue with the CPS before a number of 
		* times...just showing for example's sake. 

/*
6. Note that you can run .do-files from within other .do-files if you need to; 
this is often useful for the sake of combining distinct tasks (such as data 
management vs. data analysis). Simply type "do [file path]". */ 


/* II. Programming. 

* II.i. The big idea 
	The theme for part II of the lecture is this: programming in Stata is a very
	useful tool. What is "programming"? Aren't we already programming? Yes--but
	what is meant by "programming" in the Stata context is generally the use of
	loops in a way that involves a more direct human-machine communication than
	use of commands: we effectively write very customized instructions to Stata
	in a way that is more of a logic-chopping exercise than what we've done.

	To do this, we need to begin with a bit of a discussion of the concept of a
	macro. We've already seen macros when I've briefly shown you loops before, &
	we have made additional use of scalars, which are very similar to macros. The 
	thing that unites scalars and macros and makes them different from vars. is 
	that in an _actual_ set of data, a variable is no longer a concept/abstract 
	property, but a concrete _list_ of observations: it is a vector. By contrast,
	scalars and macros keep track of information much more flexibly: it can be a
	literal scalar, a number "in one dimension" (i.e., what we colloquially mean
	by "number" without further explanation), a string, etc. It does not have to 
	be a list of numbers of the same dimension as our data or some subset thereof. 

	This is handy for a lot of reasons, as I've mentioned before: it is often 
	confusing to store information that is _not_ a variable in a variable, usually 
	just because that is easier to do in Stata when you're first starting out. */ 

* II.ii. Scalars and local macros. 

	* Let's start with the concept of a local. This is like a scalar: it is a
	* locally-defined expression. Recall: scalars are useful because they allow
	* us to store numeric results with easily-recallable names. E.g., my demo
	* that shows how to get regression results by "hand" in Stata makes use of
	* scalars: it really allows us to use Stata to simultaneously show abstract
	* representations of mathematical operations (employing a formula) which also
	* keep track of specific examples of those variables. It's pretty neat, 
	* especially for teaching. Scalars are also useful when it would be confusing
	* to store a number as a vector (i.e., a var).
	
	* For example, as I've mentioned before, there is not a huge difference b/n
	* the following three ways of, say, marking people who are old enough to be
	* retired in the GSS. 

	use ./original_data/gss2018, clear
	* Method 1. Just write the number. Downside: since the varname is a terse
	* abbrevation, we may forget what this means or why we wrote 66. Upside: it
	* is the quickest. 
	gen SSelig_1 = age>66
	* Method 2. Make retirement age a vector of length n with all entries == 66. 
	* Downside: it may be confusing to store this as a variable since it is not
	* actually a variable property of individuals! Upside: we write down the 
	* meaning of the number 66. 
	gen retirement_age = 66
	gen SSelig_2 = age>retirement_age
	* Method 3. Make retirement age a scalar (vector of length 1). Downside: we
	* have to remember that we have done this (or write "scalar list"). Upside:
	* we are storing a single number as a number with a meaningful name. Another 
	* downside that rarely comes up -- this meta-example is an exception -- is  
	* that the scalar should not have the same name as a variable; Stata 
	* prioritizes variables if there is a conflict. 
	scalar SS_retirement_age = 66
	gen SSelig_3 = age>SS_retirement_age
	label define retire 0 "not eligible for SS" 1 "eligible for SS"
	label values SSelig_? retire
	table SSelig_? // These come to the same result. 

	* So, scalars are very useful if you want to store a number under a name for
	* the sake of a project. They are also useful for storing the exact numeric
	* value of an outcome from the return list, as I've shown before, which allows
	* us to avoid rounding and copying numbers by hand. For example, say that we 
	* want the 25th percentile of sei10 on hand. We can simply write...
	qui sum sei10, d
	scalar sei10p25 = r(p25)

	* But, scalars have a limitation: they can only be used places where Stata
	* expects a variable and they cannot easily be "invoked" in broader contexts. 
	* What if we wanted to, say, store and then actually use in a command the
	* list of the variables we hope to use in a lot of different specifications 
	* of the same model? 
	local predictors maeduc paeduc pasei10 masei10
	reg educ `predictors'
		* Pretty neat! 
	
* II.iii. The rules of local macros for strings and numbers.
	
	* 1. First, we had to define the macro and run it with one click. If you 
		* try it sequentially, you'll see Stata has "already forgotten" what 
		* predictors mean. That is because you are, in a way, creating a new 
		* do-file every time you run a portion of one. Notably, to get a macro 
		* to last for an entire session, you'll want to either type the local 
		* into the command window or use a global macro (more later). 
	
	* 2. The odd quotes (with a left tick and right-quote) are required to 
		* "de-reference" or call up the content of the local. 
		local canonicalprogram hello, world!
		* di canonicalprogram 
			* <-- this won't work b/c "canonicalprogram" is not a scalar or var
		* di `canonicalprogram' 
			* <-- this also won't work b/c Stata tries to evaluate the string
			* as numeric information in this context, but strings need to be
			* surrounded by double quotation marks. 
		di "canonicalprogram"
			* <-- this "works" b/c Stata can always repeat a string you feed it
			* but it is not what we actually put into the macro. 
		di "`canonicalprogram'"
			* <-- this is the thing we actually want in context: a reprint of
			* the contents of the macro. 

	* 3. We actually do not need an equality symbol when we define the macro,
		* and it can actually cause confusion to do this if we have numbers. We
		* also do not even need quotation marks around the contents, but it is
		* generally not a bad idea to have question marks. So, I would generally
		* define locals without an equals sign but with quotation marks. 

	* Macros with numbers. 

	* The important thing to note when we involve numbers is that there is now a
	* difference between -local- when it is followed by an equality sign and when
	* it is not. If we do _not_ include an equality symbol, Stata evaluates the
	* contents of the macro when we just have the "ticks" and it simply reprints
	* the expression as a string if it is enclosed in double quotation marks. 
		
		local testing1 2+2
		di `testing1'
		di "`testing1'"
		
	* If we _do_ include "=", Stata evaluates the expression either way.
		local testing2 = 2+2
		di `testing2'
		di "`testing2'"
		
		* You can make things even more complex by toggling whether the original 
		* expression is in quotation marks; this actually causes Stata to evaluate
		* numeric expressions as if you did _not_ have an equals sign, whether 
		* you do or not. 
		local testing3 "2+2" 
		di `testing3'
		di "`testing3'"
		local testing4 = "2+2"
		di `testing4'
		di "`testing4'"
		
	* The bottom line: you will make mistakes in programming; one reason that we
	* use -local- (as opposed to -global-, to be discussed momentarily) is that 
	* it only needs to be defined for a very specific purpose, so you can play
	* around with results until you get what you want; if it doesn't work in some
	* other context, that's OK--toggle that other macro as needed. If you want a 
	* useful general syntax, I would say that no-equals-sign and quotation marks 
	* are often your best bet since they let you decide whether to invoke a  
	* numeric expression as a string or something to be evaluated. 

	* Let's put it all together with an example. 

		local pie "an occasional treat"
			* With strings, there is no harm in adding double-quotes, and it can
			* clarify things; n.b. that -help macro- officially recommends this. 
		local pi = round(_pi, 0.00001)
		local three = sqrt(9)
		local this sqrt(9)
		di "Pie is `pie' while pi is `pi', which is pretty close to `three' ..." ///
			"which we can get in Stata by typing `this'."

* II.iv. A brief discussion of global macros. 
	* So, if we have "locals", presumably we must also have globals, and we do.
	* What makes these different? Simply put, they are available across a wider
	* range of situations than loclas. 
	
	* In one respect these are very useful. They don't require you to run blocks
	* of code defining the macro in order to invoke the macro. But, they do have 
	* the downside that they override other globals you might have going in other
	* do-files. More seriously, they will stick around in your session until you
	* close and restart, even if you change data-sets
	
	use ./original_data/gss2018, clear
	global uhoh "globals are awfully pervasive"
	clear all
	use ./original_data/gss2018, clear
	macro list 
		// It's still there! To clear it out, we would need to close and reopen
		// or use this command. 
	macro drop uhoh // "_all" is another handy option. 
	macro list
	
	* You should generally avoid these because they can be, so I'll just note 
	* easy to mishandle, so I'll just note in passing that they are called with
	* a dollar sign ($) rather than the paired ticks. 
	
* II.v. The use of macros in loops. 
	
	* OK, so, all of that is not terribly difficult, and it might well have
	* seemed tedious. The ability to save some typing might seem neat but possibly
	* not worth all of this effort. Let's now do some things with macros that are 
	* _not_ tedious and actually very powerful indeed. 
	
	* The general idea that we will employ here is that of a loop. A loop says
	* to Stata "please execute this task multiple times", and we can define the
	* number of times and over which values it should iterate the command, much
	* like -bysort- (which is basically a simple loop). The two main types of 
	* loop we will see are -foreach- and -forvalues-. The latter is kind of a 
	* special case of the former, but the difference is not huge. For the sake
	* of time, we'll just stick to these. 
	
	* The connection to macros is that the loop syntax lets us effortlessly
	* define a new local macro over which we actualy carry out the loop. You do
	* not need to define this new macro in advance, but you should take care to
	* refer to it in the way we learned above; generally, this macro will be a 
	* kind of index letter or some way to refer to a variable. 
	
	/* The general syntax is this: 
		foreach [local macro] in/of [some list] {
			[do something, probably with explicit reference to the macro]
			} 
		
		Note that you need to end the first line of the loop with an open brace,
		write the commands you want looped on an entirely new line (>1 lines
		are possible; they will be executed sequentially unless you join them
		with "///", just like we have already seen). */ 
			
	* N.b that you don't, strictly speaking, need to follow "foreach [macro]" 
	* with anything other than a list, but sometimes Stata will get very pedantic
	* about this. So, instead of the first very-general syntax listed below, 
	* consider using one of the syntaxes below it to provide "hints" for Stata: 
		* foreach lname in any list {
		* foreach lname of local lmacname {
		* foreach lname of global gmacname {
		* foreach lname of varlist varlist {
		* foreach lname of newlist newvarlist {
		* foreach lname of numlist numlist { 
	
	* II.v.a. Example 1. Looping over a numlist (revisited example). 
	
	* Let's revisit an example from earlier in the semester that might help us. 
	* For example, we saw earlier in the semester some bio-marker data from the
	* MIDUS project. This is a really interesting case of data shape. Are these
	* long or wide? 
	
	use ./original_data/MIDUS_biomarker_2012-16, clear
	
	* So, these certainly appear to be wide data because we have data recorded
	* on the same subjects for multiple days. But, it seems clear that it would
	* be quite tedious to reshape them given the many different time intervals
	* that were involved; this is a rare case where we may want to leave the 
	* data wide. So, what if we then wanted to, say, more-rationally name the
	* blood pressure variables? Let's now investigate that syntax more.
	
	* Again, the basic idea is that "foreach" tells Stata some index (here k), 
	* some command (here just -gen-), and some domain over which to execute it 
	* (here, for the number-list 1 to 3). 
	
	* Now, however, we know that we are defining some local macro k which takes
	* on values between one and three inclusive. We also see that we have to use
	* the unique "tick syntax" -- `[local macroname]' -- to invoke this macro in
	* the loop itself, which we do once in the naming of the new variables and
	* another time in referring to the old variables. Basically, k is just an
	* index letter here (and I've used a letter that is often used to represent
	* such indexes in mathematical notation to emphasize this). 
	
	* What this tells Stata to do is to set k equal to 1, 2, and 3, and then at
	* each juncture, create a variable called systolicBP[current number] which
	* equals the old variable RA4P1F[current number]S, which just happens to be
	* the pattern for how these variables were named. 
	
	foreach k of numlist 1/3 {
		gen systolicBP`k' = RA4P1F`k'S 
		}
	list RA4P1F1S systolicBP1 in 1/5, abb(20)
	list if RA4P1F1S ~=systolicBP1
	
	* Here's another example that we've seen before but with a bit more 
	* discussion of the back-end. Note that we can change the name of the local, 
	* and we can again use a common index letter.
	
	* Let's make a set of sleeping pills variables. The same basic syntax is at
	* work here, and note also that we can label the values of all these vars.
	* What's going on here? (Hint: the logic is similar to what we saw above). 
	foreach t of numlist 1/7 {
		gen sleepingpills`t' = RA4AD`t'7
		label values sleepingpills`t' RA4AD17 // all value labels are same here
		}
	list sleepingpills5 RA4AD57 in 1/5, abb(20)
	
	* II.v.b. Example 2. Looping over a variable list. 
	
	* Let's say that we wish to quickly get a picture of the different racial and
	* gender distributions of hourly wages for each category on the CPS, using
	* the most-detailed of race -- this could be a tedious task to do by hand. 
	
	* Don't worry about the immediately-following part: it is a good example of 
	* using loops to do otherwise-difficult things--here, we quickly make
	* a set of dummy variables from a single polytomous variable that have as 
	* variable names the corresponding value-label, which is something that 
	* should not be so difficult in Stata--...but it is trickier than what I will
	* expect from you. 
	
	use ./original_data/cps2019, clear
	forvalues j = 1/6 {
		gen race`j' = wbhaom == `j' // This part hopefully makes sense though
		local newname = strtoname(`"`:label wbhaom `j''"', 1)
		rename race`j' `newname'
		}
		
	* So, here, we're going to loop over variables in a way that greatly reduces
	* the amount of work which we need to do. Let's run this and appreciate the
	* immediate impact.This part I would like you to understand fairly well. 
	
	foreach var of varlist White-Mixed {
		histogram wage1 if `var' == 1, color(red%30) ///
		title("Distribution of wages among `var' residents", ///
		size(medium)) saving("./figures/`var'wages", replace)
		}
		
		* Now, let's break down the code. What's going on here? First, we tell 
		* Stata what to loop over: "for each variable in this variable list, 
		* make a histogram with the title "Distribution of wages among [var]
		* residents") and save this to /figures folder with an appropriate name.
		* Loops are generally pretty _intuitive_ -- they are things that make the
		* appeal of a digital computer very clear -- and the trick is getting
		* very _exact_ about the plan and then translating it into language; many
		* times, it is a question of figuring out the order of operations, whether
		* you need nested loops, etc. 
		
	* Let's also look at how we can quickly tell Stata to combine these graphs
	* and accumulate them into one larger graph. Here, we add a local within
	* the loop called "raceslist". raceslist is a local that consists of its 
	* past string (and Stata fortunately just gives this a null value if it has
	* not yet been defined) plus the current string. To show this accumulation,
	* I also tell Stata to display (as a character) the current race-list which
	* we can see in our output. Finally, we also told Stata, in addition to 
	* saving graphs to our /figures folder, to store the graphs in memory under
	* the name "[variable]". Finally, writing "graph combine [varlist]" puts all 
	* of these together in one graph, allowing us to examine them. 

	foreach var of varlist White-Mixed {
		histogram wage1 if `var' == 1, color(red%30) ///
		title("Distribution of wages among `var' residents", ///
		size(medium)) saving("./figures/`var'wages", replace) ///
		name(`var', replace) 
		local raceslist `raceslist' `var'
		di "`raceslist'"
		gr combine `raceslist'
		}
		
	* II.v.c. Example 3. Numlist + return lists make computations easy, part 1. 
	
	* This isn't a particularly difficult example, but it involves a new use of
	* a returned number and a new concept. Let's suppose that we wanted to make
	* centered variable for ease of interpretation and then run a series of 
	* regressions where we add predictors in bit-by-bit.
		
		* Centering vectors is a good idea for many applications; in regression,
		* it is most useful when we have interactions with continuous predictors
		* and would like our model to a meaningful zero. For example, if our
		* model is the following, the coefficient on citizen alone is hard to
		* interpret because education is unlikely to ever be zero. If we center 
		* wages, the coefficient on citizen is then interpretable as the effect 
		* of becoming a citizen when you have the mean education. See Wooldridge,
		* Introductory Econometrics, pp. 198ff. for more on this. It also makes
		* it very easy to understand regression as n-dimensional geometry. We 
		* won't do any of that here for simplicity, but it is very useful.
		
			* Wage = B0 + B1*(educ) + B2*(citizen) + B3*(educ*citizen)
	
	order uhoursi hourslw educ92 age, after(wage4) 
		// putting vars in order just makes things easier 
	foreach Xi of varlist wage1-age { 
		qui sum `Xi' 
		// we can suppress output--we just run this to get the return list
		gen c_`Xi' = `Xi' - r(mean) 
		// we subtract out the mean, stored in the return output as "r(mean)"
		}
	local preds c_uhoursi c_hourslw c_educ92 c_age // make a list of predictors
	foreach Xi of local preds { 
		local accumu_preds `accumu_preds' `Xi'
		// Now, we make a local list within the loop that stores the list of
		// _current_ predictors: it starts with the list itself (which is empty
		// at first, importantly!) plus the current predictor. Then, at the end
		// of this command, the current predictor has been added to the existing
		// list. The next time Stata adds a predictor, there will be two items
		// added to the list, etc. 
		reg wage1 `accumu_preds', nohead
		// The header output is very interesting, but it can be suppressed if it
		// would be a distraction in some contexts. 
		}

	* II.v.d. Example 4. Numlist + return lists make computations easy, part 2. 
	* We might also, say, write a loop to quickly tag the Tukey-rule outliers for
	* any variable for which they make sense, which is another task in Stata that
	* might be considered unnecessarily complicated--but loops make it tolerable. 

	use ./original_data/cps2019, clear
	local keyvars educ92 wage1
	foreach var of local keyvars { 
		qui sum `var', d
		local iqr = r(p75) - r(p25)
		local ub = [r(p75)+(1.5*`iqr')]
		local lb = [r(p25) - (1.5*`iqr')]
		gen outlier_`var' = [(`var' > `ub') | (`var' < `lb')]
		}
	set scheme tufte
	local notoutlier "if outlier_wage1 == 0 & outlier_educ92 == 0"
	local wageoutlier "if outlier_wage1 == 1"
	local edoutlier "if outlier_educ92 == 1"
	scatter wage1 educ92 `notoutlier', jitter(5) msymbol(oh) mcolor(green) || ///
		scatter wage1 educ92 `wageoutlier', jitter(5) msymbol(dh) mcolor(red) || ///
		scatter wage1 educ92 `edoutlier', jitter(5) msymbol(th) mcolor(blue) ///
		legend(order(1 "not an outlier" 2 "wage outlier" 3 "education outlier"))
		
		* Note that we do not need quotation marks around the macros because in this
		* specific setting, Stata knows to expect a string -- it is just the normal
		* conditional statements which we are used to seeing here. 
		
		
	* II.v.e. Example 5. Getting around Stata's limitations with loops. 

	* We can also make Stata quickly produce types of tables it otherwise does
	* not want to do very willingly. I showed this with -collect- several weeks
	* ago, but we can, for example, quickly make a threeway table filled with
	* CIs (you can do this with the svy: suite of commands in Stata, but I'm not 
	* totally sure if I'll have time to teach survey weights). 

	gen wage_UB = . 
		// We do stuff that can't/shouldn't be looped, e.g. making a single new
		// variable, before running any loops. 
	gen wage_LB = . 
	levelsof(wbhaom), local(races)
		// What this does is create a macro recording the number of distinct 
		// values of wbhaom. This is useful so that we don't have to hand count
		// the levels, especially if they happened not to be numbered with the 
		// first k natural numbers. 
	levelsof(female), local(sexes)
	foreach i of local races { 
		foreach j of local sexes {
			ci mean wage1 if wbhaom == `i' & female == `j'
			replace wage_UB = r(ub) if wbhaom == `i' & female == `j'
			replace wage_LB = r(lb) if wbhaom == `i' & female == `j'
			}
		} 
		* Note that this is a case where we have a loop within a loop: we have
		* Stata first loop over the levels of races before looping over levels
		* of biological sex. Then, for each unique combination of the variables'
		* values, we take a CI of wages and deposit the lower and upper bounds,
		* stored in r(lb) and r(ub), in new group-level variables called wage_UB
		* and wage_LB; then we just take the conditional means of those two vars
		* in a two-way table of race and sex. 
		
	table wbhaom female, c(mean wage_LB mean wage_UB) format(%4.2f)
	
	* To do this correctly, you'd want to set the survey weights for your data,
	* but to match the un-weighted data above, we'll just tell Stata that we have
	* simple random sampling with the first command and, then, with the second
	* command, we'll use the svy prefix to add in CIs. 
	svyset _n
	svy: mean wage1, over(wbhaom female)

	* II.v.f. Example 6. Loops let us speak simply and precisely.
	* We can also do things that we have done somewhat imprecisely before, or
	* using a syntax that required us to be more specific or sometimes required
	* study of some strange details (e.g., -autocode- and -recode) ... and these
	* often came with value labels that were misleading. 

	gen age_bkt = .
	local i = 1 // We'll use this as an index letter
	forvalues lowerbound = 16(5)85 {
		// Here we tell Stata to store every fifth number from 16 to 85 in a
		// macro called "lower bound". 
		local upperbound = `lowerbound' + 4
		// Now we define a macro _within_ the loop that is the current value of
		// the macro lowerbound plus four. 
		replace age_bkt = `i' if inrange(age, `lowerbound',`upperbound')
		// We give the new variable age_bkt the value of the index if it is b/n
		// the current lower/upper-bounds. This part doesn't matter too much but
		// simplest/best practice is to number the distinct k categories of a 
		// polytomous variable with the naturals 1...k. 
		label define agecohort `i' "`lowerbound' to `upperbound'", modify
		// Finally, and this is probably the most useful part of this, we can
		// easily make reasonable value-labels. First, we tell Stata to add a
		// value-label for the current value of the index which is the numeric
		// value of the lower-bound "to" the upper-bound, adding the option 
		// "modify" so that we update it. 
		local i = `i' + 1
		// Here we just update the counter so that "i" increases in value each
		// time. We could also use nested loops here, but it is more work.
		}
	label define agecohort 14 "older than 80", modify
		// We have some top-coding here so we need to change the last bracket. 
	label values age_bkt agecohort
	label var age_bkt "Age cohort"
	table age_bkt, c(min age max age)
		// This checks out. 
