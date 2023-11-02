Select * from CovidprotfolioProject..CovidDeaths 
where continent is not null
order by 3,4
--Select * from CovidprotfolioProject..CovidVaccinations 
--order by 3,4

--select data we are going to use 
select location,date,total_cases,new_cases,total_deaths,population
from CovidprotfolioProject..CovidDeaths 
where continent is not null
order by 1,2

--looking at the total cases vs total deaths
--shows likelihood of dying if you contact covid 
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidprotfolioProject..CovidDeaths 
where location like '%india%'
order by 1,2

--looking at the totoal cases vs population
select location,date,total_cases,total_deaths,population,(total_cases/population)*100 as percentPopulation
from CovidprotfolioProject..CovidDeaths 
where continent is not null
--where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,Max(total_cases) as HighestInfectionRate,MAX((total_cases/population))*100 as percentPopulationInfected
from CovidprotfolioProject..CovidDeaths
where continent is not null
--where location like '%states%'
group by location,population
order by percentPopulationInfected desc





--showing the countries with highest death rate per population
select location,Max(cast(total_deaths as int))as TotalDeathCount
from CovidprotfolioProject..CovidDeaths 
where continent is not null
--where location like '%india%'
group by location
order by TotalDeathCount desc

--LET'S break it down by continent
--showing continent with highest death count 
select continent , Max(cast(total_deaths as int))as TotalDeathCount
from CovidprotfolioProject..CovidDeaths 
--where location like '%india%'
where continent is  not null
group by continent 
order by TotalDeathCount desc

--breaking global numbers 
select SUM(new_cases) as totalcases,SUM(cast(new_deaths as int)) as totaldeaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from CovidprotfolioProject..CovidDeaths 
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from CovidprotfolioProject..CovidDeaths dea
join CovidprotfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte
with PopVsVac(continent,location ,date ,population,new_vaccinations,rollingpeoplevaccinated) 
as (
select  dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from CovidprotfolioProject..CovidDeaths dea
join CovidprotfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100 from PopVsVac


--temp table 
drop table if exists  #percentpopulationvaccinated 
create table #percentpopulationvaccinated 
( continent nvarchar(255),location nvarchar(255),date datetime,population numeric,new_vaccinations numeric,rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from CovidprotfolioProject..CovidDeaths dea
join CovidprotfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
select *,(rollingpeoplevaccinated/population)*100 from #percentpopulationvaccinated

--creating view to store data for later visualization 
create view percentpopulationvaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) as rollingpeoplevaccinated
--(rollingpeoplevaccinated/population)*100
from CovidprotfolioProject..CovidDeaths dea
join CovidprotfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null


select * from percentpopulationvaccinated