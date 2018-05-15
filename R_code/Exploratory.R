library(dplyr)
library(ggplot2)
library(scales)
library(plotly)
library(randomForest)
library(caret)

#percentage of each complaint type
SRANK <- sf311new %>%
  group_by(service_name) %>%
  summarise(total=n()) %>%
  arrange(desc(total)) 
SRANKnew <- SRANK[1:20,]
other <- sum(SRANK$total[20:50])
SRANKnew[20,1] <- 'Others'
SRANKnew[20,2] <- other

p <- plot_ly(SRANKnew, labels = ~service_name, values = ~total, type = 'pie',
             textposition = 'inside',
             textinfo = 'label+percent',
             insidetextfont = list(color = '#FFFFFF'),
             hoverinfo = 'text',
             showlegend = FALSE) %>%
  layout(title = 'Percentage of complaint type',
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
p

#percentage of complaint of each day of week 
S = c %>% group_by(DAY) %>% summarise(`Street and Sidewalk Cleaning` = sum(`Street and Sidewalk Cleaning`),
                                      Graffiti = sum(Graffiti),
                                      `Abandoned Vehicle` = sum(`Abandoned Vehicle`),                                                         
                                      `MUNI Feedback` = sum(`MUNI Feedback`),
                                      `Homeless Concerns` = sum(`Homeless Concerns`),
                                      Encampments = sum(Encampments),
                                      `Damaged Property` = sum(`Damaged Property`))
SS <- S %>% mutate(`Street and Sidewalk Cleaning` = `Street and Sidewalk Cleaning`/sum(`Street and Sidewalk Cleaning`),
                   Graffiti = Graffiti/sum(Graffiti),
                   `Abandoned Vehicle` = `Abandoned Vehicle`/sum(`Abandoned Vehicle`),
                   `MUNI Feedback` = `MUNI Feedback`/sum(`MUNI Feedback`),
                   `Homeless Concerns` = `Homeless Concerns`/sum(`Homeless Concerns`),
                   Encampments = Encampments/sum(Encampments),
                   `Damaged Property` = `Damaged Property`/sum(`Damaged Property`)) 

SS$DAY <- factor(SS$DAY, c('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'))

perp<- ggplot(data = SS) +
  geom_point(mapping = aes(x = DAY,y = `Street and Sidewalk Cleaning`,color ="Street and Sidewalk Cleaning"),size=4) +
  geom_point(mapping = aes(x = DAY,y = Graffiti,color ="Graffiti"),size=4) +
  geom_point(mapping = aes(x = DAY,y = `Abandoned Vehicle`,color = "Abandoned Vehicle"),size=4) +
  geom_point(mapping = aes(x = DAY,y = `MUNI Feedback`,color="MUNI Feedback"),size=4) +
  geom_point(mapping = aes(x = DAY,y = `Homeless Concerns`,color="Homeless Concerns"),size=4) +
  geom_point(mapping = aes(x = DAY,y = Encampments,color="Encampments"),size=4) +
  
  geom_line(aes(x = DAY,y = `Street and Sidewalk Cleaning`,color ="Street and Sidewalk Cleaning"),group = 1,size=2) +
  geom_line(aes(x = DAY,y = Graffiti,color="Graffiti"),group = 1,size=2) +
  geom_line(aes(x = DAY,y = `Abandoned Vehicle`,color="Abandoned Vehicle"),group = 1,size=2) +
  geom_line(aes(x = DAY,y = `MUNI Feedback`,color="MUNI Feedback"),group = 1,size=2) +
  geom_line(aes(x = DAY,y = `Homeless Concerns`,color="Homeless Concerns"),group = 1,size=2) +
  geom_line(aes(x = DAY,y = Encampments,color="Encampments"),group = 1,size=2) +
  
  labs(x = "DAY", y = "Percentage") +
  guides(color=guide_legend(title="Type"))

perp + theme(
  panel.grid.major.y = element_blank(),
  panel.grid.minor.y = element_blank(),
  panel.background = element_rect(fill = "white", color = "grey50"),
  axis.title = element_text(size = rel(2.5)),
  axis.text =  element_text(size = rel(2)),
  legend.text = element_text(size = rel(2)),
  legend.title = element_text(size = rel(2.5))                           
)  
