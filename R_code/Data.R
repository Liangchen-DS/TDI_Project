library(RSocrata)
library(dplyr)
library(ggplot2)
library(devtools)
library(rwunderground)
library(readr)
library(tidyr)
library(randomForest)
library(tidyverse)
library(ggmap)
library(DT)
library(knitr)
library(rgdal)
library(rgeos)
library(maptools)
library(scales)
library(streamgraph)
library(acs)
library(tigris)

#read data
sf311 <- read.socrata(
  "https://data.sfgov.org/resource/ktji-gk7t.json",
  app_token = "pGX3FxHqr1tlBOAoV4qCVxP9D",
  email     = "chenliang1468@gmail.com",
  password  = "*******"
)
crime <- read.socrata(
  "https://data.sfgov.org/resource/PdId.json",
  app_token = "pGX3FxHqr1tlBOAoV4qCVxP9D",
  email     = "chenliang1468@gmail.com",
  password  = "*******"
)
#read natioanl holiday data
fh <- read_csv(choose.files())
fh$Date <- as.Date(fh$Date,format = "%m/%d/%Y")
fh <- fh %>% select(-`Day of the week`)

#read historical weather data
#from weather underground
devtools::install_github("ALShum/rwunderground")
rwunderground::set_api_key("1ef8906c930a120f")
weather <- history_daily(history_range(set_location(territory = "California", city = "San Francisco"), "20120101", "20121231"))
#or from noaa
noaa <- read_csv(choose.files())
noaanew <-  noaa%>%filter(STATION=='USC00044500')
noaanew <- noaanew %>% select(DATE,PRCP,TMAX,TMIN,TOBS)
noaanew <- noaanew %>% mutate(TRAN = TMAX-TMIN)
noaanew <- noaanew %>% select(-TMAX,-TMIN)
noaanew <- noaanew %>% mutate(DAY = weekdays(as.Date(DATE)))

#study the data between 2012 to 2017
sf311 <- as_data_frame(sf311)
crime <- as_data_frame(crime)
sf311new <- sf311 %>% filter(requested_datetime >= '2012-01-01')
sf311new <- sf311new %>% filter(requested_datetime <= '2017-12-31')
crimenew <- crime %>% filter(date >= '2012-01-01')
crimenew <- crimenew %>% filter(date <= '2017-12-31')

# read in census tract definition
sfs <- tracts(state = "CA", county = "San Francisco")
sfs_f <- fortify(sfs, region = "GEOID")

test1 <- sf311new

# Read-in census data from Api
api.key.install(key = "c2e150310c96b6b98fbe658858dbcbf6cec07b08")
sfg = geo.make(state = "CA", county = "San Francisco")
pop <- acs.fetch(geography=sfg, endyear=2014,
          table.number="B19001")
# or From CSV
# median income
mincome<-read_csv("ACS_16_5YR_S1901_with_ann.csv",col_names = TRUE)
mincomec<-mincome %>% select(Id2,"Households; Estimate; Mean income (dollars)")
# modify its names to match the one on the shapefile
mincomec$Id2 <- paste("0",mincomec$Id2,sep = "")
colnames(mincomec) <- c("geo_id","median_income")
#populattion
pop<-read_csv("ACS_16_5YR_B01003_with_ann.csv",col_names = TRUE)
popc<-pop %>% select(Id2,"Estimate; Total")
popc$Id2 <- paste("0",popc$Id2,sep = "")

# assign the 311 requests to corresponding tract according to GPS coordinates

coords <- test1 %>% select(long,lat)
sp <- SpatialPoints(data.matrix(coords))
proj4string(sp) <- sfs@proj4string
spn <- over(sp, sfs)

test1["tract_name"] <- spn$NAMELSAD
test1["geo_id"] <- spn$GEOID
test1 <- test1 %>% mutate(date = substring(requested_datetime,1,10))
sf311dp <- test1 %>% group_by_at(vars(service_name,geo_id,date)) %>% summarise(total311=n()) %>% na.omit()

# assign the police requests to corresponding tract according to GPS coordinates
test2 <- crimenew
coords2 <- test2 %>% select(location.longitude,location.latitude)
sp2 <- SpatialPoints(data.matrix(coords2))

proj4string(sp2) <- sfs@proj4string
spn2 <- over(sp2, sfs)
test2["geo_id"] <- spn2$GEOID
sfcrimedp <- test2 %>% group_by_at(vars(geo_id,date)) %>% summarise(totalcrime=n()) %>% na.omit()

#join crime and 311 data base
sf311dp$date <- as.POSIXct(sf311dp$date,"" ,"%Y-%m-%d")
c311 <- left_join(sf311dp,sfcrimedp)

# join median income
c311 <- left_join(c311,mincomec)
# join population
c311 <- left_join(c311,popc)

 
