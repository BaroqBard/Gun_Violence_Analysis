shinyServer(function(input, output, session){
  
  # gunviolence map design ####
  output$gun.map = renderLeaflet({
    
    if (input$targ.char == 'All') {
      gun.mapping = gundata %>% 
        filter(., as.Date(date) >= as.Date(input$start.date))  
    } else {
      gun.mapping = gundata %>% 
        filter(., as.Date(date) >= as.Date(input$start.date)) %>% 
        filter(., grepl(input$targ.char, gundata$incident_characteristics))
    }
    
    leaflet(gun.mapping) %>% 
      addTiles() %>% 
      addPolygons(data = gun.counties, fillColor = heat.colors(6, alpha = 1), stroke = F)
    
    
  })
  
  
  
})