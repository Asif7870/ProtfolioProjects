create database Covid;
use covid;
select * from covid_deaths;
select * from covid_vacc;
select * from covid_deaths 
order by 3,4;

select location,date,total_cases,
new_cases,total_deaths,population from covid_deaths;

# Q-1 Total Cases/deaths in India ?

select max(total_cases) from covid_deaths where location ="India";
select max(total_deaths) from covid_deaths where location ="India";

# Q-2 Death Percentage of India ?

select location,date,total_cases,total_deaths,
round((total_deaths/total_cases)*100,3)as DeathPercentage from covid_deaths
where location  = "India" order by DeathPercentage desc;

# Q-3 Total Death Percentage of India ?
# Highest - 3.596%

select max(round((total_deaths/total_cases)*100,3))as DeathPercentage 
from covid_deaths
where location  = "India" ;

# Q-4 Total Cases/deaths in world ?
# Highest - Europe & Lowest - Tonga/Thailand Continent - Asia

select continent,location,date,total_cases,total_deaths from covid_deaths 
where continent is not null order by total_cases ;

# Q-5 Highest DeathPercentage in world ?
# Highest - Sudan & Lowest - Tonga/Thailand

select location,date,total_cases,total_deaths,
round((total_deaths/total_cases)*100,3)as DeathPercentage from covid_deaths
 order by DeathPercentage desc;

# Q-6 What % of population got covid in India ?

select location,date,total_cases,total_deaths,population,
 round((total_cases/population)*100,3)as CovidPercentage from covid_deaths
where location like "India" order by CovidPercentage desc;

# Q-7 What max % of population got covid in India ?
# Highest - 1.389 

select max(round((total_cases/population)*100,3))as CovidPercentage

 from covid_deaths where location = "India";

# Q-8 Country wise highest % of population who are effective with covid ?
# Highest - Andorra, Continent - Europe  17.125

select continent,location,max(total_cases),population, 
round(max(((total_cases/population))*100),3)as CovidPercentage from covid_deaths
 group by continent,location,population order by CovidPercentage desc;

# Q-9 Which country got highest % of population who are effective with covid ?

select location, max(total_cases) as HighestInfection from covid_deaths
 group by location order by HighestInfection desc limit 2;

# Q-10 Countrywise highest death % of population who are effective with covid ?

select continent,location,max(total_deaths),population, 
round(max(((total_deaths/population))*100),3)as DeathPercentage from covid_deaths
 group by continent,location,population order by DeathPercentage desc;
 
 # Q-11 Which country got highest death % of population who are effective with covid ?
 
 select location, round(max(((total_deaths/population))*100),3)as DeathPercentage
 from covid_deaths group by location
 order by DeathPercentage desc;
 
  # Q-12 Which country got highest death who are effective with covid ?
  
 select location, max(total_deaths ) as Totaldeath from covid_deaths 
 group by location order by Totaldeath desc ;
 
 # Q-13 Which continent got highest death who are effective with covid ?
 
 select continent,max(total_deaths),population from covid_deaths
 group by continent,population having continent is not null;

# Q-14 what % of medical emergency(bed) is available globally ? ---> very important (assuming '0' of home patients)
# 0.09% which is less than 0.1% 

select round((sum(icu_patients+hosp_patients)/sum(total_cases) *100),3) as medical_emergency 
from covid_deaths ;

# Q-15 what % of medical emergency(bed) is available in United States ? ---> very important (assuming '0' of home patients)
# 0.42% which is less than 0.5% 

select round((sum(icu_patients+hosp_patients)/sum(total_cases) *100),3) as medical_emergency 
from covid_deaths where location = "United States";

select * from covid_vacc
order by 3,4;

# Q-16 Total Population VS Total Vaccination ?

select dea.continent, dea.location,dea.date, dea.population , 
vac.new_vaccinations,sum(vac.new_vaccinations) as vaccinated_population  from covid_deaths dea 
join covid_vacc vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date, dea.population ,dea.total_cases, vac.new_vaccinations
order by vaccinated_population desc ;

# Q-17 Total Population VS Total Smokers?

select dea.continent, dea.location,dea.date,dea.population,dea.total_cases, vac.new_vaccinations,
ceiling(sum(vac.female_smokers + vac.male_smokers)) as Smokers  from covid_deaths dea 
join covid_vacc vac on dea.location = vac.location
and dea.date = vac.date
group by dea.continent,dea.location,dea.date, dea.population ,dea.total_cases, vac.new_vaccinations
order by dea.total_cases desc ;

# Q- 18 What % of population are vaccinated ?
# CTE Solution

with PopvsVacc (continent, location,date, population ,new_vaccinations,vaccinated_population)
as
(
select dea.continent, dea.location,dea.date, dea.population , 
vac.new_vaccinations,sum(vac.new_vaccinations) as vaccinated_population  from covid_deaths dea 
join covid_vacc vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date, dea.population ,dea.total_cases, vac.new_vaccinations
order by vaccinated_population desc 
)
select *,ceiling((vaccinated_population/population*100 )) as vaccinated_per_pop from PopvsVacc;

## Creating view for data store for later visualisation

create view Perc_Pop_vacc as 
with PopvsVacc (continent, location,date, population ,new_vaccinations,vaccinated_population)
as
(
select dea.continent, dea.location,dea.date, dea.population , 
vac.new_vaccinations,sum(vac.new_vaccinations) as vaccinated_population  from covid_deaths dea 
join covid_vacc vac on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
group by dea.continent,dea.location,dea.date, dea.population ,dea.total_cases, vac.new_vaccinations
order by vaccinated_population desc 
)
select *,ceiling((vaccinated_population/population*100 )) as vaccinated_per_pop from PopvsVacc