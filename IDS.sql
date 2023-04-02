DROP TABLE airplanes        CASCADE CONSTRAINTS;
DROP TABLE airlines         CASCADE CONSTRAINTS; 
DROP TABLE airports         CASCADE CONSTRAINTS;
DROP TABLE seats            CASCADE CONSTRAINTS;   
DROP TABLE seats_for_animal CASCADE CONSTRAINTS;
DROP TABLE flights          CASCADE CONSTRAINTS;
DROP TABLE customers        CASCADE CONSTRAINTS;
DROP TABLE reservations     CASCADE CONSTRAINTS;
DROP TABLE tickets          CASCADE CONSTRAINTS;

CREATE TABLE airlines (
    /* airline_id follows ICAO format */
    airline_id        VARCHAR(3) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(airline_id, '[A-Z]{3}')),
    airline_callsign  VARCHAR(100) NOT NULL,
    residence         VARCHAR(100) NOT NULL
);

CREATE TABLE airplanes(
    /* airplane_id follows ICAO format for aircraft registration numbers(tail number) */
    airplane_id       VARCHAR(7) NOT NULL PRIMARY KEY CHECK(REGEXP_LIKE(airplane_id, '[A-Z0-9]{3,7}')),
    manufacturer      VARCHAR(100),
    model             VARCHAR(100),
    wifi_connection_b CHAR(1) DEFAULT 'N' CHECK (wifi_connection_b IN ('Y','N')),
    airline           VARCHAR(3) CHECK (REGEXP_LIKE(airline, '[A-Z]{3}')),

CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(airline_id)
);   

CREATE TABLE airports (
    /* airport_id follows IATA format */
    airport_id      VARCHAR(3) NOT NULL PRIMARY KEY CHECK (REGEXP_LIKE(airport_id, '[A-Z]{3}')),
    country         VARCHAR(50) NOT NULL
);


CREATE TABLE flights (
    flights_id        NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    departure_time    TIMESTAMP WITH TIME ZONE NOT NULL,
    arrival_time      TIMESTAMP WITH TIME ZONE NOT NULL,
    airplane          VARCHAR(7) CHECK(REGEXP_LIKE(airplane, '[A-Z0-9]{3,7}')),
    airline           VARCHAR(3) CHECK (REGEXP_LIKE(airline, '[A-Z]{3}')),
    origin            VARCHAR(3) CHECK (REGEXP_LIKE(origin, '[A-Z]{3}')),
    destination       VARCHAR(3) CHECK (REGEXP_LIKE(destination, '[A-Z]{3}')),

    CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(airplane_id),
    CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(airline_id),
    CONSTRAINT flight_origin_airport_fk       FOREIGN KEY (origin)      REFERENCES airports(airport_id),
    CONSTRAINT flight_destination_airport_fk  FOREIGN KEY (destination) REFERENCES airports(airport_id)
    /*CONSTRAINT airline_seat_fk FOREIGN KEY (airline, flight) REFERENCES flights(airline, flights_id)
     nie je potreba, aerolinky si mozu "pozicat" lety medzi sebou, irl"*/
);

CREATE TABLE customers (
    customer_id      NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    first_name       VARCHAR(50) NOT NULL,
    last_name        VARCHAR(50) NOT NULL,
    email            VARCHAR(100) NOT NULL CHECK (REGEXP_LIKE(email, '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}')),
    blacklist_b      CHAR(1) DEFAULT 'N' CHECK (blacklist_b IN ('Y','N'))
);

/*payment status se přidal do ERD */
CREATE TABLE reservations (
    reservation_id  NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cost            NUMBER(10,2),
    payment_status  CHAR(1) DEFAULT 'N' CHECK (payment_status IN ('Y','N')), -- true or false
    created_at      TIMESTAMP WITH TIME ZONE NOT NULL,
    owner           NUMBER,

    CONSTRAINT reservation_creator_fk FOREIGN KEY (owner) REFERENCES customers(customer_id)
);


/*cena leteny přidáno do ERD + společnost a čas oddělána z ERD */
CREATE TABLE tickets (
    ticket_id       NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    cost            NUMBER(10,2),
    reservation     NUMBER NOT NULL,

    CONSTRAINT ticket_in_reservation_fk   FOREIGN KEY (reservation) REFERENCES reservations(reservation_id)
);

CREATE TABLE seats (
    seat_id     NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    class       VARCHAR2(1) NOT NULL CHECK(REGEXP_LIKE(class, '[A-Z]')),
    cost        NUMBER(10,2) NOT NULL,
    ticket      NUMBER NOT NULL,
    airline     VARCHAR(3) CHECK (REGEXP_LIKE(airline, '[A-Z]{3}')),   
    flight      NUMBER NOT NULL,
    
    /* uniqe klíč pro generalizaci */
    CONSTRAINT People_AltPK UNIQUE (seat_id, class,ticket,airline,flight),
    CONSTRAINT flight_seat_fk       FOREIGN KEY (flight)      REFERENCES flights(flights_id),
    CONSTRAINT seat_for_ticket_fk FOREIGN KEY (ticket) REFERENCES tickets(ticket_id),
    CONSTRAINT airline_seat_fk FOREIGN KEY (airline) REFERENCES airlines(airline_id)
);

CREATE TABLE seats_for_animal (
    seat_animal_id  NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    ticket          NUMBER NOT NULL,
    cage_size       VARCHAR2(1) NOT NULL CHECK(cage_size IN ('S', 'M', 'L')),
        /* S: SMALL / M: MEDIUM / L: LARGE */
    class       VARCHAR2(1) NOT NULL CHECK(class = 'A'),
    cost        NUMBER(10,2) NOT NULL,
    
    FOREIGN KEY (seat_animal_id) REFERENCES seats(seat_id),
    FOREIGN KEY (ticket) REFERENCES tickets(ticket_id)
);

/*INSERTS*/

/*AIRLINES*/
INSERT ALL
    INTO airlines (airline_id, airline_callsign, residence) VALUES ('DAL', 'Delta', 'United States')
    INTO airlines (airline_id, airline_callsign, residence) VALUES ('BAW', 'British Airways', 'United Kingdom')
    INTO airlines (airline_id, airline_callsign, residence) VALUES ('QFA', 'Qantas', 'Australia')
    INTO airlines (airline_id, airline_callsign, residence) VALUES ('RYR', 'Ryanair', 'Ireland')
    INTO airlines (airline_id, airline_callsign, residence) VALUES ('UAE', 'Emirates', 'United Arab Emirates')
SELECT 1 FROM DUAL;

/*AIRPLANES*/
INSERT ALL
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('N12345', 'Boeing', '737-800', 'Y', 'DAL')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('N23456', 'Boeing', '757-200', 'Y', 'DAL')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('G-ABCD', 'Airbus', 'A321', 'N', 'BAW')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('G-IJKL', 'Boeing', '747-400', 'Y', 'BAW')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('VH-ABC', 'Boeing', '737-800', 'Y', 'QFA')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('EI-FOD', 'Boeing', '737-700', 'N', 'RYR')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('EI-DBG', 'Airbus', 'A321', 'N', 'RYR')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('EI-GOB', 'Boeing', '757-200', 'N', 'RYR')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('EI-ENE', 'Airbus', 'A320neo', 'N', 'RYR')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('A6-1234', 'Boeing', '777-300ER', 'Y', 'UAE')
    INTO airplanes (airplane_id, manufacturer, model, wifi_connection_b, airline) VALUES ('A6-2345', 'Airbus', 'A380', 'N', 'UAE')
SELECT 1 FROM DUAL;

/*AIRPORTS*/
INSERT ALL
    INTO airports (airport_id, country) VALUES ('LAX', 'United States')
    INTO airports (airport_id, country) VALUES ('LGW', 'United Kingdom')
    INTO airports (airport_id, country) VALUES ('CDG', 'France')
    INTO airports (airport_id, country) VALUES ('NRT', 'Japan')
    INTO airports (airport_id, country) VALUES ('ZRH', 'Switzerland')
    INTO airports (airport_id, country) VALUES ('FCO', 'Italy')
    INTO airports (airport_id, country) VALUES ('SYD', 'Australia')
    INTO airports (airport_id, country) VALUES ('AMS', 'Netherlands')
    INTO airports (airport_id, country) VALUES ('DUB', 'Ireland')
    INTO airports (airport_id, country) VALUES ('SVO', 'Russia')
    INTO airports (airport_id, country) VALUES ('PEK', 'China')
    INTO airports (airport_id, country) VALUES ('CPH', 'Denmark')
    INTO airports (airport_id, country) VALUES ('PRG', 'Czech Republic')
    INTO airports (airport_id, country) VALUES ('IST', 'Turkey')
    INTO airports (airport_id, country) VALUES ('VIE', 'Austria')
SELECT 1 FROM DUAL;

/*FLIGHTS*/
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-06-01 10:15:00.00 +00:00', TIMESTAMP '2023-06-01 12:05:00.00 +00:00', 'N12345', 'DAL', 'LGW', 'LAX');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-08-12 13:00:00.00 +00:00', TIMESTAMP '2023-08-12 14:25:00.00 +00:00', 'N23456', 'DAL', 'LAX', 'PRG');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-01-06 15:30:00.00 +00:00', TIMESTAMP '2023-07-06 19:15:00.00 +00:00', 'G-ABCD', 'BAW', 'ZRH', 'FCO');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-07-22 08:00:00.00 +00:00', TIMESTAMP '2023-07-22 10:15:00.00 +00:00', 'G-IJKL', 'BAW', 'VIE', 'CPH');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-06-15 09:30:00.00 +00:00', TIMESTAMP '2023-06-15 12:15:00.00 +00:00', 'VH-ABC', 'QFA', 'IST', 'CDG');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-02-12 20:00:00.00 +00:00', TIMESTAMP '2023-04-02 08:25:00.00 +00:00', 'EI-ENE', 'RYR', 'SYD', 'NRT');
INSERT INTO flights (departure_time, arrival_time, airplane, airline, origin, destination) VALUES (TIMESTAMP '2023-03-15 19:00:00.00 +00:00', TIMESTAMP '2023-04-02 08:30:00.00 +00:00', 'A6-2345', 'UAE', 'PEK', 'SVO');


/*CUSTOMERS*/
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Eližda', 'Hlavova', 'eliskajehusta@necum.cz', 'Y');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Denis', 'Novosad', 'dnovos@seznam.cz', 'N');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Roman', 'Poliacik', 'rpolia@gmail.cz', 'Y');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Ondra', 'Parol', 'sup@phub.com', 'N');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Lenka', 'Horáková', 'lhorakova@email.cz', 'N');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Giovanni', 'Lombardi', 'glombardi@gmail.it', 'N');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Juraj', 'Kováč', 'jkovac@gmail.com', 'N');
INSERT INTO customers (first_name, last_name, email, blacklist_b) VALUES ('Jakub', 'Dvořák', 'jdvorak@email.cz', 'N');

/*RESERVATIONS*/
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'N', SYSTIMESTAMP - INTERVAL '17' HOUR, 3);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'N', SYSTIMESTAMP - INTERVAL '17' HOUR, 3);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'N', SYSTIMESTAMP - INTERVAL '23' HOUR - INTERVAL '59' MINUTE, 7);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'Y', SYSTIMESTAMP - INTERVAL '8' HOUR, 6);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'N', SYSTIMESTAMP - INTERVAL '5' HOUR - INTERVAL '47' MINUTE, 4);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'Y', TIMESTAMP '2022-08-17 06:42:00.00 +01:00', 1);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'Y', TIMESTAMP '2023-01-25 16:23:00.00 +01:00', 3);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'Y', TIMESTAMP '2022-10-11 18:31:00.00 +01:00', 4);
INSERT INTO reservations (cost, payment_status, created_at, owner) VALUES (NULL, 'Y', TIMESTAMP '2022-12-31 23:59:00.00 +01:00', 5);

/*TICKETS*/
INSERT INTO tickets (cost, reservation) VALUES (NULL, 4);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 6);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 2);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 1);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 8);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 3);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 7);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 5);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 1);
INSERT INTO tickets (cost, reservation) VALUES (NULL, 3);

/*SEATS*/

INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('E', 100.00, 1, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('Z', 74.00, 2, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('Z', 74.00, 2, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('Z', 54.00, 2, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('Z', 54.00, 2, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 250.25, 3, 'BAW', 3);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 280.00, 3, 'BAW', 3);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('E', 120.25, 3, 'BAW', 3);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 149.99, 3, 'BAW', 3);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('Y', 98.30, 3, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('J', 199.99, 4, 'DAL', 2);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 150.75, 4, 'BAW', 4);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 99.99, 5, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('C', 179.99, 6, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('C', 179.99, 6, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('C', 179.99, 6, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('C', 179.99, 6, 'DAL', 1);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('F', 250.00, 9, 'RYR', 6);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('E', 200.00, 7, 'QFA', 5);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('E', 128.99, 7, 'BAW', 3);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('D', 49.99, 8, 'UAE', 7);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('F', 84.99, 8, 'UAE', 7);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('I', 60.00, 9, 'QFA', 5);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('B', 43.50, 10, 'QFA', 5);
INSERT INTO seats (class, cost, ticket, airline, flight) VALUES ('F', 32.50, 10, 'BAW', 4);

/*SEATS FOR ANIMAL*/
INSERT INTO seats_for_animal (seat_animal_id, ticket, cage_size, class, cost) VALUES (25, 10,'S', 'A', 32.5);
INSERT INTO seats_for_animal (seat_animal_id, ticket, cage_size, class, cost) VALUES (18, 9, 'L', 'A', 250);


/* 
                1. SELECT
Najdi počet prodaných letenek pro každý let. 
spojení tabulek flights, reservations a tickets k získání informací o letech, rezervacích a prodaných letenek. 
COUNT pro výpočet počtu letenek.
WHERE pro výběr zaplacených RESERVATIONS.
GROUP BY pro seskupení výsledku podle ID letu.
*/
SELECT f.flights_id, COUNT(t.ticket_id) AS tickets_sold
FROM flights f
JOIN tickets t ON f.flights_id = t.reservation
JOIN reservations r ON t.reservation = r.reservation_id
WHERE r.payment_status = 'Y'
GROUP BY f.flights_id;

/* 
                2. SELECT
Zjisti, zda existuje let medzi letistemi CPH a VIE
pouziva vsechny sloupce z tabulky FLIGHTS
WHERE EXISTS filtrování podle spojení letišť z poddotazu.
VNORENY SELECT hleda lety, ktere pocinaji v VIE nebo CPH a konci ve VIE nebo CPH
*/
SELECT *
FROM flights
WHERE EXISTS (
    SELECT *
    FROM airports a1
    JOIN airports a2 ON (a1.airport_id = 'CPH' AND a2.airport_id = 'VIE') OR (a1.airport_id = 'VIE' AND a2.airport_id = 'CPH')
    WHERE flights.origin = a1.airport_id AND flights.destination = a2.airport_id
);

/* 
                3. SELECT
Najdi zoznam letu, ktere sou provadeny letadly s WIFI
pouziva vsechny sloupce z tabulky FLIGHTS
WHERE které rádky z tabulky budou vybrány
IN používá se v kombinaci s poddotazem pro výběr řádků, jejichž hodnoty jsou obsaženy v poddotazu
VNORENY SELECT - vrací seznam letadel, která mají wifi připojení
*/
SELECT *
FROM flights
WHERE airplane IN (
SELECT airplane_id
FROM airplanes
WHERE wifi_connection_b = 'Y'
);


/* 
                4. SELECT
Najde seznam zákazníků s pouze jednou rezervací
pouziva sloupec first name a last name z tabulky customers a počítá owners v tabulce reservations
GROUP BY vypisuje jen jemno a prijimeni
*/

  SELECT p.first_name, p.last_name, COUNT(DISTINCT t.reservation_id)
  FROM  reservations t, customers p
  WHERE t.owner = p.customer_id
  GROUP BY p.first_name, p.last_name
  HAVING COUNT(DISTINCT t.reservation_id) = 1;
  
/* 
                5. SELECT
Vypíše spolecnosti podle poctu letadel ktere vlastni
pouziva sloupec airline_id z tabulky airlines a počítá airline v tabulce airplanes
GROUP BY vypisuje název aerolinky a počer vlastněných letadel
*/

  -- vypis spolecnosti podle poctu letadel ktere vlastni
  
  SELECT a.airline_id,  COUNT(DISTINCT t.airplane_id)
  FROM  airplanes t, airlines a
  WHERE t.airline = a.airline_id
  GROUP BY a.airline_id
  ORDER BY 2 DESC;


  
  

/*
SELECT * FROM AIRLINES;
SELECT * FROM AIRPLANES;
SELECT * FROM AIRPORTS;
SELECT * FROM FLIGHTS;
SELECT * FROM CUSTOMERS;
SELECT * FROM RESERVATIONS;
SELECT * FROM TICKETS;
SELECT * FROM SEATS;
SELECT * FROM SEATS_FOR_ANIMAL;
*/
