# Brewery planner! data prep
#
# Much of this would work better using data.table, but we keep things
# minimalist here. See the 'pre-processing.R' file for the steps I used
# to process the raw data files.

# Download and load data
load(url("http://bwlewis.github.io/Feb2016_Cleveland_R_Meetup/counties.rdata"))
load(url("http://bwlewis.github.io/Feb2016_Cleveland_R_Meetup/ofhs2010_subset.rdata"))

# Aggregate average drinking rate by county
drinking = aggregate(ofhs2010_subset[,c("drinking_rate", "binge")], by=list(s9=ofhs2010_subset$s9), FUN=mean, na.rm=TRUE)
# Append total number of survey responses by couny
drinking$count = aggregate(ofhs2010_subset$s9, by=list(s9=ofhs2010_subset$s9), FUN=length)[,2]
# Crude population-adjusted drikning rate
drinking$adjusted = drinking$drinking_rate / drinking$count

# Join avgerage drinking rate by county with the county census data
data = merge(drinking, counties, by="s9")
