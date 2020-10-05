library(shinydashboard)




shinyUI(
  dashboardPage(
    dashboardHeader(
      # Header Section ####
      
    ),
    dashboardSidebar(
      # Sidebar Section ####
      sidebarMenu(
        menuItem('Incident Timeline', tabName = 'Timeline', icon = icon("chart-area")),
        menuItem('Incident Map', tabName = 'Map', icon = icon("map")),
        menuItem('Involvement', tabName = 'Involvement', icon = icon('users')),
        menuItem('How to Help', tabName = 'Help', icon = icon('envelope')),
        menuItem('Data', tabName = "Data", icon = icon("database"))
      ),
      selectizeInput("Selected",
                     "Select Start Date",
                     date.choice)
      
    ),
    dashboardBody(
      # Body Section ####
      tabItems(
        tabItem(tabName = "Timeline",
                "to be replaced with timeline breakdown of incidents"),
        tabItem(tabName = "Map",
                "to be replaced later with US map & breakdown"),
        tabItem(tabName = "Involvement",
                "to be replaced with incident analysis"),
        tabItem(tabName = "Help",
                "to MAYBE be replaced with congressional contact info"),
        tabItem(tabName = "Data",
                "to be replaced with raw gvis data")
      )
      
    )
))
