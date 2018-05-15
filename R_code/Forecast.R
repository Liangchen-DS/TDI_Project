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

#clean 311 data
sf311new <- sf311new %>% select(requested_datetime,service_name)
sf311new <- sf311new %>% mutate(date = substring(requested_datetime,1,10))
sf311new <- sf311new %>% select(date,service_name)

#select top 50 service type 
SRANK <- sf311new %>%
  group_by(service_name) %>%
  summarise(total=n()) %>%
  arrange(desc(total))

sf311new <- sf311new  %>% filter( service_name %in% SRANK$service_name[1:50])
#build table with row name date and column name service_name
a <- sf311new %>%
  group_by_at(vars(date,service_name)) %>%
  summarise(total=n())
b <- a %>% spread(service_name,total)
#combine two table together 
colnames(noaanew)[1] <- "date"
b$date <- as.Date(b$date,format="%Y-%m-%d")
noaanew$date <- as.Date(noaanew$date,format = "%Y-%m-%d")
b <- left_join(b,noaanew)
colnames(fh)[1] <- "date"
c <- left_join(b,fh)
#use random forest to do day ahead prediction for each service
c[is.na(c)] <- 0
c$TOBS<-as.numeric(c$TOBS)
c$TRAN<-as.numeric(c$TRAN)
c$PRCP<-as.numeric(c$PRCP)
c$DAY <- as.factor(c$DAY)
c$`Federal holiday` <- as.factor(c$`Federal holiday`)
x = c[8:2192,52:56]
p = c[8:2192,1]
for (i in 1:50){
  predictor = cbind(c[1:2185,i+1],c[2:2186,i+1],c[3:2187,i+1],c[4:2188,i+1],c[5:2189,i+1],c[6:2190,i+1],c[7:2191,i+1],x)
  response = as.numeric(unlist(c[8:2192,i+1]))
  model = randomForest(predictor,response)
  p = data.frame(p,predict(model,predictor))
}
#calculate r-square
actual <- c[8:2192,2:51]
predict <- p[,2:51]
r = 0
for (j in 1:50){
  r = cbind(r,1 - (sum((actual[,j]-predict[,j] )^2)/sum((actual[,j]-mean(unlist(actual[,j])))^2)))
}
r <- as.data.frame(r[2:51])
colnames(r)[1] <- "r-square"
ggplot(data = r,aes(r$`r-square`)) + 
  geom_histogram(col="blue", 
                 fill="blue", 
                 alpha = .2) +
  labs(title="Histogram for R-square") +
  labs(x="R-square", y="Count") + 
  xlim(c(0,1))

#plot prediction using streamgraph
callname <- readRDS("cc.rds")
colnames(P) <- colnames(callname)[1:51]
P$date <- as.Date(P$date,"",format="%Y-%m-%d")
PO <- callname %>% select(1:51)
P_long <- P %>% gather(calltype, count, "311 External Request":"Tree Maintenance")
Po_long <- PO %>% gather(calltype, count, "311 External Request":"Tree Maintenance")
pt1<-P_long %>% mutate(month = months.Date(date)) %>% select(-date) %>% group_by_at(vars(month,calltype)) %>% summarise(total = sum(count))
pt2<-P_long %>% mutate(year = substring(date,1,4)) %>% select(-date) %>% group_by_at(vars(year,calltype)) %>% summarise(total = sum(count))
pt3<- Po_long %>% mutate(year = substring(date,1,4)) %>% select(-date) %>% group_by_at(vars(year,calltype)) %>% summarise(total = sum(count))
pt1$month <- as.character(pt1$month)
streamgraph(pt2,calltype,total,year,width = 500)%>%  sg_axis_x(1, "year", "%Y") %>% sg_legend(show=TRUE, label="Request Type: ") %>% sg_fill_brewer("YlGnBu")
streamgraph(pt3,calltype,total,year)%>%  sg_axis_x(1, "year", "%Y") %>% sg_legend(show=TRUE, label="Request Type: ") %>% sg_fill_brewer("YlGnBu")
streamgraph(P_long,calltype,date,interpolate="cardinal")

#predict Street and Sidewalk Cleaning
ss <- c %>% select(date,`Street and Sidewalk Cleaning`,PRCP,TOBS,TRAN,DAY,`Federal holiday`)     

ss <- transform(ss, `one day ahead` = c(0, `Street and Sidewalk Cleaning`[-nrow(ss)]))
ss <- transform(ss, `two day ahead` = c(0, `one.day.ahead`[-nrow(ss)]))
ss <- transform(ss, `three day ahead` = c(0, `two.day.ahead`[-nrow(ss)]))
ss <- transform(ss, `four day ahead` = c(0, `three.day.ahead`[-nrow(ss)]))
ss <- transform(ss, `five day ahead` = c(0, `four.day.ahead`[-nrow(ss)]))
ss <- transform(ss, `six day ahead` = c(0, `five.day.ahead`[-nrow(ss)]))
ss <- transform(ss, `seven day ahead` = c(0, `six.day.ahead`[-nrow(ss)]))

sss <- as_data_frame(ss[8:2191,])
ssss <- as_data_frame(sss[,2:14])

set.seed(123)
 
rf1 <- randomForest(`Street.and.Sidewalk.Cleaning`~.,data=ssss)
print(rf1)
p1 <- predict(rf1,ssss)

#predict Graffiti
g <- c %>% select(date,Graffiti,PRCP,TOBS,TRAN,DAY,`Federal holiday`)     

g <- transform(g, `one day ahead` = c(0, Graffiti[-nrow(g)]))
g <- transform(g, `two day ahead` = c(0, `one.day.ahead`[-nrow(g)]))
g <- transform(g, `three day ahead` = c(0, `two.day.ahead`[-nrow(g)]))
g <- transform(g, `four day ahead` = c(0, `three.day.ahead`[-nrow(g)]))
g <- transform(g, `five day ahead` = c(0, `four.day.ahead`[-nrow(g)]))
g <- transform(g, `six day ahead` = c(0, `five.day.ahead`[-nrow(g)]))
g <- transform(g, `seven day ahead` = c(0, `six.day.ahead`[-nrow(g)]))

gg <- as_data_frame(g[8:2191,])
ggg <- as_data_frame(gg[,2:14])

rf2 <- randomForest(Graffiti~.,data=ggg)
print(rf2)
p2 <- predict(rf2,ggg)

#play with RF
plot(rf1)
t <- tuneRF(ssss[,-1],ssss[,1],stepFactor = 1,plot = TRUE,ntreeTry = 300,trace = TRUE,improve = 500)
hist(treesize(rf1))
varImpPlot(rf1,main = "variable importance")
importance(rf1)
varUsed(rf1)
getTree(rf1,1,labelVar = TRUE)
MDSplot(rf1,ssss$Street.and.Sidewalk.Cleaning)

#plot observed vs prediction
rfnew <- gg %>% select(date,Graffiti)
rfnew <- rfnew %>% mutate(pred2 = p2 )             
rfnew <- rfnew %>% mutate(`Street.and.Sidewalk.Cleaning` = sss$Street.and.Sidewalk.Cleaning)
rfnew <- rfnew %>% mutate(pred1 = p1 )  
rfnew <- rfnew[1821:2184,] #year 2017

ggplot(data = rfnew) +
  geom_point(aes(x = date,y = `Street.and.Sidewalk.Cleaning`,color ="Street and Sidewalk Cleaning")) +
  geom_point(aes(x = date,y = Graffiti,color ="Graffiti")) +
  
  geom_line(aes(x = date,y = pred1,color ="Street and Sidewalk Cleaning"),group = 1) +
  geom_line(aes(x = date,y = pred2,color="Graffiti"),group = 1) +
  
  labs(x = "date", y = "request volumn") +
  guides(color=guide_legend(title="Type"))+
  coord_cartesian(ylim = c(0,760))+ 
  theme(
    axis.title = element_text(size = rel(2.5)),
    axis.text =  element_text(size = rel(2)),
    legend.text = element_text(size = rel(2)),
    legend.title = element_text(size = rel(2.5))                           
  )  

 