select * from PortfolioProject..CovidDeaths
where continent is not NULL
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population from PortfolioProject..CovidDeaths
order by 1,2

-- looking at Total cases vs Total Deaths to know percentage of people dying that got infected.
-- Which shows chances of dying in your country
Select Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like 'Nigeria' and continent is not NULL
order by 1,2  

-- Looking at Total Cases vs Population
Select Location, date, total_cases, Population, (total_cases/ Population)*100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like '%states' and continent is not NULL
order by 1,2

-- Looking at the country with the highest infection rate
select location,max(total_deaths) as Deaths, max(total_cases) as InfectionCount, Population,max((total_cases/ Population)*100) as InfectionRate 
from PortfolioProject..CovidDeaths
group by location,Population
order by InfectionRate DESC

-- Change column type
alter table PortfolioProject..CovidDeaths 
	alter column total_deaths int

-- Showing countries with Highest Death Count per Population
select location,max(total_deaths) as Deaths 
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by Deaths desc

-- Showing continents with highest deaths per population
select continent,max(population) as population,max(total_deaths) as Deaths 
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by Deaths desc

-- GLOBAL NUMBERS
select sum((new_cases)) as cases, sum(cast(new_deaths as int)) as deathToll, sum(cast(new_deaths as int)) / sum((new_cases))*100 as DeathPercentage from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent

select sum(new_cases), sum(cast(new_deaths as int)),sum(cast(new_deaths as int))/sum(new_cases)*100 from PortfolioProject..CovidDeaths
where continent is not null

Select Top 10 * from PortfolioProject..CovidDeaths 
 join PortfolioProject..CovidVaccinations on PortfolioProject..CovidDeaths.iso_code = PortfolioProject..CovidVaccinations.iso_code


-- Looking at Total population vs Total vaccinated

 Select cod.continent, cod.location,cod.date, cod.population, cov.new_vaccinations,
 SUM(cast(cov.new_vaccinations as bigint)) OVER (partition by cod.location order by cod.location,cod.date) RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths cod
 join PortfolioProject..CovidVaccinations cov
 on cod.location = cov.location and cod.date = cov.date
 where cod.continent is not null
order by 2,3 

-- Using CTE 
With PopVsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
as
(
 Select cod.continent, cod.location,cod.date, cod.population, cov.new_vaccinations,
 SUM(cast(cov.new_vaccinations as bigint)) OVER (partition by cod.location order by cod.location,cod.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths cod
 join PortfolioProject..CovidVaccinations cov
 on cod.location = cov.location and cod.date = cov.date
where cod.continent is not null
--order by 2,3 
)

select *, (RollingPeopleVaccinated/population) * 100 from PopVsVac


-- Uding Temp table
Drop table if exists PercentPopulationVaccinated
CREATE table PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
NewVaccinations numeric,
PeopleVaccinated numeric)

insert into PercentPopulationVaccinated
Select cod.continent, cod.location,cod.date, cod.population, cov.new_vaccinations,
 SUM(cast(cov.new_vaccinations as bigint)) OVER (partition by cod.location order by cod.location,cod.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths cod
 join PortfolioProject..CovidVaccinations cov
 on cod.location = cov.location and cod.date = cov.date
where cod.continent is not null
--order by 2,3 

select * from PercentPopulationVaccinated

-- creating view for visualization
drop view PopulationVaccinated

create view PopulationVaccinated as 
 Select cod.continent, cod.location,cod.date, cod.population, cov.new_vaccinations,
 SUM(cast(cov.new_vaccinations as bigint)) OVER (partition by cod.location order by cod.location,cod.date) as RollingPeopleVaccinated
 from PortfolioProject..CovidDeaths cod
 join PortfolioProject..CovidVaccinations cov
 on cod.location = cov.location and cod.date = cov.date
where cod.continent is not null
--order by 2,3 

select * from dbo.PopulationVaccinated

SELECT 
OBJECT_SCHEMA_NAME(o.object_id) schema_name,o.name
FROM
sys.objects as o
WHERE
o.type = 'V';