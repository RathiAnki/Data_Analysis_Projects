 % ==== Solution: LONGEST QUERY CHALLENGE ====


With Main_cte as(
Select e.*,s.change_date,s.salary,s.promotion,
row_number()over(partition by s.employee_id order by change_date desc) as rn_desc,
row_number()over(partition by s.employee_id order by change_date ) as rn_asc
from employees e
join salary_history s on e.employee_id=s.employee_id)

,latest_salary as(
Select*
from main_cte 
where rn_desc =1)

,promotion_count as(
select employee_id,sum(case when promotion ='Yes' then 1 else 0 end )as no_of_promotions
from main_cte
group by employee_id 
)
,prev_salary_cte as(
Select *,lag(salary)over(partition by employee_id order by change_date )as prev_salary
,lag(change_date)over(partition by employee_id order by change_date )as prev_change_date
from Main_cte)

,max_salary_growth as(
Select employee_id,max( cast((salary-prev_salary)*100.0/prev_salary as decimal(4,2)))as salary_growth
from prev_salary_cte
group by employee_id)

, salary_decreased_cte as(
select distinct*,'N' as 'never_decreased'
from prev_salary_cte
where  salary<prev_salary)

, avg_month_salary_change as(
select employee_id, avg(DATEDIFF(month, prev_change_date,change_date))as avg_month_between_change
from prev_salary_cte
group by employee_id
)

,salary_ratio_cte as(
select employee_id,max(case when rn_desc =1 then salary end) /max(case when rn_asc =1 then salary end)as growth_ratio
from Main_cte
group by employee_id)

,growth_rate_rank as(
Select l.*, rank() over(order by s.growth_ratio desc, l.join_date)as rank_by_growth
from salary_ratio_cte s
join latest_salary l  on s.employee_id=l.employee_id
)

-- Final query
		Select distinct  g.employee_id,g.name,	g.salary as latest_salary,p.no_of_promotions, m.salary_growth,
	Coalesce(s.never_decreased,'Y')as salary_never_decreased,a.avg_month_between_change,g.rank_by_growth
	from growth_rate_rank g
	left join promotion_count p on g.employee_id=p.employee_id
	left join max_salary_growth m on g.employee_id=m.employee_id
	left join salary_decreased_cte s on g.employee_id=s.employee_id
	left join avg_month_salary_change a on g.employee_id=a.employee_id
