# server.R
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

loadNoisyPackages <- function() {
        library(shiny)
        library(plotly)
        library(data.table)
        library(dplyr)
        library(readxl)
        library(stringr)
        library(tidyr)        
        library(htmlwidgets)
        library(lubridate)
        library(RColorBrewer)
}
suppressPackageStartupMessages(loadNoisyPackages())


shinyServer(function(input, output) {
        getData <- reactive({
                originalData <- read_excel("340105.xls", sheet="Data1", skip=9)
                headers <- read_excel("340105.xls", sheet="Data1", n_max=0)
                names(originalData) <- c("Period", names(headers))
                names(originalData) <- gsub("Number of movements ;  ", "", names(originalData))
                names(originalData) <- gsub(" ;  Short-term Visitors arriving ;", "", names(originalData))
                totalsCols <- grep("Total", names(headers))+1
                totalsMonthly <- originalData[,c(1, totalsCols)]
                totalsMonthly <- totalsMonthly[,-ncol(totalsMonthly)] # Remove the worldwide total
                individualMonthly <- originalData[,-totalsCols]
                return(list("totalsMonthly" = totalsMonthly, "individualMonthly" = individualMonthly))
        })
        
        generatePlotData <- reactive({
                minYear <- input$yearSlider[1]
                maxYear <- input$yearSlider[2]
                annual <- input$annualCheckbox
                byRegion <- input$regionCheckbox
                data <- getData()
                if (byRegion) {
                        intData <- data$totalsMonthly
                } else {
                        intData <- data$individualMonthly
                }
                
                intData <- intData %>% filter(year(Period) >= minYear & year(Period) <= maxYear)
                
                plotData <- intData %>% gather(Country, People, 2:ncol(intData))
                
                warningText <- ""
                
                if (annual) {
                        plotData <- plotData %>% group_by(Country, year(Period)) %>% summarise(People = sum(People))
                        names(plotData)[2] <- "Period"
                         
                        if (nrow(intData) %% 12 != 0) {
                                warningText <- "WARNING: the last year has incomplete data (less than 12 months) so the annual count will be low/incomplete"
                        }
                }
                
                stats <- paste(nrow(plotData), "data points plotted")

                return(list("plotData" = plotData, "warning" = warningText, "stats" = stats))
        })
        
        output$warning <- reactive({
                generatePlotData()$warning
                })
        
        output$stats <- reactive({
                generatePlotData()$stats
        })

        output$plot1 <- renderPlotly({
                plotData <- generatePlotData()$plotData
                
                colourCount <- length(unique(plotData$Country))
                getPalette <- colorRampPalette(brewer.pal(9, "Set1"))
                
                plot_ly(plotData, x = ~Period, y = ~People, type = 'scatter', mode = 'lines', color = ~Country, colors = getPalette(colourCount), width = 1000, height = 800)
        })
})
