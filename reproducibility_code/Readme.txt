
CODE INSTRUCTIONS

This set of code processes and analyzes maternity leave policy data using Stata and R.

DATA PREPARATION:
1. Place DHS data files in your working directory
2. Make sure you have mat_leave_country_year.dta and World Bank indicators data
3. Install required Stata packages: reghdfe, estout
4. Install required R packages: tidyverse, gt, haven

EXECUTION ORDER AND INSTRUCTIONS:

1. Data Cleaning (data_cleaning.do) in Stata
- Processes DHS survey data
- Creates temporary files for each data type (HW, IR, WI)
- Check log file for any processing errors

2. Data Merging (data_merging.do) in Stata
- Creates country crosswalk
- Processes maternity leave data
- Merges with World Bank indicators
- Creates final_merged_df.dta

3. Statistical Analysis (analysis.do) in Stata
- Creates analysis variables
- Runs three regression models
- Generates clustered standard errors
- Saves results for visualization

4. Table Creation (visualizations.R) in R
- Creates formatted results table
- Outputs HTML and PDF versions
- Check table formatting in output files

NOTES:
- Height-for-age z-scores are truncated at ±6
- Sample period: 1995-2013
- Remember to adjust file paths in scripts as needed
- Check Stata and R log files for any errors

