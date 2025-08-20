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
    titlePanel("Traversata lago di Lugano 2025"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            numericInput("in_my_id", 
                         "Enter your starting number:",
                         value = 438,
                         min = ID_MIN,
                         max = ID_MAX)
        ),

        # Show a plot of the generated distribution
        mainPanel(
          
            tabsetPanel(
              tabPanel(
                "Your stats",
                
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
                
                plotOutput("ageDistPlot"),
                plotOutput("timeDistPlot"),
                plotOutput("rankDistPlot"),                
              )
            ),
        )
    )
)
