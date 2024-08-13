/*Project Phase I */
/* 1. Who is the senior most employee based on job title? */

SELECT last_name, first_name, title, MIN(hire_date) as seniority
FROM sql_project.employee
GROUP BY title;

select distinct title from sql_project.employee;

/* 2. Which countries have the most Invoices? */
SELECT count(invoice_id), billing_country
from sql_project.invoice
group by billing_country;

select distinct billing_country from sql_project.invoice;

/* 3. What are top 3 values of total invoice?  */
SELECT count(invoice_id), billing_country, max(total)
from sql_project.invoice
group by invoice_id
limit 3;

/* 4. Which city has the best customers? We would like to throw a promotional 
Music Festival in the city we made the most money. Write a query that returns one city 
that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */

select billing_city, sum(total) total_spend from sql_project.invoice
group by 1
order by 2 desc
limit 1;

SELECT billing_city, sum(total) as total_spend
FROM sql_project.invoice
GROUP BY billing_city
ORDER BY total_spend DESC
LIMIT 1;


/* 5. Who is the best customer? The customer who has spent 
the most money will be declared the best customer. Write a query 
that returns the person who has spent the most money */

select c.first_name, c.last_name, sum(i.total) as total from sql_project.customer c 
join 
sql_project.invoice i 
on 
c.customer_id = i.customer_id
group by c.first_name, c.last_name
order by total desc
limit 1;

/* Phase 2 */
/* 1. Write query to return the email, first name, last name,
 & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A */ 
 
 select distinct c.first_name, c.last_name, c.email, g.name from sql_project.customer c
 join sql_project.invoice i on 
 c.customer_id = i.customer_id
 join sql_project.invoice_line il on i.invoice_id = il.invoice_id
 join sql_project.track t on il.track_id = t.track_id
 join sql_project.genre g on t.genre_id = g.genre_id
 where g.name = "Rock" and email like "a%"
 order by email asc;
 
/* 2. Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands  */

select a.name, count(t.track_id) m_track from sql_project.artist a join sql_project.album al 
on a.artist_id = al.artist_id
join sql_project.track t on t.album_id = al.album_id
join sql_project.genre g on g.genre_id = t.genre_id
where g.name = "Rock"
group by a.name
order by m_track desc
limit 10;

/* 3. Return all the track names that have a song length longer than 
the average song length. Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first */

select milliseconds, name from sql_project.track
where milliseconds > (select avg(milliseconds) from sql_project.track)
order by 1 desc;

/* Project Phase III */ 
/* 1. Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

select c.first_name, c.last_name, a.name as artist_name, round((i.total),2) total from sql_project.customer c 
join sql_project.invoice i on c.customer_id = i.customer_id
join sql_project.invoice_line il on i.invoice_id = il.invoice_id
join sql_project.track t on il.track_id = t.track_id
join sql_project.album al on t.album_id = al.album_id
join sql_project.artist a on al.artist_id = a.artist_id
group by c.first_name, c.last_name, a.name
order by total desc;



select c.first_name, c.last_name, a.name as artist_name, sum(t.unit_price * il.quantity) total from sql_project.customer c 
join sql_project.invoice i on c.customer_id = i.customer_id
join sql_project.invoice_line il on i.invoice_id = il.invoice_id
join sql_project.track t on il.track_id = t.track_id
join sql_project.album al on t.album_id = al.album_id
join sql_project.artist a on al.artist_id = a.artist_id
group by c.first_name, c.last_name, a.name
order by total desc;




/* 2. We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres */

with CTE as (
 select c.country,  g.name as music_genre, count(invl.quantity) as max_purchases,
 row_number() over( partition by c.country order by count(invl.quantity) desc) as ranking
 from customer c 
 join invoice inv on inv.customer_id = c.customer_id
 join invoice_line invl on inv.invoice_id = invl.invoice_id
 join track t on t.track_id = invl.track_id
 join genre g on g.genre_id = t.genre_id
 group by c.country,music_genre
 order by max_purchases desc
 )
select * from cte
where ranking = 1

/* 3. Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount */

with cte as  ( 
 select ast.artist_id,ast.name as artist_name,  sum(invl.unit_price * invl.quantity) as total_spent  from invoice_line invl 
join track t on t.track_id = invl.track_id
join album alb on alb.album_id = t.album_id
join artist ast on ast.artist_id = alb.artist_id
group by ast.name,ast.artist_id
order by total_spent desc
limit 1 
)

select c.first_name, c.last_name, artist_name , sum(invl.unit_price * invl.quantity) as total_spent from customer c
join invoice inv on inv.customer_id = c.customer_id
join invoice_line invl on invl.invoice_id = inv.invoice_id
join track t on t.track_id = invl.track_id
join album alb on alb.album_id = t.album_id
join  cte ast on ast.artist_id = alb.artist_id
group by 1,2,3
order by total_spent  desc
