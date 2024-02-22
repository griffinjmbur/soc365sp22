capture log close
clear all 
set more off
cd "~/desktop/SOC365sp22"
log using ./do/Lecture6, text replace 

/* task: review of descriptive statistics and inference
   author: Griffin JM Bur, 2022-03-07
   SOC 365, Spring 2022, Lecture 6.*/ 

/* This do-file shows how you can approach the analysis of a pair of qual. vars.,
a pair of quant. vars., a pair of quant/qual. vars., and multivariate analysis. 

As you'll see when I post the full assignment, you have quite a lot of flexibility
with the project and *BY NO MEANS* do you need to try every technique here. This
is more of a reference guide. Also, much of this is, in theory, a review of your
prerequisite course in introductory statistics. At the end, I do include some
material that you might find useful if you have taken 361 and know multiple
regression, but you aren't responsible for this material. If you want to try
multivariate analysis out without having taken 361, you can just do what our 
reading for this week shows and do so informally without inference. 

Don't fret about the length of this do-file; this shows a lot of techniques that
can substitute for one another. */

* Structure -->
* 0. General introduction to variable types/clarification of K&K. 
* I. Qualitative variables (both pred. and outcome). 
	*i. Univariate analysis. 
		* a. Numeric analysis. 
		* b. Graphical analysis
	*ii. Bivariate analysis. 
		* a. Numeric analysis
		* b. Graphical analysis
* II. Quantitative variables. 
	*i. Univariate analysis. 
		* a. Numeric analysis. 
		* b. Graphical analysis
	*ii. Bivariate analysis (two quant. vars.)
		* a. Numeric analysis. 
		* b. Graphical analysis
	*iii. Quant outcome, qual. predictor. 
		* a. Numeric analysis. 
		* b. Graphical analysis
* III. Multivariate analysis. 
	*i. Graphical methods for multivariate analysis 
	*ii. Informal multivariate numeric methods for those who didn't take 361
	*ii. 361 or very-comfortable students only: multiple regression

* Note: generally, you should avoid qual. outcomes and quant. predictors since 
* those are uniquely tricky unless you reach out to me. I can give you my notes
* on the so-called linear probability model which is probably the easiest to use. 
	
/* Some general references. 
1) Stata cheat sheet for graphs: 
	https://tinyurl.com/StataGraphCheatSheet 
2) My lecture slides on data presentation: 
	* view browse https://tinyurl.com/GraphingData360
* 3) My lecture slides on two-way tables
	* view browse https://tinyurl.com/twowaytables360
* 4) My lecture slides on measures of assocation 
	* See L5, L6, L7 of this folder. 
	* view browse https://tinyurl.com/SOC360folder */ 

* 0. General introduction to variable types/clarification of K&K. 
* Let's begin by reviewing the kinds of variables that exist.

view browse https://tinyurl.com/GraphingData360
	
	/* So, takeaway: qual. vars. are those which can only be, at most, weakly-
	ordered but they don't have even-spaces between possible values of the var.
	Quant. vars have at least that; some (interval) do not have meaningful zero
	values, while others (ratio) do. 
	
	_Discrete variables_ are those that take on a finite number of possible 
	values; in theory, this is totally separate from the qual/quant distinction,
	although qual. vars tend to be more-discrete in many data-sets 
	(e.g., citizen-status, race, as opposed to wage, wealth, age). An exception 
	might be "r's favorite song" or something like that. 
	
	_Continuous variables_ have an infinite number of possible values. In 
	practice, true continuous variables are rare (time might be one, as could be
	something like "profit rate of a firm"). And, all actual, finite datasets 
	have vars. with a finite number of observed values, by definition so even 
	truly-continuous variables aren't observed with infinite possible values. 
	
	The upshot is this: the qual/quant distinction tells you what type of 
	technique should be used. Many quant. techniques (means, correlations) make 
	little sense (ordinal vars) or no sense (nominal vars) on qual vars., while 
	many qual. techniques, though technically meaningful, are impractical and 
	often useless for quant. vars (e.g., a two-way table of income measured to 
	the cent and education will be terrible to look at and understand). 
	
	The continuous/discrete distinction is somewhat redundant to the qual/quant.
	-- if a scatterplot would look dumb because the variables are "very discrete"
	you might have qualitative data anyways! -- but when it's not, it is 
	generally more about aesthetics. Number of kids and number of cars are both
	quantitative variables, but they are highly discrete in practice, so a 
	scatter-plot might look kind of silly. 
	
	The book merges these two things by calling quant. vars. "many category" vars
	and qual. vars "few category" vars. These are related and similar concepts,
	but they are not the same.*/ 

* I. Qualitative variables. 
	* We'll suppose that we are interested in whether or not someone has a bed
	* partner or roommate is related to their perception of security. 
	*I.i. Qualitative univariate analysis. 
		* I.i.a. Qualitative univariate numeric analysis. 
		* Tabulating 
		/* There is not that much that you can do numerically with qual. vars. 
		tabulating is one of those things. */
		
			// Let's look at all the stuff you can do with tabulate. 
			use ./original_data/MIDUS_biomarker_2012-16, clear
			
			// let's look at this slightly awkwardly-conceptualized question: 
			// do you have a bed partner or a roommate? 
			codebook RA4S9
			// OK, we have some missing values. Let's handle those first after
			// we rename our variable something more convenient. 
			rename RA4S9 bedpartrmmt
			label list RA4S9
			mvdecode bedpartrmmt, mv(7 = .d \ 8 = .m) 
			label define RA4S9 .d "don't know" .m "missing", add
			tab bedpartrmmt, mis // We only do this to check.
			tab bedpartrmmt // This is generally how we should present these.
			
			* This ^ is pretty self-explanatory for us, but I include it for 
			* completeness since it is a main way to describe qual. vars. 
			
			/* You can also carry out confidence intervals on each of
			these possible values or do a chi-square goodness of fit test. The 
			latter requires you to supply a hypothesized distribution, which 
			usually isn't that useful since "how should I know the distribution"; 
			you can see my DAP II project code in the SOC 360 folder if you 
			want to try it, though. 
			
			Let's stick to the approach where we try confidence intervals on a 
			set of dummy variables representing each possible outcome. */ 
			
			tab bedpartrmmt, gen(BPRMdummy)
				// Remember this way to make a set of dummies? ^
			ci prop BPRMdummy?, wald
				* I use the Wald option because this will match hand calculations
				* using the formulae you likely learned in lower-level courses.
				
				/* Also, one notable mistake in the code from last week: in 5.12, 
				I say that if you use an asterisk wildcard, Stata “ignores 
				anything after it”. This is a comment on an earlier draft of 
				the lecture, where I showed the problem in using “ d RA4AD*”
				to show us only sleeping-pill related variables. But what I  
				actually showed (and described correctly in the comment) was 
				“d RA4AD*7”. This has a subtler problem: it will only look for 
				variables that start  “RA4AD” and end with “7”, but it allows  
				any length of characters between the two (b/c of the asterisk; 
				the question mark only allows one character; the syntax can get
				a bit tricky, and it’s not the same for all commands, but
				-rename group- in the Stata Manual is useful). */ 

			* You could rename these as well to make them clearer. Let's make a 
			* new variable for that since the old name, though vague, is
			* convenient, and thus we may want to keep it.
			gen NoRoommatePartner =  BPRMdummy1
			gen RMPTOtherRoom = BPRMdummy2 
			gen SameRoomNotBed = BPRMdummy3
			gen SameBed = BPRMdummy4 
			order NoRoommatePartner RMPTOtherRoom SameRoomNotBed SameBed, ///
				after(BPRMdummy4)
				* This puts all the new variables in order and right after their
				* less-evocatively-named dummies. 
			ci prop NoRoommatePartner-SameBed, wald level(99)
				// Now this shortcut works nicely. 
			/* How to interpret this? Let's pick the last one, same bed. Using 
			a method that captures the population parameter somewhere in its 
			boundaries 99 percent of the time, between about 54 and 63 percent
			of the population has a roommate or partner sleep in their bed. 
			
			Why does that work again? CLT tells us all possible sample proportions
			are Normally-distributed; this theoretical -sampling distribution- 
			has a standard deviation, called the standard error to distinguish it
			clearly, given by population SD/sqrt(n) (this changes slightly for 
			means, but it rarely matters), and so, if we add/subtract 2.33 SDs
			(this is in Table A or can be found using invnorm) in units of our
			variable, we get the boundaries for the population parameter: if I
			will almost always be within 2.33 SDs of the mean, the mean will be
			within 2.33 SDs of mean the exact same percent of the time. */ 
			
			* We can also fix the default variable labels 
			label variable BPRMdummy1 "no roommate/bed partner"
			label variable BPRMdummy2 "in other room"
			label variable BPRMdummy3 "in room, not bed"
			label variable BPRMdummy4 "in bed"
			* ... and apply these to the "parent" var
			label define RA4S9 1 "no" 2 "in other room" ///
				3 "in room, not bed" 4 "in bed", modify 
			* We'll do the same thing but with less commentary for security. 
			codebook RA4Q7M // Inspect var
			d RA4Q7M // Get value label
			label list RA4Q7M // Inspect value label
			mvdecode RA4Q7M, mv(7 = .d \ 8 = . \ 9 = .i) // Change num. to MVs. 
				* This is just another way to code missing values. 
				* We can apply a value label if we want -- this code won't do it
				* for us -- or we can just leave them unlabeled. 
			rename RA4Q7M security // Rename for convenience
			tab security, mis // Check missing value
			tab security
			tab security, gen(securitydummy)
			ci prop securitydummy?, wald
		 
		* I.i.b. Qualitative univariate graphical analysis
			* Bar charts, pie charts
			
			/* Bar charts are a nice way to show the distribution of a qual. 
			variable graphically. A bar chart is effectively a probability mass
			function (PMF), which puts the set of possible-outcomes on the x-axis
			and the probability of observing those outcomes as heights on the
			y-axis. The bars are just there for visual reasons (this is not true
			for histograms; more later) and could be replaced by dots. 
			
			The way K&K suggest making bar charts is a little unconventional. 
			I'll show their method first, which takes a set of dummy variables as
			the primary input of -graph bar-. We already have that set made
			above for both variables. The reason to do this is that the graph
			bar syntax will graph the mean of all variables listed directly 
			after it; unfortunately, the mean of the bedpartrmmt variable is 
			just a meaningless scalar (try -graph bar bedpartrmmt- to see that 
			this is bad), but the mean of a set of dummy variables is the 
			proportion of people taking on a value of 1 on those variables, which
			is better. */ 
			graph bar bedpartrmmt // do not do this!
			graph bar BPRMdummy?, ///
				legend(label(1 "No bed partner/roommate") ///
				label(2 "Partner/RM in other room") label(3 ///
				"Partner/RM in room not bed") label(4 /// 
				"Partner in same bed")) 
			* That said, this is probably easier -- here, we just omit any 
			* primary input from the command and use our regular polytomous var.
			* This makes it easier to correct the "Afghanistan first, Zimbabwe
			* last" problem. 
				graph bar, over(bedpartrmmt)
				// Let's fix those value labels. We'll make the text smaller
				// and also wrap them over two lines and sort by height. 
				graph bar, over(bedpartrmmt, sort(1) descending ///
					label(labsize(small)) ///
					relabel(1 `""No bed partner/" "roommate""' ///
					2 `""Partner/roommate" "in other room""' ///
					3 `""Partner/roommate" "in room not bed""' ///
					4 `"Partner in same bed"'))
					* Syntax for wrapping is complex. Enclose the entire label in
					* single quotes, then double quotes. -Then- enclose each
					* line in a further pair of its own double quotes.
					* The "1" after sort just sorts by the first variable given.
			* This also works:
				graph dot BPRM*, ascategory
			// How can we make this more aesthetically-pleasing? Probably the
			// simplest way is to 
				graph dot BPRM*, ascategory ///
					title("Have a bed partner or roommate?") ///
					yvar(relabel(1 "`: var label BPRMdummy1'" ///
					2 "`: var label BPRMdummy2'" 3 "`: var label BPRMdummy3'" ///
					4 "`: var label BPRMdummy4'")) ylabel(0(0.1)0.7)
					* "ylabel" says "mark a tick starting at zero and going 'til
					* 0.7 at every 0.1. 
			// And the same alternative method as we saw for bar graphs works. 
				graph dot, over(bedpartrmmt) ///
					title("Have a bed partner or roommate?") ///
					yvar(relabel(1 "`: var label BPRMdummy1'" ///
					2 "`: var label BPRMdummy2'" 3 "`: var label BPRMdummy3'" ///
					4 "`: var label BPRMdummy4'"))
			
	*I.ii. Qualitative bivariate analysis.
		* N.b. I'll cover quant/qual. below since we'll generally use "quant."
		* techniques in this class for that set up. 
		
		*a. Numeric bivariate analysis for two qual. vars. 
		* Two qual. values of outcome and predictor: basic analysis
			* As the book notes, you can just compare the distributions by 
			* using a two-way table. When percents are calculated, TW tables give 
			* the unconditional distributions of either outcome -- a list of the 
			* probabilities of each discrete event -- on the row and/or col. 
			* margins (hence "marginal probabilities") and in the table are 
			* the probabilities of the columns (rows) conditional on the value
			* of the row (column), hence "conditional probabilities. 
			* I'm going to assume everyone understands how two-way tables work, 
			* more or less. If you feel shaky on this, my very comprehensive 
			* lecture notes are above. 
			
			* Here are four ways of doing a two-way table with these variables. 
				
				* These first two have the same numbers, but the matrices are
				* transposed, giving just an aesthetic difference -- though note
				* that one way is often *much* more readable. 
				tab bedpartrmmt security, row
				tab security bedpartrmmt, col
					* What's the story here? People who have bed partners seem
					* to feel notably more security than those who do not, among
					* other things. The small size of the intermediate rows is
					* problematic; we'll deal with that soon. 
				
				* But, in both of these two cases, we change the story! Now, we
				* can't really come up with too good a causal story -- does 
				* your sense of security really cause your bed-partner status? --
				* but maybe we just consider it predictive. 
				tab bedpartrmmt security, col
				tab security security, row
					
					* I want to also explain a tricky bit about two-way tables
					* on this note. 
					view browse https://tinyurl.com/twowaytablefinerpoint
			
		* Two qual. values of out./pred., inference: two-group proportion test
			/* If we have two possible values of the outcome, as is often the
			case, we can conduct a two-group difference in proportions test to 
			see if these data are consistent with no difference between the 
			proportion of outcome P across groups Q1 and Q2 in the population.
			
			E.g., is there a difference in the proportion of ppl who almost-never
			feel secure by whether they have a bed partner or not? Once again,
			we already have our dummy variables from before. */ 
		
			label define bprmdummy4 0 "no bed partner" 1 "has bed partner"
			label values BPRMdummy4 bprmdummy4
			label define SECURITYdummy1 0 "secure at least sometimes" ///
				1 "almost never secure"
			label values securitydummy1 SECURITYdummy1
			prtest securitydummy1, by(BPRMdummy4)
		
			/* How do we interpret this? If there really were no difference in
			the proportion of the outcome between the two groups, we would see a
			result this extreme or more about one percent of the time, so we 
			can probably reject the null hypothesis of no difference b/n grps. */
			
			/* BTW, here is a visualization to help you remember how sampling
			distributions work. This represents the distribution of all possible
			sample statistics under the null that there is no difference in prop.
			between the two groups. This is Normally-distributed according to the
			CLT. The standard error under the null is .0147684, so 1.96 times
			this gives the cutoff-points under the standard alpha of 0.05, 
			rounded to +/- 0.029 and marked on the graph. The area under the 
			curve in blue represents the probability of observing sample stats
			beyond those extremes (i.e., "alpha"); the area in red represents the 
			probability of observing sample differences this extreme or more if 
			the true pop. difference is zero; it's about one percent of the area. 
			
			You do *not* need to make a graph like this in your work, which takes
			even me about 10 minutes to make and edit. This is just pedagogical
			and meant to help you understand. 
			
			BTW, this is an example of how to use the "delimiter" option to 
			quickly change how Stata understands where a command ends. This allows
			us to avoid extending a command with "///" many, many times. You must
			always run the change of delimiter command with any code where it 
			is changed; "#delimiter cr" returns us to the carriage return 
			delimiter, the one we're familiar with. */ 
			
			#delimit ; 
			twoway function y=normalden(x/.0147684), 
			xlabel(-.038 -.029 0 .029 .038) dropline(0) 
			range(-.0590736 .0590736) color(dknavy) || 
			function y=normalden(x/.0147684), range(.0378324 .0590736)   
			recast(area) color(red) || function y=normalden(x/.0147684), 
			range(-.0590736 -.0378324) recast(area) color(red) || 
			function y=normalden(x/.0147684), range(.02894606 .0378324) 
			recast(area) color(dknavy) || function y=normalden(x/.0147684), 
			range(-.0378324 -.02894606) recast(area) color(dknavy) 
			xtitle("Difference in proportions") ytitle("Density") 
			title("Two-tailed test, {&alpha}=0.05") legend(off)
			; 
			#delimit cr
		
		* Multiple possible values: chi-square test. 
		
			/* If we do not wish to reduce the number of possible values to two, 
			we can just do a chi-square test of independence, which gives us the
			probability of results such as these were the variables independently
			distributed. 
			
			Let's do a preliminary check to see if we can do the chi-square
			on these two variables without modifying either. We'll use the 
			"expected" option on the tab[ulate] command to see if our
			expected counts meet our two rules: no more than 1/5 of the cells
			should be <5 and none should be less than 1.*/
			
			tab bedpartrmmt security, exp
			
			/* Uh-oh! We fail that check. How to move forward? I suggest merging
			values of the problematic variable as appropriate. For the sake of 
			this analysis, we might be willing to merge "same room, not in bed"  
			and "different room", the very-small/atypical set-up. */ 
			d bedpartrmmt
			label list  RA4S9  
			replace bedpartrmmt = 2 if bedpartrmmt == 3
			label define RA4S9 2 "not in bed", modify
				* Be careful about modifying value-labels. 
			tab bedpartrmmt // checks out
			
			tab bedpartrmmt security, exp // Now we're good to go
			tab bedpartrmmt security, chi2 exp cchi2
				* These options...1) tell Stata to perform a chi-square test
				* 2) supply expected counts, and 3) list the chi-square contrib.
				* under the actual count for each cell, allowing us to see which
				* cells give us sig. results and why (what direction was the 
				* deviation of observed from expected). 
				
				* Interpretation? If these variables were independent, we would
				* see a two-way table this far from independence or farther only
				* about 0.1 percent of the time just by chance. In particular,
				* people with roomies or partners who don't share a bed help 
				* us to reject the null b/c they are disproportionately insecure.
				* Same with "no BPRM" + "sometimes" and "in bed" + "sometimes". 
			
			*b. Graphical bivariate analysis for two qual. vars. 
			* Spineplots: these basically trump segmented bar charts, IMHO. They
			* are almost self-explanatory, which is one very nice thing about them
			* so I'll skip the commentary for space here. 
			ssc install spineplot 
				// ^ How to install use-written commands 
					* (written by the ubiquitous Nick Cox)
			spineplot security bedpartrmmt, xlabel(, angle(45) axis(2)) 
				* This looks pretty good, but we may want to change the variable
				* label for readability, which is the default y-axis label
			label variable security "'How often do you feel secure?'"
			label variable bedpartrmmt "'Have a partner or roommate?'"
				* Writing these ^ as quotations makes things slightly clearer. 
			spineplot security bedpartrmmt, xlabel(, angle(45) axis(2)) 
			
			* You can also play around with _paired_ bar charts using the dummy 
			* strategy from before. 
			graph bar securitydummy?, over(bedpartrmmt)
			* Once again, let's aestheticize this. 
			graph bar securitydummy?, over(bedpartrmmt) /// 
				title ("How often do you feel secure?") ///
				b1title("Partner or roommate?") ///
				legend(label(1 "almost never") label(2 "sometimes") ///
				label(3 "often") label(4 "almost always"))
				
			* Here's another option that re-orders the grouping. I'll leave the
			* aesthetic clean-up to you all. 
			graph bar, over(bedpartrmmt) over(security)
				* Note that this method is just like inverting conditional p(x)
				* in a two-way table: it can still give correct results, but 
				* we have to be careful. Here, people with a bed partner are the
				* majority in most categories just b/c they are the majority 
				* overall--we need to know the marginal probability of having a
				* bed partner to make sense of this. 
				

			// Let's save these data since we did a lot to them and move on. 
			save "./modified_data/2022-03-07 biomarker exploratory", replace
		
* II. Quantitative outcome. (Throughout, if you are using a categorical pred.,
* the univariate techniques from above work. I put that type of analysis in 
* _this_ section because the bivariate techniques for quant/quant work well). 
	
	// We'll change up the data-set here.
	use ./original_data/cps2019, clear
	*II.i. Univariate analysis. 
		*II.i.a. Quantitative univariate numeric analysis. 
			/* I'm going to assume that you feel comfortable with the concept of
			a mean and standard deviation. These ideas are pretty intuitive, 
			though if you'd like a deep dive from me, you can see SOC360fa2021
			Lecture 3 (e.g., if you've always wondered "why do we square the 
			deviations?", this lecture is perfect for you). */. 
			
			* --> view browse https://tinyurl.com/centraltendencyandspread
			
			/* Usually, doing _inference_ about the mean is also appropriate;
			typically, a confidence interval is best for doing inference about the 
			likely population parameter's value unless we have a specific reason 
			to test some specific hypothetical value of the population (in which
			case, do a t-test). That kind of test is, in this case, more common 
			in the bivariate analysis, where we typically report both the 
			t-statistic and the CI. 
			
			Inference about population standard deviations is more complicated; 
			you can just report the sample SD.
			
			Let's calculate a confidence interval then. */ 

			ci mean wage1

			ci mean age 

			/* Interpretation given above. Note that means are t-distributed 
			rather than z-distributed; the reason for this is complicated, and
			the two converge quickly (difference becomes unimportant in almost 
			all cases where n>1000). The reason for this is complicated and not
			super important; basically, two parameters are estimated for inference
			about a mean (mean itself and SD) while SD of a dummy variable is 
			defined by its mean (the proportion). */ 
		
		*II.i.b. Quantitative univariate graphical analysis. 
			/* Histograms.

			Density histograms are actually the “purest” form of histogram, tho'
			their height is somewhat hard to interpret; it's roughly equivalent
			TO the physical concept of density (mass per volume), except here we 
			have the probability per unit of the variable, p(x)/x. 
			So, the height represents the rate of change of the probability of 
			observing a particular value of the variable for some X=x. 
			
			That's a little abstract, but the gist is easy enough -- if it's tall 
			in some interval [Xj, Xj+k], there are relatively more data grouped
			in that interval. 
				
				Optional comment:
				(More precisely, a histogram is basically a graph of a discrete 
				probability density function (PDF); in turn, a PDF is just 
				a graph of the rate of change of the cumulative distribution 
				function  at different values of the variable, i.e. the PDF is 
				the derivative of the CDF). 

			The area of a density histogram is easier to interpret: it is prob.
			of observing a given bin: we find the area of rectangles with height 
			p(x)/x and multiply them by some width x, leaving a quantity in 
			units of p(x)--easy to interpret! :) 
			
				Optional comment: 
				This is quite literally the same reason that the area under the 
				curve of f(x) on the interval [a, b], where F'(x) = f(x), 
				represents the difference in heights on F(x) given by F(b)-F(a).
				It's actually a really nice way to understand the FTC!*/
				ssc install cdfplot
				gen logwages=log(wage1) if ~missing(wage1)
				cdfplot logwages, xlab(-2(0.5)6) name(CDFlogwage, replace)
					* name() stores graphs in memory; saving() saves them to disk
				kdensity logwages, xlab(-2(0.5)6) name(PDFlogwage, replace)
				gr combine CDFlogwage PDFlogwage
					* We'll talk about kernel density estimation in a second. 
			
			/*As the book notes, Stata is constrained to equal-width density
			histograms, which makes all of this a bit abstract, tho' it's worth 
			mentioning since "density" often confuses people and it's the default. 
			Density histograms in Stata will, w/o special tools, basically just 
			show fractional histograms: try setting width(1), e.g.*/ 
			hist educ92, width(1) dens xlab(0(2)20) ylab(0(0.02)0.3)
			tab educ92
			* Note that the CPS' educ variable is scaled weirdly, though, so 
			* HS grad equals 9, etc. 

			/* Also, Stata can make percent, frequency, & fractional histograms. 
			Frequency histograms constrain the bar heights to sum to n; fraction 
			histograms constrain the bar heights to sum to unity; percent 
			histograms constrain the bar heights to sum to 100. These all just
			differ by a scaling factor. 
			
			These histograms don't look too great. We'll see in a moment how we
			can make them look better by toggling the number of bins. */ 
			
			hist educ92, percent 
			hist educ92, frequency
			hist educ92, fraction

			* The question of the number of bars is tricky. It's easy to go wrong!
			hist educ92, bin(20) title("An excessively-sparse histogram")
				* Though it seems reasonable, this produces an awkward result bc 
				* it implies some possible values of educ92 weren't observed, 
				* which is false if we tabulate educ92. 
			hist wage1, bin(2) title ("An excessively-'blocky' histogram")
				* This is clearly too-few bins. 

			/* A commonly-used choice with histograms is the "discrete" option,
			which tells Stata to use as the number of bars the # of possible  
			values of the variable. This is a nice fix when the default looks 
			weird for various reasons, e.g. */ 
				hist educ92, discrete
				* But not always
				hist wage1, discrete
					* In this case, the variable is *too* continuous for this to 
					* work. The peaks are probably due to a general sociocultural 
					* tendency for people and firms to round when dealing with $. 
				hist wage1
		   
		   /* Also, note that some people prefer true density histograms with 
			equal probabilities and possibly unequal heights and widths, however. 
			These work best with *very* continuous variables. 
			Warning: Stata complains if your variable has "tied quantiles", i.e. 
			two quantile (presumably percentiles or thousand-quantiles) have the 
			same value of the variable.*/ 
	
			ssc install eqprhistogram // courtesy Nick Cox
			eqprhistogram wage1
			
			* Box-plots
			/* What are these? They show distributions of quant. vars. 
			The box is the inter-quartile range: p(75) - p(25).  
			Whiskers represent the bounds for the Tukey rule for outliers: 
			p75+(1.5*IQR) and p25-(1.25*IQR). Dots are outliers on this def'n.
			
			Here's an example of a very-roughly Normally-distributed variable. 
			Note what the box plot looks like. */ 
			
			graph box logwages
			// And here's an example of a very skewed variable. 
			graph box wage2
				/* An aside: If the smallest (largest) value in the data-set is 
				not a lower(upper)-bound outlier, the whiskers are truncated
				at whatever value those min/max are. E.g. ... */
				gen sillyexample = runiform(0, 10.333)
				sum sillyexample, d
					gen upperbound = r(p75)+(1.5*(r(p75)-r(p25)))
					count if sillyexample>upperbound
					* So, we have no upper-bound outliers and the whisker 
					* truncates at exactly the maximum, 10.33
				graph box sillyexample
				* and, it is possible that you won't even have a whisker
				replace sillyexample = 4 if sillyexample <5
				graph box sillyexample
			
			/* Kernel density estimation. */ 
			
			/* These basically estimate PDFs for quant. vars. The book's 
			discussion is good, though a bit technical; one way to think of this
			is that for any given X, we figure out how many observations are
			within some interval "in the neighborhood of" X. We end up with 
			basically a kind of (pseudo-)infinitesimal histogram without bars.
			The details can get a bit wonky here; you can consider it a type of
			moving average, in a certain way, though I'd rather you
			focus on other details that are slightly more accessible. Basically,
			these produce nice, clean pictures of distributions. */ 
			
			hist wage1, kdensity
			* We can also add a Normal density curve, BTW
			hist wage1, kdensity normal
				// Pretty far from Normal here, obviously. 

			/* Violin plots. */ 
			* We can combine box and kdensity plots, with densities replacing 
			* the box.
			ssc install vioplot 
			// Again, you can install most user-written commands this way.
			
			vioplot logwages in 1/5000
				* I restrict the range here b/c vioplots can take a long time
				* to make and the CPS is huge. 
				* Log wages are relatively Normal; salaries ("wage2") are not!
			vioplot wage2 in 1/5000
			
			/* Quantile plots, Q-Q plots, and qnorm plots */ 
			
			/* A single quantile plot basically just gives the CDF, only flipped
			so that, while a CDF has the values of our variable V on the x-axis
			and the cumulative probability p(V>v)on the Y, a quantile plot has 
			cumulative probability on the x-axis and the values on the Y. 
			
			Confusingly, Stata's "quantile" comand doesn't actually really show
			that...but this is a somewhat obscure use of a quantile plot. What
			is more common is a qnorm plot. Basically, we calculate percentiles 
			for a Normal distribution with the mean and SD of our data, then plot 
			that on a coordinate plane, with the Normal quantiles on the X-axis 
			and the quantiles of our variable on the Y. We plot a Normal for 
			reference, which of course has to be the line Y = X. OUr actual data 
			can vary, though; so, when we have the fuzzy blue line that is off 
			the thin blue line in that area, our variable has a value for those 
			quantiles that is different to the Normal. 
			
			In short, it assesses Normality. */
	
			qnorm logwages 
				// again, pretty close to Normal, though we have some left skew
			qnorm wage2 
				// This is more clearly right-skewed. 
		
	*II.ii. Bivariate analysis (two quant. vars.)
		*II.ii.a. Graphical analysis
			* i. Scatterplots 
			/* Here I changed data-sets. Sorry that this might seem abrupt -- I
			wrote parts of the code almost a week apart and forgot which set I 
			had used earlier. */ 
			
			use "./modified_data/2022-03-07 biomarker exploratory", clear
		
			* Let's look at the good work index, first cleaning it up. 
			rename RA4QSO_GW goodwork
			inspect goodwork 
			sum goodwork, d
			// Just investigating a bit
			label list RA4QSO_GW // Look for MV
			tab goodwork, mis
			recode goodwork (8 = .)
			tab goodwork, mis
			* Now let's look at the stress variable 
			rename RA4QPS_PS stress
			inspect stress
			label list RA4QPS_PS 
			sum stress, d
			tab stress, mis
			replace stress = .m if stress == 98
			tab stress, mis
			
			* OK, now we can introduce a scatter plot, which is, fortunately,
			* pretty easy to understand conceptually: observations defined on
			* any two variables can be turned into coordinate pairs in R^2 and
			* plotted using those variables as single-dimension spaces or axes, 
			* giving a rough sense of the pattern between them. 
			scatter stress goodwork
				* Uh-oh--the number of digits is also a bit annoying
				format stress %4.2f
			* Let's also add a jitter and line of best fit while we're at it. 
			scatter stress goodwork, jitter(10) || lfit stress goodwork
				* The jitter option adds noise to the plot that simulates the
				* actual density of observations -- when you have data that are
				* quant. but not-terribly-continuous, a common point -- say, dad
				* had 12 years ed. on X-axis and so did mom on Y-axis -- should
				* have many points "stacked" atop it but we cannot see this in
				* two dimensions (R^2). 
			* We can also add a fractional-polynomial fit, though I won't go 
			* through the numbers here. * I'll talk about the numeric side of 
			* linear regression soon.
			scatter stress goodwork, jitter(10) || fpfit stress goodwork
				
			/* We can also use contour plots, which provide us with another way
			of simulating that density. Think of it as a view from directly or 
			almost-directly above a mountain. You can kind of see some sides of 
			the slopes, but your eye is basically perceiving “layers” parts of 
			the mountain as concentric circles.
			
			More formally, a contour plot takes a function z=f(x, y) and fixes
			z at various different values ("heights"); then we draw the resulting
			two-dimensional curve projected onto the Cartesian plane.
				More on that logic is here: https://tinyurl.com/jointPDFs*/ 
			 
			ssc install bidensity // One of several user-written contour commands
		
			bidensity stress goodwork, levels(10) /*levels(#) dictates number of
			distinct values on the z-dimension, i.e. the third dimension that 
			you can't actually see here, that are simulated by the figure 
			with circles. */ 
			
			/* Here's an example with a tighter relation for reference using
			weight and height. */ 
			
			scatter RA4P1B RA4P1A if RA4P1A>125, jitter(10) ///
				|| lfit RA4P1B RA4P1A if RA4P1A>125
			bidensity RA4P1B RA4P1A if RA4P1A>125, levels(15)
			
		*II.ii.b. Numerical quantitative bivariate analysis. 
		
			/* Let's briefly review how regression works. Here's my 360 lecture
			https://tinyurl.com/regressioninference. What is regression in short,
			though? It's a way of modeling the variation in some outcome variable
			Y as a function of some variable X (or a set of variables; we'll get
			there in a second). Our criterion is that we want to minimize the
			sum of squared residuals (the distance between a point and its
			predicted value); it turns out that in the bivariate case, the slope
			of the regression line (or line of best fit) is given by the sample
			correlation coefficient _r_ multiplied by (Sy/Sx), where S is the
			sample standard deviation. */ 
			
			reg stress goodwork
				
			/* How to interpret this? Under the null hypothesis that stress and
			goodwork have no linear relationship in the population, we would
			see a slope this small or smaller approximately one percent of the
			time--we halve the p-value for a one-tailed test since Stata's 
			default is two-tailed--but our model fit is a bit poor -- we can 
			explain less than one percent of variation in the outcome. So the
			variables are related, but the good work index is not especially 
			useful in explaining stress linearly, at least without other 
			variables included in the regression.
			
			Remember that regression slops also come from sampling distributions.
			Here is ours. */ 
			
			#delimit ; 
				
			twoway function y=tden(848, (x)), xlabel(-2.36 -1.645 0 1 1.96,
			labsize(small)) range(-4 4) dropline(0) color(dknavy) || 
			function y=tden(848, (x)), range(-4 -2.36) recast(area) 
			color(red) || function y=tden(848, (x)), range(-2.36 -1.65) 
			recast(area) color(dknavy) 
xtitle("Standardized distribution of{it: b}{sub:1} under H{sub:0}: {&beta}{sub:1} = 0") 
			ytitle("Density") title("") 
			subtitle("One-tailed test and {&alpha}=0.05") 
			legend(off) saving(regttest2, replace) 
				; 
			#delimit cr
			
		*II.iii.a. Bivariate num. analysis (quant. outcome, qual. predictors)
			
			/* Here, you might think of situations such as the difference in
			amount of stress between men and women. This can be handled with a
			two group t-test or ANOVA, but I would recommend just converting 
			your predictor to a dummy and doing a regression, which makes things
			substantially easier. 
			
			When I discussed dummy variables a few lectures ago, I mentioned
			some of these facts, but just to quickly review, if you do a simple
			bivariate regression of a quant. outcome on a dummy predictor, the
			result is equal to (one kind) of t-test of a group difference in 
			means; the coefficient is the difference between the group coded as
			zero (or omitted value) and the group coded as one (the included
			category). The intercept is the mean for the 0-group; the intercept
			plus the coefficient is the mean for the 1-group. */ 
			
			* Let's first make sex a true dummy variable. I won't annotate this
			* data-cleaning since it's old hat by now. 
				label list RA1PRSEX
				sum RA1PRSEX,d 
				gen female = RA1PRSEX -1 if ~missing(RA1PRSEX)
				label define fem 0 "male" 1 "female"
				label values female fem
				tab RA1PRSEX female, mis
			
			reg stress female
			/* Interp? Roughly zero chance of a coefficient this far from 
			zero in either direction or more (halve the p-value for a one-
			tailed test, as you probably know) if no difference in stress 
			between men/women in the population. Men's mean stress score is 
			21.59; women's is 23.31. */ 
				
			* We can see how this relates to a t-test, BTW. 
			ttest stress, by(female)
		
		*II.iii.b. Bivariate graph. analysis (quant. outcome, qual. predictors)
			
			* Note that in some cases we can compare distributions of quantitative 
			* variables across categorical pred. (which is hard when the pred.
			* is quant.) using vioplots, boxplots, and comparative histograms. 
 
			* E.g. note that we can make comparative histograms.
				hist stress, by(female)
					* OK, so, this is not super helpful. What about...
				twoway (histogram stress if female==1, color(red%30)) ///        
				   (histogram stress if female==0, color(green%30)), ///
				   legend( label(1 "women") label(2 "men"))

			* ...or box-plots... 
			 
				graph box stress, by(female)
			
			* ... or vioplots...
				vioplot stress, over(female) title("Stress level by sex") ///
				ylabel(10(5)50) 
				
			* ... or Q-Q plots ... 
				* Let's quickly make two new variables that give women's and 
				* men's stress
				separate stress, by(female)
				sum stress?
				qqplot stress?
			* ... but other methods effectively just give us a scalar measure 
			* of the outcome (such as the mean), e.g. bar graphs and dot plots
			
				graph bar stress, over(female)
				graph dot stress, over(female)
			
				/* The book is really jazzed about dot plots, but sometimes they
				are a little too parsimonious. Not, always, though...-->*/ 
			
*III. Multivariate analysis. 
	/* So, some of you may want to do this type of analysis and not have taken
	361, which is fine -- that's basically a prerequisite for doing multivariate
	analysis with inference, but you can just do simple descriptive stats for
	this part of the analysis. There are a variety of ways to do this well; I'll
	let you have some leeway here since these are, by definition, non-standard 
	techniques. I'd like to see your first attempt on your initial submission 
	of descriptive stats, tho', so I can make sure you're on the right track.
	
	Below are some examples; below _that_ is a quick refresher on multiple reg 
	*only for those who feel up to it*. It's not tested. */ 

	*III.i. Graphic methods for multivariate analysis. 
	// Let's start by showing a technique we've seen before, where we produce a
	// qual. variable from a quant. var. using autocode, an automated version of
	// recode which is generally easier to use for making equal
	// D bands, where D is the size between adjacent categories, since you don't
	// need to spell out the different bands. Recode is more flexible, though.
	
	/* autocode(x,n,x0,x1) partitions the interval from x0 to x1 into n 
	equal-length intervals and returns the upper bound of the interval that 
	contains x or the upper bound of the first or last interval if x < x0 or
	x > x1, respectively. */ 
	
	/* Last time, we did this with age and the GSS. Here's another example. */
	inspect goodwork // goodwork has 30 unique values
	sum goodwork, d // let's look at this a bit further. 
	gen GWbands = autocode(goodwork, 6, 1, 7) // and make some bands. 
	table goodwork GWbands
		* Note that the names are confusing because of autocode's scale. Let's
		* fix that. 
	tabstat goodwork, by(GWbands) stat(min max)
		* OK, let's settle for making the smaller number in the value label
		* a closed bound. 
	label define gwb 2 "1-2" 3 "2-3" 4 "3-4" 5 "4-5" 6 "5-6" 7 "6-7"
	label values GWbands gwb
	note GWbands: bands do not include lower bound above band 1-2
	label variable GWbands "ordinal version of good work scale" 
	table goodwork GWbands // looks good. 
	
	* Now, let's graph these levels of stress by sex and good work bracket.
	graph dot (mean) stress?, over(GWbands) 
	
	* We can actually include sex as one of the things we condition on, which
	* can make it a little bit clearer. 
	graph dot (mean) stress?, over(female) over(GWbands)
		// We could even just use one variable, but using both does us the favor
		// of making the colors different and more cleanly-distinguishable. 
	graph dot (mean) stress?, over(GWbands) over(female) 
		* This is an interesting alternative perspective. 
	
	// How can we make this more aesthetically-pleasing? 
	graph dot (mean) stress?, over(female) over(GWbands)   ///
		legend( label(1 "men's stress") label(2 "women's stress")) ///
		b1title("Stress") title("Stress level by good work bracket and sex") ///
		ylabel(15(2)31) exclude0
		
		/* What's going on here? First, we change the legend so that it's more
		informative (this syntax is like the label define syntax), change the 
		x-axis label (here "b1title", though more often "xtitle"), change the
		title so that it is more informative, tell Stata to label and tick the
		values between 15 and 31, labeling every second value, and exclude zero
		since there aren't any data-points down there.
		
		The SSCC website has an excellent, very comprehensive discussion of bar
		graphs here: https://archive.ph/QJ6YZ. */ 
	
	// What if we throw in a quantitative predictor? Say we just use goodwork
	// as is. 
	scatter stress goodwork if female==0, jitter(5) || ///
		scatter stress goodwork if female == 1, jitter(5) ///
		, legend(order(1 "Males" 2 "Females")) 
	// Now let's fit two regression lines. 
	scatter stress goodwork if female==0, jitter(5) || ///
		scatter stress goodwork if female == 1, jitter(5) ///
		, legend(order(1 "Males" 2 "Females")) || ///
		lfit stress goodwork if female==0, lcolor(ltblue ) || ///
		lfit stress goodwork if female==1, lcolor(sienna)
		
	// We can even examine three quantitative variables. Let's throw in age. 
		
		/* Some guidance on interpretation are given here: 		
		https://www.ssc.wisc.edu/sscc/pubs/sfs/sfs-scatter.htm */ 
		
		scatter stress goodwork RA1PRAGE, jitter(5) || ///
			lfit stress RA1PRAGE || lfit goodwork RA1PRAGE
	
	// The last two techniques get a bit tricky as more variables are included,
	// however, although some neat stuff is possible. Generally, however, we
	// need to make separate analyses or include the numeric results of 
	// multiple regression when we get much further beyond this. 
	
	*III.ii. Informal numeric methods for multivariate analysis. 
	
	// Let's return to our analysis from earlier, showing how stress
	// varies across good work band and gender. 
	tab GWbands female, sum(stress) nostandard nofreq
		// Note that we have some surprising results: men with bad jobs are
		// feeling breezy.
		list MRID stress if female == 1 & GWbands == 2, abb(20)
		/* OK, looks like we just have one really surprising result due to the
		large outlier, observation 202/MRID 38666. Note that I have not gotten
		into the issue of outliers in too great a detail. Suffice it to say that
		generally they should not be dropped from the analysis entirely unless
		we know that they are a mistake. */ 
	
	// We can even add in yet one more categorical predictor. But note that table,
	// unlike some other commands, is less cool about MVs. 
	table GWbands female bedpartrmmt if ~missing(bedpartrmmt), c(mean stress)
		// See above for why the other three aren't missing
	
	// As you can see, this gets a bit messy when we're just relying on offhand
	// techniques as the book shows. We can take it even one step further, but
	// this is obviously getting rather messy (this is one reason to prefer
	// multiple regression. 
	
	label list RA4Q10A1
	mvdecode RA4Q10A1, mv(7 = .d \ 8 = . \ 9 = .i)
	table GWbands female bedpartrmmt if ~missing(bedpartrmmt) ///
		& ~missing(RA4Q10A1), by(RA4Q10A1) c(mean stress)

	*III.iii. Quick review of multiple regression. 
		
	* Here, I just show briefly how multiple regression can handle analyses just 
	* like those above, with a quant. outcome and interacted qual. predictors.
	* Interpreting quantitative predictors is difficult; contact me if you plan
	* to engage in multiple reg. and want help (I strongly suggest centering the
	* quantitative variable unless zero values are common so that the main 
	* uninteracted terms aren't meaningless). 
		
	* We could, e.g., run two totally separate regression models
	reg stress i.bedpartrmmt if female == 0
	reg stress i.bedpartrmmt if female == 1
	reg stress i.female##i.bedpartrmmt
		* This effectively runs two nested regression equations. Note that the
		* "margins", the conditional means for all possible values of the pred.
		* matches the output from two separate regressions as well as the kind
		* of table we created above. 
	margins i.female##i.bedpartrmmt
	table female bedpartrmmt, c(mean stress freq) format(%6.4g) row col
		/* Note that the six doubly-conditional means for each group given by
		the interaction terms are the six conditional means in the table. 
		
		The unconditional means do not appear in this table, though, so if 
		we want to uncover the unconditional means given in the table, we just 
		run...*/
	quietly reg stress i.female // quietly handily suppresses output
	margins i.female
	quietly reg stress i.bedpartrmmt
	margins i.bedpartrmmt
	
	
	
	
