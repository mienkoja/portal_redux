library(shinydashboard)

dat <- feather::read_feather("days_in_placement")

ui <- dashboardPage(
  dashboardHeader(#title = ""
                  title = tags$a(href='http://www.pocdata.org/'
                               ,tags$img(src='logo.png')
                               )
                  #Set height of dashboardHeader
                  ,tags$li(class = "dropdown"
                           ,tags$style(".main-header {max-height: 57px}")
                           ,tags$style(".main-header .logo {height: 57px}")
                           )
                  ,titleWidth = 340
                  )
  ,dashboardSidebar(
    tags$style(".left-side, .main-sidebar {padding-top: 57px}")
    ,tags$head(tags$link(rel = "stylesheet"
                                        ,type = "text/css"
                                        ,href = "poc_style.css")
                              )
                   ,sidebarMenu(
                     menuItem("Location"
                              ,icon = icon("map-o")
                              ,menuSubItem(icon = NULL
                                           ,checkboxGroupInput(inputId = "jurisdiction"
                                                               ,label = "First Visit Location"
                                                               ,choices = unique(as.character(dat$jurisdiction))
                                           )
                              )
                     )
                   )
  )
  ,dashboardBody(
           fluidRow(
             box(tags$div(h1("Days to First Visit"), id="data-title")
                 ,tags$div(h4("From Original Placement Date"), id="data-title")
                 ,width = 12)
           )
           ,fluidRow(
             # Boxes need to be put in a row (or column)
             tabsetPanel(
               tabPanel("GRAPH", icon = icon("line-chart")
                        ,style="padding-left: 20px;"
                        ,style="padding-right: 20px;"
                        ,style="padding-top: 20px;" 
                        ,style="padding-bottom: 20px;"                        
                        ,plotOutput("plot1")
                        ,uiOutput("mean")
                        ,uiOutput("median")
               )
               ,tabPanel("TABLE", icon = icon("table")
                         ,style="padding-left: 20px;"
                         ,style="padding-right: 20px;"
                         ,style="padding-top: 20px;" 
                         ,style="padding-bottom: 20px;"                             
                         ,dataTableOutput("table1"))
               #,tabPanel("DOWNLOAD", icon = icon("download"))
               ,tabPanel("INFO", icon = icon("info-circle")
                         ,style="padding-left: 20px;"
                         ,style="padding-right: 20px;"
                         ,style="padding-top: 20px;" 
                         ,style="padding-bottom: 20px;"                          
                         ,includeMarkdown("get_data.md"))
               )
            )
    # ,tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "poc_style.css")
    #            )
    )
)

