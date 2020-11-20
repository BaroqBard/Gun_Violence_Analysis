shinyServer(function(input, output, session){
  
  #### Set Reactives for the App ####
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
  
  # Find TOP CONCURRENT INCIDENT CHARACTERISTICS
  coincident.df = reactive ({
    # Finds gundata subset
    gun.subset = sidebar.selection()
    
    # Excludes input target characterstic from targ.range
    z = which(targ.range %in% input$targ.char)
    new.targ.range = targ.range[-z]
    
    # Finds Vector Sums of Coincident Characteristics
    targsum.vec = c()
    for (i in new.targ.range) {
      targsum.vec = cbind(targsum.vec, sum(grepl(
        i, gun.subset$incident_characteristics
      )))
    }
    
    # Prepares DF Output Characteristics
    char.df = rbind(new.targ.range, targsum.vec)
    char.df = data.frame(t(char.df), stringsAsFactors = F)
    names(char.df) = c("Characteristic", "Total")
    char.df$Total = as.integer(char.df$Total)
    char.df = char.df %>%                        # Calculates occurence rate
      summarise(.,
                Characteristic,
                Rate = Total / length(gun.subset$incident_characteristics),
                Total)
    char.df$Rate = label_percent()(char.df$Rate) # Presents Rate as %
    
    # Outputs DF
    char.df %>%
      arrange(., desc(Total))
    
  })
  
  
  ################################################
  
  # color.selection = reactive({
  #   gun.subset = sidebar.selection()
  #   
  #   gun.subset %>% 
  #     mutate(., happened = 1) %>% 
  #     group_by(., city_or_county) %>% 
  #     summarise(., incident_id,
  #               n_killed,
  #               n_injured,
  #               latitude, 
  #               longitude, 
  #               incidents = sum(happened))
  # })
  # 
  # leaf.selection = reactive({
  #   gun.subset = sidebar.selection()
  #   
  #   gun.subset %>% 
  #     mutate(., happened = 1)
  # })

  
  
  #################################################
  
  #### Map Output Plot ####
  # output$gun.map = renderLeaflet({
   # gun.subset = sidebar.selection()
   # tempset = gun.subset %>%
   #   mutate(., geo = paste(state, city_or_county, sep = ",")) %>% 
   #   count(., geo) %>% 
   #   right_join(., ggcounties, by = c("geo", "names"))
   # 
   # binpal = colorBin("Blues", tempset, 6, pretty = T)
  
   # leaflet(gun.subset) %>% 
   #   addProviderTiles("Esri.WorldStreetMap") %>% 
   #   addPolygons(stroke = F,
   #               smoothFactor = 0.2,
   #               fillOpacity = 1
   #               )
     # find bloody tutorial, coloring polygons
  
  # })
  
  output$gun.map = renderGvis({
    gun.subset = sidebar.selection() %>% 
      mutate(., Locations = paste(city_or_county, state, "United States",sep = ","))
    temp.subset = gun.subset %>%
      count(., state, name = "Incidents")
    gun.subset = temp.subset %>%
      full_join(., gun.subset, by = "state")# %>% 
      #mutate(., Incidents = 1)


    gvisGeoChart(
      gun.subset,
      locationvar = "state",
      colorvar = "Incidents",
      options = list(
        region = "US",
        displayMode = "auto",
        resolution = "provinces",
        datalessRegionColor = "blue"
      )
    )
    
  })
  
  #### Timeline Output Section ####
  'The goal of this section is to answer the question:
  WHEN do these things happen? Specifically, 1) Is there
  a chronological pattern to these events, and 2) Is there
  any correlation between these events and other kinds
  of incidents?'
  
  output$gun.timeline = renderPlotly({
    # Account for User Input
    gun.subset = sidebar.selection()
    gun.subset$date = as.Date(gun.subset$date)
    top.coinc = coincident.df()
    
    # Accrue the Top 3 Concurrent Incident Characteristics
    coinc1 = gun.subset %>% 
      filter(., grepl(top.coinc[2,1], incident_characteristics))
    coinc2 = gun.subset %>% 
      filter(., grepl(top.coinc[3,1], incident_characteristics))
    coinc3 = gun.subset %>% 
      filter(., grepl(top.coinc[4,1], incident_characteristics))
    
    # Plot the graphs together, one on top of the other
    g = ggplot() +
      geom_density(data = gun.subset, aes(x = date, color = "orangered4")) +
      geom_density(data = coinc1, aes(x = date, color = "orangered3")) +
      geom_density(data = coinc2, aes(x = date, color = "orangered2")) +
      geom_density(data = coinc3, aes(x = date, color = "orangered1")) +
      xlab("") +
      ylab("") +
      # annotate("rect", xmin = as.Date("2018-01-01"), xmax = as.Date("2018-04-01"), ymin = 0, ymax = 1) +
      theme_pander() +
      scale_fill_pander() +
      theme(
        legend.title = element_blank()
        
      )
    
    ggplotly(g) 
    
  })
  
  
  #### Participant Output Plots ####
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
      coord_flip() +
      theme_pander() +
      scale_fill_pander(na.translate = T,
                        na.value = "grey") +
      theme(
        axis.text.y = element_text(angle = 45),
        legend.title = element_blank(),
        legend.position = "bottom"
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
      coord_flip() +
      theme_pander(lp = "bottom") +
      scale_fill_pander(na.translate = T,     #INCLUDE NA's
                        na.value = "grey") +
      theme(
        axis.text.y = element_text(angle = 45),
        legend.title = element_blank(),
        legend.position = "bottom"
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
  

  #### Data Tab Datatable ####
  'One of the main goals with this project is transparency
  of the data involved. As such, I will provide 1) raw data
  tables in the about section, and 2) a user-filtered data
  table, matching user selections'
  
  output$detailtable = DT::renderDataTable({
    gun.details = sidebar.selection() %>%
      select(., 3:5, 7:8, 20, 10)
    names(gun.details) = c("Date", "State", "City or County",
                           "Killed", "Injured", "Incident Notes",
                           "Source URL")
    
    datatable(gun.details,
              rownames = F,
              extensions = c("Buttons"),
              options = list(
                scrollX = T,
                pageLength = 7,
                dom = "Bfrtip",
                buttons = c("copy", "csv", "excel"),
                autoWidth = T,
                columnDefs = list(list(width = '350px', targets = 5))
                )
              )
    
  })
  
  output$coincident.table = DT::renderDataTable({
    char.details = coincident.df()
    datatable(char.details, rownames = F,
              extensions = c("Buttons"),
              options = list(
                pageLength = 5,
                scrollX = T,
                dom = "Bfrtip",
                buttons = c("copy", "csv", "excel")
                
              ))
  })
  
  output$guntable = DT::renderDataTable({
    datatable(gundata,
              rownames = F,
              extensions = c("Buttons"),
              options = list(
                pageLength = 5,
                scrollX = T,
                dom = "Bfrtip",
                buttons = c("copy", "csv", "excel"))
              )
  })
  
  output$parttable = DT::renderDataTable({
    datatable(partdata, rownames = F,
              options = list(scrollX = T,
                             scrollY = T))
  })
  
})