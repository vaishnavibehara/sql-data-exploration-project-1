select*
from ['covid deaths new$']
Where continent is not null 
order by 3,4

select*
from ['covid vaccinations$']
Where continent is not null 
order by 3,4

--- Select Data that we are going to be starting with

select Location,date, total_cases ,new_cases ,total_deaths ,Population
from ['covid deaths new$']
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select Location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from ['covid deaths new$']
where location like '%india%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

select Location,date,Population, total_cases ,(total_cases/Population)*100 as PercentPopulationInfected
from ['covid deaths new$']
where location like '%india%'
order by 1,2

select Location,date,Population, total_cases ,(total_cases/Population)*100 as PercentPopulationInfected
from ['covid deaths new$']
--where location like '%india%'
Where continent is not null 
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select Location,Population, MAX(total_cases) AS highestInfectionCount ,MAX(total_cases/Population)*100 as PercentPopulationInfected
from ['covid deaths new$']
--where location like '%india%'
Where continent is not null 
GROUP by Location,Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
select Location, MAX(cast (total_deaths as int)) AS TotaldeathCount 
from ['covid deaths new$']
--where location like '%india%'
Where continent is not null 
GROUP by Location
order by TotaldeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
select Location, MAX(cast (total_deaths as int)) AS TotaldeathCount 
from ['covid deaths new$']
--where location like '%india%'
Where continent is null 
GROUP by Location 
order by TotaldeathCount desc

-- GLOBAL NUMBERS
select SUM(new_cases) AS TOTALCASES ,SUM(cast(new_deaths as INT)) AS TOTALDEATHS,SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as deathpercentage
from ['covid deaths new$']
--where location like '%india%'
Where continent is NOT null
--GROUP BY date
order by 1,2

SELECT*
FROM ['covid vaccinations$']

--- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT (INT,vac.new_vaccinations)) OVER (partition by dea.location ORDER by dea.location , dea.date)
as rollingpeoplevaccinated
from ['covid deaths new$'] dea
join ['covid vaccinations$'] vac
ON dea.location =vac.location
and dea.date = vac.date
Where dea.continent is not null
--ORDER BY 2,3
)
Select * ,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-
-- Using Temp Table to perform Calculation on Partition By in previous query


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

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid deaths new$'] dea
Join ['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ['covid deaths new$'] dea
Join ['covid vaccinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

