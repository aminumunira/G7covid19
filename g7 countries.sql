--looking at death vs total_cases
SELECT location, date, total_cases, new_cases, total_deaths, population, ROUND((total_deaths/total_cases)*100,2) AS deathpercentage
FROM public.covid_death
WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
order by 1, 2

--looking at total cases vs population
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS casespercentage
FROM public.covid_death
WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
order by 1, 2

-- looking at countries with higher infection rates compared to location
SELECT location, population, MAX(total_cases) As highest_infection_count, ROUND((MAX(total_cases)/population)*100,2) AS population_infected
FROM public.covid_death
WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
GROUP BY 1, 2
order by population_infected DESC

--looking at countries with the highest death count 
SELECT location, population, MAX(total_cases) AS total_cases, MAX(total_deaths) As total_death_count
FROM public.covid_death
WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
GROUP BY 1, 2
order by total_death_count DESC 

-- g7 summary
with top AS (
		SELECT location, population, MAX(total_cases) AS total_cases, MAX(total_deaths) As total_death_count
		FROM public.covid_death
		WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
		GROUP BY 1, 2
		order by total_death_count DESC
)
SELECT SUM(population), SUM(total_cases), SUM(total_death_count), ROUND((SUM(total_death_count)/SUM(total_cases)),2)*100 AS percentagedeath
FROM top

-- joining vaccinations table
SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS cumulative_sum
FROM public.covid_death AS d
JOIN public.vaccinations AS v
ON d.location = v.location
	and d.date = v.date
WHERE d.location ilike '%japan%' or d.location ilike '%canada%' or d.location  ilike '%states%' or d.location  ilike '%germany%' or d.location  ilike '%italy%' or d.location  ilike '%kingdom%' or d.location  ilike '%france%'
ORDER BY 2,3

--Use CTE

with popvsvac AS (
		SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS cumulative_sum
		FROM public.covid_death AS d
		JOIN public.vaccinations AS v
		ON d.location = v.location
			and d.date = v.date
		WHERE d.location ilike '%japan%' or d.location ilike '%canada%' or d.location  ilike '%states%' or d.location  ilike '%germany%' or d.location  ilike '%italy%' or d.location  ilike '%kingdom%' or d.location  ilike '%france%'
		ORDER BY 2,3
)

SELECT *, (cumulative_sum/population)*100 AS percent_vaccinated
FROM popvsvac
WHERE cumulative_sum IS NOT NULL
order by percent_vaccinated desc

-- Temp Table 

DROP TABLE IF EXISTS percent_pop_vac
Create Table percent_pop_vac
(
location varchar(255),
 date date,
 population numeric,
 new_vaccinations numeric, 
 cumulative_sum numeric
)
INSERT INTO percent_pop_vac
(SELECT d.location, d.date, d.population, v.new_vaccinations, SUM(v.new_vaccinations) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS cumulative_sum
		FROM public.covid_death AS d
		JOIN public.vaccinations AS v
		ON d.location = v.location
			and d.date = v.date
		WHERE d.location ilike '%japan%' or d.location ilike '%canada%' or d.location  ilike '%states%' or d.location  ilike '%germany%' or d.location  ilike '%italy%' or d.location  ilike '%kingdom%' or d.location  ilike '%france%'
		

)
SELECT *, (cumulative_sum/population)*100 AS percent_vaccinated
FROM percent_pop_vac

-- create view for later visualizations
CREATE VIEW summary AS
SELECT location, population, MAX(total_cases) AS total_cases, MAX(total_deaths) As total_death_count
FROM public.covid_death
WHERE location ilike '%japan%' or location ilike '%canada%' or location ilike '%states%' or location ilike '%germany%' or location ilike '%italy%' or location ilike '%kingdom%' or location ilike '%france%'
GROUP BY 1, 2

SELECT *
FROM summary
