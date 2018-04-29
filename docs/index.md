
## Two Interesting Graphs

### Correlation Between Police Incidents and 311 Requests

![Correlation](/plots/correlation.png)

### Prediction
{% include forecast.html %}

## Preliminary Results and Plan for Future Research


![Histogram of RSquare](/plots/histogram.png)

The original

{% include original.html %}

## Motivation

"311" is the toll-free number for non-emergency government communications. First piloted in Baltimore, Maryland in 1996, 311 systems have been adopted across United States to be a point of entry to all government information and to serve as one basis of the government performance metric. Citizens could request services, report non-emergency concerns, and obtain information about the city via phone call, email, twitter,or dedicated mobile apps, while government could use the requests to spot trends and anticipate future citizen needs. It is thus very important for the government to be able to forecast the request volumes of each type to reduce operation costs and to improve customer experiences by optimal investment in infrastructures and staffing decisions. 

With an enormous amount of data recorded by 311 system operators, I propose to build a day-ahead forecast model to predict the volumes of the requests of each type based on previous requests volumes and external factors such as weather, day of week, holiday, socioeconomic status of the population, and nearby police incidents. I deicide to split my project into two tasks: 

1. Influencing Factor Discovery: Spatial-temporal correlation study between complaints volume and other influencing factors 
2. Prediction Model Building: Day ahead prediction for complaints volumes of each complaint type based on their historical volumes and identified influencing factors

## Current Status for the Research

I have built a general framework for this research and tested it on two hypothesis I made. 

1. Higher 311 request volume indicates better access to the technology and may indicate more affluent neighborhoods with lower police incidents.
2. A random forest model with 12 features could be used for prediction.

This general framework is flexible enough to accommodate many more kinds of analysis than what I have shown in these two case studies with limited amount of time.

## Data Sources

|Data                                             | Source           | Access Method         |Size|
|  ---                                            |  ---             | ---                   |--- |
|San Francisco 311 Cases                          |data.sfgov.org    |    Api                |2.92M rows, 19 columns, 961MB|
|San Francisco Police Incidents                   |data.sfgov.org    |    Api                |2.2M rows, 13 columns, 442 MB|
|National Holiday                                 |US calendar       |Downloaded as csv      |60 rows, 3 columns, 3KB|		
|San Francisco Weather History                    | 	NOAA	     |Downloaded as csv      |0.2M rows, 23 columns, 9.5MB|
|San Francisco Blocks and Neighborhood Definition |	data.sfgov.org   |Downloaded as shapefile|172 KB|

