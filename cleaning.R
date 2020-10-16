### Clean & Prepare Rich Gun Data ###
# The participant categories are especially rich dictionaries
# The goal here is to expand the data set to account for
# Participants separately

library(dplyr)
library(tidyr)

gun.orig = read.csv('gun-violence-data_01-2013_03-2018.csv', 
                    stringsAsFactors = F)

# Participant Data Processing ####

# Cleans vector of strings
char.cleaner = function (x) {
  require(stringr)
  require(rlang)
  
  if (is_empty(x)) {
    return(c("N/A"))
    
  } else {
    x = gsub(" ", "", x)
    x = gsub("\\|", " ", x)
    x = str_squish(x)
    x = gsub("\\::", "\\:", x)
    x = strsplit(x, " ")
    
    return(x)
  }
}

### Clean the needed cols ### 
# Incident ID
# Participant Type
# Participant Age
# Participant Age Group
# Participant Gender
# Participant Status


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

# create dfs for each type to join later by id 
# sep into ID, Part.Key, and Part.Type cols

part.type = gun.orig %>% 
  select(., incident_id, participant_type) %>% 
  unchop(., participant_type, keep_empty = T) %>% 
  unchop(., participant_type, keep_empty = T) %>% 
  separate(., participant_type, c("key", "participant_type"), sep = ":")

part.age = gun.orig %>% 
  select(., incident_id, participant_age) %>% 
  unchop(., participant_age, keep_empty = T) %>% 
  unchop(., participant_age, keep_empty = T) %>% 
  separate(., participant_age, c("key", "participant_age"), sep = ":")

part.age_group = gun.orig %>% 
  select(., incident_id, participant_age_group) %>% 
  unchop(., participant_age_group, keep_empty = T) %>% 
  unchop(., participant_age_group, keep_empty = T) %>% 
  separate(., participant_age_group, c("key", "participant_age_group"), sep = ":")

part.gender = gun.orig %>% 
  select(., incident_id, participant_gender) %>% 
  unchop(., participant_gender, keep_empty = T) %>% 
  unchop(., participant_gender, keep_empty = T) %>% 
  separate(., participant_gender, c("key", "participant_gender"), sep = ":")

part.status = gun.orig %>% 
  select(., incident_id, participant_status) %>% 
  unchop(., participant_status, keep_empty = T) %>% 
  unchop(., participant_status, keep_empty = T) %>% 
  separate(., participant_status, c("key", "participant_status"), sep = ":")

# Next Section Imminent ####