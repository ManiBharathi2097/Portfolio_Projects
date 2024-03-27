-- Covid 19 Data Exploration 
-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

use portfolio;
set sql_mode = '';

select Location, date, total_cases, new_cases, Total_deaths, Population
from coviddeaths
where continent is not null
order by 1,2;

-- Total cases vs Total deaths
-- Shows what is the death perccentage 
select Location, date, total_cases, Total_deaths,(Total_deaths/total_cases)*100 as Death_Percentage
from coviddeaths
where location = "India"
and continent is not null
order by 1,2;

-- Total cases vs Population
-- Shows what percentage of population got Covid
select Location, population, Max(Total_cases) as Max_Cases, max((total_cases/population))*100 as Highest_percentage
from coviddeaths
where continent is not null
group by Location, population
order by Highest_percentage desc;

-- Countries with highest deaths
select location, max(total_deaths) as Death_Count
from coviddeaths
where continent is not null
group by location
order by Death_Count desc ;

-- Grouping total deaths by continent
select Continent, max(total_deaths) as Death_Count
from coviddeaths
where continent is not null
group by Continent
order by Death_Count desc ;

-- Total cases and deaths
select  sum(new_cases) as Total_cases,
sum(new_deaths) as Total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as Death_percentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2; 

-- Total population vs vaccination by joining both tables
with Pop_vs_Vac (continent, location, date, population, new_vaccinations, Running_Total_Vaccinated)
as
(
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
as Running_Total_Vaccinated
from coviddeaths cd
join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
select *, (Running_Total_Vaccinated/population)*100 as Pop_Vac_Ratio
from Pop_vs_Vac;

-- Create Table 

create table Vaccinated_Percent 
(
continent varchar(50),
Location Varchar(50),
date date,
Population int,
New_Vaccinations int,
Running_Total_Vaccinated float
);
insert into Vaccinated_Percent
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
as Running_Total_Vaccinated
from coviddeaths cd
join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date;
select *, (Running_Total_Vaccinated/population)*100 as Pop_Vac_Ratio
from Vaccinated_Percent;

-- Creating Views to store the data
create view VaccinatedPercent as
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) 
as Running_Total_Vaccinated
from coviddeaths cd
join covidvaccination cv
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null;
select *, (Running_Total_Vaccinated/population)*100 as Pop_Vac_Ratio
from Vaccinated_Percent;

create view Death_Percent_Countrywise as
select Location, population, Max(Total_cases) as Max_Cases, max((total_cases/population))*100 as Highest_percentage
from coviddeaths
where continent is not null
group by Location, population
order by Highest_percentage desc;

create view Death_count_Countrywise as
select location, max(total_deaths) as Death_Count
from coviddeaths
where continent is not null
group by location
order by Death_Count desc ;

create view Death_Count_Continentwise as
select Continent, max(total_deaths) as Death_Count
from coviddeaths
where continent is not null
group by Continent
order by Death_Count desc ;

create view Global_totals as
select  sum(new_cases) as Total_cases,
sum(new_deaths) as Total_deaths,
(sum(new_deaths)/sum(new_cases))*100 as Death_percentage
from coviddeaths
where continent is not null
-- group by date
order by 1,2; 
