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

#Map Data Prep ####
counties = map("county", fill = T, plot = F)  



#date.choice for the sidebar
d.range = unique(gundata$date)

date.end = unique(gundata$date)

targ.range = c('Shot - Dead', 'Shot - Wounded/Injured', 'Shots Fired',
               'Non-Shooting', 'Accidental Shooting', 'Negligent Discharge',
               'Officer Involved Incident', 'Officer Involved Shooting', 
               'School', 'Gun at school', 'Home Invasion', 'Resident injured', 'Resident killed',
               'Mass Shooting', 'Suicide', 'Murder/Suicide', 'Armed robbery',
               'Drive-by', 'Car-jacking', 'TSA Action', 'Terror', 
               'Gun\\(s\\) stolen from owner', 'Possession of gun by felon',
               'Stolen/Illegally owned')

# targ.char2 = c('Age Group')

