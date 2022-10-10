

select *
from PortfolioProject..CovidDeaths$
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
order by 1,2

--looking at total cases vs total deaths
--shows the % dying in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2

-- total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as CasePercentage
from PortfolioProject..CovidDeaths$
where location like '%india%'
order by 1,2

--highest infection count compared to population
select location, population, max(total_cases) as HighestInfectionRate,max((total_cases/population))*100 as PrecentPopulationInfected 
from PortfolioProject..CovidDeaths$
group by location, population
order by PrecentPopulationInfected desc

--shows heighest death count of population
select location , MAX(cast(total_deaths as int)) as TotalDeathCounts
from PortfolioProject..CovidDeaths$
group by location 
order by TotalDeathCounts desc

--except continent
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--break by continent and continent with heighest rate 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount desc

--global numbers
select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by date
order by 1,2

select sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths$ 
where continent is not null
--group by date
order by 1,2

------------------------------------------------------------------------------------------------------------------------------------------------------

select *
from PortfolioProject..CovidVaccinations$

select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated 
--, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use CTE

with popvsvac (continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated 
--, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,  (Rollingpeoplevaccinated/population)*100
from popvsvac



--temp table
Drop table if exists #presentpopulationvaccinated
create Table #presentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #presentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated 
--, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,  (Rollingpeoplevaccinated/population)*100
from #presentpopulationvaccinated



--creating view to store data for data visualization

--Drop view if exists presentpopulationvaccinated

Create View percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,  sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
order by dea.location, dea.date) as Rollingpeoplevaccinated 
--, (Rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated