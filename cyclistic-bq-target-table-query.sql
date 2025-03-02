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