Pleae find the code used for analysis in this folder.


- Data.R --> Accessing APIs and reading in csvs to get the data set for analysis and prediction.
  - Collected historical 311 data
  - Collected historical police incident data
  - Collected population of San Francisco in different census tract
  - Collected median income of San Francisco in different census tract
- Exploratory.R --> Exploratory analysis to find the most revelant factors affecting the request volumes of the data.
  - Graphs to analyze the request volume vs type of the days
  - Graphs to analyze the percentage of different request types
- Correlation.R --> Further analysis to find the spatial correlation of different neighborhoods in SF.
  - Assigned the GPS coordinates to defined neighborhoods from SF government
  - Calculated the correlation between poilice incidents and 311 requests in different neighborhoods
  - Graph for this correlation
- Forecast.R --> Building the forecast model and preliminary analysis of the results.
  - Built random forest based model for each type of request
  - Analyzed the fitnees of the models
