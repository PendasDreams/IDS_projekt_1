
    
    DROP TABLE airplanes        CASCADE CONSTRAINTS;
    DROP TABLE airlines         CASCADE CONSTRAINTS; 
    DROP TABLE airports         CASCADE CONSTRAINTS;
    DROP TABLE seats            CASCADE CONSTRAINTS;
    DROP TABLE seats_for_animal CASCADE CONSTRAINTS; /* inherits from seats */    
    DROP TABLE flights           CASCADE CONSTRAINTS;
    DROP TABLE customers            CASCADE CONSTRAINTS;
    DROP TABLE reservations    CASCADE CONSTRAINTS;
    DROP TABLE tickets          CASCADE CONSTRAINTS;


    CREATE TABLE airlines (
        ID              NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        full_name       VARCHAR(100) NOT NULL,
        residence       VARCHAR(100) NOT NULL
    );
    
    CREATE TABLE airplanes(
        ID                NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        manufacturer      VARCHAR(100),
        model             VARCHAR(100),
        wifi_connection_b NUMBER NOT NULL, -- true or false -- BOOL 1 == TRUE 0 == FALSE
        airline           NUMBER,

    CONSTRAINT airplane_owner_airline_fk FOREIGN KEY (airline) REFERENCES airlines(ID)
    );   
    
    CREATE TABLE airports (
        /* Airport code in official IATA format; Example: JFK */
        ID              NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        city            VARCHAR(100) NOT NULL,
        country         VARCHAR(100) NOT NULL
    );
    
    
    CREATE TABLE flights (
        ID     NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
        departure_time    TIMESTAMP WITH TIME ZONE NOT NULL,
        arrival_time      TIMESTAMP WITH TIME ZONE NOT NULL,
        airplane          NUMBER,
        airline           NUMBER,
        origin            NUMBER,
        destination       NUMBER,
    
        CONSTRAINT flight_with_airplane_fk        FOREIGN KEY (airplane)    REFERENCES airplanes(ID),
        CONSTRAINT flight_operated_by_airline_fk  FOREIGN KEY (airline)     REFERENCES airlines(ID),
        CONSTRAINT flight_origin_airport_fk       FOREIGN KEY (origin)      REFERENCES airports(ID),
        CONSTRAINT flight_destination_airport_fk  FOREIGN KEY (destination) REFERENCES airports(ID)

    );
  
    CREATE TABLE customers (
        ID               NUMBER PRIMARY KEY,
        first_name       VARCHAR(50) NOT NULL,
        last_name        VARCHAR(50) NOT NULL,
        email            VARCHAR(100) NOT NULL,
        blacklist_b      NUMBER NOT NULL -- true or false
    );
  
    CREATE TABLE reservations (
        id              NUMBER NOT NULL PRIMARY KEY,
        price           NUMBER,
        payment_status  NUMBER NOT NULL CHECK(payment_status = 0 or payment_status = 1), -- true or false
        created_at      TIMESTAMP NOT NULL,
        created_by      NUMBER,
    
        CONSTRAINT reservation_creator_fk FOREIGN KEY (created_by) REFERENCES customers(id)
    );
    

    
    
INSERT INTO airlines VALUES(1,'SWISS','BERLIN');


SELECT * FROM airlines;

/*nejsou sequence*/

  
  
