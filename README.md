# Cyclistic---BI-case-study
Case study on a NYC Citi Bike public dataset done during Google Business Intelligence Professional Certyficate course

### Background
In this fictitious workplace scenario, the imaginary company Cyclistic has partnered with the city of New York to provide shared bikes. Currently, there are bike stations located throughout Manhattan and neighbouring boroughs. Customers are able to rent bikes for easy travel among stations at these locations. 

### Scenario
You are a newly hired BI professional at Cyclistic. The company’s Customer Growth Team is creating a business plan for next year. They want to understand how their customers are using their bikes; their top priority is identifying customer demand at different station locations.  Previously, you gathered information from your meeting notes to complete important project planning documents and generated useful target tables.

## Project planning

### Business problem
Cyclistic's Customer Growth Team is creating a business plan for next year. The team wants to understand how their customers are using their bikes; their top priority is identifying customer demand at different station locations 

**Primary question**: How can we apply customer usage insights to inform new station growth

**Stakeholder usage details:** To effectively develop new station locations, the team wants to understand how customers use the current line of bikes. They will use this BI tool in order to gain insights related to data generated by the bikes when being used by customers. Then, this information will be used to understand what customers want, what makes a successful product, and how new stations might alleviate demand in different geographical areas.

**Primary requirements:**
- A table or map visualization exploring starting and ending station locations, aggregated by location.
- A visualization showing which destination (ending) locations are popular based on the total trip minutes.
- A visualization that focuses on trends from the summer of 2015.
- A visualization showing the percent growth in the number of trips year over year.
- Gather insights about congestion at stations.
- Gather insights about the number of trips across all starting and ending locations.
- Gather insights about peak usage by time of day, season, and the impact of weather.

## Data preparation

### Datasets
Most of the data is avaiable in Google BigQuery public data
**Primary dataset**: [NYC Citi Bike Trips](https://console.cloud.google.com/marketplace/details/city-of-new-york/nyc-citi-bike?inv=1&invt=AbpvUg)
**Secondary dataset:** [United States Census Bureau](United States Census Bureau)
The stakeholders want insights about neighborhoods so it’s necessary to add csv file to BQ:
[Cyclistic NYC zip codes](https://docs.google.com/spreadsheets/d/1qhjoGGoqZK5VhztocNtcm47Fu_hHzBnQP_u0cbASOJQ/edit?usp=sharing)

### SQL query for data extraction and transformation in BigQuery

```sql
SELECT
  t.usertype,
  -- getting for start and stop locations
  zs.zip_code AS zip_code_start,
  zsn.borough AS borough_start,
  zsn.neighborhood AS neiborhood_start,
  ze.zip_code AS zip_code_end,
  zen.borough AS borough_end,
  zen.neighborhood AS neiborhood_end,
  -- since it's fictional dashboard, I'm adding 8 years to make it look recent
  DATE_ADD(DATE(t.starttime), INTERVAL 8 YEAR) AS start_day,
  DATE_ADD(DATE(t.stoptime), INTERVAL 8 YEAR) AS stop_day,
  -- getting mean temp, wind and precipitation
  w.temp AS day_mean_temp,
  w.wdsp AS day_mean_wind_sp,
  w.prcp AS day_total_prcp,
  -- grouping trips into 10 min intervals to get less rows
  ROUND(CAST(t.tripduration / 60 AS INT64), -1) AS trip_minutes,
  COUNT(t.bikeid) AS trip_count
FROM
  `bigquery-public-data.new_york_citibike.citibike_trips` AS t
INNER JOIN
  `bigquery-public-data.geo_us_boundaries.zip_codes` AS zs
  ON ST_WITHIN(ST_GEOGPOINT(t.start_station_longitude, t.start_station_latitude), zs.zip_code_geom)
INNER JOIN 
  `bigquery-public-data.geo_us_boundaries.zip_codes` AS ze
  ON ST_WITHIN(ST_GEOGPOINT(t.end_station_longitude, t.end_station_latitude), ze.zip_code_geom)
INNER JOIN
  `bigquery-public-data.noaa_gsod.gsod20*` AS w
  ON PARSE_DATE('%Y%m%d', CONCAT(w.year,w.mo,w.da)) = DATE(t.starttime)
INNER JOIN
  `cyclistc-451119.cyclistic.zip_codes` AS zsn
  ON zs.zip_code = CAST(zsn.zip AS STRING)
INNER JOIN
  `cyclistc-451119.cyclistic.zip_codes` AS zen
  ON ze.zip_code = CAST(zen.zip AS STRING)
WHERE
  -- taking weather data from weater station NEW YORK CENTRAL PARK
  w.wban = '94728' AND
  -- data from 2014 and 2015
  EXTRACT(YEAR FROM DATE(t.starttime)) BETWEEN 2014 AND 2015
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
```

## Dashboard design
Since Tableau Public doesn’t allow connection to BigQuery, I exported target table to a .csv file. The file is attached to the repository

### Tableau Dashboard
Interactive dashboard is available on my Tabaleu Public profile:
[Cyclistic Bike Share Dashboard](https://public.tableau.com/views/CyclistcNYCBike-Share/Overview?:language=en-US&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)

PDF file is attached to the repository.

### Screenshots

**Overview**

![Overview](https://github.com/user-attachments/assets/83d844fb-df83-4764-ae75-19c41b8ff58f)

**Top Trips**

![Top Trips](https://github.com/user-attachments/assets/17631f4a-3749-437b-b58e-1db059bb3f17)

**Summer Trends**

![Summer Trends](https://github.com/user-attachments/assets/d60d4550-b5f6-4288-bdb4-e7fb4ff7ac97)






