SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--SELECT * FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location,date,total_cases,total_deaths,population FROM PortfolioProject..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Looking at Total Cases vs Population

SELECT location,date,population,total_cases, (total_cases/population)*100 AS PercentPopulationInfected FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
order by 1,2

--Lookin at Countries with Highest Infection Rate comparedd to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected FROM PortfolioProject..CovidDeaths
GROUP BY location, Population
order by PercentPopulationInfected desc

--Break Things Down By Continent


--Showing Countries with Highest Death Count per Population
SELECT location,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location 
order by TotalDeathCount desc

--Showing continents with the highest death count per population

SELECT continent,MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc

--Global Numbers
SELECT date,SUM(new_cases) as total_cases,SUM(CAST(new_deaths AS int)) as total_deaths, SUM(
cast(New_deaths as int))/SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
Where continent is not null
GROUP BY date
order by 1,2

With PopvsVac (Continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated) 
as 
(
--Looking at Total Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 From PopvsVac
--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVacinnated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
--WHERE dea.continent is not null

Select *, (RollingPeopleVacinnated/Population)*100 
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location =vac.location
	and dea.date =vac.date
WHERE dea.continent is not null
--order by 2,3

Select * 
From #PercentPopulationVaccinated