-- Create database and use it
CREATE DATABASE IF NOT EXISTS world_life_expectancy;
USE world_life_expectancy;

-- 1) Staging table mirrors the CSV as-is, all text columns trimmed later
DROP TABLE IF EXISTS raw_life_expectancy;
CREATE TABLE raw_life_expectancy (
  `Country` VARCHAR(100),
  `Year` VARCHAR(10),
  `Status` VARCHAR(20),
  `Life expectancy ` VARCHAR(16),
  `Adult Mortality` VARCHAR(16),
  `infant deaths` VARCHAR(16),
  `percentage expenditure` VARCHAR(32),
  `Measles ` VARCHAR(16),
  ` BMI ` VARCHAR(16),
  `under-five deaths ` VARCHAR(16),
  `Polio` VARCHAR(16),
  `Diphtheria ` VARCHAR(16),
  ` HIV/AIDS` VARCHAR(16),
  `GDP` VARCHAR(24),
  ` thinness  1-19 years` VARCHAR(16),
  ` thinness 5-9 years` VARCHAR(16),
  `Schooling` VARCHAR(16),
  `Row_ID` VARCHAR(16)
);

-- 2) Clean target table with proper types and snake_case names
DROP TABLE IF EXISTS life_expectancy;
CREATE TABLE life_expectancy (
  row_id INT PRIMARY KEY,
  country VARCHAR(100) NOT NULL,
  year INT NOT NULL,
  status ENUM('Developed','Developing') NULL,
  life_expectancy DECIMAL(4,1) NULL,
  adult_mortality INT NULL,
  infant_deaths INT NULL,
  percentage_expenditure DECIMAL(12,2) NULL,
  measles INT NULL,
  bmi DECIMAL(5,1) NULL,
  under_five_deaths INT NULL,
  polio INT NULL,
  diphtheria INT NULL,
  hiv_aids DECIMAL(5,1) NULL,
  gdp DECIMAL(18,2) NULL,
  thinness_1_19_years DECIMAL(5,1) NULL,
  thinness_5_9_years DECIMAL(5,1) NULL,
  schooling DECIMAL(4,1) NULL,
  UNIQUE KEY uk_country_year (country, year)
);

-- Helpful indexes for analysis
CREATE INDEX idx_year ON life_expectancy(year);
CREATE INDEX idx_country ON life_expectancy(country);
