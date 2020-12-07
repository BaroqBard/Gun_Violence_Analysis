# Library Imports ####
library(shinydashboard)
library(dplyr)    
library(stringr)  
library(leaflet)
library(maps)
library(DT)
library(ggplot2)
library(googleVis)
library(plotly)
library(ggthemes)
library(scales)
library(datasets)

#Data Import ####
gundata = read.csv('Gun_Orig.csv', stringsAsFactors = F)

partdata = read.csv('Part_Data_Clean.csv', stringsAsFactors = F)

weapondata = read.csv('Guns_Involved.csv', stringsAsFactors = F)

popdata = read.csv('State_Pops.csv', stringsAsFactors = F) %>% 
  select(., 1,2,3) %>% 
  rename(., state = State)

lawdata = read.csv('Gun_Laws_Clean.csv', stringsAsFactors = F) %>% 
  rename(., state = State)
  
# Functions ####
req_to_bool = function(x) {
  if (x == "Required") {
    x = TRUE
  } else {
    x = FALSE
  }
  
  return(x)
}

yes_to_bool = function(x) {
  if (x == "Yes") {
    x = FALSE
  } else {
    x = TRUE
  }
  
  return(x)
}

# Vars to Use ####
targ.range = c('Shots Fired', 'Shot - Wounded/Injured', 'Shot - Dead', 
               'Non-Shooting', 'Accidental Shooting', 
               'Officer Involved Incident', 'Officer Involved Shooting', 
               'School', 'Home Invasion', 'Resident injured', 'Resident killed',
               'Mass Shooting', 'Suicide', 'Murder/Suicide', 'Armed robbery',
               'Drive-by', 'Car-jacking', 'TSA Action', 'Terror', 
               'Gun(s) stolen from owner', 'Possession of gun by felon',
               'Stolen/Illegally owned')

