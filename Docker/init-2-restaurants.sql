CREATE OR REPLACE FUNCTION RESTAURANT_LIST_ORDERS(restaurant_name varchar(30))
    RETURNS
        TABLE (
            id int,
            name varchar(60),
            qty smallint
        )
    LANGUAGE plpgsql as $$
DECLARE
    restaurant_id int;
BEGIN
    SELECT restaurants.id INTO restaurant_id
        FROM restaurants
        WHERE
            restaurants.name = restaurant_name;

    RETURN QUERY SELECT orders.id, dishes.name, dishesinorder.qty
        FROM orders
            INNER JOIN restaurants ON restaurants.id = orders.restaurantid
            INNER JOIN dishesinorder ON orders.id = dishesinorder.orderid
            INNER JOIN dishes ON dishes.id = dishesinorder.dishid
        WHERE
            orders.restaurantid = restaurant_id
            AND orders.enddate is null
            AND orders.readyfordelivery is false;
END; $$;
-- select * FROM RESTAURANT_LIST_ORDERS('PizzaHut');

CREATE OR REPLACE PROCEDURE RESTAURANT_MAKE_ORDER_READY(orderid int)
    LANGUAGE plpgsql as $$
BEGIN
    UPDATE orders
        SET readyfordelivery = true
        WHERE orders.id = orderid;
END;$$;
-- CALL RESTAURANTS_MAKE_ORDER_READY(9);

CREATE OR REPLACE FUNCTION CREATE_CITY_IF_NOT_EXISTS(cityname VARCHAR) RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    city_id int;
BEGIN
    -- Check if city exists
    SELECT cities.id INTO city_id
        FROM cities
        WHERE cities.name = cityname;
    -- If not, add it and return it's ID
    IF (city_id is null) THEN
        INSERT INTO cities (name) VALUES (cityname);
        SELECT cities.id INTO city_id
            FROM cities
            WHERE cities.name = cityname;
    END IF;

    RETURN city_id;
END;$$;
-- SELECT * FROM  CREATE_CITY_IF_NOT_EXISTS('Przemyśl');

CREATE OR REPLACE FUNCTION CREATE_CONTACTINFO_IF_NOT_EXISTS(email_ VARCHAR, phonenumber_ VARCHAR(9)) RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    contactinfo_id int;
    contactinfo_id_max int;
BEGIN
    -- Check if contactinfo_id exists
    SELECT contactinfo.id INTO contactinfo_id
        FROM contactinfo
        WHERE contactinfo.email = email_;
    -- Select next free id
    SELECT MAX(id)+1 INTO contactinfo_id_max FROM contactinfo;
    -- If not, add it and return it's ID
    IF (contactinfo_id is null) THEN
        INSERT INTO contactinfo (id, email, phonenumber)
            VALUES (contactinfo_id_max, email_, phonenumber_);
        SELECT contactinfo.id INTO contactinfo_id
            FROM contactinfo
            WHERE contactinfo.email = email_;
    END IF;

    RETURN contactinfo_id;
END;$$;
-- SELECT * FROM CREATE_CONTACTINFO_IF_NOT_EXISTS('piotr.krawiec23@gmail.com', '111222333');

CREATE OR REPLACE FUNCTION CREATE_ADDRESS_IF_NOT_EXISTS(city_ VARCHAR, address_ VARCHAR, street_ VARCHAR, postalcode_ VARCHAR(5))   RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    address_id int;
    city_id int;
    address_id_max int;
BEGIN
    -- Check if address_id exists
    SELECT address.id INTO address_id
        FROM address
        WHERE address.postalcode = postalcode_
            AND address.street = street_
            AND address.postalcode = postalcode_;
    -- Select next free id
    SELECT MAX(id)+1 INTO address_id_max FROM address;
    -- If not, add it and return it's ID
    IF (address_id is null) THEN
        SELECT CREATE_CITY_IF_NOT_EXISTS(city_) INTO city_id;
        INSERT INTO address (id, cityid, address, street, postalcode)
            VALUES (address_id_max, city_id, address_, street_, postalcode_);
        SELECT address.id INTO address_id
            FROM address
            WHERE address.postalcode = postalcode_
                AND address.street = street_
                AND address.postalcode = postalcode_;
    END IF;

    RETURN address_id;
END;$$;
-- SELECT * FROM CREATE_ADDRESS_IF_NOT_EXISTS('Przemyśl', '18A', 'Grunwaldzka', '37723');
