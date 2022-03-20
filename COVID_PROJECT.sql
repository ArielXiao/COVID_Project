-- COVID Data Exploration
--Death Table Exploration
SELECT
 *
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 continent IS NOT NULL
ORDER BY
 3,
 4
 
 
--Vaccination Table Exploration
SELECT
 *
FROM
 `brave-watch-343605.COVID_data.Vaccinations`
WHERE
 continent IS NOT NULL
ORDER BY
 3,
 4
 
 
--Select specific data to start with
SELECT
 location,
 date,
 total_cases,
 new_cases,
 total_deaths,
 new_deaths,
 population
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 continent IS NULL
ORDER BY
 1,
 2
 
 
--Select the likelihood to death if got COVID in each country, eg. The US
--Total Deaths / Total Cases
SELECT
 location,
 date,
 total_cases,
 total_deaths,
 (total_deaths/total_cases)*100 AS DeathPercentage
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 location LIKE '%States%'
 AND continent IS NOT NULL
ORDER BY
 1,
 2
 
 
--Select the percentage of poeple infected to COVID in each country, eg. The US
--Total Cases / Population
SELECT
 location,
 date,
 population,
 total_cases,
 (total_cases/population)*100 AS PercentPopulationInfected
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 location LIKE '%States%'
 AND continent IS NOT NULL
ORDER BY
 1,
 2
 
 
--Select the highest infection rate compared to population of each country
SELECT
 location,
 population,
 MAX(total_cases) AS HighestInfectionCount,
 MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM
 `brave-watch-343605.COVID_data.Death`
GROUP BY
 location,
 population
ORDER BY
 PercentPopulationInfected DESC
 
 
--Select the highest death count per population of each country
SELECT
 location,
 population,
 MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM
 `brave-watch-343605.COVID_data.Death`
GROUP BY
 location,
 population
ORDER BY
 TotalDeathCount DESC
 
 
--BREAKING DOWN TO CONTINENT
--Select the highest death count per population of each continent
SELECT
 continent,
 MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 continent IS NOT NULL
GROUP BY
 continent
ORDER BY
 TotalDeathCount
 
 
--GLOBAL NUMBERS
--Select total cases and deaths and deathrate percentage all over the world
SELECT
 SUM(new_cases) AS TotalCases,
 SUM(new_deaths) AS TotalDeaths,
 (SUM(CAST(new_deaths AS int))/SUM(new_cases))*100 AS Death_Percentage
FROM
 `brave-watch-343605.COVID_data.Death`
WHERE
 continent IS NOT NULL
ORDER BY
 Death_Percentage
 
 
--Show Percentage of Population that has recieved at least one Covid Vaccine
SELECT
 d.continent,
 d.location,
 d.date,
 d.population,
 SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM
 `brave-watch-343605.COVID_data.Death` AS d
JOIN
 `brave-watch-343605.COVID_data.Vaccinations` AS v
ON
 d.location = v.location
 AND d.date = v.date
WHERE
 d.continent IS NOT NULL
ORDER BY
 2,
 3
 
 
	--Using CTE
WITH
 PopvsVac AS(
 SELECT
   d.continent,
   d.location,
   d.date,
   d.population,
   SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
 FROM
   `brave-watch-343605.COVID_data.Death` AS d
 JOIN
   `brave-watch-343605.COVID_data.Vaccinations` AS v
 ON
   d.location = v.location
   AND d.date = v.date
 WHERE
   d.continent IS NOT NULL
 ORDER BY
   2,
   3 )
SELECT
 *,
 (RollingPeopleVaccinated/population)*100 AS VAC_PERCENTAGE
FROM
 PopvsVac
 
 
--Using TEMP TABLE to perform windown function in previous query
CREATE TABLE
 COVID_data.PercentPopulationVaccinated AS
SELECT
 dea.continent,
 dea.location,
 dea.date,
 dea.population,
 vac.new_vaccinations,
 SUM(vac.new_vaccinations) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
 `brave-watch-343605.COVID_data.Death` dea
JOIN
 `brave-watch-343605.COVID_data.Vaccinations` vac
ON
 dea.location = vac.location
 AND dea.date = vac.date
 --where dea.continent is not null
 --order by 2,3
SELECT
 *,
 (RollingPeopleVaccinated/Population)*100
FROM
 `brave-watch-343605.COVID_data.PercentPopulationVaccinated`
