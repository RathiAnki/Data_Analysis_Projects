**💳 Credit Card Transactions – SQL Case Study**


This case study involves comprehensive SQL analysis on a dataset of credit card transactions, with the aim to derive meaningful insights into consumer behavior, spending patterns, and city/card performance across multiple dimensions. Below are the key business questions addressed and the respective SQL solutions implemented.

**Business Questions & Solutions**

**1. write a query to print top 5 cities with highest spends and their percentage contribution of total credit card spends **

with city_exp as (

Select city, sum(amount) as city_spend 
from credit_card_transcations
group by city)

, total_spend as(

Select sum(cast(amount as bigint)) as total_spend from credit_card_transcations)

Select top 5  city, city_spend,round(c.city_spend*1.0/t.total_spend*100,2) as percentage_contribution
from city_exp c	
join total_spend t
on 1=1
order by percentage_contribution desc


![Top_5_cities](https://github.com/user-attachments/assets/8df0cdd5-35e1-4631-a821-0f75dcb05260)



**2. write a query to print highest spend month and amount spent in that month for each card type.**

**-- sub_query**

select card_type, mo, total_spend from (

Select card_type, mo, total_spend,rank()over(partition by card_type order by total_spend desc) rn from 
(Select  card_type,Datename(month,transaction_date)  as mo,sum(amount)  as total_spend
from credit_card_transcations
group by card_type,Datename(month,transaction_date)  ) a) b
where rn =1;


**-- CTE**

with monthly_spend as(

Select  card_type,month(transaction_date) as mo,sum(amount)  as total_spend
from credit_card_transcations
group by card_type,month(transaction_date))

,  ranked_monthly_spend as (
Select card_type, mo, total_spend,rank()over(partition by card_type order by total_spend desc) rn 
from monthly_spend)

select card_type, mo, total_spend
from ranked_monthly_spend
where rn =1;


![Highest_Spend_Card_Type](https://github.com/user-attachments/assets/f94f14b7-46c3-4b1a-916a-5722ac3991ca)

**3.write a query to print the transaction details(all columns from the table) for each card type 
when it reaches a cumulative of 1000000 total spends(We should have 4 rows in the o/p one for each card type)**

with cte as(

select *,
sum(amount) over(partition by card_type order by transaction_date,transaction_id )as running_sum
from credit_card_transcations)
, flagged as(
Select *, rank() over(partition by card_type order by running_sum) as rn
from cte
where running_sum>= 1000000)

select transaction_id,city,transaction_date,card_type,exp_type,gender,amount,running_sum from flagged
where rn =1

![Cumulative_Sum](https://github.com/user-attachments/assets/e2a15051-9389-4882-9ce8-d56c17760314)


**4. write a query to find city which had lowest percentage spend for gold card type**

with city_wise as(

Select city, sum(amount) as gold_citywise_spend
from credit_card_transcations
where card_type='Gold'
group by city)

, total_spend as(

Select city, sum(amount) as total_citywise_amount
from credit_card_transcations
group by city)

Select top 1 city from (

Select c.city,c.gold_citywise_spend,t.total_citywise_amount,
c.gold_citywise_spend*100.0/t.total_citywise_amount as percent_contri
from city_wise c
join total_spend t
on c.city =t.city
) a 
order by percent_contri


![City_lowest_on gold](https://github.com/user-attachments/assets/707d6f17-5f4b-466e-a147-b9fc6a5a4877)



**5.write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)**

with expense_by_type as(

Select city, exp_type, sum(amount) as total_amount
from credit_card_transcations
group by city, exp_type)

,ranked_exp as(

Select  city, exp_type,
rank() over(partition by city order by total_amount desc) as max_rank,
rank() over(partition by city order by total_amount ) as min_rank
from expense_by_type
)

, highest_exp as (

Select city, exp_type as highest_expense_type from ranked_exp
			where max_rank =1)

, lowest_exp as (

select city, exp_type as lowest_expense_type from ranked_exp
			where min_rank =1)

Select h.city, h.highest_expense_type,l.lowest_expense_type
	 from 
	highest_exp h
	join lowest_exp l
	on h.city =l.city


 ![city_highest_lowest(986 rows)](https://github.com/user-attachments/assets/6e9b3ce3-164a-4078-864b-a8086554238d)


**6. write a query to find percentage contribution of spends by females for each expense type**

Select exp_type,
round(sum(case when gender ='F' then amount end )*1.0/ sum(amount)*100.0 ,2)as percentage_female_contri
from credit_card_transcations
group by exp_type
order by percentage_female_contri desc\


![Female_expense](https://github.com/user-attachments/assets/0419e27b-c19d-43db-a2cc-9704f710aa6d)


**7. which card and expense type combination saw highest month over month growth in Jan-2014**
with card_exp_type as(

Select card_type, exp_type, format(transaction_date, 'yyyy-MM')as yr_mo, sum(amount) as total_spend
from credit_card_transcations
group by card_type, exp_type, format(transaction_date, 'yyyy-MM'))

Select  top 1 *,(total_spend-prev_month_amount) as Mom_growth from (
Select *,
lag(total_spend,1,0) over(partition by  card_type, exp_type order by yr_mo) as prev_month_amount
from card_exp_type) a
where yr_mo = '2014-01'
order by Mom_growth desc

![card_exp_type_combo](https://github.com/user-attachments/assets/977f4772-7d45-442b-82b9-bd7268202dd8)




**8. during weekends which city has highest total spend to total no of transcations ratio **


with weekend_spend as(

Select city, sum(amount) as total_spend,count(1)as total_no_transactions
from credit_card_transcations
where DATENAME(WEEKDAY, transaction_date) in('Saturday','Sunday')
group by city
)

Select  top 1 city  ,round((w.total_spend*1.0/total_no_transactions),2)as ratio
from weekend_spend w
order by ratio desc 


![Weekend_highest_spend](https://github.com/user-attachments/assets/dc130336-d8ba-4b4f-b813-7e7c8ece387b)

**9. which city took least number of days to reach its 500th transaction after the first transaction in that city**


with rank_date as(
select city ,transaction_date,
row_number() over(partition  by city order by transaction_date) as rn
from credit_card_transcations)

Select top 1 city, DATEDIFF(day, min(transaction_date),max(transaction_date)) as date_diff
from rank_date
where rn = 1 or rn =500
group by city
having count(1)=2
order by date_diff

![Least_day_to_reach_500trans](https://github.com/user-attachments/assets/1f97541c-793d-426f-a98f-adb41aac6184)



