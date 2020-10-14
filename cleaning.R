#### Clean & Prepare Rich Gun Data ####
# The participant categories are especially rich dictionaries
# The goal here is to expand the data set to account for
# Participants separately
library(dplyr)
library(tidyr)

gun.orig = read.csv('gun-violence-data_01-2013_03-2018.csv', 
                    stringsAsFactors = F)


"
####Participant Data to Clean####
---------------------------------
Incident ID
Participant Type
Participant Age
Participant Age Group
Participant Gender
Participant Status
"

#takes in character, returns vector of chars
char.cleaner = function (x) {
  require(stringr)
  
  if (is.null(x)) {
    return("N/A")
    
  } else {
    x = gsub(" ", "", x)
    x = gsub("\\|", " ", x)
    x = str_squish(x)
    x = strsplit(x, " ")
    
    return(x)
  }
}

#tidyr chop???? preserve width, lengthen dataframe, works on lists

gun.orig$participant_type = lapply(gun.orig$participant_type, 
                                  char.cleaner)
gun.orig$participant_age = lapply(gun.orig$participant_age, 
                                  char.cleaner)
gun.orig$participant_age_group = lapply(gun.orig$participant_age_group, 
                                  char.cleaner)
gun.orig$participant_gender = lapply(gun.orig$participant_gender, 
                                  char.cleaner)
gun.orig$participant_status = lapply(gun.orig$participant_status,
                                  char.cleaner)

#note for next time: add in and work on separators for this sect
# sep into key columns, join, select out


part.type = gun.orig %>% 
  select(., incident_id, participant_type) %>% 
  unchop(., participant_type)
part.age = gun.orig %>% 
  select(., incident_id, participant_age) %>% 
  unchop(., participant_age)
part.age_group = gun.orig %>% 
  select(., incident_id, participant_age_group) %>% 
  unchop(., participant_age_group)
part.gender = gun.orig %>% 
  select(., incident_id, participant_gender) %>% 
  unchop(., participant_gender)
part.status = gun.orig %>% 
  select(., incident_id, participant_status) %>% 
  unchop(., participant_status)
