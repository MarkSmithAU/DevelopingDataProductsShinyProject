# ui.R
# 
# Developing Data Products: Shiny Project
# By Mark Smith
# 21 September 2018
#
# This application loads data from the Australian Buearu Of Statistics to investigate the trends in where visitors to Australia originate from. 
# The URL for the Data was http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/3401.0Jul%202018?OpenDocument
# under the section "Table 5: Short-term Movement, Visitors Arriving - Selected Countries of Residence: Original"
# with the downloaded file name "340105.xls".  The download has not been automated as the file path will change over time.
# The code has been written to handle minor changes to column formatting (extra countries/categories) so long as the last column remains as worldwide total, as it is removed as part of the processing.
# There are few comments in this file as it's only UI layout - please see server.R for the bulk of the code.

# Load packages silently
loadNoisyPackages <- function() {
        library(shiny)
        library(plotly)
}
suppressPackageStartupMessages(loadNoisyPackages())

# Render the UI
shinyUI(fluidPage(
        titlePanel("Visitors to Australia Jan 1991 - Jul 2018 by Mark Smith"),
        sidebarLayout(
                sidebarPanel(
                        sliderInput("yearSlider", "Select Years", 1991, 2018, value = c(1991,2018)),
                        checkboxInput("annualCheckbox", "Summarise to Annual"),
                        checkboxInput("regionCheckbox", "Summarise by Region"),
                        submitButton("Submit"),
                        p(""),
                        textOutput("stats"),
                        textOutput("warning"),
                        p(""),
                        h1("Help/Guide Documentation"),
                        h2("Getting Started"),
                        p("Select the year range on the slider above, and if you wish select either or both of the summarisation options to get a different view of the data, then click Submit.  Note that if the options have not changed, the Submit button has no effect."),
                        p("A warning will be displayed above if annual summarisation is selected but there is incomplete data in the final year - the data will be included but will most likely be misleadingly low."),
                        p("A count of the number of raw data points is also calculated and displayed below the Submit button."),
                        p("If any glitches are present in the rendering of the plot, maximise the browser window and refresh/reload the page."),
                        h2("Plot Interaction"),
                        p("To select or compare individual countries/regions, do the following in the legend:"),
                        p("1. Double click-on the line next to the country to isolate it."),
                        p("2. Single click on other country/region names to add them for comparison."),
                        p("To reset the view double-click on any line next to an entry in the legend."),
                        p("Mouse-over individual lines to see the data point values."),
                        p("Note that when plotting 10,000+ points the result of an interaction can be slow."),
                        h2("Source Code"),
                        tags$a(href="https://github.com/MarkSmithAU/DevelopingDataProductsShinyProject", "Click here to be taken to GitHub to view the source code"),
                        h2("Pitch Presentation"),
                        tags$a(href="https://github.com/MarkSmithAU/DevelopingDataProductsShinyPitch", "Click here to be taken to GitHub to view the pitch")
                ),
                mainPanel(
                        p("Optimised for a 1920x1080 screen with the window maximised.  Please change an option and click Submit if the plot does not fully display initially."),
                        plotlyOutput("plot1")
                )
        )
))
