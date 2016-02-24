# Brewery planner!
# Data preparation
#
# Much of this would work better using data.table, but we keep things
# minimalist here. See the 'pre-processing.R' file for the steps I used
# to process the raw data files.

# Download and load data
load(url("http://bwlewis.github.io/Feb2016_Cleveland_R_Meetup/counties.rdata"))
load(url("http://bwlewis.github.io/Feb2016_Cleveland_R_Meetup/ofhs2010_subset.rdata"))

# Aggregate average drinking rate by county
drinking = aggregate(ofhs2010_subset[,c("drinking_rate", "binge")], by=list(s9=ofhs2010_subset$s9), FUN=mean, na.rm=TRUE)

# Join avgerage drinking rate by county with the county census data
data = merge(drinking, counties, by="s9")

ui <- fluidPage(
 selectInput("select", label = h3("Variable"), 
             choices = list("Population" = "POP10",
                            "Drinking rate" = "drinking_rate",
                            "Binge drinking rate" = "binge")),
  hr(),
  leafletOutput("mymap", height=800),
  dataTableOutput("mytable")
)

server <- function(input, output, session) {

  pal = reactive({
    i = floor(1 + data[, input$select])
    substr(colorRampPalette(c("blue", "red"))(max(i))[i], 1, 7)
  })  # color

  rad = reactive({
    2e4 * data[, input$select] / max(data[, input$select])
  })  # radius
  
  output$mymap <- renderLeaflet({
    map = addTiles(leaflet())
    map = setView(map, -83, 39.96, zoom = 8)
 #   shiny::showReactLog()
    addCircles(map, lat=data$INTPTLAT, lng=data$INTPTLONG, radius=rad(), popup=data$NAME, fillColor=pal(), fillOpacity=0.7, stroke=FALSE)
  })

  output$mytable = renderDataTable(data)
}
