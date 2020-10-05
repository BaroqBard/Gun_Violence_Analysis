# Library Import ####
library(dplyr)    #for dplyr goodness
library(stringr)  #to mess with factor characters




#Data Import ####
gundata = read.csv('gun-violence-data_01-2013_03-2018.csv')

"probably going to prep multiple data frames using this
Im thinking itll probably be expedient to make a dataframe
for each tab, uniquely cleaned here
"

#date.choice for the sidebar
date.choice = unique(gundata$date)