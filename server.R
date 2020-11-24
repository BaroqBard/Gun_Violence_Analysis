shinyServer(function(input, output, session){
  
  #### Set Reactives for the App ####
  'Here we will set the reactives for the app. They
  will ensure throughout the study that data is 
  restricted to the user-made selections on the sidebar'
  
  # Filter ORIGINAL dataset BY SIDEBAR (return DF)
  sidebar.selection = reactive({
    gundata %>% 
      filter(., grepl(input$targ.char,
                      incident_characteristics, fixed = T)) %>% 
      filter(., date >= min(input$daterange) &
               date <= max(input$daterange))
  })
  
  # Filter PARTICIPANT dataset BY SIDEBAR (return DF)
  part.selection = reactive({
    gun.subset = sidebar.selection()
    
    # Find participant data relevant to INCIDENT_ID
    partdata %>% 
      filter(incident_id %in% gun.subset[, 2])
  })
  
  # Find Top Concurrent Incident Characteristics (return DF)
  coincident.df = reactive ({
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
    char.df = rbind(new.targ.range, targsum.vec) # rbinds vecs into df
    char.df = data.frame(t(char.df), stringsAsFactors = F) # rows into cols
    names(char.df) = c("Characteristic", "Total")# Renames cols; cosmetic
    char.df$Total = as.integer(char.df$Total)
    char.df = char.df %>%                        # Calculates occurence rate
      summarise(.,
                Characteristic,
                Rate = Total / length(gun.subset$incident_characteristics),
                Total)
    char.df$Rate = label_percent()(char.df$Rate) # Presents Rate as %
    
    # Outputs DF, ordered HIGH chars to LOW chars
    char.df %>%
      arrange(., desc(Total))
    
  })
  
  # Find most-involved gun classifications (return DF)
  gunsinvolved.df = reactive({
    gun.subset = sidebar.selection()
    gunvec = unique(weapondata$gun_type)
    weap.subset = weapondata %>%                #find weapons in selection
      filter(incident_id %in% gun.subset[,2])
    targsum.vec = c()                 #empty vec for loop
    
    for (i in gunvec) {
      targsum.vec = cbind(targsum.vec, sum(grepl(
        i, weap.subset$gun_type, fixed = T
      )))
      
    }
    
    gun.df = rbind(gunvec, targsum.vec)
    gun.df = data.frame(t(gun.df), stringsAsFactors = F)
    names(gun.df) = c("Weapon", "Total")
    gun.df$Total = as.integer(gun.df$Total)
    gun.df = gun.df %>% 
      summarise(.,
                Weapon,
                Rate = Total / length(gun.subset$incident_characteristics),
                Total)
    gun.df$Rate = label_percent()(gun.df$Rate)
    
    gun.df %>% 
      arrange(., desc(Total))
    
  })
  
  # Create Dashboard DF with Mapping, Legal, & Population Data (return DF)
  dashdata.df = reactive({
    gun.subset = sidebar.selection() #%>% 
      #mutate(., Locations = paste(city_or_county, state, "United States",sep = ","))
    
    # Calculates the "Incidents" column, counts by state
    temp.subset = gun.subset %>%
      group_by(., state) %>% 
      summarise(., Incidents = n(), 
                Injured = sum(n_injured), 
                Killed = sum(n_killed),
                Guns = sum(n_guns_involved, na.rm = T)) %>% 
      left_join(., popdata, by = "state") %>% 
      left_join(., lawdata, by = "state") %>% 
      filter(., state != "District of Columbia")
      
    
    if (input$pop_scale == "percap") {
      temp.subset = temp.subset %>% 
        mutate(., Incidents = (Incidents/Pop) * 1000,
               Injured = (Injured/Pop) * 1000, 
               Killed = (Killed/Pop) * 1000,
               Guns = (Guns/Pop) * 1000)
    } else {
      temp.subset = temp.subset %>% 
        mutate(., Injured = Injured / Incidents,
               Killed = Killed / Incidents,
               Guns = Guns / Incidents)
    }
      
    temp.subset
    
  })
  
  #### Map Output ####

  output$gun.map = renderGvis({
    dash.data = dashdata.df()

    # Produces the gvis output, using the counted incidents
    gvisGeoChart(
      dash.data,
      locationvar = "state",
      colorvar = "Incidents",
      options = list(
        region = "US",
        displayMode = "auto",
        resolution = "provinces",
        datalessRegionColor = "grey"
      )
    )
    
  })
  
  #### Infobox Outputs ####
  
  output$dashMax = renderInfoBox({
    dash.data = dashdata.df()
    
    maxtemp = dash.data %>% 
      arrange(., desc(Incidents)) %>% 
      head(., 1) %>% 
      summarise(., state, Incidents)
    
    infoBox(maxtemp$state, 
            round(maxtemp$Incidents, digits = 3),
            subtitle = "Most Incidents",
            icon = icon("lightbulb"),
            color = "yellow",
            width = 3)
    
  })
  
  output$dashMeanGuns = renderInfoBox({
    dash.data = dashdata.df()
    
    meanGuns = dash.data %>% 
      arrange(., desc(Guns)) %>% 
      head(., 1) %>% 
      summarise(., state, Guns)
    
    infoBox(meanGuns$state,
            round(meanGuns$Guns, digits = 3),
            subtitle = "AVG Guns Involved",
            icon = icon("crosshairs"),
            color = "yellow",
            width = 3,
            fill = T)
    
  })
  
  output$dashMaxInj = renderInfoBox({
    dash.data = dashdata.df()
    
    maxInj = dash.data %>% 
      arrange(., desc(Injured)) %>% 
      head(., 1) %>% 
      summarise(., state, Injured)
    
    infoBox(maxInj$state,
            round(maxInj$Injured, digits = 3),
            subtitle = "Most Persons Injured",
            color = "red",
            width = 3,
            icon = icon("ambulance"))
    
  })
  
  output$dashMaxKill = renderInfoBox({
    dash.data = dashdata.df()
    
    maxKill = dash.data %>% 
      arrange(., desc(Killed)) %>% 
      head(., 1) %>% 
      summarise(., state, Killed)
    
    infoBox(maxKill$state,
            round(maxKill$Killed, digits = 3),
            subtitle = "Most Persons Killed",
            color = "red",
            width = 3,
            fill = T,
            icon = icon("dizzy"))
    
  })
  
  #### Timeline Output ####
  'The goal of this section is to answer the question:
  WHEN do these things happen? Specifically, 1) Is there
  a chronological pattern to these events, and 2) Is there
  any correlation between these events and other kinds
  of incidents?'
  
  output$gun.timeline = renderPlotly({
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
  
  
  #### Participant Plot Outputs ####
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
    
    ggplotly(g)
  })
  
  # Render a Plotly Graph of Suspect Involvement
  # --> Status filled with Gender, log10 scale
  output$part.sus = renderPlotly({
    sus.temp = part.selection() %>%
      filter(., participant_type == "Subject-Suspect") 
    
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
  

  #### Datatable Outputs ####
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
                pageLength = 5,
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
  
  output$weapons.table = DT::renderDataTable({
    weap.details = gunsinvolved.df()
    datatable(weap.details, rownames = F,
              extensions = c("Buttons"),
              options = list(
                pageLength = 5,
                scrollX = T,
                dom = "Bfrtip",
                buttons = c("copy", "csv", "excel")
                
              ))
  })
  
  output$dashtable = DT::renderDataTable({
    dashdata = dashdata.df() %>% 
      mutate(., Incidents = round(Incidents, digits = 3),
             Guns = round(Guns, digits = 3),
             Injured = round(Guns, digits = 3),
             Killed = round(Killed, digits = 3)) %>% 
      select(., 1:5,7,9:12) %>% 
      arrange(., desc(Incidents))
    
    datatable(dashdata,
              rownames = F,
              extensions = c("Buttons"),
              options = list(
                pageLength = 3,
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