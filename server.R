shinyServer(function(input, output, session){
  
  # gunviolence map design ####
  output$gun.map = renderLeaflet({
    gun.mapping = gundata %>% 
      filter(., as.Date(date) >= as.Date(input$start.date))
    
    leaflet(gun.mapping) %>% 
      addTiles() %>% 
      addPolygons(data = gun.counties, fillColor = heat.colors(6, alpha = 1), stroke = F)
    
    
  })
  
  # 
  
})