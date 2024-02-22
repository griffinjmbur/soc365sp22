/* 1. Write a do file to conduct this assignment and save it as
Exercise8_YourLastName.do in your “Do” folder. In your do file, specify that your
log file should be called Exercise8_YourLastName.log. Use the standard do file
header that we’ve been using in class. */ 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise8 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-04-11
	   SOC 365, Spring 2022.*/ 

/* 2. Let’s begin with a straightforward extension of some of our key techniques 
for analyis, focusing on whether fathers monitor their children’s homework 
(question BB046B).*/ 

	use ./original_data/hsb, clear
	rename *, lower
	d bb046b
	tab bb046b
	label list LABV

	/* A) At the individual level, is fathers’ educational attainment related to 
	whether they monitor their child’s homework? One way to do this would be to 
	examine a cross-tabulation of father’s education and monitoring, handling 
	missing values appropriately and calculating conditional probabilities 
	“correctly”. Comment on this. */ 
	
	tab bb039 bb046b, row nofreq
	mvdecode bb046b, mv(3=.)
	mvdecode bb039, mv(1 = .a \ 11 = .d)
	
	tab bb039 bb046b, row nofreq

	/* B) At the individual level, is a student’s score on the math test related  
	to whether their father monitors their homework? One way to answer this would
	be to compare mean math scores by whether fathers monitor homework. Comment 
	on your results. */ 
	
	ttest bbmathf, by(bb046b) unequal
		// Statistically significant difference, though practically not huge. 
		// Using the "unequal" option is almost always a good idea, BTW. 
	
	
	/* C) Create a dummy variable that equals 1 if fathers monitor their children’s 
	homework and 0 if they do not. Use this variable to create another variable 
	that measures the average proportion of fathers who monitor their children’s 
	homework by school. At the school level, is the proportion of fathers who 
	monitor their children’s homework related to the average math test score in 
	the school? Stated more generally, are test scores higher in schools where 
	the average father is more involved? One way to answer this would be to carry 
	out a regression of mean math test scores on the proportion of fathers who 
	are involved in child’s homework. Comment on your results. */ 
	
	gen dad_monitors = -1*(bb046b -2)
		* This is often a useful trick with this type of coding. Subtracting off
		* two from the old variable turns "old two" into zero. It also turns 
		* "old one" into -1, so then we just multiply by -1 at the end to get
		* a "proper dummy" in one go. 
	tab dad_monitors bb046b, mis nola
	label define dm 0 "doesn't" 1 "does" 
	label values dad_monitors dm
	label var dad_monitors "Does father monitor child's homework?"
	
	bysort schoolid: egen school_dad_monitor = mean(dad_monitors)
		// We loop over schools and take the mean of dad_monitors, which is a 
		// dummy (and so the mean is the proportion of people with 1s on this
		// var. in this group--contact me for a link to the simple algebraic 
		// proof from my 360 lecture notes if you would like). 
	list dad_monitors school_dad_monitor if schoolid == 1032
		* We can spot-check with a single school. The mean of dad_monitors for
		* this school should be the  same value as that of the group-level var.
		* we just made. 
	sum dad_monitors if schoolid == 1032
	
	bysort schoolid: egen school_math_scores = mean(bbmathf)
		// This is a simpler case because math scores are quantitative already
		// so this procedure should be even more intuitive. 
	list school_math_scores bbmathf if schoolid == 1032
	sum school_math_scores bbmathf if schoolid == 1032
		* Spot-check checks out. 
	
	reg school_math_scores school_dad_monitor
	scatter school_math_scores school_dad_monitor || lfit ///
		school_math_scores school_dad_monitor
		
		/* Interpretation: we would see a coefficient this large or larger on
		school_dad_monitor approximately zero percent of the time if there were
		no relationship between that and school math scores in the population: 
		p(the relationship in this sample | no population relationship) ≈ 0. 
		In particular, we can say that 10 percentage point increase in the 
		proportion of dads monitoring in a school increases math scores by about 
		1.2 points. The interpretation is a little tricky here, but remember that
		the proportion of dads monitoring by school is a 0/1 variable, so the 
		coefficient without adustment represents moving from no dads monitoring
		to all dads monitoring; we can divide by 100 to get a percentage pt chg.
		
		Below is a way to very roughly see that with a categorical version of 
		dads monitoring if that feels more concrete to you. */ 
	
	sum school_dad_monitor	
	gen monitor_bkt = autocode(school_dad_monitor,10,r(min), r(max))
	version 16:table monitor_bkt, c(mean school_math_scores)

/* 3. Within each school, calculate the difference between the highest and the 
lowest math test scores. (Hint: see slides from this week’s lecture.)
	
	A) What is the largest gap in test scores? */ 
	
	drop if missing(bbmathf)
	sort schoolid bbmathfs
		* This step is extremely important! We need scores to be orderd first by
		* the school they're in, then by the value of the score. 
	order bbmathfs, after(schoolid)
		* We can hand-check this with browse after moving bbamthfs to a more 
		* intuitive location in the varlist. 
	br
	by schoolid: gen math_gap = bbmathfs[_N] - bbmathfs[1]
		* This generates a variable that takes the difference between the last
		* observation when math scores are sorted by their value within each 
		* school and the first one -- in other words, the math gap. 
	list bbmathfs math_gap if schoolid == 1032
		* We can just spot-check this first school. A little mental math confirms
		* that we have done this correctly. 
	sum math_gap
	
	/* B) What is the smallest gap in test scores? */ 
	sum math_gap
		* Some people overthought this, but you can just observe the min/max
		* of the gap variable here. 

/* In this part of the homework, we will be working from an excerpt of the NLSY79,
a longitudinal data set. These data contain information from 1979, 1980, and 1981.
Each respondent has a record for each year they were interviewed. This data set 
is called nlsy_excerpt_79_81.dta. These data contain information from surveys 
conducted in 1979, 1980, and 1981. The variable id uniquely identifies rs.*/
	
/* 4. Respondents in these data were between the ages of 14-22 in 1979. Thus, 
many are still in school when they are interviewed. Compute the change in 
respondents’ years of education (using redu) between their last observation and 
their first (so that increases over time are positive) following the example from 
class. Make sure to handle missing values appropriately. Check your variable. */

	use ./original_data/nlsy_excerpt_79_81.dta, clear
	drop if missing(redu)
		// Dropping is a good idea here because working around it with rank-
		// ordering can be a pain. 
	bysort id (year): gen change_ed = redu[_N] - redu[1]
	list id year change_ed redu in 1/500, sepby(id)

/* 5. Whose education increased more on average between these years, male or 
female respondents? Perform an appropriate analysis and comment on the results.*/

	ttest change_ed, by(rsex) unequal
	* men! How do we interpret this? If there really were no difference between
	* men and women in their change in education, we'd see a difference this
	* large or larger about 0.03 percent of the time (or a difference this big
	* in an absolute value sense about 0.06 percent of the time). The option
	* ", unequal" is usually the more realistic option, BTW. 
	
	* BTW, I made some pretty elaborate pictures of two-sample t-tests and their
	* sampling distributions last semester for SOC 360. You may find these
	* useful in recalling how such tests work; here is an example where I use
	* Stata to visualize the distribution
	
	view browse https://tinyurl.com/twosamplettesteg 

/* 6. Create a new variable that equals 0 if respondents are never married, 1 if 
they are married, and otherwise is missing. Check to make sure that this variable 
was created correctly. */ 

	gen on_first_marriage = MARTLD==1
	replace on_first_marriage = 0 if MARTLD == 0
	replace on_first_marriage = . if MARTLD ~= 0 & MARTLD ~= 1
	tab on_first_marriage MARTLD, mis
	
	* A few people had a little bit of trouble with this; note that I am not 
	* here asking for ever-/never-married but instead a threefold ever-/never-/
	* "complex situation" variable. The reason for this is that we want to hone
	* in on cases where people married for the first time. It is possible to leave
	* in those other situations as other numeric codes, but this method is the
	* simplest for doing the algebra that we want later on. 
	
	label define ofm 0 "never married" 1 "on first marriage" 
	label values on_first_marriage ofm
	tab on_first_marriage MARTLD, mis
	
/* 7. Using this new variable, create another variable that looks at changes in 
martial status from never married to married from year to year within respondents
following the examples from class. Check your variable. What is the average 
years of schooling completed (redu) of women in this sample who have just 
entered into marriage (moved from never married to married)? */ 

	sort id year
	by id: gen just_married = ///
		(on_first_marriage[_n] - on_first_marriage[_n-1] == 1)
		
		* OK, so, what does this do? It tags anyone whose marital status in year
		* n minus that of year n-1 changed from zero to one (since, in this way
		* of coding the marriage dummy, that is the only way for someone's status
		* to have a numeric change == 1. 
		
	sum redu if just_married == 1 & rsex ==2
	
	* This would also work: 
	by id: gen nvm_to_m = on_first_marr - on_first_marr[_n-1]
	
		* What the above code does differently is take the actual difference. 
		* This produces missings (not zeros) if it is the first year in the 
		* sample that the person was observed. That is consequential sometimes 
		* but not in this case. 
	
	sum redu if just_married == 1 & rsex ==2
	sum redu if nvm_to_m == 1 & rsex ==2
