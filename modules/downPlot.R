#
# Author: Maciej Dobrzynski
#
# This R shiny module is for downloading pdf/png/rdf of the plot
# Use:
# in ui.R
# downPlotUI('uniqueID', "your_label")
#
# in server.R
# callModule(downPlot, "uniqueID", 'fname.pdf', input_plot_to_save)

helpText.downPlot = c(
  downPDF = "Download rendered plot in a PDF format.",
  downPNG = "Download rendered plot in a PNG format.",
  inPlotWidth = "Adjust width of the saved plot.",
  inPlotHeight = "Adjust height of the saved plot.")

# UI ----
downPlotUI <- function(id, label = "Download Plot") {
  ns <- NS(id)
  
  tagList(
    # Label to display as h4 header
    h4(label),
    
    fluidRow(
      # CSS to make label next to text input
      # From: https://stackoverflow.com/a/45299050/1898713
      tags$head(
        tags$style(type="text/css", 
                   "#inline label{ display: table-cell; text-align: center; vertical-align: middle; } #inline .form-group { display: table-row;}")
      ),
      
      
      column(2,
             downloadButton(ns('downPDF'), label = "PDF"),
             bsTooltip(ns("downPDF"),
                       helpText.downPlot[["downPDF"]],
                       placement = "top",
                       trigger = "hover",
                       options = NULL)
      ),
      
      column(2,
             downloadButton(ns('downPNG'), label = "PNG"),
             bsTooltip(ns("downPNG"),
                       helpText.downPlot[["downPNG"]],
                       placement = "top",
                       trigger = "hover",
                       options = NULL)
      ),
      column(
        3,
        tags$div(id = "inline", 
                 numericInput(
                   ns('inPlotWidth'),
                   "Width [in]",
                   11,
                   min = 1,
                   width = 100
                 )
        ),
        bsTooltip(ns("inPlotWidth"),
                  helpText.downPlot[["inPlotWidth"]],
                  placement = "top",
                  trigger = "hover",
                  options = NULL)
      ),
      column(
        3,
        tags$div(id = "inline", 
                 numericInput(
                   ns('inPlotHeight'),
                   "Height [in]",
                   8.5,
                   min = 1,
                   width = 100
                 )
        ),
        bsTooltip(ns("inPlotHeight"),
                  helpText.downPlot[["inPlotHeight"]],
                  placement = "top",
                  trigger = "hover",
                  options = NULL)
      )
    )
  )
}

# SERVER ----

downPlot <- function(input, output, session, in_fname, in_plot, in.gg = FALSE) {
  
  # Download rendered plot
  output$downPDF <- downloadHandler(
    filename = function() {
      fname = paste0(in_fname, ".pdf")
      if (DEB) {
        cat(sprintf("Saving plot to %s\n", fname))
      }
      fname
    },
    
    content = function(file) {
      if (in.gg) {
        ggsave(
          file,
          limitsize = FALSE,
          in_plot(),
          width  = input$inPlotWidth,
          height = input$inPlotHeight
        )
      } else {
        if (in_fname %like% 'pdf') {
          pdf(file,
              width  = input$inPlotWidth,
              height = input$inPlotHeight)
        } else {
          png(file,
              width  = input$inPlotWidth,
              height = input$inPlotHeight, units = 'in', res = 1200)
        }
        
        
        in_plot()
        dev.off()
      }
    }
  )
  
  output$downPNG <- downloadHandler(
    filename = function() {
      fname = paste0(in_fname, ".png")
      if (DEB) {
        cat(sprintf("Saving plot to %s\n", fname))
      }
      fname
    },
    
    content = function(file) {
      if (in.gg) {
        ggsave(
          file,
          limitsize = FALSE,
          in_plot(),
          width  = input$inPlotWidth,
          height = input$inPlotHeight
        )
      } else {
        if (in_fname %like% 'pdf') {
          pdf(file,
              width  = input$inPlotWidth,
              height = input$inPlotHeight)
        } else {
          png(file,
              width  = input$inPlotWidth,
              height = input$inPlotHeight, units = 'in', res = 1200)
        }
        
        
        in_plot()
        dev.off()
      }
    }
  )
  
  # download object used for plotting
  output$downRDS <- downloadHandler(
    filename = function() {
      cat(in_fname, "\n")
      gsub("pdf|png", "rds", in_fname)
    },
    
    content = function(file) {
      saveRDS(
        in_plot(),
        file = file,
      )
    }
  )
  
}

