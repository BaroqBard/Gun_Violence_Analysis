### Clean & Prepare Rich Gun Data ###
'The selected dataset from kaggle is already very clean, however,
the participant columns are especially rich (read: dense)
and need unpacking. Here I will create a secondary dataset
for the purpose of in-depth analysis of persons involved

Kaggle source for the data:
https://www.kaggle.com/jameslko/gun-violence-data
'

# Processing Prep; import libraries, data, define functions ####
library(dplyr)
library(tidyr)
gun.orig = read.csv('gun-violence-data_01-2013_03-2018.csv', 
                    stringsAsFactors = F)

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



#### Original File Data Processing ####
'Participants will be processed later. The only change
I wish to make to the dataset at the moment is to alter
the Date column formats to as.Date for easier usage'

gun.orig$date = as.Date(gun.orig$date)


#### Participant Data Processing ####
'Each cell consists of a dictionary; numbered keys
connected to regular descriptors. In order to effectively
expand these data we perform the following:

 I.   Clean the columns, prepping them for separation
 II.  Separate each column into its own dataframe (5 total)
  --> dictionaries inherit incident_ID
 III. Split dictionary columns into key & characteristic
 IV.  Full_Join() the dataframes by incident_ID AND key'

# Select target participant characteristics
partic = gun.orig %>%
  select(
    .,
    incident_id,
    participant_type,
    participant_status,
    participant_gender,
    participant_age_group,
    participant_age
  )

# identify & index colnames for future assignment
pcols = data.frame(colnames(partic))

# loop to apply function & create preparatory dataframes
for (i in 2:6) {
  # apply char.cleaner to the dictionary columns
  partic[,i] = lapply(partic[, i, drop=F], char.cleaner)
  
  # separate&expand cols: incident_id, key#, participant
  x = partic %>% 
    select(., incident_id, any_of(i)) %>% 
    unchop(., 2) %>% 
    unchop(., 2) %>% 
    separate(., 2, c("key", paste(pcols[[1]][i])), sep = ":")

  # assign bespoke df for later full_join()
  assign(paste(pcols[[1]][i]), x)
  
}

# define final participant dataframe
all.parts = participant_type %>% 
  full_join(participant_status, by = c("incident_id", "key")) %>% 
  full_join(participant_gender, by = c("incident_id", "key")) %>% 
  full_join(participant_age_group, by = c("incident_id", "key")) %>% 
  full_join(participant_age, by = c("incident_id", "key"))

# take out the garbage data
all.parts = all.parts %>% 
  filter(., participant_gender == "Male" |
           participant_gender == "Female" |
           is.na(participant_gender) == T)

stat.cleaner = function(x) {
  if (is.na(x)) {
    x = "Missing Data"
  } else {
    x = gsub(",", ", ", x)
  }
  
}

all.parts$participant_status = sapply(all.parts$participant_status, stat.cleaner)

#### Gun Involvement Processing ####
'This section will perform a similar function to
that of the Participant Processing'

gun.inv = gundata %>% 
  select(., incident_id, gun_stolen, gun_type)

# Preserves Column Naming
gcols = data.frame(colnames(gun.inv))

# Loops through columns
for (i in 2:3) {
  gun.inv[,i] = lapply(gun.inv[, i, drop = F], char.cleaner)
  
  # Separates each column per incident_id, maintaining keys
  x = gun.inv %>% 
    select(., incident_id, any_of(i)) %>% 
    unchop(., 2) %>% 
    unchop(., 2) %>% 
    separate(., 2, c("key", paste(gcols[[1]][i])), sep = ":")
  
  # Assigns separate dfs per col, to preserve keys & ids
  assign(paste(gcols[[1]][i]), x)
  
}

all.guns = gun_type %>% 
  full_join(., gun_stolen, by = c("incident_id", "key"))

#### Law Data Processing ####
glaws = read.csv('Gun_Laws.csv', stringsAsFactors = F)

for (i in 2:4) {
  glaws[,i] = sapply(glaws[,i], function(x) ifelse(x == "true", "Required", "Not Required"))
  
}

glaws[, 5] = sapply(glaws[, 5], function(x) ifelse(x == "true", "Yes", "No"))

names(glaws) = c("State", "Firearm Registration", "Carry Permit", "Purchase Permit", "Open Carry")

#### Finalize Data; create csv's ####

#write.csv(all.guns, "/home/theodore/Gallery_Prime/RStuff/Projects/Shiny_GunViolence/Guns_Involved.csv")
#write.csv(all.parts, "/home/theodore/Gallery_Prime/RStuff/Projects/Shiny_GunViolence/Part_Data2.csv")
#write.csv(gun.orig, "/home/theodore/Gallery_Prime/RStuff/Projects/Shiny_GunViolence/Gun_Orig.csv")
#write.csv(glaws, "/home/theodore/Gallery_Prime/RStuff/Projects/Shiny_GunViolence/Gun_Laws_Clean.csv")

