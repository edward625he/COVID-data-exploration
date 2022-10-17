-- data exploration for COVIDdeaths
select * from dbo.CovidDeaths
order by 3,4;

--find top 5 and bottom 5 countries with highest total new death in Europe,Asia, North America, South America
drop table if exists temp1;
select a.continent,a.location,sum(new_deaths_per_million)*100 as total_newdeath_10k,avg(new_deaths_per_million)*100 as mean_newdeath_10k,population 
into temp1 from dbo.CovidDeaths as a
where new_deaths_per_million is not null
group by continent,[location],population;

With cte_temp2 as (select b.continent,b.location,b.total_newdeath_10k,b.mean_newdeath_10k,
                    ROW_NUMBER() over(partition by b.continent order by total_newdeath_10k desc) as row_num from temp1 as b)
select * from cte_temp2 
where continent in('Europe','Asia','North America','South America','Africa') and total_newdeath_10k is not NULL and row_num<=5
order by continent;

With cte_temp2 as (select b.continent,b.location,b.total_newdeath_10k,b.mean_newdeath_10k,
                    ROW_NUMBER() over(partition by b.continent order by total_newdeath_10k ) as row_num from temp1 as b)
select * from cte_temp2 
where continent in('Europe','Asia','North America','South America','Africa') and total_newdeath_10k is not NULL AND row_num<=5
order by continent;

-- data exploration for COVIDVaccination
select * from dbo.CovidVaccinations
order by 3,4;

--find top 5 and bottom 5 countries with highest vaccincation per 10k in Europe,Asia, North America, South America
drop table if exists temp2;
select a.continent,a.location,sum(new_vaccinations_smoothed_per_million)*100 as total_newvac_10k,avg(new_vaccinations_smoothed_per_million)*100 as mean_newvac_10k 
into temp2 from dbo.CovidVaccinations as a
where new_vaccinations_smoothed_per_million is not null
group by continent,[location];

drop table if exists top5_vac;
With cte_temp2 as (select b.continent,b.location,b.total_newvac_10k,b.mean_newvac_10k,
                    ROW_NUMBER() over(partition by b.continent order by total_newvac_10k desc) as row_num from temp2 as b)
select * into top5_vac from cte_temp2 
where continent in('Europe','Asia','North America','South America','Africa') and total_newvac_10k is not NULL and row_num<=5
order by continent;

drop table if exists bottom5_vac;
With cte_temp2 as (select b.continent,b.location,b.total_newvac_10k,b.mean_newvac_10k,
                    ROW_NUMBER() over(partition by b.continent order by total_newvac_10k ) as row_num from temp2 as b)
select * into bottom5_vac from cte_temp2 
where continent in('Europe','Asia','North America','South America','Africa') and total_newvac_10k is not NULL AND row_num<=5
order by continent;

-- merge temp1 and temp2 to get vaccination and death information for each country
drop table if exists temp3;
select a.*,b.total_newvac_10k,b.mean_newvac_10k into temp3 FROM
    temp1 as a left join temp2 as b 
    on a.continent=b.continent and a.[location]=b.[location];