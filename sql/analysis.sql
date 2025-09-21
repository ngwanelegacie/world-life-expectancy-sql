USE world_life_expectancy;

-- 1) Head count and coverage
SELECT
  COUNT(*) AS rows_total,
  COUNT(DISTINCT country) AS countries,
  MIN(year) AS min_year,
  MAX(year) AS max_year
FROM life_expectancy;

-- 2) Summary stats for key metrics
SELECT
  ROUND(AVG(life_expectancy),2) AS avg_life,
  MIN(life_expectancy) AS min_life,
  MAX(life_expectancy) AS max_life,
  ROUND(AVG(gdp),2) AS avg_gdp,
  ROUND(AVG(schooling),2) AS avg_schooling
FROM life_expectancy;

-- 3) Average life expectancy by country
SELECT country, ROUND(AVG(life_expectancy),1) AS avg_life
FROM life_expectancy
GROUP BY country
ORDER BY avg_life DESC
LIMIT 20;

-- 4) Yearly global trend
SELECT year, ROUND(AVG(life_expectancy),2) AS world_avg_life
FROM life_expectancy
GROUP BY year
ORDER BY year;

-- 5) South Africa trend
SELECT year, life_expectancy
FROM life_expectancy
WHERE country = 'South Africa'
ORDER BY year;

-- 6) GDP vs Life Expectancy Pearson correlation (global)
WITH s AS (
  SELECT
    COUNT(*) AS n,
    SUM(gdp) AS sx,
    SUM(life_expectancy) AS sy,
    SUM(gdp * life_expectancy) AS sxy,
    SUM(gdp * gdp) AS sx2,
    SUM(life_expectancy * life_expectancy) AS sy2
  FROM life_expectancy
  WHERE gdp IS NOT NULL AND life_expectancy IS NOT NULL
)
SELECT
  ROUND(
    (n * sxy - sx * sy) /
    SQRT( (n * sx2 - sx * sx) * (n * sy2 - sy * sy) )
  , 4) AS corr_gdp_life
FROM s;

-- 7) Top 10 countries by peak HIV/AIDS rate
SELECT country, MAX(hiv_aids) AS max_hiv
FROM life_expectancy
GROUP BY country
ORDER BY max_hiv DESC
LIMIT 10;

-- 8) Year over year change in life expectancy by country (last 5 years of data for each)
WITH ranked AS (
  SELECT
    country,
    year,
    life_expectancy,
    LAG(life_expectancy) OVER (PARTITION BY country ORDER BY year) AS prev_life
  FROM life_expectancy
)
SELECT country, year,
       life_expectancy,
       ROUND(life_expectancy - prev_life, 2) AS yoy_change
FROM ranked
WHERE prev_life IS NOT NULL
ORDER BY country, year DESC
LIMIT 200;

-- 9) Infant deaths vs life expectancy relationship buckets
SELECT
  CASE
    WHEN infant_deaths <= 10 THEN '0-10'
    WHEN infant_deaths <= 50 THEN '11-50'
    WHEN infant_deaths <= 100 THEN '51-100'
    ELSE '100+'
  END AS infant_deaths_bucket,
  ROUND(AVG(life_expectancy),2) AS avg_life
FROM life_expectancy
GROUP BY infant_deaths_bucket
ORDER BY
  CASE infant_deaths_bucket
    WHEN '0-10' THEN 1
    WHEN '11-50' THEN 2
    WHEN '51-100' THEN 3
    ELSE 4
  END;

-- 10) Schooling vs life expectancy deciles
WITH dec AS (
  SELECT
    country, year, life_expectancy, schooling,
    NTILE(10) OVER (ORDER BY schooling) AS sch_decile
  FROM life_expectancy
  WHERE schooling IS NOT NULL
)
SELECT sch_decile, ROUND(AVG(life_expectancy),2) AS avg_life
FROM dec
GROUP BY sch_decile
ORDER BY sch_decile;
