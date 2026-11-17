-- Cleaning EV_population -- 
#1 Electric Range = 0 to NULL (unreported, not real zeros)
SET SQL_SAFE_UPDATES = 0;

UPDATE EV_population
SET electric_range = NULL
WHERE electric_range = 0;

SET SQL_SAFE_UPDATES = 1;

#2 Confirm WA focus (state breakdown for reference)
SELECT state, COUNT(*) AS row_count
FROM EV_population
GROUP BY state
ORDER BY row_count DESC;

#3 Check blank counties (found 9)
SELECT * FROM EV_population
WHERE county IS NULL OR TRIM(county) = '';

#4 CAFV Eligibility categories ("unknown" is its own category)
SELECT cafv_eligibility, COUNT(*) AS row_count
FROM EV_population
GROUP BY cafv_eligibility;

#5 Model Year outliers (confirming range makes sense) #1999-2027
SELECT model_year, count(electric_range) AS row_counts
FROM EV_population
group by model_year
order by model_year;

#6 Transaction Type (keep types separate, just confirm what's there)
SELECT transaction_type, COUNT(*) AS row_counts
FROM vehicle_registration
GROUP BY transaction_type;

#7 CAFV Eligibility categories ("unknown" is its own category)
SELECT model_year, cafv_eligibility, COUNT(*) AS row_count
FROM EV_population
GROUP BY cafv_eligibility,model_year;

##add range tier column
select count(*),
CASE
  WHEN electric_range IS NULL                              
	THEN 'Unknown'
  WHEN electric_range < 100                                
	THEN 'Short (<100)'
  WHEN electric_range < 250                                
	THEN 'Mid (100-249)'
  ELSE 'Long (250+)'
END AS range_tier
from EV_population
where state = 'WA'
	AND model_year BETWEEN 2011 AND 2025
group by range_tier;

#---add----#
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE EV_population ADD COLUMN range_tier VARCHAR(20);
UPDATE EV_population
SET range_tier = CASE
    WHEN electric_range IS NULL  
		THEN 'Unknown'
    WHEN electric_range < 100    
		THEN 'Short (<100)'
    WHEN electric_range < 250    
		THEN 'Mid (100-249)'
    ELSE 'Long (250+)'
END;
SET SQL_SAFE_UPDATES = 1;

#total rows
select count(*)
from EV_population
where state = 'WA'
	AND model_year BETWEEN 2011 AND 2025;


### Visualization 3
SELECT county,
       ROUND(SUM(ev_type='Battery Electric Vehicle (BEV)') / COUNT(*) * 100, 1) AS phev_pct,
       COUNT(*) AS n_total,
       SUM(model_year = 2022) AS cnt_2022,
    SUM(model_year = 2023) AS cnt_2023,
    ROUND(
        (SUM(model_year = 2023) - SUM(model_year = 2022)) / SUM(model_year = 2022) * 100
		, 1) AS yoy_2023_pct,
	COUNT(electric_range) AS cnt_has_range
FROM EV_population
WHERE state = 'WA'
  AND model_year BETWEEN 2011 AND 2025
GROUP BY county
HAVING cnt_2022 > 20
ORDER BY yoy_2023_pct DESC;

### Visualization 4
select county, round(avg(electric_range),0) as avg_electric_range,
	SUM(model_year = 2022) AS cnt_2022,
    SUM(model_year = 2023) AS cnt_2023,
    ROUND(
        (SUM(model_year = 2023) - SUM(model_year = 2022)) / SUM(model_year = 2022) * 100
		, 1) AS yoy_2023_pct,
	COUNT(electric_range) AS cnt_has_range,
    SUM(electric_range IS NULL) AS cnt_unknown
from EV_population
where state = 'WA'
	AND model_year BETWEEN 2011 AND 2025
    and ev_type='Battery Electric Vehicle (BEV)'
group by county
having cnt_2022 > 20
ORDER BY yoy_2023_pct DESC;
