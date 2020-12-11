shinyServer(function(input, output, session){
  
  #### Set Reactives for the App ####
  'Here we will set the reactives for the app. They
  will ensure throughout the study that data is 
  restricted to the user-made selections on the sidebar'
  
  ## * Gundata Dataset ####
  # Filter Gundata by Sidebar
  sidebar.selection = reactive({
    gundata %>% 
      filter(., grepl(input$targ.char,
                      incident_characteristics, fixed = T)) %>% 
      filter(., date >= min(input$daterange) &
               date <= max(input$daterange))
  })
  
  # Find Dataframe of MOST COINCIDENT Target Characteristics
  coincident.df = reactive ({
    gun.subset = sidebar.selection()
    
    # Excludes input target characterstic from targ.range
    z = which(targ.range %in% input$targ.char)
    new.targ.range = targ.range[-z]
    
    # Builds Vector of Sums of Coincident Characteristics
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
  
  ## * State-Related Data ####
  statedata.df = reactive({
    gun.subset = sidebar.selection()
    
    temp.subset = gun.subset %>%
      group_by(., state) %>% 
      summarise(., Incidents = n(), 
                Injured = sum(n_injured), 
                Killed = sum(n_killed),
                Guns = sum(n_guns_involved, na.rm = T)) %>% 
      left_join(., popdata, by = "state") %>% 
      left_join(., lawdata, by = "state") %>% 
      filter(., state != "District of Columbia")
    
    temp.subset
    
  })
  
  ## * Participant Data ####
  part.selection = reactive({
    gun.subset = sidebar.selection()
    
    # Find participant data relevant to INCIDENT_ID
    partdata %>% 
      filter(incident_id %in% gun.subset[, 2])
  })
  
  ## * Weapon Data ####
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
  
  ## * Dashboard Data ####
  dashdata.df = reactive({
    dash.subset = statedata.df()
    
    
    if (input$pop_scale == "percap") {
      dash.subset = dash.subset %>% 
        mutate(., Incidents = (Incidents/Pop) * 100000,
               Injured = (Injured/Pop) * 100000, 
               Killed = (Killed/Pop) * 100000,
               Guns = (Guns/Pop) * 100000)
    } else {
      dash.subset = dash.subset %>% 
        mutate(., Injured = Injured / Incidents,
               Killed = Killed / Incidents,
               Guns = Guns / Incidents)
    }
    
    dash.subset
    
  })
  
  ## * Legal Analysis Data ####
  legaldata.df = reactive({
    legal.subset = statedata.df() %>%
      select(., 1:5, 7, 9:12) %>%
      mutate(
        .,
        Fire = sapply(Firearm.Registration, req_to_bool),
        Carry = sapply(Carry.Permit, req_to_bool),
        Purchase = sapply(Purchase.Permit, req_to_bool),
        Open = sapply(Open.Carry, yes_to_bool)
      ) %>%
      rename(., lstate = state)
    
    # Recalculate Gun Restrictions
    if ("Fire" %in% input$legal.parameter == F) {
      legal.subset$Fire = FALSE
    }
    if ("Carry" %in% input$legal.parameter == F) {
      legal.subset$Carry = FALSE
    }
    if ("Purchase" %in% input$legal.parameter == F) {
      legal.subset$Purchase = FALSE
    }
    if ("Open" %in% input$legal.parameter == F) {
      legal.subset$Open = FALSE
    }
    
    # Fix State Names
    legal.subset = legal.subset %>%
      mutate(.,
             lstate = state.abb[match(lstate, state.name)],
             Restrictions = (Fire + Carry + Purchase + Open)) %>%
      rename(., State = lstate)
    
    
    if (input$state.scale == "percap") {
      # Mutate in place to account for per capita
      legal.subset = legal.subset %>%
        mutate(
          .,
          Incidents = (Incidents / Pop) * 100000,
          Injured = (Injured / Pop) * 100000,
          Killed = (Killed / Pop) * 100000,
          Guns = (Guns / Pop) * 100000
        )
      # posinput = grep(input$state.cat, t(data.frame(colnames(legal.subset))))
      # meaninput = sapply(legal.subset[posinput], mean)
      
      # Calculate Deviation from user input
      # I have retired this from the app, but will retain
      # the calculation in case I find it useful later
      legal.subset = legal.subset %>%
        mutate(., Difference = !!(sym(input$state.cat)) - 
                                            median(!!sym(input$state.cat)))
      
    } else {
      # Just output with user input & deviation
      # posinput = grep(input$state.cat, t(data.frame(colnames(legal.subset))))
      # meaninput = sapply(legal.subset[posinput], mean)
      
      legal.subset = legal.subset %>%
        mutate(., Difference = !!(sym(input$state.cat)) - 
                                            median(!!sym(input$state.cat)))
      
    }
    
    
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
  
  
  ## * State Infoboxes ####
  
  output$dashMax = renderInfoBox({
    dash.data = dashdata.df()
    
    maxtemp = dash.data %>% 
      arrange(., desc(Incidents)) %>% 
      head(., 1) %>% 
      summarise(., state, Incidents)
    
    if (input$pop_scale == "percap") {
      scaling = "per Capita"
    } else {
      scaling = ""
    }
    
    infoBox(maxtemp$state, 
            round(maxtemp$Incidents, digits = 3),
            subtitle = paste("Most Incidents", scaling),
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
    
    if (input$pop_scale == "percap") {
      scaling = "per Incident, per Capita"
    } else {
      scaling = "per Incident"
    }
    
    infoBox(meanGuns$state,
            round(meanGuns$Guns, digits = 3),
            subtitle = paste("Most Guns", scaling),
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
    
    if (input$pop_scale == "percap") {
      scaling = "per Incident, per Capita"
    } else {
      scaling = "per Incident"
    }
    
    infoBox(maxInj$state,
            round(maxInj$Injured, digits = 3),
            subtitle = paste("Most Persons Injured", scaling),
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
    
    if (input$pop_scale == "percap") {
      scaling = "per Incident, per Capita"
    } else {
      scaling = "per Incident"
    }
    
    infoBox(maxKill$state,
            round(maxKill$Killed, digits = 3),
            subtitle = paste("Most Persons Killed", scaling),
            color = "red",
            width = 3,
            fill = T,
            icon = icon("dizzy"))
    
  })
  
  ## * Natl Infoboxes ####
  
  output$sus.outcome = renderInfoBox({
    part.temp = part.selection() %>% 
      filter(., participant_type == "Subject-Suspect") %>% 
      count(., participant_status) %>% 
      arrange(., desc(n)) %>% 
      mutate(., rate = label_percent(accuracy = 0.01)(n / sum(n)))
    
    infoBox(title = part.temp[1,1],
            value = paste(part.temp[1,3], "of cases"),
            subtitle = "Most Common Result for Suspects",
            color = "red",
            width = 6)
    
  })
  
  output$vic.outcome = renderInfoBox({
    part.temp = part.selection() %>% 
      filter(., participant_type == "Victim") %>% 
      count(., participant_status) %>% 
      arrange(., desc(n)) %>% 
      mutate(., rate = label_percent(accuracy = 0.01)(n / sum(n)))
    
    infoBox(title = part.temp[1,1],
            value = paste(part.temp[1,3], "of cases"),
            subtitle = "Most Common Result for Victims",
            color = "yellow",
            width = 6)
    
  })
  
  output$sus.age = renderValueBox({
    part.temp = part.selection() %>% 
      filter(., participant_type == "Subject-Suspect") %>% 
      summarise(., med = median(participant_age, na.rm = T))
    
    valueBox(value = as.integer(part.temp),
            subtitle = "Median Suspect Age",
            color = "red",
            width = 3)
    
  })
  
  output$vic.age = renderValueBox({
    part.temp = part.selection() %>% 
      filter(., participant_type == "Victim") %>% 
      summarise(., med = median(participant_age, na.rm = T))
    
    valueBox(value = as.integer(part.temp),
            subtitle = "Median Victim Age",
            color = "yellow",
            width = 3)
    
  })
  
  #### Graph Outputs ####
  
  
  ## * State Graphs ####
  output$dash.law = renderGvis({
    legaldat = legaldata.df()
    
    gvisBubbleChart(
      data = legaldat,
      idvar = "State",
      xvar = "Incidents",
      yvar = input$state.cat,
      colorvar = "Restrictions",
      options = list(
        height = "400px",
        width = "auto",
        explorer = "{keepInBounds: true}",
        legend = "{position:'bottom'}",
        sizeAxis = "{minSize: 15, maxSize: 15}",
        hAxis = "{title: 'Total Incidents - Select Scaling Below'}",
        vAxis = "{title: 'Secondary Incident Parameter'}"
      )
    )
    
  })
  

  ## * Natl. Graphs ####

  output$natl.timeline = renderPlotly({
    gun.subset = sidebar.selection()
    gun.subset$date = as.Date(gun.subset$date)
    bwidth = as.integer(0.01 * (max(input$daterange) - min(input$daterange)))
    
    g = ggplot(data = gun.subset, aes(x = date)) +
      geom_freqpoly(binwidth = bwidth) +
      xlab("") +
      ylab("") +
      theme_pander() +
      scale_fill_pander() +
      theme(
        legend.title = element_blank()
      )
    
  })
  
  output$natl.coinc1 = renderPlot({
    gun.subset = sidebar.selection()
    gun.subset$date = as.Date(gun.subset$date)
    coinc = coincident.df()
    bwidth = as.integer(.04 * (max(input$daterange) - min(input$daterange)))
    gun.subset = gun.subset %>% 
      filter(., grepl(coinc[1,1], incident_characteristics))
    
    g = ggplot(data = gun.subset, aes(x = date)) +
      geom_freqpoly(binwidth = bwidth) +
      xlab("") +
      ylab("") +
      labs(title = coinc[1,1], 
           subtitle = paste("Coincident Rate:", coinc[1,2])) +
      theme_pander() +
      scale_fill_pander() +
      theme(
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()
      )
    
    plot(g)
    
  })
  
  output$natl.coinc2 = renderPlot({
    gun.subset = sidebar.selection()
    gun.subset$date = as.Date(gun.subset$date)
    coinc = coincident.df()
    bwidth = as.integer(.04 * (max(input$daterange) - min(input$daterange)))
    gun.subset = gun.subset %>% 
      filter(., grepl(coinc[2,1], incident_characteristics))
    
    g = ggplot(data = gun.subset, aes(x = date)) +
      geom_freqpoly(binwidth = bwidth) +
      xlab("") +
      ylab("") +
      labs(title = coinc[2,1],
           subtitle = paste("Coincident Rate:", coinc[2,2])) +
      theme_pander() +
      scale_fill_pander() +
      theme(
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()
      )
    
    plot(g)
    
  })
  
  output$natl.coinc3 = renderPlot({
    gun.subset = sidebar.selection()
    gun.subset$date = as.Date(gun.subset$date)
    coinc = coincident.df()
    bwidth = as.integer(.04 * (max(input$daterange) - min(input$daterange)))
    gun.subset = gun.subset %>% 
      filter(., grepl(coinc[3,1], incident_characteristics))
    
    g = ggplot(data = gun.subset, aes(x = date)) +
      geom_freqpoly(binwidth = bwidth) +
      xlab("") +
      ylab("") +
      labs(title = coinc[3,1],
           subtitle = paste("Coincident Rate:", coinc[3,2])) +
      theme_pander() +
      scale_fill_pander() +
      theme(
        axis.text.x = element_text(angle = 45),
        legend.title = element_blank()
      )
    
    plot(g)
    
  })
  
  output$part.status = renderPlotly({
    part.temp = part.selection()
    
    g = ggplot(data = part.temp, aes(x = participant_status)) +
      geom_bar(aes(fill = participant_gender)) +
      facet_wrap( ~ participant_type) +
      scale_y_log10() +
      xlab("") +
      ylab("") +
      theme_pander(lp = "bottom") +
      scale_fill_pander(na.translate = T,     #INCLUDE NA's
                        na.value = "grey") +
      theme(
        axis.text.x = element_text(angle = -45),
        legend.title = element_blank(),
        legend.position = "bottom"
      ) 
    
    ggplotly(g)
    
  })
  
  output$part.agegroup = renderPlot({
    part.temp = part.selection()
    
    g = ggplot(data = part.temp, aes(x = 1)) +
      geom_bar(aes(fill = participant_age_group), position = "fill") +
      coord_polar(theta = "y") +
      facet_wrap( ~ participant_type) +
      xlab("") +
      ylab("") +
      theme_pander() +
      scale_fill_pander(na.translate = T,
                        na.value = "grey") +
      theme(
        legend.title = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        legend.position = "bottom"
      )
    
    plot(g)
  })
  
  output$part.age = renderPlotly({
    part.temp = part.selection() %>% 
      filter(., is.na(participant_age) == F)
    zoom = coord_cartesian(xlim = c(0, 85))
    
    g = ggplot(data = part.temp, aes(x = participant_age)) +
      geom_freqpoly(aes(color = participant_gender), binwidth = 1) +
      facet_wrap( ~ participant_type) +
      zoom +
      xlab("") +
      ylab("") +
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
    #15 and 19
    gun.details = sidebar.selection() %>%
      select(., 3:5, 7:8, 19, 20, 9, 10, 15) %>%
      mutate(
        .,
        incident_url = paste0(
          "<a href='",
          incident_url,
          "' target='_blank'>",
          incident_url,
          "</a>"
        ),
        source_url = paste0(
          "<a href='",
          source_url,
          "' target='_blank'>",
          source_url,
          "</a>"
        )
      )
    names(gun.details) = c("Date",
                           "State",
                           "City or County",
                           "Killed",
                           "Injured",
                           "Guns Involved",
                           "Incident Notes",
                           "Archival URL",
                           "Source URL",
                           "Characteristics")
    
    # Want to widen 10th Column... Project for Later
    
    datatable(
      gun.details,
      rownames = F,
      extensions = c("Buttons"),
      escape = F,
      options = list(
        scrollX = T,
        pageLength = 5,
        dom = "Bfrtip",
        buttons = c("copy", "csv", "excel"),
        autoWidth = T,
        columnDefs = list(list(width = '350px', targets = 6))
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
  
  # Prep Dashdata for Clean, Dashboard Presentation
  output$dashtable = DT::renderDataTable({
    legaldata = legaldata.df() %>% 
       mutate(., Incidents = round(Incidents, digits = 2),
              Guns = round(Guns, digits = 2),
              Injured = round(Guns, digits = 2),
              Killed = round(Killed, digits = 2)) %>% 
       select(., 1:10) %>% 
       arrange(., desc(Incidents)) %>% 
       rename(.,
              "Population" = Pop,
              "Firearm Registration" = Firearm.Registration,
              "Carry Permit" = Carry.Permit,
              "Purchase Permit" = Purchase.Permit,
              "Open Carry" = Open.Carry)
    
    datatable(legaldata,
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
  
})