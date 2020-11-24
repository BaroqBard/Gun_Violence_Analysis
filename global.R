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


#Data Import ####
gundata = read.csv('Gun_Orig.csv', stringsAsFactors = F)
partdata = read.csv('Part_Data.csv', stringsAsFactors = F)
weapondata = read.csv('Guns_Involved.csv', stringsAsFactors = F)
popdata = read.csv('State_Pops.csv', stringsAsFactors = F) %>% 
  select(., 1,2,3) %>% 
  rename(., state = State)
lawdata = read.csv('Gun_Laws_Clean.csv', stringsAsFactors = F) %>% 
  rename(., state = State)


#date.choice for the sidebar
targ.range = c('Shots Fired', 'Shot - Wounded/Injured', 'Shot - Dead', 
               'Non-Shooting', 'Accidental Shooting', 'Negligent Discharge',
               'Officer Involved Incident', 'Officer Involved Shooting', 
               'School', 'Gun at school', 'Home Invasion', 'Resident injured', 'Resident killed',
               'Mass Shooting', 'Suicide', 'Murder/Suicide', 'Armed robbery',
               'Drive-by', 'Car-jacking', 'TSA Action', 'Terror', 
               'Gun(s) stolen from owner', 'Possession of gun by felon',
               'Stolen/Illegally owned')

