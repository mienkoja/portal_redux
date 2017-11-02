library(shinydashboard)

dat <- feather::read_feather("days_in_placement")
dat_counties <- unique(as.character(dat$jurisdiction))
dat_counties_order <- order(dat_counties)
dat_counties_ordered <- dat_counties[dat_counties_order]

ui <- dashboardPage(
  dashboardHeader(#title = ""
                  title = tags$a(href='http://www.pocdata.org/'
                               ,tags$img(src='logo.png')
                               )
                  #Set height of dashboardHeader
                  # ,tags$li(class = "dropdown",
                  #         tags$style(".main-header {max-height: 57px}"),
                  #         tags$style(".main-header .logo {height: 57px;}")
                  #         #tags$style(".sidebar-toggle {height: 57px; padding-top: 1px !important;}"),
                  #         #tags$style(".navbar {min-height:57px !important}")
                  # )                   
                  # 
                  ,titleWidth = 340
                  )
  ,dashboardSidebar(
    #tags$style(".left-side, .main-sidebar {padding-top: 57px}")
    tags$head(tags$link(rel = "stylesheet"
                                        ,type = "text/css"
                                        ,href = "poc_style.css")
                              )
                   ,sidebarMenu(
                     menuItem("Location"
                              ,icon = icon("map-o")
                              ,menuSubItem(icon = NULL
                                           ,checkboxGroupInput(inputId = "jurisdiction"
                                                               ,label = "First Visit Location"
                                                               ,selected = "Spokane"
                                                               ,choices = dat_counties_ordered
                                           )
                              )
                     )
                     ,menuItem("Upper Limit"
                               ,icon = icon("hand-stop-o")
                               ,menuSubItem(icon = NULL
                                            ,numericInput(inputId = "upper_limit"
                                                         ,label = "Maximum Days in Placement"
                                                         ,min = 0
                                                         ,max = max(dat$days_in_placement)
                                                         ,value = 90)
                               )
                   )
                   ,menuItem("Graph Settings"
                             ,icon = icon("cogs")
                             ,menuSubItem(icon = NULL
                                          ,numericInput(inputId = "bin_width"
                                                       ,label = "The number of days in each histogram bar"
                                                       ,min = 1
                                                       ,max = max(dat$days_in_placement)
                                                       ,value = 7)
                             )
                   )                   
  ))
  ,dashboardBody(
           fluidRow(
             #style = "border-bottom: 1px; border-bottom-style: solid;border-bottom-color: #DDDDDD"
             box(tags$div(h1("Days to First Visit from Original Placement Date"), id="data-title")
                 ,tags$div(h4(textOutput("title")), id="data-title")
                 ,width = 12)
           )
           ,fluidRow(
             # Boxes need to be put in a row (or column)
             tabsetPanel(
               
               tabPanel("GRAPH", icon = icon("line-chart")
                        ,style="background-color: #ffffff; 
                                padding-left: 20px;
                                padding-right: 20px;
                                padding-top: 20px;
                                padding-bottom: 20px;"       
                        ,plotOutput("plot1")
                        ,uiOutput("mean")
                        ,uiOutput("median")
               )
               ,tabPanel("TABLE", icon = icon("table")                       
                         ,style="background-color: #ffffff; 
                                 padding-left: 20px;
                                 padding-right: 20px;
                                 padding-top: 20px;
                                 padding-bottom: 20px;"                              
                         ,dataTableOutput("table1"))
               #,tabPanel("DOWNLOAD", icon = icon("download"))
               ,tabPanel("INFO", icon = icon("info-circle")                       
                         ,style="background-color: #ffffff; 
                                 padding-left: 20px;
                                 padding-right: 20px;
                                 padding-top: 20px;
                                 padding-bottom: 20px;"                          
                         ,includeMarkdown("get_data.md"))
               )
            )
    # ,tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "poc_style.css")
    #            )
    )
)

