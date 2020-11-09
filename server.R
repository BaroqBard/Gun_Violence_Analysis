shinyServer(function(input, output, session){
  
  # Set Reactives for the App ####
  # Select Date Range
  sidebar.selection = reactive({
    gundata %>% 
      filter(., grepl(input$targ.char,
                      incident_characteristics)) %>% 
      filter(., date >= input$start.date &
               date <= input$end.date)
  })
  
  part.selection = reactive({
    gun.subset = sidebar.selection()
    
    partdata %>% 
      filter(incident_id %in% gun.subset[, 2])
  })
  
  
  
  # Map Output Plot ####
  output$gun.map = renderLeaflet({
    temp.map = sidebar.selection()
    binpal = colorBin("Blues", temp.map[, 2], 6, pretty = F)
    
    leaflet(temp.map) %>% 
      addProviderTiles("Esri.WorldStreetMap") %>% 
      addPolygons(data = gun.counties,
                  stroke = F,
                  color = ~binpal())
      
   
  })
  

  
  # Participant Output Plots ####
  
  # Plot for Participant Types: Bar.... Pie Maybe?
  'Not pie maybe, but vic suspect balance filled with gender or
  age group, position dodge?'
  
  output$part.type = renderPlot({
    type.temp = part.selection() %>% 
      filter(., is.na(participant_type) == F)
    
    ggplot(data = type.temp, aes(x = participant_type)) + 
      geom_bar(aes(fill = participant_type))
  })
  
  # Plot for Gender Balance. Perhaps Unneeded... maybe a fill?
  'likely unneeded'
    output$part.gen = renderPlot({
    gen.temp = part.selection() %>% 
      filter(., is.na(participant_gender) == F)
    
    ggplot(data = gen.temp, aes(x = participant_gender)) +
      geom_bar(aes(fill = participant_gender))
  })
  
  output$part.status = renderPlot({
    status.temp = part.selection() %>% 
      filter(., is.na(participant_status) == F)
    
    ggplot(data = status.temp, aes(x = participant_status)) +
      geom_bar(aes(fill = participant_type)) +
      coord_flip() +
      scale_y_log10()
  })
  
  output$part.age = renderPlot({
    age.temp = part.selection() %>% 
      filter(., is.na(participant_age) == F)
    
    ggplot(data = age.temp, aes(x = participant_age)) +
      geom_bar(aes(fill = participant_type))
  })
  
  'scatter, fill with vic/sus?'
  
  
  # Data Tab Datatable ####
  
  output$detailtable = DT::renderDataTable({
    gun.details = sidebar.selection() %>%
      select(., 3:6, 17, 7:8, 15, 20, 13:14, 28, 2)
    
    datatable(gun.details,
              rownames = F,
              options = list(scrollX = T))
    
  })
  
  output$guntable = DT::renderDataTable({
    datatable(gundata, rownames = F,
              options = list(scrollX = T)) 
  })
  
  output$parttable = DT::renderDataTable({
    datatable(partdata, rownames = F,
              options = list(scrollX = T))
  })
  
})