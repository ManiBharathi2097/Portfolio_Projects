-- Queries to creste views for tableau dashboarding

use portfolio;

-- 1. Global Numbers
select sum(new_cases) as Total_case, sum(new_deaths) as Total_deaths, 
sum(new_deaths)/sum(new_cases)*100 as Percentage_of_deaths
from coviddeaths
where continent is not null;

-- 2. Death percent by continent
select continent, sum(total_deaths) as Death_count
from coviddeaths
where continent in ('asia', 'europe', 'africa', 'oceania', 'north america', 'south america')
group by continent
order by death_count desc;

-- 3. Death percent by country
select location, population, max(total_cases) as highest_Infectious_Count, 
max((total_cases/population))*100 as  Percent_population_Infected
from coviddeaths
group by location, population
order by Percent_population_Infected desc;

