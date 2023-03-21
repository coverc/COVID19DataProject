SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Looking At Total Cases Vs. Total Deaths

SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;

--Total Cases Vs Population
--Shows Percentage of Population that contracted COVID

SELECT location, date, population, total_cases, (CAST(total_cases AS float)/CAST(population AS float))*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'United States'
ORDER BY 1,2;

--Countries with highest infection rate

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((CAST(total_cases AS float)/CAST(population AS float)))*100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group BY location, population
ORDER BY 4 DESC;

--Countries with most deaths

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group BY location
ORDER BY TotalDeathCount DESC;

--Continents

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
Group BY location
ORDER BY TotalDeathCount DESC;

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Group BY continent
ORDER BY TotalDeathCount DESC;

--Global

SELECT SUM(CAST(new_cases AS int)) AS totalNewCases, SUM(CAST(new_deaths AS int)) AS totalNewDeaths, (SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float)))*100 AS NewCaseDeathPercentage --total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;


--total population vs vaccinations

SELECT d.continent, d.location, d.date,  d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CurrentPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
INNER JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--GROUP BY d.location
ORDER BY 2,3;

WITH PopulationVsVaccination (continent, location, date, population, NewVaccinations, CurrentPeopleVaccinated) AS
(
SELECT d.continent, d.location, d.date,  d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CurrentPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
INNER JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
--GROUP BY d.location
--ORDER BY 2,3
)
SELECT *, (CurrentPeopleVaccinated/population)*100 AS PercentVaccinated
FROM PopulationVsVaccination;

--TEMP Table
DROP TABLE IF EXISTS #PercentageOfPopulationVaccinated
CREATE TABLE #PercentageOfPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CurrentPeopleVaccinated numeric
)
INSERT INTO #PercentageOfPopulationVaccinated
SELECT d.continent, d.location, d.date,  d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CurrentPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
INNER JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *
FROM #PercentageOfPopulationVaccinated;

--Create View For later Visualization

CREATE View PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date,  d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CurrentPeopleVaccinated
FROM PortfolioProject..CovidDeaths d
INNER JOIN CovidVaccinations v
	ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL;


--Tesiting View
SELECT *
FROM PercentPopulationVaccinated