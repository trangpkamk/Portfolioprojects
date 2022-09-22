
Select *
From [Project Tutorials]..CovidDeaths
Where continent is null
Order by 3,4

--Select *
--From [Project Tutorials]..CovidVaccination
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths,population
From [Project Tutorials]..CovidDeaths
Order by 1,2

--Looking at total cases vs total deaths
--Show the likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths,(Total_deaths/total_cases)*100 as DeathPercentage
From [Project Tutorials]..CovidDeaths
Where location like 'united kingdom'
Order by 1,2

--Looking at total cases vs population
--Show what percentage of population got Covid

Select location, date, total_cases, population,(Total_cases/population)*100 as DeathPercentage
From [Project Tutorials]..CovidDeaths
Where location like 'united kingdom'
Order by 1,2

--Looking at Country with Highest Infection Rate compared to Population

Select location, Population, MAX(total_cases) as HighestInfectioninCount, Max(Total_cases/population)*100 as PercentPopulationInfected
From [Project Tutorials]..CovidDeaths
--Where location like 'united kingdom'
Group by Location, Population
Order by PercentPopulationInfected desc

--Showing Country with highest death count compared to population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Project Tutorials]..CovidDeaths
--Where location like 'united kingdom'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break things down by continent
--SHOWING THE CONTINENTS WITH THE HIGHEST DEATH COUNT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Project Tutorials]..CovidDeaths
--Where location like 'united kingdom'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(New_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Project Tutorials]..CovidDeaths
--Where location like 'united kingdom'
Where continent is not null
--group by date
Order by 1,2

-- Looking at Total Population vs Vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project Tutorials]..CovidDeaths dea
Join [Project Tutorials]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM( Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project Tutorials]..CovidDeaths dea
Join [Project Tutorials]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project Tutorials]..CovidDeaths dea
Join [Project Tutorials]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3
Select *,(RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated

-- Creating View to store data for later visualisation



Create View Percent_PopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(cast(vac.new_vaccinations AS bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Project Tutorials]..CovidDeaths dea
Join [Project Tutorials]..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *
From Percent_PopulationVaccinated
