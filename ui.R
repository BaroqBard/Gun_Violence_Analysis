

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
        menuItem('How to Help', tabName = 'Help', icon = icon('envelope')),
        menuItem('Data', tabName = "Data", icon = icon("database"))
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
                     chara.choice)
    ),
    
    # Body Section ####
    dashboardBody(
      tabItems(
        tabItem(tabName = "Map",
                "Here's a heat map, representing gun violence in USA by county",
                leafletOutput("gun.map")
                
                ),
        tabItem(tabName = "Timeline",
                "to be replaced with timeline breakdown of incidents"
                
                ),
        tabItem(tabName = "Involvement",
                "to be replaced with incident analysis"
                
                
                ),
        tabItem(tabName = "Help",
                "to MAYBE be replaced with congressional contact info"
                
                ),
        tabItem(tabName = "Data",
                "to be replaced with raw gvis data"
                
                )
      )
    )
))
