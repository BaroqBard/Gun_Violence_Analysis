library(stringr)

gun.orig = read.csv('gun-violence-data_01-2013_03-2018.csv')


#make empty dataframe for appending
gun.df = data.frame(Incident_ID = character(),
                    Participant_Type = character())

"
####Participant Data to Clean####
Participant Age
Participant Age Group
Participant Gender
Participant Status
Participant Type
"


strcleaning = function (x){
  #takes in factor
  x = gsub("\\|", " ", x)
  x = str_squish(x)
  x = strsplit(x, " ")
  
  #returns list of strings
  return(x)
}

for (i in 1:length(gun.orig$incident_id)){
  #clean factors into list of strings
  
  #make a matrix, id x cleanstrings
  
  #append to dataframe
  do.call(rbind.data.frame, )
  
}




t.var = gun.orig$participant_type[1]
