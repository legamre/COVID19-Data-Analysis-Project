SELECT *
FROM COVIDVACCINATIONS
ORDER BY 3,4

SELECT *
FROM COVIDDEATHS
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM COVIDDEATHS
ORDER BY 1, 2

-- Total cases vs. total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM COVIDDEATHS
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Total Death Count for each Continent
SELECT continent, SUM(CAST(new_deaths AS UNSIGNED)) AS TotalDeathCount
FROM CovidDeaths
WHERE location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Highest Infection Count for each Country
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

-- Total cases vs. population
-- Shows what percent of pupulation in the United States got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM COVIDDEATHS
WHERE location LIKE '%states%'
ORDER BY STR_TO_DATE(date, '%d/%m/%Y') ASC;

-- Countries with Highest Infection Rate
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM COVIDDEATHS
HAVING PercentPopulationInfected > 15
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM COVIDDEATHS
HAVING PercentPopulationInfected > 15
ORDER BY PercentPopulationInfected DESC;

-- Global death rate
Select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 as TotalDeathRate
From CovidDeaths

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated,(SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) / dea.population) * 100 AS VaccinationPercentage
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Using CTE to perform Calculation on Partition By in previous query
WITH PopvsVac AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated,
    (SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) / dea.population) * 100 AS VaccinationPercentage
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS VaccinationPercentage
FROM PopvsVac;


    
