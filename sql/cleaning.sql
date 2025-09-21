USE world_life_expectancy;

-- 0) Load CSV into staging (adjust path to your server file path or use Workbench Import Wizard)
-- Example for LOCAL load:
-- LOAD DATA LOCAL INFILE '/absolute/path/to/WorldLifeExpectancy.csv'
-- INTO TABLE raw_life_expectancy
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES;

-- 1) Insert cleaned rows into target with TRIM, NULLIF, and CAST
INSERT INTO life_expectancy (
  row_id, country, year, status, life_expectancy, adult_mortality, infant_deaths,
  percentage_expenditure, measles, bmi, under_five_deaths, polio, diphtheria,
  hiv_aids, gdp, thinness_1_19_years, thinness_5_9_years, schooling
)
SELECT
  CAST(TRIM(`Row_ID`) AS SIGNED),
  TRIM(`Country`),
  CAST(TRIM(`Year`) AS SIGNED),
  CASE
    WHEN UPPER(TRIM(`Status`)) IN ('DEVELOPED','DEVELOPING') THEN
      IF(UPPER(TRIM(`Status`))='DEVELOPED','Developed','Developing')
    ELSE NULL
  END,
  CAST(NULLIF(TRIM(`Life expectancy `), '') AS DECIMAL(4,1)),
  CAST(NULLIF(TRIM(`Adult Mortality`), '') AS SIGNED),
  CAST(NULLIF(TRIM(`infant deaths`), '') AS SIGNED),
  CAST(NULLIF(TRIM(`percentage expenditure`), '') AS DECIMAL(12,2)),
  CAST(NULLIF(TRIM(`Measles `), '') AS SIGNED),
  CAST(NULLIF(TRIM(` BMI `), '') AS DECIMAL(5,1)),
  CAST(NULLIF(TRIM(`under-five deaths `), '') AS SIGNED),
  CAST(NULLIF(TRIM(`Polio`), '') AS SIGNED),
  CAST(NULLIF(TRIM(`Diphtheria `), '') AS SIGNED),
  CAST(NULLIF(TRIM(` HIV/AIDS`), '') AS DECIMAL(5,1)),
  CAST(NULLIF(TRIM(`GDP`), '') AS DECIMAL(18,2)),
  CAST(NULLIF(TRIM(` thinness  1-19 years`), '') AS DECIMAL(5,1)),
  CAST(NULLIF(TRIM(` thinness 5-9 years`), '') AS DECIMAL(5,1)),
  CAST(NULLIF(TRIM(`Schooling`), '') AS DECIMAL(4,1))
FROM raw_life_expectancy;

-- 2) Basic data quality checks
-- Count rows
SELECT COUNT(*) AS rows_loaded FROM life_expectancy;

-- Null counts per important columns
SELECT
  SUM(life_expectancy IS NULL) AS null_life_expectancy,
  SUM(status IS NULL) AS null_status,
  SUM(gdp IS NULL) AS null_gdp,
  SUM(schooling IS NULL) AS null_schooling
FROM life_expectancy;

-- 3) De-duplicate by country,year keeping the row with the most complete data
DELETE le FROM life_expectancy le
JOIN life_expectancy other
  ON le.country = other.country AND le.year = other.year
  AND le.row_id > other.row_id;

-- 4) Impute missing life_expectancy by country average (rounded to 1 decimal)
UPDATE life_expectancy t
JOIN (
  SELECT country, ROUND(AVG(life_expectancy),1) AS avg_life
  FROM life_expectancy
  WHERE life_expectancy IS NOT NULL
  GROUP BY country
) c ON c.country = t.country
SET t.life_expectancy = c.avg_life
WHERE t.life_expectancy IS NULL;

-- 5) Optional: constrain after cleaning
ALTER TABLE life_expectancy
  MODIFY life_expectancy DECIMAL(4,1) NOT NULL,
  MODIFY year INT NOT NULL,
  MODIFY country VARCHAR(100) NOT NULL;
