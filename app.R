# Brewery planner! Simple Shiny app
# First run "prep.R"

library(shiny)
library(DT)
library(leaflet)

ui = fluidPage(
  title = "A particularly silly brewery planner",
  fluidRow(
    column(2, h3("A silly brewery planner"), 
           selectInput("select", label = h3("Variable"), 
                       choices = list("Population" = "POP10",
                                       "Drinking rate" = "drinking_rate",
                                       "Pop adjusted rate" = "adjusted",
                                       "Binge drinking rate" = "binge"))),
    column(10, leafletOutput("mymap", height=700))
  ),
  hr(),
  dataTableOutput("mytable")
)


server = function(input, output, session) {

  pal = reactive({
    i = floor(1 + 10 * data[, input$select] / max(data[, input$select]))
    substr(colorRampPalette(c("blue", "red"))(max(i))[i], 1, 7)
  })  # color, coverted to non-alpha hex RGB values for leaflet (the substr)

  rad = reactive({
    2e4 * data[, input$select] / max(data[, input$select])
  })  # radius
  
  output$mymap = renderLeaflet({
    map = addTiles(leaflet())
    map = setView(map, -83, 39.96, zoom = 7)
    addCircles(map, lat=data$INTPTLAT, lng=data$INTPTLONG, radius=rad(),
               popup=data$NAME, fillColor=pal(), fillOpacity=0.7, stroke=FALSE)
  })

  output$mytable = renderDataTable(data)
}
