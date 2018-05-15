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

#correlation study
# read in neighborhood definition shapefile
sfm <- readOGR(dsn="geo", layer="sfm")
sfm_f <- fortify(sfm, region = "name")
test1 <- sf311new 

# assign 311 events to corresponding neighborhoods
coords <- test1 %>% select(long,lat)
sp <- SpatialPoints(data.matrix(coords))

proj4string(sp) <- sfm@proj4string
spn <- over(sp, sfm)

test1["zone_name"] <- spn$name
test1 <- test1 %>% mutate(date = substring(requested_datetime,1,10))
sf311dp <- test1 %>% group_by_at(vars(zone_name,date)) %>% summarise(total311=n()) %>% na.omit()

# assign police events to corresponding neighborhoods
test2 <- crimenew
coords2 <- test2 %>% select(location.longitude,location.latitude)
sp2 <- SpatialPoints(data.matrix(coords2))

proj4string(sp2) <- sfm@proj4string
spn2 <- over(sp2, sfm)
test2["zone_name"] <- spn2$name
sfcrimedp <- test2 %>% group_by_at(vars(zone_name,date)) %>% summarise(totalcrime=n()) %>% na.omit()

#join crime and 311 data base
sf311dp$date <- as.POSIXct(sf311dp$date,"" ,"%Y-%m-%d")
c311 <- left_join(sf311dp,sfcrimedp)
c311[is.na(c311)] <- 0

# calculate the correlation
c311cor <- c311 %>% group_by(zone_name) %>% summarise(corr = cor(total311,totalcrime)) 
colnames(c311cor) <- c("id","correlation")
crmap2 <- left_join(sfm_f , c311cor)
#plot heat map
g2 <- ggplot()
g2 <- g2 +  geom_polygon(data = crmap, aes(x=long, y=lat, group=group, fill=correlation), color = "black", size=0.2) 
g2 <- g2 + coord_map()  + scale_fill_distiller(type="seq", trans="reverse", palette = "Greens", breaks=pretty_breaks(n=8)) + theme_nothing(legend=TRUE) 
