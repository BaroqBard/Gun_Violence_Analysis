

shinyUI(
  dashboardPage(
    # Header Section ####
    dashboardHeader(
      title = "US Gun Violence"
    ),
    
    # Sidebar Section ####
    dashboardSidebar(
      ## * Initial Menu Tabs ####
      sidebarMenu(
        menuItem("A Shiny App by Theodore Cheek",
                 icon = NULL, 
                 href = "https://www.linkedin.com/in/theodorecheek/"),
        menuItem('Incident Dashboard', tabName = 'Breakdown', icon = icon("map")),
        menuItem('National Characteristics', tabName = 'Involvement', icon = icon('users')),
        menuItem('Data Reporting', tabName = "News", icon = icon("newspaper"))
      ),
      
      ## * Daterange Slider ####
      sliderInput("daterange",
                  "Select a Date Range",
                  min = as.Date("2013-01-01"),
                  max = as.Date("2018-03-01"),
                  value = c(as.Date("2014-01-01"), as.Date("2018-03-01")),
                  timeFormat = "%b %Y"),
      
      ## * Characteristic Drop-down ####
      selectizeInput("targ.char",
                     "Select Target Characteristic",
                     targ.range),
      br(),
      
      ## * Sources Sidebar ####
      sidebarMenu(
        menuItem("Sources", icon = icon("folder-open"),
                 menuSubItem("Github R Source Code", icon = icon("file-code-o"),
                             href = "https://github.com/BaroqBard/Gun_Violence_Analysis"),
                 menuSubItem("Kaggle Web-Scraped Data", icon = icon("list-alt"),
                             href = "https://www.kaggle.com/jameslko/gun-violence-data"),
                 menuSubItem("Gun Violence Archive", icon = icon("list-alt"),
                             href = "https://www.gunviolencearchive.org/"),
                 menuSubItem("Population Data", icon = icon("list-alt"),
                             href = "https://worldpopulationreview.com/states"),
                 menuSubItem("Gun Laws by State 2020", icon = icon("list-alt"),
                             href = "https://worldpopulationreview.com/state-rankings/gun-laws-by-state")),
        menuItem("Blog Post - Using this Website", icon = icon("blog"),
                 href = ""),
        menuItem("~ Theodore Cheek LinkedIn ~", icon = icon("linkedin"),
                 href = "https://www.linkedin.com/in/theodorecheek/")
      )

    ),
    
    # Body Section ####
    dashboardBody(tabItems(
      tabItem(tabName = "Breakdown",
              tabsetPanel(
                tabPanel(
                  ## * Incident Dashboard ####
                  "Incident Dashboard",
                  fluidRow(
                    box(
                      title = "Incident Tracker by State",
                      solidHeader = T,
                      status = "primary",
                      htmlOutput("gun.map"),
                      width = 12
                    )
                  ),
                  fluidRow(
                    box(
                      title = "Choose a Scale:",
                      solidHeader = T,
                      "Select whether incidents are displayed per capita or
                      by total",
                      status = "warning",
                      radioButtons(inputId = "pop_scale",
                                   label = NULL,
                                   choices = c("Per Capita x 100,000" = "percap",
                                               "Per Incident" = "identity")),
                      width = 3
                    ),
                    
                    infoBoxOutput("dashMax"),
                    infoBoxOutput("dashMeanGuns"),
                    infoBoxOutput("dashMaxInj"),
                    infoBoxOutput("dashMaxKill")
                    
                  ),
                  fluidRow(
                    box(
                      title = "Data by State",
                      solidHeader = T,
                      status = "primary",
                      DT::dataTableOutput("dashtable"),
                      width = 12
                    )
                  )
                ),
                
                tabPanel(
                  ## * Legal Ramifications ####
                  "Legal Ramifications",
                  fluidRow(
                    box(
                      title = "State Weapon Laws",
                      solidHeader = T,
                      status = "warning",
                      checkboxGroupInput("legal.parameter", 
                                         "Choose Your Legal Parameters:",
                                         c("Firearm Registration" = "Firearm.Registration",
                                           "Carry Permit" = "Carry.Permit",
                                           "Purchase Permit" = "Purchase.Permit",
                                           "Open Carry" = "Open.Carry")),
                      width = 3
                      
                    ),
                    box(
                      title = "Select Parameters",
                      solidHeader = T,
                      "Secondary Characteristic: ",
                      status = "warning",
                      selectizeInput(inputId = "state.cat",
                                     label = NULL,
                                     choices = c("Injured",
                                                 "Killed",
                                                 "Guns")),
                      "Display scale: ",
                      radioButtons(inputId = "state.scale",
                                   label = NULL,
                                   choices = c("Per Capita x 100,000" = "percap",
                                               "Per Incident" = "identity")),
                      width = 3
                    )
                  ),
                  
                  fluidRow(
                    box(
                      title = "State Gun Friendliness; Breakdown Per Incident",
                      solidHeader = T,
                      status = "primary",
                      htmlOutput("dash.law"),
                      width = 12
                    )
                    
                  )
                  
                )
              )
              ),
      

      # WHO is involved? Details of Victims & Suspects
      tabItem(tabName = "Involvement",
              tabsetPanel(
                ## * Participant Involvement ####
                tabPanel("Participant Involvement",
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
                             status = "warning",
                             solidHeader = T,
                             plotOutput("part.agegroup",
                                        width = "100%",
                                        height = "250px"),
                             width = 6
                           )
                         ),
                         
                         fluidRow(
                           box(
                             title = "Subsequent Status of Participants",
                             status = "primary",
                             solidHeader = T,
                             plotlyOutput("part.status"),
                             width = 12
                           )
                           
                         )
                         
                         ),
                ## * Coincident Details ####
                tabPanel("Coincidental Details",
                         fluidRow(
                           box(
                             title = "Timeline Data",
                             status = "primary",
                             solidHeader = T,
                             plotlyOutput("natl.timeline"),
                             width = 12
                           ),
                           box(
                             title = "Primary Association",
                             status = "warning",
                             solidHeader = T,
                             plotOutput("natl.coinc1",
                                          height = "120px"),
                             width = 4
                           ),
                           box(
                             title = "Secondary Association",
                             status = "warning",
                             solidHeader = T,
                             plotOutput("natl.coinc2",
                                          height = "120px"),
                             width = 4
                           ),
                           box(
                             title = "Third Association",
                             status = "warning",
                             solidHeader = T,
                             plotOutput("natl.coinc3",
                                          height = "120px"),
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
                             title = "Weapons Most Often Involved",
                             status = "info",
                             solidHeader = T,
                             "The following weapons are most often recognized 
                             in reports of gun violence per your selection",
                             DT::dataTableOutput("weapons.table"),
                             width = 6
                           )
                         ))
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
                         )),
                
                tabPanel("Participant Data", fluidRow(box(
                  DT::dataTableOutput("parttable"), width = 12
                )))
                
              ))
    ))
))
