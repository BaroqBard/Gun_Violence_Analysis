# Library Imports ####
library(dplyr)    #for dplyr goodness
library(stringr)  #to mess with factor characters
library(leaflet)
library(maps)


#Data Import ####
gundata = read.csv('gun-violence-data_01-2013_03-2018.csv')


#Map Data Prep ####
gun.counties = map("county", fill = T, plot = F)  


#date.choice for the sidebar
date.choice = unique(gundata$date)
chara.choice = c()