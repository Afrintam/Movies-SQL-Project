Use mavenmovies;

-- EXPLORATORY DATA ANALYSIS --

-- UNDERSTANDING THE SCHEMA --

SELECT* FROM RENTAL;

SELECT* FROM INVENTORY;

SELECT* FROM CUSTOMER;

-- You need to provide customer firstname, lastname and email id to the marketing team --
SELECT FIRST_NAME, LAST_NAME, EMAIL FROM CUSTOMER;

-- How many movies are with rental rate of $0.99? --
SELECT count(*) AS Cheapeast_rate
 FROM film
 WHERE rental_rate=0.99;
 
 -- We want to see rental rate and how many movies are in each rental category --
 
SELECT RENTAL_RATE,COUNT(*) AS RENTAL_RATES
FROM FILM
group by RENTAL_RATE;

-- Which rating has the most films? --

SELECT RATING, COUNT(*)AS HIGH_RATING FROM FILM GROUP BY RATING ORDER BY HIGH_RATING DESC;

-- Which rating is most prevalant in each store? --

SELECT INV.STORE_ID,F.RATING,COUNT(*) AS NUMBER_OF_COPIES
FROM INVENTORY AS INV LEFT JOIN FILM AS F
ON INV.FILM_ID=F.FILM_ID
GROUP BY INV.STORE_ID,F.RATING
ORDER BY NUMBER_OF_COPIES DESC;

-- List of films by Film Name, Category, Language --

SELECT F.FILM_ID,F.TITLE,C.NAME,L.NAME
FROM FILM AS F LEFT JOIN film_category AS FC
ON F.film_id=FC.film_id LEFT JOIN category AS C
ON FC.category_id=C.category_id LEFT JOIN language AS L
ON L.language_id=F.LANGUAGE_ID;

-- How many times each movie has been rented out?

Select F.TITLE,Count(R.rental_id) AS POPULARITY
from rental AS R LEFT JOIN inventory AS INV
ON R.inventory_id=INV.inventory_id LEFT JOIN FILM AS F
ON INV.film_id=F.FILM_ID
GROUP BY F.TITLE
ORDER BY POPULARITY DESC;

-- REVENUE PER FILM (TOP 10 GROSSERS)

SELECT 
    F.TITLE, SUM(P.AMOUNT) AS REVENUE
FROM
    rental AS R
        LEFT JOIN
    inventory AS INV ON R.inventory_id = INV.inventory_id
        LEFT JOIN
    FILM AS F ON INV.film_id = F.FILM_ID
        LEFT JOIN
    payment AS P ON R.rental_id = P.rental_id
GROUP BY F.title
ORDER BY REVENUE DESC
LIMIT 10;

-- Most Spending Customer so that we can send him/her rewards or debate points

SELECT 
    CU.customer_id, C.*
FROM
    (SELECT 
        customer_id, SUM(AMOUNT) AS SPENDING
    FROM
        PAYMENT
    GROUP BY customer_id
    ORDER BY SPENDING DESC
    LIMIT 1) AS CU
        INNER JOIN
    customer AS C ON CU.CUSTOMER_ID = C.CUSTOMER_ID;

SELECT 
    P.customer_id,
    SUM(AMOUNT) AS SPENDING,
    C.FIRST_NAME,
    C.last_name
FROM
    PAYMENT AS P
        LEFT JOIN
    customer AS C ON C.CUSTOMER_ID = P.CUSTOMER_ID
GROUP BY P.customer_id
ORDER BY SPENDING DESC
LIMIT 1;

-- Which Store has historically brought the most revenue?

SELECT 
    ST.store_id, SUM(P.AMOUNT) AS REVENUE
FROM
    PAYMENT AS P
        LEFT JOIN
    staff AS ST ON P.STAFF_ID = ST.staff_id
GROUP BY ST.store_id
ORDER BY revenue DESC;

-- How many rentals we have for each month

SELECT 
    MONTHNAME(rental_date) AS Month_name,
    EXTRACT(YEAR FROM rental_date) AS Yearr,
    COUNT(rental_id) AS Rentals
FROM
    rental
GROUP BY EXTRACT(YEAR FROM rental_date) , MONTHNAME(rental_date)
ORDER BY Rentals DESC;

-- Reward users who have rented at least 30 times (with details of customers)

SELECT 
    r.customer_id,
    c.first_name,
    c.last_name,
    COUNT(*) AS Number_of_rentals,
    c.email
FROM
    rental AS r
        LEFT JOIN
    customer AS c ON r.customer_id = c.customer_id
GROUP BY customer_id
HAVING Number_of_rentals > 30;

SELECT 
    LOYAL_CUSTOMERS.CUSTOMER_ID,
    C.FIRST_NAME,
    C.LAST_NAME,
    C.EMAIL,
    AD.PHONE
FROM
    (SELECT 
        CUSTOMER_ID, COUNT(RENTAL_ID) AS NUMBER_OF_RENTALS
    FROM
        RENTAL
    GROUP BY CUSTOMER_ID
    HAVING NUMBER_OF_RENTALS >= 30
    ORDER BY CUSTOMER_ID) AS LOYAL_CUSTOMERS
        LEFT JOIN
    CUSTOMER AS C ON LOYAL_CUSTOMERS.CUSTOMER_ID = C.CUSTOMER_ID
        LEFT JOIN
    ADDRESS AS AD ON C.ADDRESS_ID = AD.ADDRESS_ID;

Select*
from customer;

-- Could you pull all payments from our first 100 customers (based on customer ID)
SELECT 
    customer_id, rental_id, amount, payment_date
FROM
    payment
WHERE
    customer_id < 101;

-- Now I’d love to see just payments over $5 for those same customers, since January 1, 2006

SELECT 
    customer_id, rental_id, amount, payment_date
FROM
    payment
WHERE
    customer_id < 101 AND AMOUNT > 5
        AND PAYMENT_DATE > '2006-01-01';

-- We need to understand the special features in our films. Could you pull a list of films which
-- include a Behind the Scenes special feature?

SELECT 
    *
FROM
    film
WHERE
    special_features LIKE '%Behind the Scenes';

-- unique movie ratings and number of movies

SELECT 
    rating, COUNT(film_id) AS Number_of_films
FROM
    film
GROUP BY Rating;

-- Could you please pull a count of titles sliced by rental duration?

SELECT 
    rental_duration, COUNT(film_id) AS Number_of_films
FROM
    Film
GROUP BY rental_duration;

-- RATING, COUNT_MOVIES,LENGTH OF MOVIES AND COMPARE WITH RENTAL DURATION

SELECT 
    rating,
    COUNT(film_id) AS count_movies,
    MIN(length) AS shortest_film_length,
    MAX(length) AS longest_film_length,
    AVG(length) AS average_film_length,
    AVG(rental_duration) AS average_rental_duration
FROM
    film
GROUP BY rating
ORDER BY average_film_length;

-- I’m wondering if we charge more for a rental when the replacement cost is higher.
-- Can you help me pull a count of films, along with the average, min, and max rental rate,
-- grouped by replacement cost?

SELECT 
    replacement_cost,
    COUNT(film_id) AS count_of_films,
    AVG(rental_rate) AS Average_rental_rate,
    MIN(rental_rate) AS Min_rental_rate,
    MAX(rental_rate) AS Max_rental_rate
FROM
    film
GROUP BY replacement_cost
ORDER BY replacement_cost DESC;

-- -- “I’d like to talk to customers that have not rented much from us to understand if there is something
-- we could be doing better. Could you pull a list of customer_ids with less than 15 rentals all-time?”

SELECT 
    CUSTOMER_ID, COUNT(*) AS TOTAL_RENTALS
FROM
    RENTAL
GROUP BY CUSTOMER_ID
HAVING TOTAL_RENTALS < 15;

-- “I’d like to see if our longest films also tend to be our most expensive rentals.
-- Could you pull me a list of all film titles along with their lengths and rental rates, and sort them
-- from longest to shortest?”

SELECT 
    TITLE, LENGTH, RENTAL_RATE
FROM
    FILM
ORDER BY LENGTH DESC
LIMIT 20;

-- CATEGORIZE MOVIES AS PER LENGTH

SELECT 
    TITLE,
    LENGTH,
    CASE
        WHEN LENGTH < 60 THEN 'UNDER 1 HR'
        WHEN LENGTH BETWEEN 60 AND 90 THEN '1 TO 1.5 HRS'
        WHEN LENGTH > 90 THEN 'OVER 1.5 HRS'
        ELSE 'ERROR'
    END AS LENGTH_BUCKET
FROM
    FILM;
    
-- CATEGORIZING MOVIES TO RECOMMEND VARIOUS AGE GROUPS AND DEMOGRAPHIC

SELECT DISTINCT
    TITLE,
    CASE
        WHEN RENTAL_DURATION <= 4 THEN 'RENTAL TOO SHORT'
        WHEN RENTAL_RATE >= 3.99 THEN 'TOO EXPENSIVE'
        WHEN RATING IN ('NC-17' , 'R') THEN 'TOO ADULT'
        WHEN LENGTH NOT BETWEEN 60 AND 90 THEN 'TOO SHORT OR TOO LONG'
        WHEN DESCRIPTION LIKE '%Shark%' THEN 'NO_NO_HAS_SHARKS'
        ELSE 'GREAT_RECOMMENDATION_FOR_CHILDREN'
    END AS FIT_FOR_RECOMMENDATTION
FROM
    FILM;
    
-- “Can you pull for me a list of each film we have in inventory?
-- I would like to see the film’s title, description, and the store_id value
-- associated with each item, and its inventory_id.

SELECT 
    F.title,
    F.description,
    INV.store_id,
    INV.inventory_id,
    F.film_id
FROM
    film AS F
        INNER JOIN
    inventory AS INV ON F.film_id = INV.film_id;
    
-- Actor first_name, last_name and number of movies

select * from film_actor;
select * from actor;

SELECT 
    AC.first_name,
    AC.last_name,
    COUNT(Fa.film_id) AS number_of_movies
FROM
    actor AS AC
        LEFT JOIN
    film_actor AS FA ON AC.actor_id = FA.actor_id
GROUP BY AC.actor_id
ORDER BY number_of_movies DESC;

-- “One of our investors is interested in the films we carry and how many actors are listed for each
-- film title. Can you pull a list of all titles, and figure out how many actors are
-- associated with each title?”

SELECT 
    F.title, COUNT(actor_id) AS nummber_of_actors
FROM
    film AS F
        LEFT JOIN
    film_actor AS FA ON F.film_id = FA.film_id
GROUP BY F.title
ORDER BY number_of_actors DESC;


-- “We will be hosting a meeting with all of our staff and advisors soon. Could you pull one list of all staff
-- and advisor names, and include a column noting whether they are a staff member or advisor? 

SELECT * FROM STAFF;
SELECT * FROM ADVISOR;

(SELECT FIRST_NAME,
		LAST_NAME,
        'ADVISORS' AS DESIGNATION
FROM ADVISOR

UNION

SELECT FIRST_NAME,
		LAST_NAME,
        'STAFF MEMBER' AS DESIGNATION
FROM STAFF);










