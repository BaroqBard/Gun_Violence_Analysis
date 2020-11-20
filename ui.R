

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
        menuItem('Incident Map', tabName = 'Map', icon = icon("map")),
        menuItem(
          'Incident Timeline',
          tabName = 'Timeline',
          icon = icon("chart-area")
        ),
        menuItem('Involvement', tabName = 'Involvement', icon = icon('users')),
        menuItem('Details', tabName = 'Details', icon = icon('newspaper')),
        menuItem('About', tabName = "About", icon = icon("database"))
      ),
      
      # Select date range START
      selectizeInput("start.date",
                     "Select Study Start Date",
                     d.range)
      ,
      
      # Select date range END
      selectizeInput(
        "end.date",
        "Select Study End Date",
        date.end,
        selected = max(date.end)
      ),
      
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
                             href = "https://www.gunviolencearchive.org/")),
        menuItem("Blog Post - Using this Website", icon = icon("blog"),
                 href = ""),
        menuItem("~ Theodore Cheek LinkedIn ~", icon = icon("linkedin"),
                 href = "https://www.linkedin.com/in/theodorecheek/")
      )

    ),
    
    # Body Section ####
    dashboardBody(tabItems(
      # WHERE did this happen and are there geographical trends?
      tabItem(tabName = "Map",
              fluidRow(box(
                # leafletOutput("gun.map"), width = 12
                htmlOutput("gun.map"), width = 12
              ))),
      
      # WHEN did this happen and what does the timeline look like?
      tabItem(tabName = "Timeline",
              fluidRow(box(title = "Event Timeline Density", status = "primary",
                           solidHeader = T,
                           plotlyOutput("gun.timeline"), width = 12,
                           footer = "Here's a footer, let's expand on it"),
                       box(title = "Concurrent Incident Characteristics", 
                           status = "info",
                           solidHeader = T,
                           "The following characteristics represent the most common, coincident
                           characteristics, featured alongside your target characteristic",
                           DT::dataTableOutput("coincident.table"), width = 6))
      ),
      
      # WHO is involved? Details of Victims & Suspects
      tabItem(tabName = "Involvement",
              tabsetPanel(
                tabPanel("Subsequent Participant Status",
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
                         ))
              )),
      
      tabItem(tabName = "Details",
              fluidRow(
                box(title = "Select Details from the Filtered Dataset", 
                    status = "primary", solidHeader = T,
                    "Here you will find searchable, selected notes from the dataset
                    that has been filtered according to your target characteristic.
                    In order to save this selection, use the buttons below to capture
                    the information",
                    DT::dataTableOutput("detailtable"), width = 12)
              )),
      
      tabItem(tabName = "About",
              tabsetPanel(
                tabPanel("About the Project",
                         "to be replaced with mild documentation"),
                tabPanel("Raw Data",
                         fluidRow(box(
                           DT::dataTableOutput("guntable"), width = 12
                         ))),
                tabPanel("Participant Data", fluidRow(box(
                  DT::dataTableOutput("parttable"), width = 12
                )))
                
              ))
    ))
))
