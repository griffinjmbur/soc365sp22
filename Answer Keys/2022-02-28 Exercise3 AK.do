* 1. 
	capture log close
	clear all 
	set more off
	cd "~/desktop/SOC365sp22/"  
	log using "./do/answer keys/Exercise3 AK", text replace 

	/* task: provide answers
	   author: Griffin JM Bur, 2022-02-24 
	   SOC 365, Spring 2022.*/ 
	   
/* The most common mistake on this exercise was when it came time to construct
the "previous stats course" variable. This could be rendered as one categorical
var. with many possible values (i.e., a "polytomous" variable) ... but that takes
careful construction. Some people also just made a var that only took on values
that actually obtained in the data-set, which works well _if_ you would never,
say, have any other observations...but what if these data were just the first 
seven you inputted after a first round of data collection? 

So, it makes more sense (and is much easier) to make a set of dummy vars 
for each of the four classes. 

Why is it hard to construct such a polytomous var.? In the appendix, I show why.*/
	   
* 6. making variable labels, value labels 
	

	use ./original_data/SOC365studentsvy_raw.dta, clear
	
	label data "SOC 365 Student Survey Responses"
	/* Add variable names (if not already entered into Stata directly
	-- I did this directly but you didn't have to). 
	
	rename var1 personalname
	rename var2 surname
	rename var3 grad
	rename var4 carstudent
	rename var5 soc357  
	rename var6 soc360  
	rename var7 soc361  
	rename var8 soc362  
	rename var9 reasontake
	rename var10 statauser
	rename var11 height   
	rename var12 id */
	

	*Variable labels

	/* Here's how to make an ID variable --> */ gen ID = _n	
	lab var ID           "Identifier" 
	lab var personalname "first name"
	lab var surname      "last name" 	
	lab var grad         "Undergraduate = 0, Graduate = 1"
	lab var carstudent   "CAR student?"
	lab var soc357       "Has taken Soc 357 or equivalent"
	lab var soc360       "Has taken Soc 360 or equivalent"
	lab var soc361       "Has taken Soc 361"
	lab var soc362       "Has taken Soc 362"
	lab var reasontake   "Type of research interested in"
	lab var statauser    "Previous stata experience"   
	lab var height       "Height in inches" 


	* Assign value labels

	/* Here, I create a yes/no label that can be applied to many variables.
	Notice that I made "not applicable" values .n so I could label them as such.
	When I input the data in the Stata data editor, I put .n for the two 
	grad students who left the CAR variable blank. 
	
	This is important to do instead of just assigning these folks to "no" both
	because they literally did not answer the question and because Stata will
	not include missing values in routine calculations -- so, if you wanted to
	do inference on how many undergrads in this course choose to join CAR, having
	grad students in the denominator of all students who are eligible would be
	misleading! */ 
	
	lab define yesno_lbl 1 "Yes" 0 "No" .n "not applicable"
	lab val carstudent soc357 soc360 soc361 soc362 statauser yesno_lbl 

	note car: only undergrads can be CAR students. not applicable for grads. 
	// added a note to "car" variable

	lab define studentstat 0 "undegraduate" 1 "graduate" 
	label values grad studentstat

	lab def interest_lbl 1 "academic" 2 "policy" 3 "business" 
	lab val reasontake interest_lbl


* 7. Describe content of data

	describe
	codebook


* 8. *Check contents of data for missing and/or unexpected values
	tab grad, miss
	tab carstudent, miss
	tab soc357, miss
	tab soc360, miss
	tab soc361, miss
	tab soc362, miss
	tab reasontake, miss
	tab statauser, miss
	tab ID, miss
	sum height, d
	

	* Example error that I deliberately included in this data-set. 
	
	* I notice that I have an unexpected value in soc361.
	* this is a dummy variable, so the only values should be 1 or 0, but there is
	* one observation of 2. this could be a typo from when I entered the data.
	* step 1 is to see who this person is:
	list personalname surname ID soc361 if soc361==2

	* I go back to my original surveys and check what value this should be
	* I see that I made a typo. This should be a 1.
	* I can fix it with "replace"

	replace soc361=1 if ID==5
	* note that I have specified that I only want to fix the one row of my 
	* data with id=5
	* check my data:
	list personalname surname ID soc361 if ID == 5, abb(20)
	* good, now Chimamanda is corrected. In this case, it's fine to use 
	* non-universal logic because we are fixing a single random typo.
	* let's make sure I didn't mess anything else up the process:
	tab soc361, miss
	* Good; when I compare this table to the table I made a few commands back 
	* (I can look in my stata window or my log file), this looks correct.
	*I can even add a note:
	note soc361: one typo identified and corrected. soc361=1 for ///
		observation ID=5. TS

	/* There are two missing values on the variable "carstudent". I chose to add 
	them as a sepcific kind of missing by adding them as .n. This allowed me to
	label them as "not applicable" and I added a note. */ 

	tab grad carstudent, miss

* 9.

	* What percentage of obs are 5'6" or taller?
	* There are a few ways you could do this. 
	
	* Here's the simplest. Note that you don't need to use "scalar". You can
	* just do the mental math or calculate 5' 6'' in inches on scrap paper. 
	* You also don't have to round, but with small n data-sets, giving too much
	* precision can be misleading. Using the round function is fancy, but you
	* don't have to do it if you don't want. 

	scalar heightcutoff = (5*12)+6

	count if height >=heightcutoff
	scalar percentabovefivesix = round((3/7)*100, 0.01)
		* This function round(arg1, arg2) rounds arg1 to the precision of arg2.
	di percentabovefivesix
		* Remember to display a scalar to see what the actual value of what you
		* chose to store under it is. Also, BTW, this is a bit of an obscure
		* mistake that one might make, but NEVER NAME SCALARS THE SAME THING AS
		* A VARIABLE. Stata will "pick" the variable. Usually this is not a very
		* intuitive mistake to make, fortunately. 
	
	/* Here's another way that mirrors question 10.*/ 
	
	gen tallerside = 1 if height>=heightcutoff
		* This creates a dummy variable if the person exceeds or equals 5'6''
	replace tallerside = 0 if missing(tallerside)
		* The last command created some missing values, and we want them all to
		* be zero anyways, so this works. 
	
	tab tallerside
		// So, again, we see 42.86. 
		
	/* BTW, what if you had entered height in the vernacular way of writing it,
	which is somewhat inconvenient when computing? You could just hand re-enter
	it here since the data-set is small, but this is how you could quickly fix 
	it with Stata and the string functions we discussed last week. */ 
	
	d tradheight // inspecting variable -- it is a string
	tab tradheight // briefly looking at how it is rendered.
	gen heightmain = substr(tradheight, 1, 1)
		* ^ substr(varname, position, length) takes tradheight, goes to position
		* one, and pulls a string of length one. 
	gen heightremainder = substr(tradheight, 3, 1)
		* ^ substr(varname, position, length) takes tradheight, goes to position
		* three, and pulls a string of length one.
	destring heightmain heightremainder, replace
		* Now, since we have a number that is rendered as a string, -destring- is
		* the best option for turning it into a number. 
	gen heightinches = (12*heightmain)+heightremainder
		* We recall that the first number needs to be multiplied by 12 since it
		* is height in feet. 
	list height heightinches
	list height heightinches if height ~= heightinches
		* And we confirm that this was done correctly using the variable rendered
		* in inches in the first place.

* 10. 

	tab soc362, miss

	* 28.57 percent of students have taken Soc 362.

* 11. 
	
	* you should save this to your "modified data" folder. 

	save ./modified_data/SOC365studentsvy_clean, replace
	
/* Appendix: why it is hard to make a polytomous variable for the stats sequence
variables. YOU DO NOT NEED TO READ THIS FOR ANY DIRECT TESTING PURPOSE. If you are 
totally unsure about why my method above is easier, read the "easier explanation"
which draws on a little bit of counting theory, but not much. IF and ONLY IF (iff)
you find  all of this very easy and want to know more, you can read the second. 

Here are two ways to understand it that help us refresh our counting skills. 
Counting at a high level is one of those math skills that just does not get enough
attention in middle/high school, so I'll keep this pretty minimalist. 

First, the easier method. Suppose we do go ahead and make that set of four dummy 
variables as suggested. Now, how many different outcomes are possible from 
four Bernoulli trials (i.e., a trial with a yes/no outcome)? 
That's 2*2*2*2 = (2^4) = 16. So, our polytomous var would need 16 possible values.
Is that impossible? No, and it's not even that hard to make. But it could be a
pain to keep track of.

Second, the combinatorial method. THIS IS SUPER, SUPER OPTIONAL. It's something
that you should read only if you are totally on board with the above, feel like
the class is going really slow, and want to review an idea that *is* very impt.
if you go on to higher math that happens to come up. 

Another way to count this is to realize that we are also asking how many ways
there are to choose (zero classes out of four) + (one class out of four) + (two 
classes out of four) + (three classes out of four) + (all four classes). These 
are called "combinations" in combinatorics, the branch of math devoted to counting.
Here, the order of the k items picked from a set of n does *not* matter (and 
often it is not clear how that would even be possible). The counterpart of a
combination is a permutation, where order does matter. The "funny" way to 
remember this is that combination locks on your bikes are really "permutation
locks" (don't blame me, not my bad joke). 

Combinations where you can only pick an element once are called combinations 
without repetition, and they are easy to count. First, you think of how many
ways there are to permute k items from a set of n. This is, fairly intuitively,
the largest k numbers <= n. So, if I want to randomly call on some *order* of 
five people in any given class of 14, I have 14*13*12*11*10 options. That can
be quickly written as n!/(n-k!) = 14!/9! because all terms in the numerator below
10 cancel out. By the way, here, "!" is the factorial operator, not the "not" 
operator (which is one reason to use "~" instead of "!", though that also causes
confusion since "~" can mean "approximately equal to"...all the Greek and Hebrew
letters in math seem kind of silly until you see how how many problems just using
Roman letters and West European symbols causes...). 

In counting, it is often easier to count what you don't want and subtract, or 
"overcount strategically" and then correct. So, to find out how many combinations 
there are for a subset of k items from a set of n items, you simply figure out 
how many ways there are to permute a set of k items, and then figure out by what
factor that overcounts the combinations. So, for every set of five people I call
on, the above method -- n!/(n-k)! -- counts every permutation of those five ppl
as a separate group. So, how many ways can I permute the set of k items? Easy--
that is k! times. So, I just divide by k! and I have my formula for combinations
without repetition: n!/k!(n-k)!. We generally write this formula as nCk or nCr, 
depending on your region. There is also a way to write this as stacked items in
parentheses that you've probably seen, but I can't do it in a simple text editor.

Importantly, you might notice that if I want to select not _k_ items but (n-k) 
items, this is actually the same thing because the denominator is now 
(n-k)!(n-[n-k])! = (n-k)!(k!). If you really want to see how math can sometimes 
be almost spiritual, note that this symmetry can also be seen in Pascal's triangle,
whose entries can also be understood as (rows down)C(steps to the left/right). 
So the mysterious, beautiful symmetry of the triangle is also just arithmetic. 

So, back to the point, counting (zero classes out of four) + (one class out of 4)
+ (two classes out of four) + (three classes out of four) + (all four classes) is
4c0 + 4c1 + 4c2 + 4c3 + 4C4 using Google or WolframAlpha (you may need to write
out "choose" in place of "C". This also yields 16. */ 

log close 
