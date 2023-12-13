SELECT *
FROM PortfolioProject.dbo.CovidDeaths death
Where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--order by 3,4


-- Select the data that u are going to be using

SELECT Location, date, total_cases, new_cases,total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Israel%'
ORDER BY 1,2


--Looking at total cases vs the population
--shows what precentage of the population got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%Israel%'
and continent is not null
ORDER BY 1,2


-- looking at countries with highest infection rate compared to population

SELECT Location, population,MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PrecentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Israel%'
GROUP BY Location, population
ORDER BY 4 desc



-- showing the countries with highest death count per Population



SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Israel%'
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



--LET'S BREAK THING DOWN BY CONTINENT



SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Israel%'
Where continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc


--showing the continents with highest death count per population


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Israel%'
Where continent is null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(New_deaths as int))/SUM(New_Cases)*100
	as DeathPrecentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%Israel%'
Where continent is not null
GROUP BY date
ORDER BY 1,2



SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingVaccinated
--, (RollingVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingVaccinated
--, (RollingVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
)
SELECT *, (RollingVaccinated/population)*100
FROM PopvsVac



--TEMP TABLE

DROP Table if exists #PrecentPopulationVaccinated
Create Table #PrecentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric,
)

insert into #PrecentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingVaccinated
--, (RollingVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *,(RollingVaccinated/Population)*100 as PrecentPopulationVaccinated

FROM #PrecentPopulationVaccinated
ORDER BY 3 desc



-- Creating View to store data for later visualizations

Create View PrecentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingVaccinated
--, (RollingVaccinated/population)*100 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
From PrecentPopulationVaccinated
