SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL:


SELECT location, date, population, total_cases, new_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


--Total Cases Vs Total Detahs 
--likelihood of dying if diagnosed with covid
SELECT location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date;


SELECT location, continent, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM CovidDeaths
WHERE location = 'India'
ORDER BY location, date;


WITH d_per AS (
SELECT location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM CovidDeaths
WHERE location = 'India'
)
SELECT MAX(death_percentage) AS max_death_percentage, MIN(death_percentage) AS min_death_percentage
FROM d_per;
--based on our analysis we can say that death percentage for India lies between 1.11 and 3.6


--Name of countries starting with letter B
SELECT location, date, population, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS death_percentage
FROM CovidDeaths
WHERE location LIKE 'B%'
ORDER BY location, date;


--Total cases Vs Population
--percentage of population that got covid
--per_diag_covid is percentage of population diagnosed with covid
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS per_diag_covid
FROM CovidDeaths
WHERE location = 'India'
ORDER BY location, date;


--Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS max_total_cases, MAX(ROUND((total_cases/population)*100,2)) AS per_diag_covid
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY per_diag_covid DESC;


--Top 5 countries where percentage of population diagnosed with covid is high
SELECT TOP 5 location, population, MAX(total_cases) AS max_total_cases, MAX(ROUND((total_cases/population)*100,2)) AS per_diag_covid
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY per_diag_covid DESC;


--Top 10 countries with large populations (population > 30000000)  where percentage of population diagnosed with covid is high
SELECT TOP 10 location, population, MAX(total_cases) AS max_total_cases, MAX(ROUND((total_cases/population)*100,2)) AS per_diag_covid
FROM CovidDeaths
WHERE population > 30000000 AND continent IS NOT NULL
GROUP BY location, population
ORDER BY per_diag_covid DESC;

--Countries with Highest death count
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Death count of countries with large populations (population > 30000000)
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE population > 30000000 AND continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Analysing data by continents
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--Global numbers 
--Analysis by each day

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) AS death_percentage 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date;

--Global analysis
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100,2) AS death_percentage 
FROM CovidDeaths
WHERE continent IS NOT NULL;


--Joining CovidDeaths and CovidVaccinations
--Total population Vs Vaccination
--Vaccinated_Cum_Sum - cumulative sum of new vaccinations

WITH pop_vs_vacc (continent,location,date,population,new_vaccinations,vaccinated_cum_sum)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_cum_sum
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, ROUND((vaccinated_cum_sum/population)*100,2) AS per_pop_vacc
--per_pop_vacc is percentage of population vaccinated
FROM pop_vs_vacc;


--Creating a Temp table

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated_cum_sum numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_cum_sum
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date;


SELECT *, ROUND((vaccinated_cum_sum/population)*100,2) AS per_pop_vacc
FROM #PercentPopulationVaccinated;


--Creating a view to store data

CREATE VIEW PercentPopulationVaccinated AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS vaccinated_cum_sum
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
);

SELECT *, ROUND((vaccinated_cum_sum/population)*100,2) AS per_pop_vacc
FROM PercentPopulationVaccinated;


-- VIEW for Analysing data by continents
CREATE VIEW data_by_continents AS
(
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
);

SELECT * FROM data_by_continents;

