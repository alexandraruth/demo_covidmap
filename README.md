# DEMO: Using the Socrata developer platform to map county-level COVID data using federal dataset APIs

This presentation demonstrates use of the Socrata Developer Platform and the U.S. Census API for mapping COVID-19 risk at skilled nursing facilities in the U.S. based on county-level COVID transmission nearby.


**Learning resources:**
+ Documentation for `tidycensus` package: https://walker-data.com/tidycensus/
+ Online book on `tidycensus`, "Analyzing U.S. Census Data" by Kyle Walker (highly recommend!):  https://walker-data.com/census-r/index.html
+ Documentation for Socrata dataset: https://dev.socrata.com/foundry/data.cdc.gov/3nnm-4jni 

**R packages used:**
+ `tidyverse` for importing, cleaning, and manipulating data
+ `tidycensus` for accessing the Census API and getting Census variables 
+ `RSocrata` for accessing the Socrata platform housing the CDC's COVID-19 county-level data
+ `mapview` for simple mapping
