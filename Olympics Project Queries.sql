DROP TABLE IF EXISTS OLYMPICS_HISTORY;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
(
    id          INT,
    name        VARCHAR,
    sex         VARCHAR,
    age         VARCHAR,
    height      VARCHAR,
    weight      VARCHAR,
    team        VARCHAR,
    noc         VARCHAR,
    games       VARCHAR,
    year        INT,
    season      VARCHAR,
    city        VARCHAR,
    sport       VARCHAR,
    event       VARCHAR,
    medal       VARCHAR
);

DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
(
    noc         VARCHAR,
    region      VARCHAR,
    notes       VARCHAR
);

select * from OLYMPICS_HISTORY;
select * from OLYMPICS_HISTORY_NOC_REGIONS;

List of all these 20 queries mentioned below:

-- 1. How many olympics games have been held?
create materialized view total_games
as
select 
	count(1) as total_olympic_games
from (select 
	 	games
	 from OLYMPICS_HISTORY
	 group by games) as subquery;

select * from total_games


-- 2. List down all Olympics games held so far.
select 
	substring(games, 1, position(' ' in games)) as year, 
	substring(games, position(' ' in games)) as season, 
	city
from OLYMPICS_HISTORY
group by games, city
order by year;



3. Mention the total no of nations who participated in each olympics game?
create materialized view total_no_of_countries_per_season
as
select 
	games, 
	count(1) as total_countries
from
	(select 
		games, 
	 	region
	from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS ohn using(noc)
	group by games,region
	order by games) as no_of_countries
group by games;

select * from total_no_of_countries_per_season


4. Which year saw the highest and lowest no of countries participating in olympics?
      select distinct
      concat(first_value(games) over(order by total_countries)
      , ' - '
      , first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
      concat(first_value(games) over(order by total_countries desc)
      , ' - '
      , first_value(total_countries) over(order by total_countries desc)) as Highest_Countries
      from total_no_of_countries_per_season
      order by 1;
	  
	  

-- 5. Which nation has participated in all of the olympic games?

with countries_in_each_game as (
			select 
				games, 
				region
			from OLYMPICS_HISTORY oh
			join OLYMPICS_HISTORY_NOC_REGIONS ohn using(noc)
			group by games, region
			order by games),
	games_per_country as (
			select 
				region as country, 
				count(1) as no_of_games
			from countries_in_each_game ceg
			group by region)
select 
	gpc.country, 
	gpc.no_of_games as total_participated_games
from games_per_country as gpc
join total_games tg on gpc.no_of_games = tg.total_olympic_games
order by country;



6. Identify the sport which was played in all summer olympics.
with total_summer_games as
		(select 
			count(distinct games) as total_games
		from OLYMPICS_HISTORY
		where season = 'Summer'),
		
		
	sports_in_summer_games as
		(select 
			sport, 
			count(games) as no_of_games
		from
			(select 
				games, 
				sport 
			from OLYMPICS_HISTORY oh
			where season = 'Summer'
			group by games, sport
			order by games) as sub
		group by sport)
		
		
select 
	sport, 
	no_of_games,
	total_games
from sports_in_summer_games ssg
join total_summer_games tsg on total_games = no_of_games;




-- 7. Which Sports were just played only once in the olympics?
with sports_per_games as (
			select 
					games, 
					sport 
				from OLYMPICS_HISTORY oh
				where season = 'Summer'
				group by games, sport
				order by games),
	 no_of_sports as
			(select 
				sport,
				count(sport) over (partition by sport) as no_of_games,
			 	games
			from
				sports_per_games
			)
select *
from no_of_sports
where no_of_games = 1
order by sport;





8. Fetch the total no of sports played in each olympic games.

select 
	games,
	count(1) no_of_sports
from
	(select distinct
		games,
		sport
	from olympics_history
	order by games) as sub
group by games
order by no_of_sports desc, games;







9. Fetch details of the oldest athletes to win a gold medal.
with cte as
		(select 
			name,
			sex,
			case when age = 'NA' then '0'
			else age
			end as age,
			team,
			games,
			city,
			sport,
			event,
			medal
		from olympics_history
		order by age),
		
		
	ranking as
		(SELECT *,
			RANK() OVER (ORDER BY age DESC) AS ranking
		FROM cte
		WHERE medal = 'Gold')
		
select 
	name,
	sex,
	age,
	team,
	games,
	city,
	sport,
	event,
	medal 
from ranking
where ranking = 1;









10. Find the Ratio of male and female athletes participated in all olympic games.
with cte as
	(select
	 	sex,
	 	count(1)
	from olympics_history
	group by sex)

select 
	concat('1',
		   ' : ',
		   round((select count from cte where sex = 'M')::numeric/(select count from cte where sex = 'F'),2)) as ratio






11. Fetch the top 5 athletes who have won the most gold medals.
with cte as
		(select 
			name,
			team,
			count(1) as total_gold_medals
		from olympics_history
		where medal = 'Gold'
		group by name, team),
		
	ranking as
		(select *,
			dense_rank() over (order by total_gold_medals desc) as rank
		from cte)

select 
	name, 
	team,
	total_gold_medals
from ranking
where rank <=5








12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

with cte as
		(select 
			name,
			team,
			count(1) as total_medals
		from olympics_history
		where medal <> 'NA'
		group by name, team),
		
	ranking as
		(select *,
			dense_rank() over (order by total_medals desc) as rank
		from cte)

select 
	name, 
	team,
	total_medals
from ranking
where rank <=5




13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with cte as
		(select 
			region,
			count(1) total_medals
		from olympics_history
		join olympics_history_noc_regions using(noc)
		where medal <> 'NA'
		group by region
		order by total_medals desc),

	ranking as
		(select *,
			dense_rank() over (order by total_medals desc) as rnk
		from cte)

select *
from ranking
where rnk <=5;





14. List down total gold, silver and broze medals won by each country.
with cte as
		(select 
			region,
			medal,
			count(1) total_medals
		from olympics_history
		join olympics_history_noc_regions using(noc)
		where medal <> 'NA'
		group by region, medal
		order by total_medals desc)

SELECT
  region,
  coalesce(MAX(CASE WHEN medal = 'Gold' THEN total_medals END), 0) AS gold,
  coalesce(MAX(CASE WHEN medal = 'Silver' THEN total_medals END), 0) AS silver,
  coalesce(MAX(CASE WHEN medal = 'Bronze' THEN total_medals END), 0) AS bronze
FROM cte
GROUP BY region
order by gold desc, silver desc, bronze desc




					OR
					
					
					
-- Or you can do this query by using cross tab function.
-- To do that you need to intall the teblefunc extension first.
CREATE EXTENSION IF NOT EXISTS tablefunc;


SELECT country,
	coalesce(gold, 0) as gold,
	coalesce(bronze, 0) as bronze,
	coalesce(silver, 0) as silver

FROM crosstab(
   'select 
			region,
			medal,
			count(1) total_medals
		from olympics_history
		join olympics_history_noc_regions using(noc)
		where medal <> ''NA''
		group by region, medal
		order BY region,medal',
	
   'values (''Bronze''), (''Gold''), (''Silver'')') 
    AS result(country text, bronze int, gold int, silver int)
	order by gold desc, silver desc, bronze desc;







15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

CREATE MATERIALIZED VIEW country_medals
as
		SELECT 
			substring(games_country,1, position(' - ' in games_country) - 1) as games,
			substring(games_country, position(' - ' in games_country) +3) as country,
			coalesce(gold, 0) as gold,
			coalesce(bronze, 0) as bronze,
			coalesce(silver, 0) as silver
			
		FROM crosstab(
		   'select 
					concat(games, '' - '', region) as games_country,
					medal,
					count(1) total_medals
				from olympics_history
				join olympics_history_noc_regions using(noc)
				where medal <> ''NA''
				group by games, region, medal
				order BY games, region,medal',

		   'values (''Bronze''), (''Gold''), (''Silver'')') 
			AS result(games_country text, bronze int, gold int, silver int)
			order by games, country;


-- ans
select * from country_medals


-- To refresh the view
refresh materialized view country_medals;










16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
select distinct
	games,
	concat(first_value(country) over (partition by games order by gold desc), ' - ', first_value(gold) over (partition by games order by gold desc)) as max_gold,
	concat(first_value(country) over (partition by games order by silver desc), ' - ', first_value(silver) over (partition by games order by silver desc)) as max_silver,
	concat(first_value(country) over (partition by games order by bronze desc), ' - ', first_value(bronze) over (partition by games order by bronze desc)) as max_bronze
from country_medals
order by games



17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with cte as
		(select *,
			(Gold+Silver+Bronze) as total_medals
		from country_medals)
		
select distinct
	games,
	concat(first_value(country) over (partition by games order by gold desc), ' - ', first_value(gold) over (partition by games order by gold desc)) as max_gold,
	concat(first_value(country) over (partition by games order by silver desc), ' - ', first_value(silver) over (partition by games order by silver desc)) as max_silver,
	concat(first_value(country) over (partition by games order by bronze desc), ' - ', first_value(bronze) over (partition by games order by bronze desc)) as max_bronze,
	concat(first_value(country) over (partition by games order by total_medals desc), ' - ', first_value(total_medals) over (partition by games order by total_medals desc)) as max_medal
from cte
order by games	
		










18. Which countries have never won gold medal but have won silver/bronze medals?
select 
	country,
	coalesce(gold, 0)as gold,
	coalesce(silver, 0) as silver,
	coalesce(bronze, 0) as bronze
from

	crosstab('select 
		region as country,
		medal,
		count(1)
	from olympics_history
		join olympics_history_noc_regions using(noc)
		where medal <> ''NA''
		group by 
			region,
			medal
		order by region,medal',
	'values (''Bronze''), (''Gold''), (''Silver'')')
as result (country varchar(255), bronze bigint, gold bigint, silver bigint)
where gold is null
order by silver desc, bronze desc







19. In which Sport/event, India has won highest medals.
with cte as 
		(select 
			sport, 
			count(1),
			rank() over (order by count(1) desc) rnk
		from olympics_history
		join olympics_history_noc_regions 
			using(noc)
		where region ='India' and medal <> 'NA'
		group by sport)

select 
	sport,
	count as total_medals
from cte
where rnk = 1;









20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
select
	team,
	sport,
	games,
	count(1) as total_medals
from olympics_history
where team = 'India' and sport = 'Hockey' and medal <> 'NA'
group by
	team,
	sport,
	games
order by count(1) desc;
