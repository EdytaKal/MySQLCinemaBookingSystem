-- Code for girls project: cinema ticket booking system.
-- ------------------------------------------------------------- CREATE TABELS
CREATE DATABASE IF NOT EXISTS cinemas;
USE cinemas;

-- -----------------------------------------------------MODIFY TABELS AND ADD FOREIGN KEYS
ALTER TABLE bookings
ADD CONSTRAINT pk_bookings 
PRIMARY KEY (booking_id),
MODIFY COLUMN booking_date DATE,
MODIFY COLUMN paid BOOLEAN;

ALTER TABLE customers
ADD CONSTRAINT pk_customer_id
PRIMARY KEY (customer_id),
MODIFY COLUMN customer_name VARCHAR(50),
MODIFY COLUMN customer_surname VARCHAR(50),
MODIFY COLUMN email_address VARCHAR(50),
MODIFY COLUMN street_name VARCHAR(50),
MODIFY COLUMN city VARCHAR(50),
MODIFY COLUMN postcode VARCHAR(20);

ALTER TABLE movies
ADD CONSTRAINT pk_movies
PRIMARY KEY (movie_id),
MODIFY COLUMN movie_title VARCHAR(100),
MODIFY COLUMN genre VARCHAR(10),
MODIFY COLUMN three_D TINYINT,
MODIFY COLUMN sixteen_plus TINYINT,
MODIFY COLUMN director_name VARCHAR(50),
MODIFY COLUMN director_surname VARCHAR(50),
MODIFY COLUMN lead_cast_name VARCHAR(50),
MODIFY COLUMN lead_cast_surname VARCHAR(50);

ALTER TABLE seats
ADD CONSTRAINT pk_seat_id
PRIMARY KEY (seat_id),
MODIFY COLUMN seat_row CHAR,
MODIFY COLUMN available TINYINT;

ALTER TABLE showtime
ADD CONSTRAINT pk_showtime_id
PRIMARY KEY (showtime_id),
MODIFY COLUMN show_date DATE,
MODIFY COLUMN start_time TIME,
MODIFY COLUMN end_time TIME,
MODIFY COLUMN ticket_price DEC(10,2);

ALTER TABLE theatres 
ADD CONSTRAINT pk_theatre_id
PRIMARY KEY (theatre_id),
MODIFY COLUMN street_name VARCHAR(50),
MODIFY COLUMN city VARCHAR(50),
MODIFY COLUMN postcode VARCHAR(20);

ALTER TABLE bookings
ADD CONSTRAINT fk_showtime_id
FOREIGN KEY (showtime_id) REFERENCES showtime(showtime_id),
ADD CONSTRAINT fk_customer_id 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
ADD CONSTRAINT fk_seat_id
FOREIGN KEY (seat_id) REFERENCES seats(seat_id);

ALTER TABLE seats 
ADD CONSTRAINT fk_theatre_id
FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id),
ADD CONSTRAINT fk_showtime_id2
FOREIGN KEY (showtime_id) REFERENCES showtime(showtime_id);

ALTER TABLE showtime
ADD CONSTRAINT fk_theatre_id3
FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id),
ADD CONSTRAINT fk_movie_id2
FOREIGN KEY (movie_id) REFERENCES movies(movie_id);

-- ------------------------------------------------------------------- CREATE VIEWS
-- Create view, which includes booking details as you would find them on your ticket:
-- booking reference, customers name and surname, movie title, date and ticket price.
CREATE VIEW show_bookings
AS 
SELECT b.booking_id AS booking_nb,
	   c.customer_name AS name, c.customer_surname AS surname,
       sh.show_date AS show_date, sh.start_time AS start_time,
       m.movie_title AS title,
       se.seat_row AS row_nb, se.seat_nb AS col,
       sh.ticket_price AS price
FROM customers c
INNER JOIN bookings b
USING(customer_id)
INNER JOIN seats se
USING(seat_id)
INNER JOIN showtime sh
ON se.showtime_id = sh.showtime_id
INNER JOIN movies m
USING(movie_id);
       
SELECT * FROM show_bookings;

-- Create view showing movie details, start time and the cinema address.
CREATE VIEW show_timetable
AS
SELECT s.show_date, s.start_time, s.end_time,
	   m.movie_title, m.genre,
    t.city
FROM showtime s
INNER JOIN movies m
USING(movie_id)
INNER JOIN theatres t
USING(theatre_id)
ORDER BY s.show_date ASC;

SELECT * fROM show_timetable;

-- ---------------------------------------------------- VIEW 3 OR 4 AND USE query to analyse it
--  Analyse what types of movies are shown the most in the cinemas.
SELECT COUNT(genre), genre FROM show_timetable 
GROUP BY genre ORDER BY COUNT(genre);
--  Show movie titles and number of shows for each of that movie from each of the genre.
SELECT COUNT(genre), genre, movie_title FROM show_timetable 
GROUP BY genre, movie_title ORDER BY genre;
-- Show which of the movie is shown the most often.
SELECT COUNT(movie_title), movie_title, genre FROM show_timetable 
GROUP BY movie_title, genre ORDER BY COUNT(movie_title) DESC;

-- --------------------------------------------------- CREATE STORED FUNCTION
-- Create a stored function to show customer if there are any discounts available for them 
-- depending on how much they spent so far.
DELIMITER $$
CREATE FUNCTION discounts(client_id INT)
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	DECLARE granted_discount VARCHAR(50);
    SET @money_spent = (SELECT SUM(sh.ticket_price) FROM showtime sh WHERE sh.showtime_id IN
    (SELECT b.showtime_id FROM bookings b WHERE b.customer_id = client_id));
    
    IF @money_spent BETWEEN 0 AND 29 THEN 
		SET granted_discount = '10% discount if you spent minimum 30 pounds';
        
	ELSEIF @money_spent BETWEEN 30 AND 50 THEN 
		SET granted_discount = '10% discount on your next purchase';
        
	ELSEIF @money_spent >= 50 THEN 
		SET granted_discount = '20% discount on your next purchase';
        
    END IF;
    RETURN granted_discount;
END$$
DELIMITER ;

-- Added extra columns for customer id and total tickets price for better visibility
SELECT 24356 AS 'customer id', discounts(24356) AS 'available discounts:', 
SUM(sh.ticket_price) AS 'paid amount' FROM showtime sh WHERE sh.showtime_id IN
(SELECT b.showtime_id FROM bookings b WHERE b.customer_id = 24356); -- no discount

SELECT 78969 AS 'customer id', discounts(78969) AS 'available discounts:'; -- 10% discount
SELECT 12345 AS 'customer id', discounts(12345) AS 'available discounts:'; -- 20% dicount

SELECT SUM(sh.ticket_price) FROM showtime sh WHERE sh.showtime_id IN
    (SELECT b.showtime_id FROM bookings b WHERE b.customer_id = 24356);

-- Create a stored function to find a movie that is shown on the given date.
DELIMITER $$
CREATE FUNCTION dates_of_movies(movie_name VARCHAR(50))
RETURNS DATE
DETERMINISTIC
BEGIN
	DECLARE dates DATE;
    SET dates := (SELECT show_date FROM showtime WHERE movie_id IN
    (SELECT movie_id FROM movies m WHERE m.movie_title = movie_name) LIMIT 1);
    RETURN dates;
END$$
DELIMITER ;

SELECT dates_of_movies('Flash');

-- To show that the query worked:
SELECT show_date FROM showtime WHERE movie_id IN 
(SELECT m.movie_id FROM movies m WHERE m.movie_title = 'Flash');

-- Create a stored function to find out when a given movie is shown in a cinema.
DELIMITER $$
CREATE FUNCTION what_movies_on_day(show_date DATE)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE movies_on_date VARCHAR(50);
    SET movies_on_date := (SELECT m.movie_title FROM movies m WHERE m.movie_id IN
    (SELECT sh.movie_id FROM showtime sh WHERE sh.show_date = show_date) LIMIT 1);
    RETURN movies_on_date;
END$$
DELIMITER ;

SELECT what_movies_on_day('2023-09-24');
SELECT * FROM showtime;

-- ------------------------------------------------------------------------- SUBQUERIES 
-- Show list of movies to which tickets cost less than 15 pounds and which are shown in Bath.
SELECT m.movie_title AS 'Movie Title', m.genre, m.three_D AS '3D', m.sixteen_plus AS '16+'
FROM movies m WHERE movie_id IN 
(SELECT sh.movie_id FROM showtime sh WHERE (sh.ticket_price < 20 AND sh.theatre_id IN
(SELECT t.theatre_id FROM theatres t WHERE city = 'Glasgow')));

SELECT * FROM showtime;
SELECT * FROM movies;
SELECT* from theatres;

-- Show list of movies which starts after 7 pm and are either animated or thrillers.
SELECT movie_title FROM movies m WHERE (m.movie_id IN 
(SELECT sh.movie_id FROM showtime sh WHERE (start_time < '19:00:00')) AND m.genre IN ('animated', 'thriller'));

-- ---------------------------------------------------- STORED PROCEDURE
-- A stored procedure to reserve a seat for a movie on a specific date.
DELIMITER $$ 
CREATE PROCEDURE book_seat(IN input_date DATE, IN input_movieName VARCHAR(100))
BEGIN
DECLARE available_seat_id INT;
SET available_seat_id = (SELECT se.seat_id FROM seats se WHERE se.showtime_id 
	IN (SELECT sh.showtime_id FROM showtime sh WHERE sh.show_date = input_date AND sh.movie_id 
    IN (SELECT m.movie_id FROM movies m WHERE m.movie_title = input_movieName))
	AND se.available = 1 LIMIT 1);

UPDATE seats 
SET available = 0
WHERE seat_id = available_seat_id;

END $$
DELIMITER ;

SELECT 
se.seat_id, se.available,
sh.movie_id, sh.show_date,
m.movie_id, m.movie_title
FROM seats se
JOIN showtime sh
ON se.showtime_id = sh.showtime_id
JOIN movies m
ON sh.movie_id = m.movie_id;

CALL book_seat('2023-10-01','The Black Swan');

-- ----------------------------------------------------------------------------- TRIGGER
-- A trigger that ensures that updated email address is saved all in lower case letters.
DELIMITER \\
CREATE TRIGGER insert_email_address
BEFORE UPDATE ON customers
FOR EACH ROW
BEGIN
SET NEW.email_address = LOWER(new.email_address);
END \\

DELIMITER ;

UPDATE customers
SET email_address = 'MLEE@GMAIL.COM'
WHERE customer_id = 11111;

-- -------------------------------------------------------------------------- group by, having
-- Group the bookings by customer id and show the ones that have purchased more than 1 tickets.
SELECT customer_id, COUNT(booking_id) FROM bookings GROUP BY customer_id HAVING COUNT(booking_id) > 1;

-- ------------------------------------------------------------------------------------- EVENT
-- Delete shows from the showtime table if the show date has already passed.
SET GLOBAL event_scheduler = ON;
CREATE EVENT remove_past_shows
	ON SCHEDULE EVERY 24 HOUR
	DO DELETE FROM showtime
	WHERE `show_date` < CURRENT_TIMESTAMP - INTERVAL 1 DAY;

SELECT * from SHOWTIME ORDER BY show_date;









    