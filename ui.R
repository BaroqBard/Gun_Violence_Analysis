

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
                     targ.range)
    ),
    
    # Body Section ####
    dashboardBody(tabItems(
      # WHERE did this happen and are there geographical trends?
      tabItem(tabName = "Map",
              fluidRow(box(
                leafletOutput("gun.map")
              ))),
      
      # WHEN did this happen and what does the timeline look like?
      tabItem(tabName = "Timeline",
              "to be replaced with timeline breakdown of incidents",
              fluidRow(plotlyOutput("gun.timeline"))
      ),
      
      # WHO is involved? Details of Victims & Suspects
      tabItem(
        tabName = "Involvement",
        fluidRow(box(plotlyOutput("part.sus")),
                 box(plotlyOutput("part.vic")),
                 box(plotlyOutput("part.age")))
        
      ),
      
      tabItem(tabName = "Details",
              fluidRow(box(
                DT::dataTableOutput("detailtable")
              ))),
      
      tabItem(tabName = "About",
              tabsetPanel(
                tabPanel("About the Project",
                         "to be replaced with mild documentation"),
                tabPanel("Raw Data", DT::dataTableOutput("guntable")),
                tabPanel("Participant Data", DT::dataTableOutput("parttable"))
                
              ))
    ))
))
