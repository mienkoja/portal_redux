library(shinydashboard)
library(ggplot2)
library(tidyverse)
library(ggthemes)

server <- function(input, output) {
  dat <- feather::read_feather("days_in_placement")
  
  dat_filter <- reactive({
    
    if (is.null(input$jurisdiction)) {
      dat %>% 
        filter(days_in_placement <= input$upper_limit)
    } else {
      dat %>% 
        filter(jurisdiction %in% input$jurisdiction
               ,days_in_placement <= input$upper_limit)
    }
  })
  
  output$title <- renderText({
    
    if (is.null(input$jurisdiction)) {
      paste0("Among visits which took place within "
             ,input$upper_limit
             ," days, in All Counties")
    } else if (length(input$jurisdiction) == 1) {
      paste0("Among visits which took place within "
             ,input$upper_limit
             ," days, in "
             ,input$jurisdiction
             ," County")
    } else if (length(input$jurisdiction) == 2) {
      paste0("Among visits which took place within "
             ,input$upper_limit
             ," days, in "
             ,paste0(input$jurisdiction, collapse=" and ")
             ," Counties")
    } else {
      valid_vector <- na.omit(input$jurisdiction)
      vector_end <- length(valid_vector)
      vector_penultimate <- vector_end - 1
      paste0("Among visits which took place within "
             ,input$upper_limit
             ," days, in "
             ,paste0(valid_vector[1:vector_penultimate], collapse=", ")
             ,", and "
             ,valid_vector[vector_end]
             ," Counties"
             )
    }

  })
  
  output$plot1 <- renderPlot({

    dat_update <- dat_filter()
    dat_update %>%
          ggplot(aes(days_in_placement)) + 
          geom_histogram(aes(y=..count../sum(..count..)), binwidth = input$bin_width) + 
          xlab("Days in Placement") + 
          ylab("Percentage of Cases") + 
          scale_y_continuous(labels = scales::percent) + 
          theme_hc() + 
          theme(text = element_text(size=18))

  })
  
  output$mean <- renderText({
    dat_update <- dat_filter()
    paste0("Average Days to First Visit: ", round(mean(dat_update$days_in_placement), 2))
  })
  
  output$median <- renderUI({
    dat_update <- dat_filter()
    paste0("Median Days to First Visit: ", round(median(dat_update$days_in_placement), 2))
  })
  
  output$table1 <- renderDataTable({
    
    dat_update <- dat_filter()
    
    dat_update %>% 
      filter(jurisdiction %in% input$jurisdiction) %>%
      select(`First Visit Location` = jurisdiction
             ,`Days in Placement` = days_in_placement)
    
  })  
  
}