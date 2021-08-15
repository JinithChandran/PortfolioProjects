 /*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


SELECT *
FROM dbo.CovidDeaths 
Where continent is not null
Order by 3,4


-- Select Data that we are going to be using

SELECT Location, Date, Total_cases, new_cases, total_deaths, population
FROM CovidDeaths
Order By 1,2

-- Total Cases vs Total Deaths
-- Displays likelihood of dying if you contract Covid-19 in Canada

SELECT Location, Date, Total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE Location = 'Canada'
AND continent is not null
Order By 1,2 

-- Total Cases vs Population
-- Displays what percentage of population got Covid-19

SELECT Location, Date, Population, Total_cases, (total_cases/Population)*100 as ConfirmedCasesPercentage
FROM CovidDeaths
WHERE Location = 'Canada'
Order By 1,2 

-- Countries with Highest Infection rate in relation to Population

SELECT Location, Population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as ConfrimedCasesPercentage
FROM CovidDeaths
--WHERE Location = 'Canada'
Group By location, population
Order By ConfrimedCasesPercentage desc


-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Canada'
Where continent is not null
Group By location
Order By TotalDeathCount desc


--  CATEGORIZING BY CONTINENT

-- Continents with the highest death count per population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE Location = 'Canada'
Where continent is not null
Group By continent
Order By TotalDeathCount desc



-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE Location = 'Canada'
WHERE continent is not null
--Group By date
Order By 1,2 


-- Total Population vs Vaccinations
-- Displays Percentage of Population that has received at least one vaccine


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order By 2 ,3


-- Using CTE to perform Calucaltion of Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--Order By 2 ,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac



-- Using Temp Table to perform Calucaltion of Partition By in previous query


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--Order By 2 ,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for future visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

