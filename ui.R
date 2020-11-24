

shinyUI(
  dashboardPage(
    # Header Section ####
    dashboardHeader(
      title = "US Gun Violence"
    ),
    
    # Sidebar Section ####
    dashboardSidebar(
      # Menu setup for the tab selections
      sidebarMenu(
        menuItem("A Shiny App by Theodore Cheek",
                 icon = NULL, 
                 href = "https://www.linkedin.com/in/theodorecheek/"),
        menuItem('Incident Breakdown', tabName = 'Breakdown', icon = icon("map")),
        menuItem('Involvement', tabName = 'Involvement', icon = icon('users')),
        menuItem('Legality Ramifications', tabName = 'Legality', icon = icon('book')),
        menuItem('News & Data', tabName = "News", icon = icon("newspaper"))
      ),
      
      sliderInput("daterange",
                  "Select a Date Range",
                  min = as.Date("2013-01-01"),
                  max = as.Date("2018-03-01"),
                  value = c(as.Date("2013-01-01"), as.Date("2018-03-01")),
                  timeFormat = "%b %Y"),
      
      # Select target characteristic of study
      selectizeInput("targ.char",
                     "Select Target Characteristic",
                     targ.range),
      br(),
      
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
      # WHERE did this happen and are there geographical trends?
      tabItem(tabName = "Breakdown",
              tabsetPanel(
                tabPanel(
                  "Incident Dashboard",
                  fluidRow(
                    box(
                      title = "Map of Gun Violence across the Country",
                      solidHeader = T,
                      status = "primary",
                      htmlOutput("gun.map"),
                      width = 12
                    )
                  ),
                  
                  # throw in dashboard boxes here
                  # info, 1 toggling per-capita numbers
                  fluidRow(
                    box(
                      title = "Choose a Scale:",
                      solidHeader = T,
                      "Select whether incidents are displayed per capita or
                      by total",
                      status = "warning",
                      radioButtons(inputId = "pop_scale",
                                   label = NULL,
                                   choices = c("Per Capita x 1,000" = "percap",
                                               "Per Incident" = "identity")),
                      ####MAKE CUSTOM SCALE @ scales::trans_new() - find in
                      ####scale_y_continuous documentation
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
                  "Timeline",
                  fluidRow(
                    box(
                      title = "Event Timeline Density",
                      status = "primary",
                      solidHeader = T,
                      plotlyOutput("gun.timeline"),
                      width = 12,
                      footer = "Here's a footer, let's expand on it"
                    )
                    
                  )
                  
                )
              )
              ),
      

      # WHO is involved? Details of Victims & Suspects
      tabItem(tabName = "Involvement",
              tabsetPanel(
                tabPanel("Participant Status",
                         # put the boxes here
                         fluidRow(
                           box(
                             title = "Subsequent Subject Status",
                             status = "primary",
                             solidHeader = T,
                             plotlyOutput("part.sus"),
                             width = 12
                           ),
                           box(
                             title = "Subsequent Victim Status",
                             status = "primary",
                             solidHeader = T,
                             plotlyOutput("part.vic"),
                             width = 12
                           )
                         )),
                tabPanel("Participant Age Distribution",
                         # Put the age box here
                         fluidRow(
                           box(
                             title = "Age Distribution of Incident Participants",
                             status = "primary",
                             solidHeader = T,
                             plotlyOutput("part.age"),
                             width = 12
                           )
                         )),
                tabPanel("Coincident Details",
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
      
      # tabItem(tabName = "Legality",
      #         tabsetPanel("Stats by State",
      #           fluidRow(
      #             
      #             
      #           )
      #           
      #         )
      #         
      #         ),
      
      tabItem(tabName = "News",
              tabsetPanel(
                tabPanel("Notes & News Links",
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
                
                tabPanel("Unfiltered Data",
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
