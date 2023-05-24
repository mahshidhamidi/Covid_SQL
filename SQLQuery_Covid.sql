SELECT *
FROM [Portfolio Project]..CovidDeath
WHERE continent IS NOT NULL

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1,2


--total cases vs total deaths
--likelihood of dying if you contract covid
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeath
WHERE location LIKE '%Finland%'
AND continent IS NOT NULL
ORDER BY 1,2




--countries with highest infection 
SELECT location, population,MAX (total_cases) As HighestInfectionCount, MAX(CAST((total_cases/population) AS float)*100) AS PercentPopulationInfected
FROM [Portfolio Project]..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS int )) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--break things down by continent


--continents with the highest death count
SELECT continent, MAX(CAST(total_deaths AS float )) AS TotalDeathCount
FROM [Portfolio Project]..CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--global numbers
SELECT  SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS float)) AS total_deaths , SUM(CAST(new_deaths AS float ))/SUM(new_cases)*100 AS DeathPercentage
--,(total_deaths/total_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeath 
--WHERE location LIKE '%Finland%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

--total population vs vaccination
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float, vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeath dea
JOIN [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

--CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float, vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeath dea
JOIN [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac



--temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float, vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeath dea
JOIN [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating view for visualizations

CREATE VIEW PercentPopulationVaccinated AS 

SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (CONVERT(float, vac.new_vaccinations)) OVER( PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM [Portfolio Project]..CovidDeath dea
JOIN [Portfolio Project]..CovidVaccination vac
	on dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated