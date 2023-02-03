SELECT *
FROM CoronaVirusProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM CoronaVirusProject..covidVaccinations
--ORDER BY 3,4

--Select Data that we're going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CoronaVirusProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the probability of dying if you contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CoronaVirusProject..covidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got COVID
SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM CoronaVirusProject..covidDeaths
WHERE location LIKE '%states%'
AND continent IS NOT NULL
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS
	PercentPopulationInfected
FROM CoronaVirusProject..covidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing the Continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CoronaVirusProject..covidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/
SUM(new_cases)*100 AS DeathPercentage
FROM CoronaVirusProject..covidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



--Looking at Total Population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS running_vaccincation_count
FROM CoronaVirusProject..covidDeaths dea
JOIN CoronaVirusProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, running_vaccincation_count)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS running_vaccincation_count
FROM CoronaVirusProject..covidDeaths dea
JOIN CoronaVirusProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (running_vaccincation_count/population)*100
FROM PopvsVac



--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
running_vaccincation_count numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS running_vaccincation_count
FROM CoronaVirusProject..covidDeaths dea
JOIN CoronaVirusProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL

SELECT *, (running_vaccincation_count/population)*100
FROM #PercentPopulationVaccinated




--Creating view to store data for later visualizations
USE CoronaVirusProject
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS running_vaccincation_count
FROM CoronaVirusProject..covidDeaths dea
JOIN CoronaVirusProject..covidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated





/*
Queries used for Tableau Project
*/



-- 1. 

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100
AS DeathPercentage
FROM CoronaVirusProject..covidDeaths
WHERE continent is not null 
ORDER BY 1,2



-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM CoronaVirusProject..covidDeaths
WHERE continent IS NULL 
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income',
'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- 3.

SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CoronaVirusProject..covidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- 4.


SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CoronaVirusProject..covidDeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

