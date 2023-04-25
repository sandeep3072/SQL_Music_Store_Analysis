
--Q1 who is the senior most employee based on job title.

select * from employee_music
where levels=(select max(levels) from employee_music)

--Q2 Which countries have most invoices?
--Method1
select billing_country,count(billing_country) as count_of_invoices from invoice
group by billing_country
order by count_of_invoices desc
--method2
select billing_country,count(billing_country) as count_of_invoices,rank() over(order by count(billing_country) desc) as rnk from invoice
group by billing_country

---Q3 what are top 3 values of total invoice.

select top 3 round(total,2) as top3 from invoice
order by total desc

--Q4 Which city has best customers? We would like to throw a promotional music festival in the city we made the most money.
--Write a query that returns one city that has highest sum of invoice totals. return both city name & sum of all invoice totals.

select billing_city,round(sum(total),2) as sum_of_invoice_amount from invoice
group by billing_city
order by sum_of_invoice_amount desc

--Q5 who is the best customer? The customer who has spent the most money declared the best customer.
--Write a query that returns who has spent most money.

select * from invoice

select top 1 C.customer_id, C.first_name,C.last_name,round(sum(total),2) as sum_of_invoice 
from customer c inner join invoice i
on c.customer_id=i.customer_id
group by first_name,last_name,C.customer_id
order by sum_of_invoice desc

--Q6 write a query to retrun the email,firstname,last name, and genre of all rock music listeners.
--return  your list  ordered alphabetically by email starting with A

select distinct C.email,c.first_name,c.last_name from 
customer C inner join invoice i
on C.customer_id=i.customer_id
inner join invoice_line il
on il.invoice_id=i.invoice_id
inner join track t
on t.track_id=il.track_id
inner join genre g
on g.genre_id=t.genre_id
where g.name='Rock'
order by c.email asc

--Q7 Let's invite the artists who have written the most rock music in our dataset
--Write a query that retruns the artist name and total track count of the top 10 rock bands.

select top 10 a.artist_id,a.name,count(a.artist_id)as number_of_songs from 
artist a inner join album al
on a.artist_id=al.album_id
inner join track t
on t.album_id=al.album_id
join genre g
on g.genre_id=t.genre_id
where g.name='Rock'
group by a.artist_id,a.name
order by number_of_songs desc

--Q8 Return all the track names that have a song length longer than the average song length.
--Return the name and milliseconds for each track. Order by song length with the longest songs listed first.

select name,milliseconds from track
Where milliseconds > (select AVG(milliseconds) as avg_track_length from track)
order by milliseconds desc

--Q9 Find how much amount spent by each customer on artists? Write a query to return customer name, aritst name
--and total spent

with best_selling_artist as (
select top 1 artist.artist_id as artist_id,artist.name as artist_name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on track.track_id=invoice_line.track_id
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
group by artist.artist_id,artist.name
order by total_sales desc
)

select c.customer_id,c.first_name,c.last_name,bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id=i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by c.customer_id,c.first_name,c.last_name,bsa.artist_name
order by amount_spent desc

--Q10 we want to find out the most popular music genere for each country.
--we determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top genre. For countries where the maximum number of purchases
--is shared return all genres.

with popular_genre as
(
select count(il.quantity) as purchases,C.country,g.name,g.genre_id,
ROW_NUMBER() over (Partition by C.country order by count(il.quantity) desc) as Rn
from customer C
inner join invoice i
on c.customer_id=i.customer_id
inner join invoice_line il
on i.invoice_id=il.invoice_id
inner join track t
on t.track_id=il.track_id
inner join genre g
on t.genre_id=g.genre_id
group by C.country,g.name,g.genre_id
--order by c.country,purchases desc
)

select * from popular_genre where Rn<=1

