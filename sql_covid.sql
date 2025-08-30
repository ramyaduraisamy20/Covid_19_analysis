Select * from data_analysis_projects..CovidDeaths
order by 3,4

Select * from data_analysis_projects..CovidVaccinations
order by 3,4

--Percentage of Death (Case Fatality Rate : deaths per total case) 
Select continent, location, date, total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from data_analysis_projects..CovidDeaths
Where continent is not null and  location like '%Kingdom%'
order by DeathPercentage desc

--Calculation Total Cases Percentage 
Select continent, location, date, total_cases, population, (total_cases/population)*100 as Total_Cases_Percentage
from data_analysis_projects..CovidDeaths
Where continent is not null 
order by Total_Cases_Percentage desc

--The maximum reported COVID-19 cases per country
Select location, MAX(total_cases) as total_cases_per_location
from data_analysis_projects..CovidDeaths
Where continent is not null
Group by location
order by total_cases_per_location desc

--Highest recorded COVID-19 cases and deaths by country
Select location, MAX(cast(total_deaths as int)) as total_deaths_per_location, MAX(cast(total_cases as int)) as total_cases_per_location
from data_analysis_projects..CovidDeaths
Where continent is not null
Group by location
order by total_deaths_per_location desc

--Percentage of population infected by country
Select location, population, MAX(total_cases) as Highest_Infection_Rate, MAX((total_cases/population)) * 100 as PercentPopulationInfected
from data_analysis_projects..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Global summary of new COVID-19 cases, deaths, and death rate
Select SUM(new_cases) as total_new_cases , SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) as DeathPercentage
from data_analysis_projects..CovidDeaths
where continent is not null

--Calculate cumulative COVID-19 vaccinations per country over time
Select dea.location , dea.date, dea.population, vacc.new_vaccinations,
SUM(convert(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

From data_analysis_projects..CovidDeaths dea
Join data_analysis_projects..CovidVaccinations vacc
	ON dea.location = vacc.location
	AND dea.date = vacc.date
Where dea.continent is not null
order by 1,2


--Using CTE to calculate total vaccinations and % of population vaccinated per country
WITH PopVsVac As(
	Select dea.location , dea.date, dea.population, vacc.new_vaccinations,
	SUM(convert(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

	From data_analysis_projects..CovidDeaths dea
	Join data_analysis_projects..CovidVaccinations vacc
		ON dea.location = vacc.location
		AND dea.date = vacc.date
	Where dea.continent is not null
	
)
Select *,(RollingPeopleVaccinated/Population)*100 as VaccinePercentage
FROM PopvsVac;


--Using Table to calculate cumulative vaccinations and % population vaccinated per country
DROP Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent,dea.location , dea.date, dea.population, vacc.new_vaccinations,
	SUM(convert(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

	From data_analysis_projects..CovidDeaths dea
	Join data_analysis_projects..CovidVaccinations vacc
		ON dea.location = vacc.location
		AND dea.date = vacc.date
	Where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100 as VaccinePercentage
FROM PercentPopulationVaccinated


--Using View to track rolling vaccinations for each country
Create View Vaccination_Percent as 
Select dea.continent,dea.location , dea.date, dea.population, vacc.new_vaccinations,
	SUM(convert(int, vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

From data_analysis_projects..CovidDeaths dea
Join data_analysis_projects..CovidVaccinations vacc
		ON dea.location = vacc.location
		AND dea.date = vacc.date
Where dea.continent is not null


SELECT * 
FROM Vaccination_Percent;
