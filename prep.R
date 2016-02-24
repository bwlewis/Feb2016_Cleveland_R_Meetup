# Brewery planner!
# Data preparation
#
# Much of this would work better using data.table, but we keep things
# minimalist here.

#counties = read.table(url("http://www2.census.gov/geo/docs/maps-data/data/gazetteer/counties_list_39.txt"), sep="\t", header=TRUE)
# The Census Bureau gives us the geographic center of each county, some of which
# are in Lake Erie! We correct a few of those manually here to help make plots
# look more reasonable...
counties$INTPTLAT [c(18,22,43)] = counties$INTPTLAT [c(18,22,43)] - 0.25

# The Medicaid Assessment numbers counties with only odd numbers
counties$s9 = seq(from=1, by=2, length.out=88)
save(counties, file="counties.rdata")

# Medicaid assessment data    http://grc.osu.edu/omas/datadownloads/ofhsoehspublicdatasets/
#download.file("https://osuwmcdigital.osu.edu/sitetool/sites/omaspublic/documents/2010_R_Public_Data_Set.zip")
load("ofhs2010_v6_public.rdata")

ages = factor(c("18-24", "25-34", "45-54", "55-64", "65+"), ordered=TRUE)
# We set up a new data frame with just the data subset we're interested in
# Code gender as a factor, using the provided imputation of missing responses
x = data.frame(
  s9     = ofhs2010_v6_public$s9,
  gender = factor(c("male","female"), levels=c("male", "female"))[ofhs2010_v6_public$s15_imp],
  age    = ages[ofhs2010_v6_public$age_a], key="s9"
)

# Drinking rate in days / month of one or more drinks
x$drinking_rate = ofhs2010_v6_public$d46

# Binge drinking rate in days / month of five or more drinks
x$binge = ofhs2010_v6_public$d46a

# Remove missing/unknown data
x = x[x$s9 < 176 & x$drinking_rate < 31,]

# Aggregate average drinking rate by county
drinking = aggregate(x[,c("drinking_rate", "binge")], by=list(s9=x$s9), FUN=mean, na.rm=TRUE)

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
