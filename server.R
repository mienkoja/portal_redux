library(shinydashboard)
library(ggplot2)
library(tidyverse)

server <- function(input, output) {
  dat <- feather::read_feather("days_in_placement")
  
  dat <- reactive({
    
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
    
    paste0("Among visits which took place within ", input$upper_limit, " days")

  })
  
  output$plot1 <- renderPlot({
      # if (is.null(input$jurisdiction)) {
      #   dat %>% 
      #     filter(days_in_placement <= input$upper_limit) %>%
      #     ggplot(aes(days_in_placement)) + 
      #     geom_histogram()
      # } else {
      #   dat %>% 
      #     filter(jurisdiction %in% input$jurisdiction) %>%
    dat %>%
          ggplot(aes(days_in_placement)) + 
          geom_histogram()        
      }
  })
  
  output$mean <- renderText({
    if (is.null(input$jurisdiction)) {
      paste0("Average Days to First Visit: ", round(mean(dat$days_in_placement), 2))
    } else {
      filtered_dat <- dat %>% filter(jurisdiction %in% input$jurisdiction)
      paste0("Average Days to First Visit: ", round(mean(dat$days_in_placement), 2))
    }
  })
  
  output$median <- renderUI({
    if (is.null(input$jurisdiction)) {
      paste0("Median Days to First Visit: ", median(dat$days_in_placement))
    } else {
      filtered_dat <- dat %>% filter(jurisdiction %in% input$jurisdiction)
      paste0("Median Days to First Visit: ", median(filtered_dat$days_in_placement))
    }
  })
  
  output$table1 <- renderDataTable({
    if (is.null(input$jurisdiction)) {
      dat
    } else {
      dat %>% filter(jurisdiction %in% input$jurisdiction)
    }
  })  
  
}