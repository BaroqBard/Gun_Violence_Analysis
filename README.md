# Gun Violence Analysis Shiny Website

### [Website](https://theodorecheek.shinyapps.io/GunViolence) | [LinkedIn](https://www.linkedin.com/in/theodorecheek)

---------------------------------------------------

### This website serves two primary functions: 
1) To provide a transparent, user-friendly interface to encourage the exploration national data on Gun Violence, originally collected & collated by the Gun Violence Archive (this particular data was scraped and recorded on [Kaggle](https://www.kaggle.com/jameslko/gun-violence-data)). 
2) To furnish the user with the ability to cross analyse the data with national legal data and population data. 

### Background:
The [Gun Violence Archive](https://www.gunviolencearchive.org/) was founded in 2013 to track Gun Violence Data across the US for two reasons: 1) the FBI & CDC have been observed to under-report casualties in incidents of gun violence, and 2) the NRA pushed Congress in 1996 to prevent Federal Funding from going to research that might be used to curtail gun ownership.

Mark Bryant, a gun & gun safety hobbyist, founded the non-profit in the wake of the school shooting by Adam Lanza in December 2012. Originally run from his home, the group has a number of researchers who reach out to original sources as well as official ones to verify the nature of the incident thoroughly. In spite of this, Bryant deliberately leaves analysis absent from the website in order that its readers may "draw their own conclusions". Funding for the non-profit comes entirely from the pocket of co-founder and retired commercial real estate mogul, Michael Klein.

While Bryant is very outspoken on the topic of how clearly the data show that background checking on gun purchasing is absolutely necessary, I believe that the presentation of the website fails to adequately encourage the very exploration of the data that would build awareness of the data. To this end, I have constructed this Shiny App to both enable easy exploration of the data as well as to enable some cross-analysis with state population data as well as state legal data.

---------------------------------------------------

## Notes Regarding the Code & the App

The app is broken down into the standard portions of a Shiny Dashboard App, however, includes with it a separate cleaning.R file. It is with this file that I first cleaned and compiled the data sets incorporated in the app itself. 

The original data set derived from the GVA was extremely rich and was catalogued by incident. Within each incident there were also interconnected dictionaries stretched between a number of columns, containing personal data. The first great task was to expand this into a separate dataframe of incidents organized by persons involved.

My primary tools in visualizing these data were GoogleVis, DT, ggplot, & Plotly. I found it useful to employ dplyr and tidyr as the primary tools for recombining data on the fly.

NB: the District of Columbia has largely been excluded from Geographical data as it features far more Gun Violence per capita than any state, such that it overbalances the Geographical significance of any of the other states. As I do believe this is an issue that should be raised publicly, I have plans to return to this project in the future to integrate it effectively.

For more information, please contact me at theodore.m.cheek@gmail.com or visit my LinkedIn above.

---------------------------------------------------
## [Blogpost & Writeup: Using this Website](https://nycdatascience.com/blog/student-works/us-gun-violence/)

### Text Excerpt: Navigating the Data

Usage of this website revolves largely around developing the focused study of a particular Target Characteristic. These terms, ranging from anything as general as "Shots Fired" to "TSA Action," were standardized and applied by the GVA accross the dataset to inclusively reflect the collective reporting of an incident, both through official and commercial channels.

The drop down on the left focuses the dataset on that particular kind of incident. From there, the app breaks down into two axes of study: 1) State & Legal trends, and 2) National Trends of the Characteristic. These can be explored respectively through the State Dashboard tab and the National Dashboard tab. It is important to note that, while I have incorporated all of the GVA's data, I have set the default start-date to January of 2014, rather than 2013. This selection reflects the significant increase in the GVA's data collection that occured at the end of 2013.

