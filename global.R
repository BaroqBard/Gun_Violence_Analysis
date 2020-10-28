# Library Imports ####
library(shinydashboard)
library(dplyr)    
library(stringr)  
library(leaflet)
library(maps)
library(googleVis)


#Data Import ####
gundata = read.csv('Gun_Orig.csv', stringsAsFactors = F)
partdata = read.csv('Part_Data.csv', stringsAsFactors = F)

#Map Data Prep ####
gun.counties = map("county", fill = T, plot = F)  


#date.choice for the sidebar
d.range = unique(gundata$date)

date.end = unique(gundata$date)
chara.choice = c('All', 'Shot - Dead', 'Shot - Wounded/Injured', 'Shots Fired',
                 'Non-Shooting', 'Accidental Shooting', 'Negligent Discharge',
                 'Officer Involved Incident', 'Officer Involved Shooting', 
                 'School', 'Home Invasion', 'Resident injured', 'Resident killed',
                 'Mass Shooting', 'Suicide', 'Murder/Suicide', 'Armed robbery',
                 'Drive-by', 'Car-jacking', 'TSA Action', 'Terror', 
                 'Possession of gun by felon')

# Dependent elements

'
Characteristics of interest

chara.choice details, grepl for them

IN which(grepl("Terror", gundata$incident_characteristics))


'