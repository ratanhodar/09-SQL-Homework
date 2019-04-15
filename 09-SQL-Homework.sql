use sakila;

select * from actor ;
-- 1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, " ", last_name) AS 'Actor Name' FROM sakila.actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name,  last_name FROM sakila.actor where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select first_name,  last_name FROM sakila.actor where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

select last_name,  first_name FROM sakila.actor where last_name like '%Li%' Order by last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country from sakila.country where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
select * from actor;
Alter table actor 
	add column description BLOB(10) after last_name;
-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor 
	drop column description;
-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(*) as count from sakila.actor group by last_name order by count desc; 


-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(*) as count from sakila.actor group by last_name having count > 2; 

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.

select first_name, last_name from sakila.actor where last_name = "Williams" and first_name = "GROUCHO";
update sakila.actor
   set first_name = 'HARPO'
   where last_name = 'Williams' and first_name = 'GROUCHO';
   
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
  
select first_name, last_name from sakila.actor where last_name = "Williams" ;
update sakila.actor
   set first_name = 'GROUCHO'
   where last_name = 'Williams' and first_name = 'HARPO';
   
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
   
   SHOW Create TABLE address;
 
 -- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
  
SELECT first_name, last_name, address
FROM staff
left JOIN address ON staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT  first_name, sum(amount) as "Total Amount" FROM payment 
JOIN staff ON payment.staff_id = staff.staff_id
where payment_date between '2005-08-01 00:00:00' and '2005-09-01 00:00:00'
group by staff.first_name  ;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

select title, count(actor_id) as "Number of Actors" from film_actor
inner join film on film_actor.film_id = film.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select count(inventory.film_id) as "Number of copies Hunchback Impossible"   from inventory
join film on film.film_id = inventory.film_id
where title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:

select customer.first_name, customer.last_name, sum(payment.amount) as "Total Amount Paid" from customer
join payment on customer.customer_id = payment.customer_id
group by customer.last_name, customer.first_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

select title from film where language_id in (
select language_id from language where name = "english") and title like 'k%' or title like 'q%';


-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name, last_name from actor where actor_id in(
select actor_id from film_actor where film_id in(
select film_id from film where title ='Alone Trip'));


-- 7c You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select first_name, last_name, email from customer where address_id in(
select address_id from address where city_id in(
select city_id from city where country_id in(
select country_id  from country where country ='canada')));

select customer.first_name, customer.last_name, customer.email from customer
join address on (address.address_id = customer.address_id)
join city on (address.city_id = city.city_id)
join country on (city.country_id = country.country_id)
where country = 'Canada';

-- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

select title as "Family Films" from film where film_id in(
select film_id from film_category where category_id in(
select category_id from category where name in ('children', 'family', 'animation', 'comedy')));

-- 7e Display the most frequently rented movies in descending order.
select inventory_id from inventory where film_id in(
select film_id from film where film_id = '1');

-- 7f Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(amount) AS "Gross in Dollars"
  FROM payment p
  JOIN rental r
  ON (p.rental_id = r.rental_id)
  JOIN inventory i
  ON (i.inventory_id = r.inventory_id)
  JOIN store s
  ON (s.store_id = i.store_id)
  GROUP BY s.store_id;


-- 7g Write a query to display for each store its store ID, city, and country.


SELECT s.store_id, c.city, co.country
  FROM store s
  JOIN address a
  ON (s.address_id = a.address_id)
  JOIN city c
  ON (c.city_id = a.city_id)
  JOIN country co
  ON (c.country_id = co.country_id);

-- 7h List the top five genres in gross revenue in descending order. 
SELECT ca.name, sum(amount) as "gross"
  FROM category ca
  JOIN film_category fa
  ON (ca.category_id = fa.category_id)
  JOIN inventory i
  ON (i.film_id = fa.film_id)
  JOIN rental r
  ON (r.inventory_id = i.inventory_id)
  JOIN payment p
  ON (p.rental_id = r.rental_id)
  group by ca.name
  order by gross desc
  limit 5;


-- 8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view. 
CREATE VIEW top_five_genres AS
 SELECT ca.name, sum(amount) as "gross"
  FROM category ca
  JOIN film_category fa
  ON (ca.category_id = fa.category_id)
  JOIN inventory i
  ON (i.film_id = fa.film_id)
  JOIN rental r
  ON (r.inventory_id = i.inventory_id)
  JOIN payment p
  ON (p.rental_id = r.rental_id)
  group by ca.name
  order by gross desc
  limit 5;
  
-- 8b How would you display the view that you created in 8a?

select * from top_five_genres;

-- 8c You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view top_five_genres;