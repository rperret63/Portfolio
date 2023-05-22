/*
Covid 19 Exploration des donn�es

Comp�tences utilis�es: Joins, CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From Portfolio..CovidDeaths
Where continent is not null 
order by 3,4


-- S�lection des donn�es de d�part

Select Location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Probabilit�s de d�c�s en cas de contamination

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
Where location like 'fr%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Pourcentage de population infect�e par la Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
order by 1,2


-- Pays avec le plus haut taux d'infection par rapport � la population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Pays avec le plus grand nombre de d�c�s

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- APPROCHE PAR CONTINENT

-- Continents avec le plus grand nombre de d�c�s

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- VISION GLOBALE

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null 
order by 1,2



-- Total Population vs Vaccinations
-- Pourcentage de la population ayant re�u au moins une dose de vaccin

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Utilisation d'un CTE pour effectuer un calcul avec Partition By dans la pr�c�dente requ�te

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Utilisation d'une temp table pour effectuer un calcul avec Partition By dans la pr�c�dente requ�te

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
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Cr�ation d'une View pour stocker les donn�es en vue de cr�er des visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
