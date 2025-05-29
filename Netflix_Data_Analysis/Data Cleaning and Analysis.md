# Data Cleaning

````sql
select * from netflix_raw ;
````

--handling foreign characters (as there were some movies of Korean or Japnese Language)

     handled it through changing the data type of title from varchar to nvarchar

--remove duplicates 
````sql
select show_id,COUNT(*) 
from netflix_raw
group by show_id 
having COUNT(*)>1

select * from netflix_raw
where concat(upper(title),type)  in (
select concat(upper(title),type) 
from netflix_raw
group by upper(title) ,type
having COUNT(*)>1
)
order by title

with cte as (
select * 
,ROW_NUMBER() over(partition by title , type order by show_id) as rn
from netflix_raw
)
select show_id,type,title,cast(date_added as date) as date_added,release_year
,rating,case when duration is null then rating else duration end as duration,description
into netflix
from cte 
where rn =1

select * from netflix
````

--new table for listed_in,director, country,cast
````sql
-- genre
select show_id , trim(value) as genre
into netflix_genre
from netflix_raw
cross apply string_split(listed_in,',')


select * from netflix_genre
````

````sql
-- director
select show_id , trim(value) as director
into netflix_director
from netflix_raw
cross apply string_split(director,',')


select * from netflix_director
````
````sql
--country
select show_id , trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

select * from netflix_country
````
````sql
-- cast

select show_id , trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')

select * from netflix_cast
````

--data type conversions for date added 

--populate missing values in country,duration columns

       as cross apply doesnt populate null values


````sql
insert into netflix_country
select  show_id,m.country 
from netflix_raw nr
inner join (
select director,country
from  netflix_country c
inner join netflix_director d on c.show_id=d.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null
````

-------------------
# Data Analysis

** 1  for each director count the no of movies and tv shows created by them in separate columns 
for directors who have created tv shows and movies both **

````sql
Select  d.director,
Count(distinct case when n.type ='Movie' then  n.show_id end )as Movie_count,
Count(distinct case when n.type ='Tv Show' then  n.show_id end )as TV_show_count
from netflix_director d
join netflix n
on d.show_id =n.show_id
group by d.director
having count(distinct n.type)>1
````

**--2 which country has highest number of comedy movies **

````sql
Select top 1 c.country ,count(distinct g.show_id)as no_of_movies
from netflix_country c
join netflix_genre g
on c.show_id =g.show_id
join netflix n 
on c.show_id=n.show_id 
where g.genre = 'Comedies' and n.type ='Movie'
group by c.country
order by no_of_movies desc
````

**--3 for each year (as per date added to netflix), which director has maximum number of movies released**
````sql
with total_movie_year_wise as(
Select year(n.date_added)as year_added ,d.director ,count(1) as no_of_movies
from netflix n
join netflix_director d
on n.show_id=d.show_id
where n.type ='Movie'
group by year(n.date_added),d.director
)

,rank_cte as(select * ,
row_number()over(partition by year_added order by no_of_movies desc,director)as rn
from total_movie_year_wise)

select *
from rank_cte
where rn =1
````



**--4 what is average duration of movies in each genre**
````sql
Select g.genre ,avg(cast(replace(n.duration,' min','')as int)) as avg_duration
from netflix n
join netflix_genre g
on n.show_id=g.show_id
where n.type='Movie'
group by genre

````


**--5  find the list of directors who have created horror and comedy movies both.
-- display director names along with number of comedy and horror movies directed by them **
````sql
Select d.director,
count(distinct case when g.genre ='Comedies' then n.show_id end)as comedy_movie,
count(distinct case when g.genre ='Horror Movies' then n.show_id end)as horror_movie
from netflix n
join netflix_director d
on n.show_id =d.show_id
join netflix_genre g
on n.show_id =g.show_id
where g.genre in ('Comedies' , 'Horror Movies')
and n.type ='Movie'
group by d.director
having count(distinct g.genre)=2
````


select distinct genre from netflix_genre

