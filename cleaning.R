### Clean & Prepare Rich Gun Data ###
# The participant categories are especially rich dictionaries
# The goal here is to expand the data set to account for
# Participants separately

# import libraries & initial dataset ####
library(dplyr)
library(tidyr)
gun.orig = read.csv('gun-violence-data_01-2013_03-2018.csv', 
                    stringsAsFactors = F)

# Participant Data Processing ####

# Function: Cleans vector or column of strings
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

# Use Dplyr to select participant characteristics
partic = gun.orig %>% 
  select(., incident_id,
         participant_type,
         participant_status,
         participant_gender,
         participant_age_group,
         participant_age)

# identify & index colnames for future assignment
pcols = data.frame(colnames(partic))

for (i in 2:6) {
  # apply char.cleaner to the dictionary columns
  partic[,i] = lapply(partic[, i, drop=F], char.cleaner)
  
  # separate the cleaned cols to person keys
  x = partic %>% 
    select(., incident_id, any_of(i)) %>% 
    unchop(., 2) %>% 
    unchop(., 2) %>% 
    separate(., 2, c("key", paste(pcols[[1]][i])), sep = ":")

  # assign 3 col df for later merging
  assign(paste(pcols[[1]][i]), x)
  
}

participants = part.type %>% full_join(part.status, by = c("incident_id", "key"))
participants = participants %>% full_join(part.gender, by = c("incident_id", "key"))
participants = participants %>% full_join(part.age_group, by = c("incident_id", "key"))
participants = participants %>% full_join(part.age, by = c("incident_id", "key"))
