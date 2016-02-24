# Brewery planner!
# Data preparation from raw data file sources
#

counties = read.table(url("http://www2.census.gov/geo/docs/maps-data/data/gazetteer/counties_list_39.txt"), sep="\t", header=TRUE)
# The Census Bureau gives us the geographic center of each county, some of which
# are in Lake Erie! We correct a few of those manually here to help make plots
# look more reasonable...
counties$INTPTLAT [c(18,22,43)] = counties$INTPTLAT [c(18,22,43)] - 0.25

# The Medicaid Assessment numbers counties with only odd numbers
counties$s9 = seq(from=1, by=2, length.out=88)
save(counties, file="counties.rdata")

# Medicaid assessment data    http://grc.osu.edu/omas/datadownloads/ofhsoehspublicdatasets/
download.file("https://osuwmcdigital.osu.edu/sitetool/sites/omaspublic/documents/2010_R_Public_Data_Set.zip")
# then unzip that file and load  the R data file
unzip("2010_R_Public_Data_Set.zip")
load("ofhs2010_v6_public.rdata")

# Age ranges present in the file (interestingly, most responses are older folks)
ages = factor(c("18-24", "25-34", "45-54", "55-64", "65+"), ordered=TRUE)

# We set up a new data frame with just the data subset we're interested in
# Code gender as a factor, using the provided imputation of missing responses
ofhs2010_subset = data.frame(
  s9     = ofhs2010_v6_public$s9,
  gender = factor(c("male","female"), levels=c("male", "female"))[ofhs2010_v6_public$s15_imp],
  age    = ages[ofhs2010_v6_public$age_a], key="s9"
)

# Drinking rate in days / month of one or more drinks
ofhs2010_subset$drinking_rate = ofhs2010_v6_public$d46

# Binge drinking rate in days / month of five or more drinks
ofhs2010_subset$binge = ofhs2010_v6_public$d46a

# Remove missing/unknown data
ofhs2010_subset = ofhs2010_subset[ofhs2010_subset$s9 < 176 & ofhs2010_subset$drinking_rate < 31,]

save(ofhs2010_subset, file="ofhs2010_subset.rdata")
