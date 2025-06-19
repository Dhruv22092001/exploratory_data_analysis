-- Exploratory Data Analysis (EDA) on Cleaned Layoffs Data

-- View the entire cleaned dataset
SELECT *
FROM layoffs_copy_2;

-- Find the highest number of layoffs by a single record
SELECT MAX(total_laid_off)
FROM layoffs_copy_2;

-- Industries with the most layoffs (only non-null industries)
SELECT industry, MAX(total_laid_off)
FROM layoffs_copy_2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY 2 DESC;

-- Companies that laid off 100% of their employees and had funding info
SELECT company, funds_raised_millions
FROM layoffs_copy_2
WHERE percentage_laid_off = 1 
  AND funds_raised_millions IS NOT NULL
ORDER BY funds_raised_millions DESC;

-- Total layoffs per company
SELECT company, SUM(total_laid_off)
FROM layoffs_copy_2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs per country
SELECT country, SUM(total_laid_off)
FROM layoffs_copy_2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by company stage (e.g., Series A, B, etc.)
SELECT stage, SUM(total_laid_off)
FROM layoffs_copy_2
GROUP BY stage
ORDER BY 2 DESC;

-- Total layoffs by month (using only the month part of the date)
SELECT MONTH(`date`), SUM(total_laid_off)
FROM layoffs_copy_2
GROUP BY MONTH(`date`)
ORDER BY 2 DESC;

-- Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_copy_2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Monthly total layoffs (formatted as YYYY-MM)
SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off)
FROM layoffs_copy_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

-- Monthly layoffs with cumulative (rolling) total
WITH monthly_layoffs AS (
  SELECT SUBSTRING(`date`, 1, 7) AS `Month`, SUM(total_laid_off) AS total_layoffs
  FROM layoffs_copy_2
  WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
  GROUP BY `Month`
)
SELECT `Month`, total_layoffs,
       SUM(total_layoffs) OVER (ORDER BY `Month` ASC) AS rolling_total
FROM monthly_layoffs;

-- Company-wise layoffs per year
SELECT company, SUBSTR(`date`, 1, 4) AS `Year`, SUM(total_laid_off)
FROM layoffs_copy_2
WHERE total_laid_off IS NOT NULL AND SUBSTR(`date`, 1, 4) IS NOT NULL
GROUP BY company, `Year`
ORDER BY 3 DESC;

-- Top 5 companies by layoffs per year using DENSE_RANK
WITH cte AS (
  SELECT company, SUBSTR(`date`, 1, 4) AS `Year`, SUM(total_laid_off) AS total_layoffs
  FROM layoffs_copy_2
  WHERE total_laid_off IS NOT NULL AND SUBSTR(`date`, 1, 4) IS NOT NULL
  GROUP BY company, `Year`
),
company_ranked AS (
  SELECT *, 
         DENSE_RANK() OVER(PARTITION BY `Year` ORDER BY total_layoffs DESC) AS ranking
  FROM cte
)
SELECT *
FROM company_ranked
WHERE ranking <= 5;

-- For each country, find the year with the highest total layoffs
WITH cte_1 AS (
  SELECT country, YEAR(`date`) AS `Year`, SUM(total_laid_off) AS total_layoffs
  FROM layoffs_copy_2
  WHERE total_laid_off IS NOT NULL
  GROUP BY country, `Year`
),
cte_2 AS (
  SELECT *, 
         DENSE_RANK() OVER(PARTITION BY country ORDER BY total_layoffs DESC) AS ranking
  FROM cte_1
)
SELECT country, `Year`, total_layoffs
FROM cte_2
WHERE ranking = 1
ORDER BY total_layoffs DESC;

-- Total funding raised per company per year
SELECT company, YEAR(`date`) AS `Year`, 
       SUM(funds_raised_millions) AS total_raised_per_year
FROM layoffs_copy_2
WHERE funds_raised_millions IS NOT NULL
GROUP BY company, `Year`
ORDER BY total_raised_per_year DESC;
