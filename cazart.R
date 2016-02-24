library(data.table)
library(leaflet)

#counties = read.table(url("http://www2.census.gov/geo/docs/maps-data/data/gazetteer/counties_list_39.txt"), sep="\t", header=TRUE)
# save(counties, file="counties.rdata")
load("counties.rdata")
# The Census Bureau gives us the geographic center of each county, some of which
# are in Lake Erie! We correct a few of those manually here to help make plots
# look more reasonable...
counties$INTPTLAT [c(18,22,43)] = counties$INTPTLAT [c(18,22,43)] - 0.25
# The Medicaid Assessment numbers counties with only odd numbers
counties$s9 = seq(from=1, by=2, length.out=88)
counties = data.table(counties, key="s9")

# Medicaid assessment data    http://grc.osu.edu/omas/datadownloads/ofhsoehspublicdatasets/
load("ofhs2010_v6_public.rdata")

ages = factor(c("18-24", "25-34", "45-54", "55-64", "65+"), ordered=TRUE)
# We set up a new data frame with just the data subset we're interested in
# Code gender as a factor, using the provided imputation of missing responses
x = data.table(
  s9     = ofhs2010_v6_public$s9,
  gender = factor(c("male","female"), levels=c("male", "female"))[ofhs2010_v6_public$s15_imp],
  age    = ages[ofhs2010_v6_public$age_a], key="s9"
)

# Drinking rate in days / month of one or more drinks
x$drinking_rate = ofhs2010_v6_public$d46

# Binge drinking rate in days / month of five or more drinks
x$binge = ofhs2010_v6_public$d46a

# Remove missing/unknown data
x = x[s9 < 176 & drinking_rate < 31,]

# Join avgerage drinking rate by county with the county data
counties = counties[x[, list(drinks=mean(drinking_rate),
                             binge=mean(binge, na.rm=TRUE)), by=list(s9)]]





# devtools::install_github("ramhiser/noncensus")
#library(noncensus)
#data("county_polygons", package="noncensus")
#ohio = data.table(county_polygons[grep("^ohio", county_polygons$names),], key="county")
#map = addTiles(leaflet())
#map = setView(map, -83, 39.96, zoom = 8)
#map = addPolygons(map, lat=ohio$lat, lng=ohio$long,
#              opacity=1, fillOpacity=0.8,
#              stroke=TRUE, color="black", weight=1)
