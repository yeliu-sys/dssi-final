# Maternity Leave Policy Analysis

This repository contains code for analyzing the impact of maternity leave policies on child health outcomes across 37 countries. The analysis combines data from the Demographic and Health Surveys (DHS), maternity leave policy information, and country-level economic indicators.

## Data Sources

The analysis utilizes three main data sources:

1. **Demographic and Health Surveys (DHS)**
   - Child and household level information from 37 countries
   - Requires registration at [DHS Program](http://www.dhsprogram.com/data/new-user-registration.cfm)
   - Access instructions: [DHS Data Access](http://dhsprogram.com/data/Access-Instructions.cfm)

2. **Maternity Leave Policy Data**
   - Historical policy data from 1995 onwards
   - Compiled by UCLA's World Legal Rights Data Centre (WoRLD)
   - Extended by McGill University's Maternal and Child Health Equity (MACHEquity)
   - Available in this repository: `mat_leave_country_year.dta`

3. **World Bank Indicators**
   - Country-level covariates including:
     - GDP per capita (PPP)
     - Female labor force participation (ages 15-64)
     - Health expenditure (% GDP)
     - Urban population percentage
     - Government effectiveness rating
     - Per capita government health expenditure (PPP)
   - Available at [World Bank Indicators](http://data.worldbank.org/indicator)

## Repository Structure

```
├── reproducibility_code/
│   ├── data_cleaning.do     # Data cleaning and processing
│   ├── data_merging.do      # Data integration
│   ├── analysis.do          # Statistical analysis
│   └── visualizations.R     # Results visualization
├── output/
│   └── tables/                 # Generated tables and figures

```

## Setup Instructions

1. **DHS Data Access**
   - Register at the [DHS Program](http://www.dhsprogram.com/data/new-user-registration.cfm)
   - Request access to the required datasets
   - Download the data files once access is granted

2. **Software Requirements**
   - Stata (version 14 or higher)
   - R (version 4.0 or higher)
   - Required R packages:
     ```r
     install.packages(c("tidyverse", "gt", "haven"))
     ```
   - Required Stata packages:
     ```stata
     ssc install reghdfe
     ssc install estout
     ```

3. **Data Preparation**
   - Place DHS data files in the `data/dhs/` directory
   - Download World Bank indicators and save in `data/wb/`
   - The maternity leave data (`mat_leave_country_year.dta`) is provided in the repository

## Running the Analysis

1. **Data Processing**
   ```stata
   do "code/01_data_cleaning.do"
   do "code/02_data_merging.do"
   ```

2. **Statistical Analysis**
   ```stata
   do "code/03_analysis.do"
   ```

3. **Generate Tables**
   ```r
   source("code/04_visualizations.R")
   ```

## Output

The code generates:
- Regression tables with three model specifications
- Summary statistics
- Data quality checks
- Formatted tables for publication

## Notes

- Height-for-age z-scores are truncated at ±6 to remove extreme values
- Standard errors are clustered at the country level
- The analysis period covers 1995-2013
- All monetary variables are in current US dollars

## Citation
Original paper: Jahagirdar, Deepa & Harper, Sam & Heymann, Jody & Swaminathan, Hema & Mukherji, Arnab & Nandi, Arijit. (2017). The effect of paid maternity leave on early childhood growth in low-income and middle-income countries. BMJ Global Health. 2. e000294. 10.1136/bmjgh-2017-000294. 
