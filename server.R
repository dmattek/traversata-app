#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(data.table)
library(ggplot2)
library(ggthemes)

# Define server logic required to draw a histogram
function(input, output, session) {
  
  get_dat_all <- function() {
    # Read the file
    loc_dat <- fread('data/564476_C3QK433370_ANONYM.csv.gz')
    
    # Convert string with time to POSIXct format
    loc_dat[,
            TEMPO := as.POSIXct(TEMPO_UFFICIALE, 
                                format = '%H:%M:%S', 
                                tz = 'UTC')]

    # Create age column
    loc_dat[,
            AGE := CURR_YEAR - ANNO]
    loc_dat <- loc_dat[AGE > 0]
    
    age_min <- min(loc_dat[['AGE']])
    age_max <- max(loc_dat[['AGE']])
    
    # Create age group column
    loc_dat[,
            AGE_BIN := cut(AGE, 
                           breaks = c(age_min, 15, 20, 25, 35, 45, 55, 65, age_max),
                           include.lowest = T,
                           right = FALSE)]
    
    # Order by race time and add a rank column
    loc_dat <- loc_dat[order(TEMPO)]
    loc_dat[,
            RANK := 1:.N]
    loc_dat[,
            RANK_AGEGR := 1:.N,
            by = AGE_BIN]
    
    
    # Calculate overall rank
    loc_dat[,
        RANK := 1:.N]
    
    # Calculate rank per group
    loc_dat[,
        RANK_AGEGR := 1:.N,
        by = AGE_BIN]
    
    # Calculate percentile faster
    loc_dat[,
        PERC_FASTER := ( 1 - (RANK - 1) / (max(RANK) - 1)) * 100]
    
    loc_dat[,
        PERC_FASTER_AGEGR := ( 1 - (RANK_AGEGR - 1) / (max(RANK_AGEGR) - 1)) * 100,
        by = AGE_BIN]
    
    return(loc_dat)
  }
  
  get_dat_me <- function() {
    loc_dat_all <- get_dat_all()
    
    if (input$in_my_id %in% loc_dat_all[['PETTORALE']]) {
      loc_dat_me <- loc_dat_all[PETTORALE == input$in_my_id]
    } else {
      loc_dat_me = NULL
    }
    
    return(loc_dat_me)
  }
  
  get_dat_aggr <- function() {
    
    dat_all <- get_dat_all()
    dat_aggr <- dat_all[,
                        .(TEMP_MED = median(TEMPO),
                          TEMP_MN = mean(TEMPO),
                          N = .N),
                        by = AGE_BIN]
    dat_aggr[,
             `:=`(AGE_BIN_LOW = as.numeric(gsub('\\[([0-9]{2}),([0-9]{2,})(\\]|\\))', '\\1', AGE_BIN)),
                  AGE_BIN_HI = as.numeric(gsub('\\[([0-9]{2}),([0-9]{2,})(\\]|\\))', '\\2', AGE_BIN)))]
  }
  
  get_race_stats <- function() {
    dat_all <- get_dat_all()
    
    return(list(
      n_part = nrow(dat_all),
      age_min = min(dat_all[["AGE"]]),
      age_max = max(dat_all[["AGE"]]),
      age_med = median(dat_all[["AGE"]]),
      age_mn = mean(dat_all[["AGE"]]),
      time_min = min(dat_all[["TEMPO"]]),
      time_max = max(dat_all[["TEMPO"]]),
      time_med = median(dat_all[["TEMPO"]]),
      time_mn = mean(dat_all[["TEMPO"]])
    ))
  }
  
  get_me_stats <- function() {
    loc_dat_me <- get_dat_me()
    
    # Throw an error if starting number invalid
    shiny::validate(
      shiny::need(!is.null(loc_dat_me), "The provided starting number is invalid!")
    )
    
    return(list(
      age = loc_dat_me[["AGE"]],
      agegr = loc_dat_me[["AGE_BIN"]],
      tempo = loc_dat_me[["TEMPO"]],
      tempo_str = loc_dat_me[["TEMPO_UFFICIALE"]],
      rank = loc_dat_me[["RANK"]],
      rank_agegr = loc_dat_me[["RANK_AGEGR"]],
      perc_faster = loc_dat_me[["PERC_FASTER"]],
      perc_faster_agegr = loc_dat_me[["PERC_FASTER_AGEGR"]]
    ))
  }
  
  output$outPlotRes <- renderPlot({

    loc_p = plotRes()
    if(is.null(loc_p))
      return(NULL)
    
    return(loc_p)
  })
  
  plotRes <- function() {
    loc_dat_all <- get_dat_all()
    loc_dat_aggr <- get_dat_aggr()
    loc_me_stats <- get_me_stats()
    
    p_out <- ggplot(loc_dat_all,
           aes(x = AGE,
               y = TEMPO)) +
      geom_point(aes(color = AGE_BIN),
                 alpha = 0.75) +
      geom_segment(data = loc_dat_aggr,
                   aes(x = AGE_BIN_LOW,
                       xend = AGE_BIN_HI,
                       y = TEMP_MED),
                   color = "#555555",
                   linewidth = 1,
                   alpha = 0.75) +
      geom_hline(yintercept = loc_me_stats$tempo,
                 color = '#00FFFF',
                 linetype = 'dashed',
                 linewidth = 1) +
      geom_point(data = data.frame(AGE = loc_me_stats$age,
                                   TEMPO = loc_me_stats$tempo),
                 aes(x = AGE,
                     y = TEMPO),
                 size = 4,
                 stroke = 1,
                 shape = 1,
                 color = '#00FFFF') +
      scale_color_tableau(palette = 'Tableau 10', name = "Age\ngroup") +
      xlab('Age [years]') +
      ylab("Race time [h:m]") +
      labs(title = sprintf("Traversata del Lago di Lugano %d with %d swimmers", 
                           CURR_YEAR, 
                           nrow(loc_dat_all)),
           subtitle = sprintf("You swam 2.5km in %s; faster than %.1f%% of all swimmers (rank %d); %.1f%% in age group (rank %d)", 
                              loc_me_stats$tempo_str,
                              loc_me_stats$perc_faster,
                              loc_me_stats$rank,
                              loc_me_stats$perc_faster_agegr,
                              loc_me_stats$rank_agegr)) +
      theme_few() +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5))
    
    return(p_out)
  }
  
  output$ageDistPlot <- renderPlot({
    
    loc_dat_aggr <- get_dat_aggr()
    loc_race_stats <- get_race_stats()
    
    ggplot(loc_dat_aggr,
           aes(x = AGE_BIN,
               y = N)) +
      geom_bar(stat = 'identity',
               aes(fill = AGE_BIN),
               color = "grey50", ) +
      scale_fill_tableau(palette = 'Tableau 10', name = "Age\ngroup") +
      labs(title = sprintf("Traversata del Lago di Lugano 2025 with %d swimmers",
                           loc_race_stats$n_part),
           subtitle = sprintf("Age distribution: min=%d, max=%d, median=%d years", 
                              loc_race_stats$age_min, 
                              loc_race_stats$age_max, 
                              loc_race_stats$age_med)) +
      xlab("Age group [years]") +
      ylab("Participant count") +
      theme_few() +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5),
            legend.position = 'none')
  })
  
  output$timeDistPlot <- renderPlot({
    
    loc_dat_all <- get_dat_all()
    loc_stats_me <- get_me_stats()
    loc_stats_race <- get_race_stats()

    ggplot(loc_dat_all,
           aes(x = TEMPO)) +
      geom_histogram(binwidth = 300,
                     color = 'grey50',
                     fill = 'grey80') +
      geom_vline(xintercept = loc_stats_me$tempo,
                 linetype = "dashed",
                 color = "#00FFFF") +
      labs(title = sprintf("Traversata del Lago di Lugano 2025 with %d swimmers", 
                           nrow(loc_dat_all)),
           subtitle = sprintf("Time distribution: min=%s, max=%s, median=%s [h:m:s]",  
                              as.ITime(loc_stats_race$time_min),  
                              as.ITime(loc_stats_race$time_max),  
                              as.ITime(loc_stats_race$time_med))) +
      xlab("Race time [h:m]") +
      ylab("Participant count") +
      theme_few() +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5),
            legend.position = 'none')
    
  })

  output$rankDistPlot <- renderPlot({
    
    loc_dat_all <- get_dat_all()
    loc_me_stats <- get_me_stats()

    ggplot(loc_dat_all,
           aes(x = RANK,
               y = TEMPO)) +
      geom_step() +
      geom_vline(xintercept = loc_me_stats$rank,
                 linetype = "dashed",
                 color = "#FF5555") +
      labs(title = sprintf("Traversata del Lago di Lugano 2025"),
           subtitle = sprintf("You ranked %d out of %d swimmers with time %s [h:m:s]",  
                              loc_me_stats$rank, 
                              nrow(loc_dat_all), 
                              loc_me_stats$tempo_str)) +
      xlab("Arrival rank") +
      ylab("Race time [h:m]") +
      theme_few() +
      theme(plot.title = element_text(hjust = 0.5),
            plot.subtitle = element_text(hjust = 0.5),
            legend.position = 'none')
    
  })
  
  ## Download ----
  
  # Download pdf or png of the plot
  callModule(downPlot, "downPlot",
             "my_result",
             plotRes,
             TRUE)
  
}
