SELECT *
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--Order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows the liklihood of death if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where Location = 'United Kingdom'
and continent IS NOT NULL
ORDER BY 1,2


--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopInfected
FROM PortfolioProject..CovidDeaths$
Where Location = 'United Kingdom' and continent IS NOT NULL
ORDER BY 1,2


--Looking at countries with Highest Infection Rate compared to Population

SELECT Location, population, Max(Total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population)*100),2) AS PercentagePopInfected
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Group by Location, population
ORDER BY PercentagePopInfected DESC

--Showing the Countries with the Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Group by Location
ORDER BY TotalDeathCount DESC

--And now by Continent

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
Where continent IS NOT NULL
Group by continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where Location = 'United Kingdom'
Where continent IS NOT NULL
ORDER BY 1,2

--Global Numbers by date

SELECT date, SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where Location = 'United Kingdom'
Where continent IS NOT NULL
Group By date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
Order by 2,3


with PopvsVac (Continent, Location, date, population, New_Vaccinations, RollingPeopleVacc)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3
)

Select *, (RollingPeopleVacc/population)*100
From PopvsVac




--Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVacc numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL
--Order by 2,3


Select *, (RollingPeopleVacc/population)*100 as PercentPopVacc
From #PercentPopulationVaccinated



-- Creating View to store data for later visuals

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacc
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent IS NOT NULL

Select *
From PercentPopulationVaccinated