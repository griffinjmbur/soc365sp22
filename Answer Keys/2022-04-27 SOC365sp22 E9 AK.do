/* 0. Write a do file to conduct this assignment and save it as 
Exercise9_YourLastName.do in your “Do” folder. In your do file, specify that 
your log file should be called Exercise9_YourLastName.log. Use the standard 
do file header that we’ve been using in class. */ 

	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise9 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-04-27
	   SOC 365, Spring 2022.*/ 
	   
	use ./original_data/psid_extract.dta, clear
	describe 
 
/* 

1. First, let’s create dummy variables indicating whether husbands have 
completed at least college for each year. To do this, we’ll reshape the data.*/

	* A) Reshape the data so that they are the format we want for panel data.

		/* The data are in wide format because we have panel data and yearly info is 
		included in the form of different variables. So, let's reshape wide>long.*/
	
	reshape long wedy hedy wedc hedc, i(fid wfpid hdpid) j(year)

		/* For a detailed explanation of the syntax, see my lecture.

	B) Next, create a variable called hcoll that indicates whether husbands have 
		completed college (for each year) using the education category variables. 
	
	C) Do the same for wives; be sure to check the creation of your variables.*/
	
	gen hcollgjmb = hedc == 4 if ~missing(hedc)
	gen wcollgjmb = (wedc == 4) if ~missing(wedc)
	tab hedc hcoll, miss
	tab wedc wcoll, miss
	

	* D) Perform an analysis that shows the extent to which the percentage of
		* husbands completing college has changed between 1970/2009. Interpret. 
	
	tab year hcollg, row

		* College completion for husbands more than doubled between 1970-2009, 
		* from about 14 percent to 30 percent. 

* 2. Create a categorical variable called rel_edc that equals 2 if husbands have 
	* a higher education category than their wives 1 if husbands have a lower 
	* education category than their wives 0 if they have the same education 
	* category. Be sure to handle missing variables appropriately and assign 
	* value labels to your variables. Check the creation of your new variable.
	
	* First, let's create the relative education variable. 

	gen rel_edcgjmb = 2 if (hedc > wedc & hedc != . )
	replace rel_edcgjmb = 1 if (hedc < wedc & wedc != . )
	replace rel_edcgjmb = 0 if (hedc == wedc & wedc != . )

 
	* Check -- it works
	bysort rel_edc: tab hedc wedc, miss
	sort fid
	list rel_edc hedc wedc in 1/50
 
	* Label variable and values
	lab var rel_edc "Relative Education, Couples"
	lab def rel_edc_lbl 2 "2:Hedc>Wedc" 1 "1:Hedc<Wedc" 0 "0:Hedc=Wedc"
	lab val rel_edc rel_edc_lbl
 
 
* 3. Perform an analysis showing how the percent distribution of spouse’s relative
	* education (the 3-category variable you created above) has changed between 
	* 1970 and 2009. Comment on your results.

	tab year rel_edc, row nof

 
	*A smaller proportion of couples have the same education level and there is a
	*larger proportion of couples in which wives have more education than their 
	*husbands. The proportion of couples in which husbands have more education 
	*than wives has stayed relatively constant. 


/* 4. Next, collapse husbands’ years of education by spouses’ relative education
	(created in step 3) and year. This will give you husbands’ mean years of 
	schooling by spouses’ relative education and year. List the data. (This is 
	one of the few times you will list all of the data. This is ok because, 
	after collapsing, your dataset should be small in size.) 
	
	Comment on (a) differences in husbands’ mean education by spouses’ relative 
	education and (b) how husbands’ mean education by spouses’ relative education
	has changed across the years. You may ignore the missing values of couples’ 
	relative education in your interpretation. */ 
 
	preserve 
	collapse hedy, by(rel_edc year)
	list
	restore
 
	*Husbands in couples where husbands have more education than wives have the
	*highest years of schooling, followed by those that have equal levels of 
	*schooling, and then by those who have less than their wives. It looks like
	*husbands' years of schooling increased fastest among couples who shared the
	*same education and slowest for couples where husbands had more education than
	*wives.
 
	log close
 
 
 
