  #
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(shinyBS)
library(shinythemes)

# Define UI for application that draws a histogram
fluidPage(theme = shinytheme("superhero"),
          
    # Application title
    titlePanel("Traversata del Lago di Lugano 2025"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            numericInput("in_my_id", 
                         "Enter your starting number:",
                         value = 438, 
                         width = '100px',
                         min = ID_MIN,
                         max = ID_MAX)
        ),

        # Show a plot of the generated distribution
        mainPanel(
          
            tabsetPanel(
              tabPanel(
                "Your stats",
                
                h4('Race time vs. age'),
                p("The anonymised results come from the ",
                  a("official records", 
                    href = "https://www.endu.net/it/events/traversata-lago-lugano/results",
                    title ="External link",
                    target = "_blank"),
                  "."
                ),
                p("Each point corresponds to a single participant. Black horizontal lines indicate median race time within the age group. The dashed horizontal line indicates your race time. "),
                
                plotOutput("outPlotRes"),
                
                checkboxInput('chBdownload',
                              'Save Plot',
                              FALSE),
                conditionalPanel(
                  condition = "input.chBdownload",
                  downPlotUI('downPlot'), ""),
              ),
              
              tabPanel(
                "Race stats",
                
                h4('Race statistics'),
                p("Distribution of participants' age."),
                plotOutput("ageDistPlot"),

                br(),
                p("Distribution of race times. The dashed vertical line indicates your result."),
                plotOutput("timeDistPlot"),

                br(),
                p("Race times ordered by arrival ranks. The dashed lines indicate your result."),
                plotOutput("rankDistPlot"),                
              ),
              
              tabPanel(
                "About",
                
                h4('App Info'),
                p("This is an",
                  a("R/Shiny", 
                    href = "https://shiny.posit.co",
                    title ="External link",
                    target = "_blank"),
                  "app created by ",
                  a("Maciej Dobrzyński", 
                    href = "https://macdobry.net",
                    title ="External link",
                    target = "_blank"),
                  "."),
                  p("Download the source code from",
                  a("GitHub", 
                    href = "https://github.com/dmattek/traversata-app",
                    title ="External link",
                    target = "_blank"),
                  "."),
              )
            ),
        )
    )
)
