-- Displaying the all Covid Deaths table content
SELECT *
FROM CovidDeaths
ORDER BY location, date

-- Displaying the all Covid Vaccination table content
SELECT *
FROM CovidVaccinations
ORDER BY location, date

--Filtering Covid Death table to make it easy to analyse
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order By location, date

-- death rate among those who got Covid
SELECT location, date, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Portugal'
Order By location, date

-- percentage of population got Covid
SELECT location, date, total_cases, (total_cases/population)*100 as DeathPercentage
FROM CovidDeaths
WHERE location = 'Spain'
Order By location, date

-- Countries with highest infection rate
SELECT location, population, MAX(total_cases) as TotalCases, MAX((total_cases/population)*100) as PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC --most infected countries first

-- Highest Death Count per Country
SELECT location, population, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population)*100) as PercentPopulationDied
FROM CovidDeaths
WHERE continent is NOT NULL --In order to see only the country information, as the continent information is kept as additionally.
GROUP BY location, population
ORDER BY TotalDeaths DESC  

-- Highest Death Count per Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population)*100) as PercentPopulationDied
FROM CovidDeaths
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY continent DESC  

--Death Rate per day
SELECT date, SUM(new_cases) as NewCases, SUM(cast(new_deaths as int)) as NewDeaths, (SUM(cast(new_deaths as int)) / SUM(new_cases)) * 100 as DeathRate
FROM CovidDeaths
WHERE continent is not NULL
GROUP BY date
HAVING SUM(new_cases) is not null --In order to hide the empty rows
ORDER BY date

--Vaccination rate per country
SELECT dea.continent, dea.location, dea.population, SUM(CAST(vac.people_vaccinated as bigint)) as VaccinatedPopulation
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.iso_code = vac.iso_code AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
GROUP BY dea.continent,dea.population, dea.location
ORDER BY dea.continent, dea.location

--Daily vaccination changes per day by locaion
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as newvacperday --used partition by in order to see daily changes per day
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date --to match identical rows
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Vaccination Rate per day by location
WITH save_newvacperday (Continent, Location, Date, Population, New_Vaccinations, TotalVaccinations)
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as newvacperday --used partition by in order to see daily changes per day
FROM CovidDeaths dea
JOIN CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date --to match identical rows
WHERE dea.continent IS NOT NULL
)
SELECT *, (TotalVaccinations / Population)*100 as VaccinationRatePerDay
FROM save_newvacperday
ORDER BY location, date