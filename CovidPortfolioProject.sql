--select *
--FROM PortfolioProject..CovidVaccinations

SELEct * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

/*
Cahange the data Type for Total Cases and Total Deaths
From Varchar(255) to int so we will use it in divission
NOTICE that we convert to Float instead of int becausw we will use it in
Divivsion and when we use int it is get 0 ever.
*/
Alter table PortfolioProject..CovidDeaths
ALTER COLUMN total_deaths float;

Alter table PortfolioProject..CovidDeaths
ALTER COLUMN total_cases float;

-- Looking at Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, population,(total_deaths/total_cases)*100 as "DeathPercentage"
From PortfolioProject..CovidDeaths
where (location Like '%Egypt%' or location like '%States%') and continent is not null
order by 6 desc

-- Looking at Total Cases VS Populatoiuns
-- Shows Persentage of populations got Covid

SELECT Location, date, total_cases, population,
(total_cases/population)*100 as CovidpeoplePer 
From PortfolioProject..CovidDeaths
where location Like '%States%' and continent is not null
order by 1,2

-- Looking at countries with with highest infection rate compared to population

SELECT Location, population, max(total_cases) as HighestInfectionCount,  
MAX((total_cases/population))*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
where continent is not null
-- where location Like '%States%'
Group by location, population
order by PercentPopulationInfected desc

-- Shownig Countries With Highest Death Count Per Population

SELECT Location, max(total_deaths) as HighestDeathCount   
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by HighestDeathCount desc

-- Let's break Things down by continent

SELECT location , max(total_deaths) as HighestDeathCount  
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by HighestDeathCount desc

SELECT continent , max(total_deaths) as HighestDeathCount  
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by HighestDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent , max(total_deaths) as HighestDeathCount  
From PortfolioProject..CovidDeaths
where continent is null
Group by location
order by HighestDeathCount desc

-- Gloabel Numbers

SELECT sum(total_cases) STotalCases, sum(new_deaths) SNewDeaths
, (sum(total_cases)/NULLIF(sum(new_deaths),0))*100 as DeathPersentage
From PortfolioProject..CovidDeaths
where continent is not null --and (new_deaths is not null and total_cases is not null)
--Group by date
order by 1,2
/* 
--, total_deaths, (total_deaths/total_cases)*100 as "DeathPercentage",(total_cases/population)*100 as CovidpeoplePer 
where location Like '%States%' and 
*/

-- CovidVaccinations
Select * 
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date

-- Looking at Total People vs vaccinations
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select *, (RollingPeopleVaccinated/ population)*100 
from PopvsVac


-- Temp Table 
Drop table if exists #PercentPopulationVaccinated  
create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

select *, (RollingPeopleVaccinated/ population)*100 
from #PercentPopulationVaccinated


-- Creating View to store data for later visualization
create view PercentPopulationVaccinated
as Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(convert(bigint, vac.new_vaccinations)) over 
(partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/ population) * 100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
-- order by 2,3


select *
from PercentPopulationVaccinated