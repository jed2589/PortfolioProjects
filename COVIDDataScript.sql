SELECT *
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Albania%'
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE location LIKE '%Albania%'
ORDER BY 3,4

--Select Data that we are going to be using

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CovidDeaths
--ORDER BY 1,2


--Looking at Total Cases VS Total Deaths
--Shows liklihood of dying if you contract covid in your country


SELECT Location, date, total_cases, total_deaths, (CONVERT(int, total_deaths)/NULLIF(CONVERT(int, total_cases),0))*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Total Cases VS Population
--Shows what percentage of population got Covid

SELECT Location, date,  population, total_cases, (CONVERT(float, total_cases)/NULLIF(CONVERT(float, population),0))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(CONVERT(float, total_cases)) AS HighestInfectionCount, MAX(CONVERT(float, total_cases)/NULLIF(CONVERT(float, population),0))*100 AS
PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


--Show Countries with Highest Death Count per Population
--Both of these get the same results. Just different ways of doing it. 

SELECT Location, MAX(CONVERT(float, total_deaths)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE NULLIF(continent, '') IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE NULLIF(continent, '') IS NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC



--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the Highest Death Count per population


SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE NULLIF(continent, '') IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS

SELECT date, SUM(CONVERT(int, new_cases)), SUM(CONVERT(int, new_deaths)), NULLIF(SUM(CONVERT(float, new_deaths)),0)/NULLIF(SUM(CONVERT(float, new_cases)),0)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE NULLIF(continent, '') IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total New Cases and Total New Deaths
SELECT SUM(CONVERT(int, new_cases)), SUM(CONVERT(int, new_deaths)), NULLIF(SUM(CONVERT(float, new_deaths)),0)/NULLIF(SUM(CONVERT(float, new_cases)),0)*100 AS Deathpercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE NULLIF(continent, '') IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date




SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE NULLIF(dea.continent, '') IS NOT NULL
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE NULLIF(dea.continent, '') IS NOT NULL
ORDER BY 2,3


--USE CTE
--Some reason * won't work after SELECT. Causes data to be missing. 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE NULLIF(dea.continent, '') IS NOT NULL
--ORDER BY 2,3
)
SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated)/NULLIF(CONVERT(float, population),0)*100
FROM PopvsVac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
RollingPeopleVaccinated bigint
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE NULLIF(dea.continent, '') IS NOT NULL
--ORDER BY 2,3

SELECT continent, location, date, population, new_vaccinations, RollingPeopleVaccinated, (RollingPeopleVaccinated)/NULLIF(CONVERT(float, population),0)*100
FROM #PercentPopulationVaccinated






--Creating View to store data for later visualizations


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE NULLIF(dea.continent, '') IS NOT NULL
--ORDER BY 2,3



SELECT * 
FROM PercentPopulationVaccinated
