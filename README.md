# Race Results Browser
Source code of the results browser of the 2025 crossing of the Lugano Lake, [Traversata lago di Lugano](https://traversatalagolugano.ch).

Browse the results online [here](https://macdobry.shinyapps.io/traversata-app/)!

![screen-shot](demo/traversata-app-screen.png)

## Data source

The results are anonymised (no first and last name) from the [official records](https://www.endu.net/it/events/traversata-lago-lugano/results).

## Running the browser locally

This is an [R/Shiny](https://shiny.posit.co) app.
It works on all major operating systems (Windows, macOS, standard Linux distributions), and only requires an installation of an [R](https://www.r-project.org/) programming language. 

For new R users, once you have installed R, we recommend using [RStudio IDE](https://posit.co/products/open-source/rstudio)

## Install and start the app

First, download the latest version of the app directly from here (green button *<>Code*, download as zip). 
Unzip the folder and place it in your favorite location.

If you have installed RStudio, launch it and go to *File -> Open Project*. 
In the contextual menu navigate to the location where you placed the app and open the file `traversata-app.Rproj`. 
This will load the app in the current RStudio session. 
To start the app, open the `server.R` or the `ui.R` file in the RStudio session, then click the *Run App* button with a green triangle in the upper right corner of the window with code open.
