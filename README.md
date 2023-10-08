# MySQLCinemaBookingSystem
This project aims to create a cinema booking system as part of the Code First Girls project.

Currently, the system allows:
- the users to search for movies of a specific genre or played on a specific date,
- the customers to view details of their bookings
- the cinema owner to inform their customer about available discounts.

The cinema booking project uses 6 tables: theatres, movies, showtime, bookings, customers and seats.
![image](https://github.com/EdytaKal/MySQLCinemaBookingSystem/assets/44825133/d16a7bb3-2d8a-4f98-bdc0-0b78018ec123)

Each contains a primary key and some are referenced in other tables with foreign keys. 

This project showcases the use of:
- views and joins- to combine data from different tables and show details that cinema customer would see on their ticket,
- views with query- to analyse which movie genre is the most often watched and from that genre, which movie is the most popular,
- stored function - to check how much each customer had spent in total and give them an equivalent discount,
- stored procedure- to book a seat for a chosen movie on a specific date,
- event- to remove past shows from the shows table,
- trigger- to ensure that edited customer email is kept in low case to match the already entered data,
- subqueries- to find movies played in the specified city with ticket prices below a specific amount
- group by and having- to see which customers have bought more than 1 ticket and show how many exactly have they got.

This project could be further improved by further finishing of the booking procedure:
- showing to the customer how much they have to pay for a ticket,
- checking that the payment went through- if it wouldn't, the seat they would be reserving would go back to being available,
- confirming the booking.



