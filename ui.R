

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
        menuItem('Incident Timeline', tabName = 'Timeline', icon = icon("chart-area")),
        menuItem('Involvement', tabName = 'Involvement', icon = icon('users')),
        menuItem('Details', tabName = 'Details', icon = icon('newspaper')),
        menuItem('About', tabName = "About", icon = icon("database"))
      ),
      
      # sets analysis time range. Add an end bound?
      selectizeInput("start.date",
                     "Select Study Start Date",
                     d.range)
      ,
      
      selectizeInput("end.date",
                     "Select Study End Date",
                     date.end,
                     selected = max(date.end)),
      
      # sets target characteristic of the study
      selectizeInput("targ.char",
                     "Select Target Characteristic",
                     targ.range)
    ),
    
    # Body Section ####
    dashboardBody(
      tabItems(
        tabItem(tabName = "Map",
                # 
                fluidRow(box(leafletOutput("gun.map")))
                
                ),
        
        tabItem(tabName = "Timeline",
                "to be replaced with timeline breakdown of incidents"
                
                
                
                # Timeline density or bar graph
                # Toggle on body of page for second characteristic
                # Overlays them. Add info box for correlation
                ),
        tabItem(tabName = "Involvement",
                fluidRow(box(plotOutput("part.type")),   #bar
                         box(plotOutput("part.status")), #bar
                         box(plotOutput("part.gen")),    #bar
                         box(plotOutput("part.age")))    #bar
                
                ),
        
        tabItem(tabName = "Details",
                #"to be filled out with some fancy, filtered data"
                DT::dataTableOutput("detailtable")
                
                ),
        
        tabItem(tabName = "About",
                tabsetPanel(
                  tabPanel("About the Project", 
                           "to be replaced with mild documentation"
                           ),
                  tabPanel("Raw Data", DT::dataTableOutput("guntable")),
                  tabPanel("Participant Data", DT::dataTableOutput("parttable"))
                  
                  )
                
                )
      )
    )
))
