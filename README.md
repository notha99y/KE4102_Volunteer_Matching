# Volunteer Matching
### Dated: 10 March 2018
### Authors:
- [Tan Ren Jie](https://github.com/notha99y/)
- [Cai Yu Tian](https://github.com/Yutian-KE)
- [Shahril Mustafa](https://github.com/RefShah)
- Kevin Yeo
- Lim Hui Juin

### Credits:
We owe our knowledge elicitation to the following domain experts:
- Ms. Saw Min Hsian
- Mrs. Joyce Tan
- Mr. Adrian Ng
- Charles Fong
- Mr. Jim
- Ms Adelina Kuan

#Introduction
In this repo, you will find code to a platform that provides recommendations of volunteering events
based on the user’s preferences. <br>
The platform is essentially an expert system that takes in the key preferences from the user
and then recommends a ranked list of VWO and their events. <br>

The matching engine is written using a rule based programming language (CLIPS) [4], which allow weighted
rankings recommendation instead of filter system that we find in most websites.

# Problem Formulation
The scheduling problem of an earth observation satellite is a large and difficult combinatorial optimization problem. <br>
Thankfully, such a scheduling problem is well-studied with numerous papers stating different problem formulations. <br>
Some notable formulations are the generalized knapsack formulation, which is well-known to be NP-hard, adopted in [2]. <br>
In [3], it discusses the possibility of using linear integer programming formulation with CPLEX or as a constraint satisfaction problem formulation. <br>
For this demo, we shall adopt a Constraint-Optimization Problem (COP) formulation using Object Oriented Programming(OOP). <br>

COP refers to a set of problems that requires the optimization of an objective function with respect to some variables in the presence of constraints on those variables. <br>

# Object Used
The objects used are summarized in the class table below. <br>
The classes Imaging Missions, Satellites and Ground Stations are user inputs designed by the users to fulfil the mission requirements. <br>
Imaging Opportunities and Downlink are derived classes which the programme would automatically generate after the users has specified the Tasks and Resources he/she wants to simulate for a given Scenario time frame. <br>

<img src="classhiearchy.JPG" alt="class hierarchy" style="width: 100px;"/>

# Algorithm
<!-- <img src="algorithm.png" alt="algo" style="width: 100px;"/> -->
![Algo](algorithm.PNG)

## Objective function
<!-- $$Score_i = k_a a_i + k_b b_i + k_c c_i + k_d d_i + k_e e_i$$ -->

<p align="center">
<a href="https://www.codecogs.com/eqnedit.php?latex=$$Score_i&space;=&space;k_a&space;a_i&space;&plus;&space;k_b&space;b_i&space;&plus;&space;k_c&space;c_i&space;&plus;&space;k_d&space;d_i&space;&plus;&space;k_e&space;e_i$$" target="_blank"><img src="https://latex.codecogs.com/gif.latex?$$Score_i&space;=&space;k_a&space;a_i&space;&plus;&space;k_b&space;b_i&space;&plus;&space;k_c&space;c_i&space;&plus;&space;k_d&space;d_i&space;&plus;&space;k_e&space;e_i$$" title="$$Score_i = k_a a_i + k_b b_i + k_c c_i + k_d d_i + k_e e_i$$" /></a>
</p>


## To run
1. Create the Resource and Imaging Mission by changing and running the creating_IM_params.py and creating_resource_params.py file (you can skip this step to run the sample simulation I have created.)
2. Open the main.py file and uncomment out the algorithm you want to use. Run it.
3. This would generate 2 .csv files per orbit (Results and Remaining targets)
4. To plot, open the subplotting.py file and change the numberOfOrbits variable to the same as the last number of the orbit.

## Plots
![plots](plotting_results.png)
The Mission is simulated to complete in 8 orbits. The plot is taken in the frame with respect to the satellite orbit path.

### Mission Requirements
- 20 distinct point targets scattered at Near Equatorial Orbit.
- All to be imaged twice
- All to be imaged using an Optical Sensor
- The maximum look angle is set to be 45deg
- Priorities were set to be all equal

### Resources
- One Satellite with an Optical Sensor and a carry capacity of 8 images.
- Satellite agility was modelled have an average angular speed of 0.0628 rad/s
- One Ground Station at

# References
[1] NATIONAL VOLUNTEER & PHILANTHROPY CENTRE, "Individual Giving Survey 2016 Findings,"
15 March 2017. [Online]. Available: https://www.nvpc.org.sg/resources/individual-giving-survey-2016-
findings. [Accessed 22 Febuary 2018]. <br>
[2] Ministry of Culture, Community and Youth, Charities Unit, "Commissioner of Charities Annual Report,"
August 2017. [Online]. Available:
https://www.charities.gov.sg/Publications/Documents/Commissioner%20of%20Charities%20Annual%20R
eport%202016.pdf. [Accessed 22 Febuary 2018]. <br>
[3] National Volunteer & Philanthropy Centre (NVPC), "giving.sg," [Online]. Available:
https://www.giving.sg/search?type=volunteer. [Accessed 23 Feburary 2018]. <br>
[4] G. Riley, "About CLIPS," [Online]. Available: http://www.clipsrules.net/?q=AboutCLIPS. [Accessed 23
Feburary 2018]. <br>
[5] Singapore Ministry of Social and Family Development (MSF) , "Voluntary Welfare Organisations," 20
December 2016. [Online]. Available: https://www.msf.gov.sg/policies/Voluntary-Welfare-
Organisations/Pages/default.aspx. [Accessed 23 Feburary 2018]. <br>
[6] Ministry of Culture, Community and Youth, "About Charities And IPCs," 11 January 2016. [Online].
Available: https://www.charities.gov.sg/setting-up-a-charity/Pages/About-Charities-And-IPCs.aspx.
[Accessed 3 March 2018]. <br>
[7] HOPE worldwide (Singapore), "About Us ( HOPE worldwide (Singapore))," 2015. [Online]. Available:
https://www.hopewwsea.org/who-we-are/. [Accessed 3 March 2018]. <br>
[8] C. P. Team, "Matching Volunteers with Voluntary Welfare Organisations," 10 Febuary 2018. [Online].
Available:
https://docs.google.com/forms/d/e/1FAIpQLSf6jNdjbOMw0M0qcSPEUduDpOUYCodo_bJfqRqAjtx9ox
lNzQ/viewform. <br>
[9] R. 0. D. BRUCE G. BUCHANAN, "Principles of Rule-Based Expert Systems," New York: Academic Press,
Advances in Computers, Vol.22, 1982. <br>
[10] Microsoft Developer Network, "Implementing the MVVM Pattern," Microsoft, [Online]. Available:
https://msdn.microsoft.com/en-us/library/gg405484(v=pandp.40).aspx. [Accessed 23 Feburary 2018].
