shinyServer(function(input, output, session){
  
  # Set Reactives for the App ####
  'Here we will set the reactives for the app. They
  will ensure throughout the study that data is 
  restricted to the user-made selections on the sidebar'
  
  # Filter ORIGINAL dataset BY SIDEBAR
  sidebar.selection = reactive({
    gundata %>% 
      filter(., grepl(input$targ.char,
                      incident_characteristics)) %>% 
      filter(., date >= input$start.date &
               date <= input$end.date)
  })
  
  # Filter PARTICIPANT dataset BY SIDEBAR
  part.selection = reactive({
    # Find original dataset
    gun.subset = sidebar.selection()
    
    # Find participant data relevant to INCIDENT_ID
    partdata %>% 
      filter(incident_id %in% gun.subset[, 2])
  })
  
  color.selection = reactive({
    gun.subset = sidebar.selection()
    
    gun.subset %>% 
      mutate(., happened = 1) %>% 
      group_by(., city_or_county) %>% 
      summarise(., incident_id,
                n_killed,
                n_injured,
                latitude, 
                longitude, 
                incidents = sum(happened))
  })
  
  leaf.selection = reactive({
    gun.subset = sidebar.selection()
    
    gun.subset %>% 
      mutate(., happened = 1)
  })

  
  # Map Output Plot ####
  output$gun.map = renderLeaflet({
    color.map = color.selection()
    leaf.map = leaf.selection()

    binpal = colorBin("Blues", color.map$incidents, 6, pretty = T)

    leaflet(leaf.map) %>% 
      addProviderTiles("Esri.WorldStreetMap") %>% 
      addPolygons(data = gun.counties,
                  stroke = F,
                  smoothFactor = 0.2,
                  fillOpacity = 1,
                  color = ~binpal(leaf.map$happened))
      
   
  })
  
  # Timeline Output Section ####
  'The goal of this section is to answer the question:
  WHEN do these things happen? Specifically, 1) Is there
  a chronological pattern to these events, and 2) Is there
  any correlation between these events and other kinds
  of incidents?'
  
  output$gun.timeline = renderPlotly({
    timeline.temp = sidebar.selection()
    timeline.temp$date = as.Date(timeline.temp$date)
    
    g = ggplot(data = timeline.temp, aes(x = date)) +
      geom_density()
    
    ggplotly(g)
    
  })
  
  
  
  # Participant Output Plots ####
  'The goal of this section is to answer the question:
  WHO is involved in this study? Specifically, 1) Who
  are the VICTIMS, and 2) Who are the SUSPECTS? What was
  their respective end in their involvement?'
  
  'We will use the secondary dataset of Participant Data,
  which was derived from the Participant Dictionary Data
  in the original dataset.'
  
  # Render a Plotly Graph of Victim Involvement
  # --> Status filled with Gender, log10 scale
  output$part.vic = renderPlotly({
    # Select victim participants
    vic.temp = part.selection() %>%
      filter(., participant_type == "Victim") 
    
    # ggplot the graph w/ customization, colorblind friendly
    g = ggplot(data = vic.temp, aes(x = participant_status)) +
      geom_bar(aes(fill = participant_gender)) +
      ggtitle("Status of Victims") +
      scale_y_log10() +
      xlab("") +
      ylab("") +
      #coord_flip() +
      theme_pander() +
      scale_fill_pander(na.translate = T,
                        na.value = "grey") +
      theme(
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()
        )
    
    # output ggplotly transformation of graph
    ggplotly(g)
  })
  
  # Render a Plotly Graph of Suspect Involvement
  # --> Status filled with Gender, log10 scale
  output$part.sus = renderPlotly({
    # Select suspect participants
    sus.temp = part.selection() %>%
      filter(., participant_type == "Subject-Suspect") 
    
    # ggplot the graph w/ customization, colorblind friendly
    g = ggplot(data = sus.temp, aes(x = participant_status)) +
      geom_bar(aes(fill = participant_gender)) +
      ggtitle("Status of Suspects") +
      scale_y_log10() +
      xlab("") +
      ylab("") +
      #coord_flip() +
      theme_pander() +
      scale_fill_pander(na.translate = T,     #INCLUDE NA's
                        na.value = "grey") +
      theme(
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()
        )
    
    # output ggplotly transformation of graph
    ggplotly(g)
  })
  
  output$part.age = renderPlotly({
    age.temp = part.selection() %>% 
      filter(., is.na(participant_age) == F)
    zoom = coord_cartesian(xlim = c(0, 85))
    
    g = ggplot(data = age.temp, aes(x = participant_age)) +
      geom_density(aes(color = participant_gender)) +
      facet_wrap( ~ participant_type) +
      zoom +
      xlab("") +
      ylab("") +
      ggtitle("Age Density Information") +
      theme_pander() +
      scale_fill_pander() +
      theme(
        legend.title = element_blank()
      )
    
    ggplotly(g)
  })
  
  'scatter, fill with vic/sus?'
  
  
  # Data Tab Datatable ####
  'One of the main goals with this project is transparency
  of the data involved. As such, I will provide 1) raw data
  tables in the about section, and 2) a user-filtered data
  table, matching user selections'
  
  output$detailtable = DT::renderDataTable({
    gun.details = sidebar.selection() %>%
      select(., 3:6, 7:8, 15, 20, 17, 13:14, 28, 2)
    
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