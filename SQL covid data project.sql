Select *
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths, population
From PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
where location like '%states%'
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
order by 1,2



--Looking at countries with Highest Infection Rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
Group by location,population
order by PercentPopulationInfected desc



--Showing Countries with Highest Death Count population

select location,MAX(cast(total_deaths as int)) as TotalDeatCount
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--where location like '%states%'
Group by location
order by TotalDeatCount desc

--LETS'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with the highest death count per population

select continent,MAX(cast(total_deaths as int)) as TotalDeatCount
From PortfolioProject.dbo.CovidDeaths
where continent is NOT null
--where location like '%states%'
Group by continent
order by TotalDeatCount desc



--Global Numbers

select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2


--Lokking at total Population Vs Vaccinations

select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
   on dea.location = vac.location  
   and dea.date = vac.date
where dea.continent is not null
 order by 2,3

 --USE CTE

With PopvsVac (continent,location,date,population,New_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
   on dea.location = vac.location  
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
   on dea.location = vac.location  
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3



select*,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated




--creating view to store data for later visulization

Create View Percentpopulationvaccinated as
select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated--(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
   on dea.location = vac.location  
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from Percentpopulationvaccinated