/* This week, we will work with data from the 2000 Census. The 2000 Census 
contains three variables from which we can identify same-sex cohabiting couples: 
(1) everyone in the household’s sex; (2) everyone in the household’s marital 
status; (3) and how people in the household are related to one another. Thus, 
same-sex cohabiting couples are members of households who are of the same sex, 
are not currently-married (divorced, widowed, separated, or never married), and 
who defined themselves as “unmarried partners” (please note that people’s answers
to these questions were shaped by a set of laws around marriage that differ 
significantly from the law today).

The person who owns or rents the home/apartment in which the household lives is
known as the “householder.” We have one data set that contains characteristics 
of males and females in same-sex cohabiting relationships who are householders 
(sscouples2000_hhldr.dta) and another that contains non-householder partners 
(sscouples2000_nonhhldr.dta). The ones after the variables in 
sscouples2000_hhldr.dta (e.g., age1, educ1) indicate that the variables pertain
to the householder. The zeros after the variables in sscouples2000_nonhhldr.dta 
indicate that the variables pertain to the non-householder. When the variables 
do not have zeros or ones after them, they are the same for householders and 
non-householders. The variable serial uniquely identifies households. */ 

/* 1. Write a do file to conduct this assignment and save it as
exercise6_YourLastName.do in your “Do” folder. In your do file, specify that your
log file should be called exercise5_YourLastName.log. Use the standard do file
header that we’ve been using in class. */ 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise7 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-04-11
	   SOC 365, Spring 2022.*/ 
	   
* 2. We would like to create a file in which there is one record per couple. In 
* other words, each observation contains a single record containing information 
* on both the householder and non-householder in couples. Decide whether a merge 
* or append is required and then carry out the code. Make sure to include code 
* that checks whether the merge/append was carried out correctly (tabulate your 
* merge variable and list a few cases—make sure the results are as you expected).
* Comment on the results. 

	* Let's examine householder data
	use ./original_data/sscouples2000_hhldr.dta, clear
	describe
	
	* Now, let's examine non-householder data
	use ./original_data/sscouples2000_nonhhldr.dta, clear
	describe

	* Now, let's merge. Why merging? Because we would like to have data structured
	* so that the household is the basic unit of analysis -- and what we have in
	* each data-set is information on individuals, with information on their
	* households recorded. This is a bit like a case where you would have, say,
	* information across multiple data-sets on all major cities for all states in 
	* the Midwest, e.g., and you want to just collapse this in state-level data.

	merge 1:1 serial using ./original_data/sscouples2000_hhldr.dta
	tab _merge
	drop _merge

	* OK, our results look nice -- we did not have any unmatched people. This is
	* about the simplest case possible. 

	* Let's look at some of the data just to check our work...
	sort serial // Let's do this just to give the data some kind order...
	list serial age0 age1 sex0 sex1 in 1/25
	
	* Finally, let's check to confirm that all of our couples are same-sex.
	
	list serial sex1 sex0 if sex1!=sex0

	* Looks like it worked. We have same-sex male and female couples.

/* 3. Let’s consider only same-sex male couples for now. Drop same-sex female 
couples from the data using the “drop if” or “keep if” command. Run a “tab” that
shows your data now only contain same-sex male couples. */ 

	tab sex0
	tab sex0, nolab

	keep if sex0 == 1 & sex1 == 1

	*Check
	tab sex0 sex1

/* 4. Create a variable that indicates whether the householder and the 
non-householder share the same education category. The variable should equal 1 
if they share the same education category and 0 if they do not. Include code to 
check the creation of your new variable that will convince a skeptical reader 
but does not produce excessive output. Be sure to pay attention to missing values
if there are any. */ 

	* First, let's check to see if we have to deal with missing values.
	tab educ0 educ1, miss
		
		* Apparently not!
		
	* Now, let's create the variable
	gen sameeduc = (educ0 == educ1)
		
	* and check to make sure that the variable creation worked... 
	bysort sameeduc: tab educ0 educ1
		* Good! We have a hollow matrix in the first-case (all zero elements
		* on the main diagonal, which makes sense: this should be *only* people
		* who lack the same education as their partner. Since these variables
		* are encoded in the same way, if there is a non-zero number in row j and 
		* column j, there is at least one person who shares their educational
		* attainment with their partner. 
		
		* In the second case, we have a square diagonal matrix, which again is
		* the _only_ possibility if we have done this correctly. 
	sort serial
	list sameeduc educ0 educ1 in 1/20
		
	* So, we conclude that our creation of sameeduc seems to have worked and 
	* we can make a value label for convenience. 
	label define se 0 "differ on educ" 1 "share educ"
	label values sameeduc se
	label variable sameeduc "Do the partners share educational attainment"

/* 5. What proportion of same-sex male couples share the same education? */ 
	tab sameeduc
	* About 52 percent share their educational attainment. 

/* 6. How does the proportion of same-sex male couples who share the same 
education vary by the householder’s education? For example, are more highly 
educated householders more or less likely to share the same education level as 
their partners? Comment on the relationship in your do/log file. */ 

	* How does this vary by the householder's education?
	tab educ1 sameeduc, row nofreq
		
	* ANSWER: College graduate-householders and those who did not complete high 
	* school are more likely to share the same education. If we tabulate the
	* same for non-householders, we see much stronger homophily among college 
	* grads and much less homophily among those who finished HS but have no
	* additional school. This is pretty interesting, and a bit puzzling, but it
	* turns out that we have significantly different marginal distributions among
	* the householders and non-householders (who have significantly less education).
	
	tab educ0 sameeduc, row nofreq
	
	* There are a few ways to interpret this, but the best guess is probably that
	* people in committed relationships are a non-random subset of the population,
	* and those relationships probably involve a lot of homophily with a bit of
	* social-mixing. In particular, if we run a couple of twoway tables of both
	* partners' education, it looks like non-householders with 12 years of educ
	* are generally "'marrying' up" a slight bit, so to speak--lots of non-HHers
	* in that bracket end up with someone with some college, but most people who
	* are the "householder" bucket aren't doing the same. This makes sense: to
	* the extent that "householders" are probably the person in the relationship
	* with more income and status--and age, by a small but notable amount--they
	* are a different subset of the population. This might sound a bit odd, but 
	* consider that, in heterosexual relationships until very recently, one 
	* partner was generally poorer in income terms and has less formal education
	* (this is changing rapidly, though). One might want to turn to the work of
	* gender scholars to explain the fact that this dynamic appears to be somewhat
	* present among partners of the same sex or gender. 
