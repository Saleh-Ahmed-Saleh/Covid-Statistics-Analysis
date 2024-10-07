
-- Percentage of Population got Covid.
Select location, date, total_cases , population ,(total_cases/population) * 100 as PercentPopulationInfected

From [Covid Project]..CovidDeaths

Order by 1,2


-- 1) Global Numbers
Select --date,
Sum(new_cases) as total_cases , SUM(CAST(new_deaths as int )) as total_deaths ,
SUM(CAST(new_deaths as int )) / Sum(new_cases) * 100 as DeathPercentage
From [Covid Project]..CovidDeaths
Where continent is not null
--Group by date
Order By 1,2

--2) Countries with Highest Infection Rate Comapred To Population.
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
--where location like '%Africa%'
Group by location, Population
Order by PercentPopulationInfected DESC


-- 3) Continent with Total Death Count   
Select location, SUM(CAST(new_deaths as int)) as TotalDeathCount
From [Covid Project]..CovidDeaths
Where continent is null 
AND location not in ('world','European Union','International')
Group by location
Order By TotalDeathCount DESC

--4) Countries & Date with Highest Infection Rate Comapred To Population.
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
From [Covid Project]..CovidDeaths
--where location like '%Africa%'
Group by location, Population,date
Order by PercentPopulationInfected DESC




--Countries with Highest Death Count Per Population 
Select location, MAX(CAST(total_deaths as int)) as TotalDeathCases
From [Covid Project]..CovidDeaths
Where continent is not null
Group by location
Order By TotalDeathCases DESC

--Continent with Highest Death Count Per Population 

Select continent,MAX(try_cast(total_deaths as int)) as TotalDeathsCases
From [Covid Project]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathsCases DESC




--looking at Total Population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations ,
Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated

From [Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
ON  dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent is not null
)

Select * , (RollingPeopleVaccinated/Population) * 100 as prc
From PopvsVac
Order by 2,3

-------------------------------------------------------------------

--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
--RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations 
--,Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
on  dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null
order by 1,2

Select * --, (RollingPeopleVaccinated / population) * 100
From  #PercentPopulationVaccinated

--------------------------------------------------------------

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations
--,Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location , dea.Date) as RollingPeopleVaccinated
From [Covid Project]..CovidDeaths dea
JOIN [Covid Project]..CovidVaccinations vac
on  dea.location = vac.location 
and dea.date = vac.date
WHERE dea.continent is not null

Select * From PercentPopulationVaccinated

 