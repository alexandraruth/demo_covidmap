##### Description: This is a script that maps the locations of nursing homes in the U.S. and pulls in recent CDC Covid-19 case data in surrounding counties using the Socrata API.

##### Author: Ali Ruth 
##### Date last updated: 2023-04-18

### BEFORE YOU BEGIN: 

# 1) Make sure that you have installed the relevant packages (use the "install.packages("PACKAGENAME") command)
# 2) Ensure that you've registered for a census API key. You can register and immediately receive a key here: https://api.census.gov/data/key_signup.html  
# 3) If you are doing small queries, you shouldn't need to register for a Socrata App token, but if you do need one you can register here: https://dev.socrata.com/docs/app-tokens.html
# 4) Make sure you have all the files and data you need - especially the .Rda file - in your current working directory (I recommend using .Rproj to organize this)

### LINKS TO LEARNING RESOURCES:

#  tidycensus package documentation: https://walker-data.com/tidycensus/
#  tidycensus book (highly recommend!): https://walker-data.com/census-r/index.html
#  Socrata CDC COVID dataset page: https://dev.socrata.com/foundry/data.cdc.gov/3nnm-4jni


# Setup: load packages and nursing home point geometry dataset ----

library(tidyverse)   # allows for data merging, import, cleaning
library(tidycensus)  # accesses Census API for census data queries and state/county shapefiles
library(RSocrata)    # accesses Socrata API to pull county-level CDC Covid data
library(mapview)     # provides interactive mapping functions


load("snf_sf.Rda") # this is a static dataset with geographic coordinates for nursing homes (SNFs) in the U.S., already converted to sf format for mapping

# ^NOTE: SNF location dataset is outdated and should be used for demo purposes only. This is a dataset that I manually saved in 2020/2021 back when CMS was reporting geographic coordinates for SNFs. Some coordinates are missing and errors are present. Maintaining up-to-date, accurate geographic fields for U.S. nursing homes is an ongoing federal challenge given SNF ownership turnover, closures, and state-level heterogeneity in reporting.


# Setup: Store Census API key ----

# enter your specific API key below

census_api_key("YOUR-KEY-HERE", overwrite = FALSE, install = FALSE)



############ PART I: Using APIs to get county covid map data ----

# Task: Map an individual state's COVID transmission levels and nursing home locations on a specified date (here, we use 2023-01-05)

# Using the Census API: Get state's county-level shapefile from Census API using tidycensus package ----

state <- get_acs(
  geography = "county", 
  variables = "B19013_001",   # note - this is a household income census ACS variable. we don't need it for our task but tidycensus requires at least one variable input
  state = "New Mexico",
  year = 2021,
  geometry = TRUE
)

# check shapefile correctness

mapview(state)

# Using the Socrata API: For a given state, pull in CDC's county-level COVID data using RSocrata package ----

county_covid <- read.socrata("https://data.cdc.gov/resource/3nnm-4jni.json?date_updated=2023-01-05T00:00:00.000&state=New Mexico")

# merge shapefile and covid dataframes to generate county covid map

state <- state %>%
  mutate(county_fips = GEOID)

state_covid <- merge(state, county_covid, by="county_fips", all.x=T)

state_map <- mapview(state_covid, zcol = "covid_19_community_level")

state_map


# ADD ON A LAYER: state-level SNF locations

state_snf <- snf_sf %>%
  filter(state =="New Mexico")

snf_map = mapview(state_snf, cex = 2, legend = FALSE)


# combine map layers to map locations of SNFs & county case rates

state_map + snf_map


##################################### ----

############ PART II: Automating the COVID map ----


## Let's get fancy!

## Task: Write a function that pulls in data for a user-entered state with a pre-specified date (we use 2023-01-05 again here)


# Writing our function: This is very similar to the code above but it pastes user input into our code chunks with a user-entered state name

map_covidrisk <- function(user_state) {
  
  user_state = as.character(user_state)
  
  # pull in shapefile for state input using Census API
  
  state_geo <- get_acs(
    geography = "county", 
    variables = "B19013_001",
    state = user_state, 
    year = 2021,
    geometry = TRUE
  )
  
  # build a Socrata query from the user input
  
  url <- paste0("https://data.cdc.gov/resource/3nnm-4jni.json?date_updated=2023-01-05T00:00:00.000&state=", user_state)
  
  # read in covid data for state using Socrata API for the query constructed above
  
  county_covid <- read.socrata(url)
  
  county_covid <- county_covid %>%
    select(county_fips, county, county_population, covid_19_community_level)
  
  # merge dataframes and map county covid
  
  state_geo <- state_geo %>%
    select(GEOID, geometry) %>%
    mutate(county_fips = GEOID)
  
  state_covid <- merge(state_geo, county_covid, by="county_fips", all.x=T)
  
  state_map <- mapview(state_covid, zcol = "covid_19_community_level")
  
  # filter SNF locations for state and map SNF points
  
  state_snf <- snf_sf %>%
    filter(state == user_state)
  
  snf_map = mapview(state_snf, cex = 2, legend = FALSE)
  
  # combine and return both map layers 
  
  state_map + snf_map
} 

# try the function out with your state of interest!

map_covidrisk("California")

map_covidrisk("New Hampshire")



##### END #######

