use sakila;

  
#### The 1st query to use in my jupyter notebook ####  
#drop view predict_rentals;
#create view predict_rentals as
with cte_predict_rentals as (
    select f.film_id, f.title, f.length, f.rating, c.category_id, count(r.rental_id) as num_rentals from film f
    left join film_category c
    using (film_id)
    join inventory i
    using (film_id)
    join rental r
    using (inventory_id)
    group by f.film_id, f.title, f.length, f.rating, c.category_id)
select p.*, date(r.rental_date) as rental_date from cte_predict_rentals p
right join inventory i
using (film_id)
join rental r
using (inventory_id);

# without rental_date
with cte_predict_rentals as (
    select f.film_id, f.title, f.length, f.rating, c.category_id, count(r.rental_id) as num_rentals from film f
    left join film_category c
    using (film_id)
    join inventory i
    using (film_id)
    join rental r
    using (inventory_id)
    group by f.film_id, f.title, f.length, f.rating, c.category_id)
select * from cte_predict_rentals
order by num_rentals desc;


#### Creating new feature rented_last_month with boolean values ####
alter table rental 
add rented_last_month int;

update rental
set rented_last_month = (case
							when month(rental_date) > 01 and year(rental_date) = 2006
								then 1
							else 0
						 end);
                            
select rented_last_month from rental;
#where rented_last_month = 1;


#### Adding columns for all the months that the films have been rented to feed the model more substantial data
select distinct month(rental_date) from rental
order by month(rental_date) asc; # 2, 5, 6, 7, 8

alter table rental
add (rented_feb int, rented_may int, rented_june int,  rented_july int, rented_aug int);

update rental
set rented_feb = (case
						when month(rental_date) = 02
							then 1
						else 0
					end);
                    
update rental
set rented_may = (case
						when month(rental_date) = 05
							then 1
						else 0
					end);
                    
update rental
set rented_june = (case
						when month(rental_date) = 06
							then 1
						else 0
					end);

update rental
set rented_july = (case
						when month(rental_date) = 07
							then 1
						else 0
					end);

update rental
set rented_aug = (case
						when month(rental_date) = 08
							then 1
						else 0
					end);
                    
#### and now to create a query that accesses the cummulative data from all the months
select f.film_id,
f.title,
f.rating,
c.category_id,
sum(r.rented_last_month) as last_month,
sum(r.rented_feb) as february,
sum(r.rented_may) as may,
sum(r.rented_june) as june,
sum(r.rented_july) as july,
sum(r.rented_aug) as august,
count(r.rental_id) as num_rentals
from film f
	join film_category c
		using (film_id)
	join inventory i
		using (film_id)
	join rental r
		using (inventory_id)
group by
f.film_id,
f.title,
f.rating,
c.category_id
order by film_id asc;            