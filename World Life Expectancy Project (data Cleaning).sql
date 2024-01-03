#A. World Life Expectancy Project (data Cleaning)

SELECT *
FROM world_life_expectancy
;

#LOOKING FOR DUPLICATE ROWS

SELECT country, year, CONCAT(country, year), COUNT(CONCAT(country, year))
FROM world_life_expectancy
GROUP BY country, year, CONCAT(country, year)
HAVING COUNT(CONCAT(country, year)) > 1 
;

SELECT*
FROM (
	SELECT row_id,
    CONCAT (country, year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS Row_num
    FROM world_life_expectancy
    ) AS row_table
WHERE row_num > 1
;

DELETE FROM world_life_expectancy
WHERE
	row_id IN (
    SELECT row_id
FROM (
	SELECT row_id,
    CONCAT (country, year),
    ROW_NUMBER() OVER( PARTITION BY CONCAT(country, year) ORDER BY CONCAT(country, year)) AS Row_num
    FROM world_life_expectancy
    ) AS row_table
WHERE row_num > 1
    )
;

#FILLING IN BLANK SPACES 

SELECT *
FROM world_life_expectancy
WHERE status = ''
;

UPDATE world_life_expectancy
SET status = 'Developing'
WHERE status = '';

 #mistake was made and USA was placed as a developing country instead of a developed country. This mistake is being corrected in the query below
 
 SELECT *
FROM world_life_expectancy
WHERE status = 'Developing' AND country = 'United States of America'
;

UPDATE world_life_expectancy
SET status = 'Developed'
WHERE status = 'Developing' AND country = 'United States of America'
;

SELECT *
FROM world_life_expectancy
WHERE country = 'United States of America'
;

#Filling the blanks for life expectancy

SELECT *
FROM world_life_expectancy
WHERE `life expectancy` = ''
;

#since there are only two rows with blank life expectancy we will take the average of the year before and the year after

SELECT t1.country, t1.year, t1.`life expectancy`,
	t2.country, t2.year, t2.`life expectancy`,
	t3.country, t3.year, t3.`life expectancy`,
    ROUND((t2.`life expectancy` + t3.`life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1    
WHERE t1.`life expectancy` = ''
;

UPDATE  world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year + 1 
SET t1.`life expectancy` =  ROUND((t2.`life expectancy` + t3.`life expectancy`)/2,1)
WHERE t1.`life expectancy` = ''
;

SELECT *
FROM world_life_expectancy ;

#B. Exploring the data

#Checking how many countries are present

SELECT COUNT(DISTINCT (country))
FROM world_life_expectancy ;

#Life Expectancy over a 15 year period

SELECT country, 
	MAX(`Life expectancy`), 
    MIN(`Life expectancy`), 
    ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1)  AS 15_Year_Difference
FROM world_life_expectancy 
GROUP BY country
HAVING MAX(`Life expectancy`) != 0 
   AND MIN(`Life expectancy`) != 0 
   ORDER BY 15_Year_Difference DESC;
   

#World average life expectancy by year

SELECT Year, ROUND(AVG(`Life expectancy`),2) AS AVG_Life
FROM world_life_expectancy 
WHERE `Life expectancy` != 0
GROUP BY Year
ORDER BY Year
;

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS AVG_Life, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY country
HAVING AVG_Life > 0
AND GDP > 0 
ORDER BY GDP ASC;


#avg GDP
select ROUND(MEDIAN(GDP),2)
from world_life_expectancy;

#GDP Correlation 
SELECT 
	SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_count,
    AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_expectancy,
    SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_count,
    AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_expectancy
FROM world_life_expectancy
;

#Status Correlation 

SELECT status, COUNT(DISTINCT country) AS Num_of_countries, ROUND(AVG(`Life expectancy`),1) AS Avg_Life_exp
FROM world_life_expectancy
GROUP BY status
;


#BMI Correlation
SELECT Country, ROUND(AVG(`Life expectancy`),1) AS AVG_Life, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY country
HAVING AVG_Life > 0
AND BMI > 0 
ORDER BY BMI ASC;


#Adult Mortality correlation
SELECT country, year,
`Life expectancy`, 
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY country ORDER BY year) AS Rolling_total
FROM world_life_expectancy
WHERE country = 'United States of America';