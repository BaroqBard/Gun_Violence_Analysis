



shinyUI(dashboardPage(
  # Header Section ####
  dashboardHeader(title = "US Gun Violence"),
  
  # Sidebar Section ####
  dashboardSidebar(
    ## * Initial Menu Tabs ####
    sidebarMenu(
      menuItem("A Shiny App by Theodore Cheek",
               icon = NULL,
               href = "https://www.linkedin.com/in/theodorecheek/"),
      menuItem('State Dashboard',
               tabName = 'Breakdown',
               icon = icon("map")),
      menuItem(
        'National Dashboard',
        tabName = 'Involvement',
        icon = icon('users')
      ),
      menuItem(
        'Data Reporting',
        tabName = "News",
        icon = icon("newspaper")
      )
    ),
    
    ## * Daterange Slider ####
    sliderInput(
      "daterange",
      "Select a Date Range",
      min = as.Date("2013-01-01"),
      max = as.Date("2018-03-01"),
      value = c(as.Date("2014-01-01"), as.Date("2018-03-01")),
      timeFormat = "%b %Y"
    ),
    
    ## * Characteristic Drop-down ####
    selectizeInput("targ.char",
                   "Select Target Characteristic",
                   targ.range),
    br(),
    
    ## * Sources Sidebar ####
    sidebarMenu(
      menuItem(
        "Sources",
        icon = icon("folder-open"),
        menuSubItem(
          "Github R Source Code",
          icon = icon("file-code-o"),
          href = "https://github.com/BaroqBard/Gun_Violence_Analysis"
        ),
        menuSubItem(
          "Kaggle Web-Scraped Data",
          icon = icon("list-alt"),
          href = "https://www.kaggle.com/jameslko/gun-violence-data"
        ),
        menuSubItem(
          "Gun Violence Archive",
          icon = icon("list-alt"),
          href = "https://www.gunviolencearchive.org/"
        ),
        menuSubItem(
          "Population Data",
          icon = icon("list-alt"),
          href = "https://worldpopulationreview.com/states"
        ),
        menuSubItem(
          "Gun Laws by State 2020",
          icon = icon("list-alt"),
          href = "https://worldpopulationreview.com/state-rankings/gun-laws-by-state"
        )
      ),
      menuItem(
        "Blog Post - Using this Website",
        icon = icon("blog"),
        href = ""
      ),
      menuItem(
        "~ Theodore Cheek LinkedIn ~",
        icon = icon("linkedin"),
        href = "https://www.linkedin.com/in/theodorecheek/"
      )
    )
    
  ),
  
  # Body Section ####
  dashboardBody(tabItems(
    tabItem(tabName = "Breakdown",
            tabsetPanel(
              tabPanel(
                ## * State Dashboard ####
                "State Dashboard",
                fluidRow(
                  box(
                    title = "Incident Density Tracker by State",
                    solidHeader = T,
                    status = "primary",
                    htmlOutput("gun.map"),
                    footer = "Hover for individual state information",
                    width = 12
                  )
                ),
                fluidRow(
                  box(
                    title = "Choose a Scale:",
                    solidHeader = T,
                    "Select whether incidents are displayed per capita or
                      by total",
                    status = "success",
                    radioButtons(
                      inputId = "pop_scale",
                      label = NULL,
                      choices = c("Per Capita x 100,000" = "percap",
                                  "Per Incident" = "identity")
                    ),
                    width = 3
                  ),
                  
                  infoBoxOutput("dashMax"),
                  infoBoxOutput("dashMeanGuns"),
                  infoBoxOutput("dashMaxInj"),
                  infoBoxOutput("dashMaxKill")
                  
                )
              ),
              
              tabPanel(## * Legal Analysis ####
                       "Legal Analysis",
                       fluidRow(
                         box(
                           title = "Relationship between State Regulations & Incident Fallout",
                           solidHeader = T,
                           status = "primary",
                           htmlOutput("dash.law"),
                           footer = "The bubble color represents the density of
                           statewide restrictions on Weaponry. Filter these 
                           below. Scroll Up to Zoom Out, Scroll Down to 
                           Zoom in. Click & Drag to Pan, Right-click to Reset",
                           width = 12
                         )
                         
                       ),
                       fluidRow(
                         box(
                           title = "State Weapon Regulations",
                           solidHeader = T,
                           status = "success",
                           checkboxGroupInput(
                             "legal.parameter",
                             "Select Included Weapon Restrictions:",
                             c(
                               "Firearm Registration" = "Fire",
                               "Carry Permit" = "Carry",
                               "Purchase Permit" = "Purchase",
                               "Open Carry Restricted" = "Open"
                             ),
                             selected = c("Fire",
                                          "Carry",
                                          "Purchase",
                                          "Open")
                           ),
                           width = 6
                           
                         ),
                         box(
                           title = "Select Parameter & Scaling",
                           solidHeader = T,
                           "Secondary Characteristic: ",
                           status = "warning",
                           selectizeInput(
                             inputId = "state.cat",
                             label = NULL,
                             choices = c("Injured",
                                         "Killed",
                                         "Guns")
                           ),
                           "Display scale: ",
                           radioButtons(
                             inputId = "state.scale",
                             label = NULL,
                             choices = c("Per Capita x 100,000" = "percap",
                                         "Total Incidents" = "identity")
                           ),
                           width = 6
                         )#,
                         # box(
                         #   title = "Select Display Mode",
                         #   solidHeader = T,
                         #   status = "warning",
                         #   "Select graph color value",
                         #   radioButtons(
                         #     inputId = "display.mode",
                         #     label = NULL,
                         #     choices = c(
                         #       "Weaponry Restrictions" = "Restrictions",
                         #       "Difference from Mean" = "Difference"
                         #     )
                         #   ),
                         #   # "Include ONLY States with Selected Restrictions",
                         #   # checkboxInput(
                         #   #   inputId = "focus.restriction",
                         #   #   label = "Restrict Selection",
                         #   #   value = FALSE
                         #   # ),
                         #   width = 4
                         # )
                       ),
                       
                       
                       fluidRow(
                         box(
                           title = "Searchable Legal & Incidental State Data",
                           solidHeader = T,
                           status = "info",
                           DT::dataTableOutput("dashtable"),
                           width = 12
                         )
                         
                       ))
            )),
    
    
    # WHO is involved? Details of Victims & Suspects
    tabItem(tabName = "Involvement",
            tabsetPanel(
              ## * Participant Data ####
              tabPanel(
                "Participant Data",
                # put the boxes here
                fluidRow(
                  box(
                    title = "Age Distribution of Incident Participants",
                    status = "primary",
                    solidHeader = T,
                    plotlyOutput("part.age"),
                    width = 12
                  )
                ),
                
                fluidRow(
                  box(
                    title = "Proportional Age Involvement",
                    status = "info",
                    solidHeader = T,
                    plotOutput("part.agegroup",
                               width = "100%",
                               height = "250px"),
                    width = 6
                  ),
                  valueBoxOutput("vic.age", width = 3),
                  valueBoxOutput("sus.age", width = 3),
                  infoBoxOutput("sus.outcome", width = 6),
                  infoBoxOutput("vic.outcome", width = 6)
                ),
                
                fluidRow(
                  box(
                    title = "Subsequent Status of Participants (Log Scale)",
                    status = "success",
                    solidHeader = T,
                    plotlyOutput("part.status"),
                    width = 12
                  )
                  
                )
                
              ),
              ## * Coincident Details ####
              tabPanel(
                "Coincidental Details",
                fluidRow(
                  box(
                    title = "Visual Record of Incidents Over Time",
                    status = "primary",
                    solidHeader = T,
                    plotlyOutput("natl.timeline"),
                    width = 12
                  )
                ),
                fluidRow(
                  box(
                    title = "Primary Coincidence",
                    status = "warning",
                    solidHeader = T,
                    plotOutput("natl.coinc1",
                               height = "160px"),
                    width = 4
                  ),
                  box(
                    title = "Secondary Coincidence",
                    status = "warning",
                    solidHeader = T,
                    plotOutput("natl.coinc2",
                               height = "160px"),
                    width = 4
                  ),
                  box(
                    title = "Tertiary Coincidence",
                    status = "warning",
                    solidHeader = T,
                    plotOutput("natl.coinc3",
                               height = "160px"),
                    width = 4
                  )
                ),
                fluidRow(
                  box(
                    title = "Concurrent Incident Characteristics",
                    status = "info",
                    solidHeader = T,
                    "The following characteristics represent the most
                             common, coincident characteristics, featured
                             alongside your target characteristic",
                    DT::dataTableOutput("coincident.table"),
                    width = 6
                  ),
                  box(
                    title = "Weaponry Most Often Reported",
                    status = "info",
                    solidHeader = T,
                    "The following weapons are most often recognized
                             in reports of gun violence per your selection.
                             This section includes BOTH Guns & Ammunition",
                    DT::dataTableOutput("weapons.table"),
                    width = 6
                  )
                )
              )
            )),
    
    
    tabItem(tabName = "News",
            tabsetPanel(
              ## * Filtered, Searchable Data ####
              tabPanel("Filtered, Searchable Data",
                       fluidRow(
                         box(
                           title = "Select Details from the Filtered Dataset",
                           status = "primary",
                           solidHeader = T,
                           "Here you will find searchable, selected notes
                             from the dataset that has been filtered according
                             to your target characteristic. In order to save
                             this selection, use the buttons below to capture
                             the information",
                           DT::dataTableOutput("detailtable"),
                           width = 12
                         )
                       )),
              ## * Original Unfiltered Dataset
              tabPanel("Original, Unfiltered Dataset",
                       fluidRow(
                         box(
                           title = "Original, Unfiltered Incident Data",
                           status = "warning",
                           solidHeader = T,
                           "Below you may find the raw, unfiltered dataset,
                             which I acquired from Kaggle. Feel free to peruse it
                             here, however, if you wish for further documentation,
                             please navigate to the Kaggle link in the Sources
                             drop-down",
                           DT::dataTableOutput("guntable"),
                           width = 12
                         )
                       ))
              
            ))
  ))
))
