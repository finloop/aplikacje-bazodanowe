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
        SELECT MAX(id)+1 INTO city_id FROM cities;
        INSERT INTO cities (id, name) VALUES (city_id, cityname);
    END IF;

    RETURN city_id;
END;$$;
-- SELECT * FROM  CREATE_CITY_IF_NOT_EXISTS('Przemyśl');

CREATE OR REPLACE FUNCTION CREATE_CONTACTINFO_IF_NOT_EXISTS(email_ VARCHAR, phonenumber_ VARCHAR(9)) RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    contactinfo_id int;
BEGIN
    -- Check if contactinfo_id exists
    SELECT contactinfo.id INTO contactinfo_id
        FROM contactinfo
        WHERE contactinfo.email = email_;
    -- If not, add it and return it's ID
    IF (contactinfo_id is null) THEN
        -- Select next free id
        SELECT MAX(id)+1 INTO contactinfo_id FROM contactinfo;
        INSERT INTO contactinfo (id, email, phonenumber)
            VALUES (contactinfo_id, email_, phonenumber_);
    END IF;

    RETURN contactinfo_id;
END;$$;
-- SELECT * FROM CREATE_CONTACTINFO_IF_NOT_EXISTS('piotr.krawiec23@gmail.com', '111222333');

CREATE OR REPLACE FUNCTION CREATE_ADDRESS_IF_NOT_EXISTS(city_ VARCHAR, address_ VARCHAR, street_ VARCHAR, postalcode_ VARCHAR(5))   RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    address_id int;
    city_id int;
BEGIN
    -- Check if address_id exists
    SELECT address.id INTO address_id
        FROM address
        WHERE address.postalcode = postalcode_
            AND address.street = street_
            AND address.postalcode = postalcode_;
    -- If not, add it and return it's ID
    IF (address_id is null) THEN
        -- Select next free id
        SELECT MAX(id)+1 INTO address_id FROM address;
        -- Add city
        SELECT CREATE_CITY_IF_NOT_EXISTS(city_) INTO city_id;
        INSERT INTO address (id, cityid, address, street, postalcode)
            VALUES (address_id, city_id, address_, street_, postalcode_);
    END IF;

    RETURN address_id;
END;$$;
-- SELECT * FROM CREATE_ADDRESS_IF_NOT_EXISTS('Przemyśl', '18A', 'Grunwaldzka', '37723');

CREATE OR REPLACE PROCEDURE RESTAURANTS_CREATE_RESTAURANT_IF_NOT_EXISTS(restaurantname_ VARCHAR,
                                                                        email_ VARCHAR,
                                                                        phonenumber_ VARCHAR(9),
                                                                        address_ VARCHAR,
                                                                        street_ VARCHAR,
                                                                        postalcode_ VARCHAR(5),
                                                                        cityname_ VARCHAR,
                                                                        dishes_ VARCHAR[][])
    LANGUAGE plpgsql as $$
DECLARE
    restaurant_id int;
    contactinfo_id int;
    address_id int;
    dish_id int;
    dish_ VARCHAR[];
BEGIN
     -- Check if restaurant exists
    SELECT restaurants.id INTO restaurant_id
        FROM restaurants
        WHERE restaurants.name = restaurantname_;
    -- Create restaurant if not exists
    IF (restaurant_id is null) THEN
        -- Select next free id
        SELECT MAX(restaurants.id)+1 INTO restaurant_id FROM restaurants;
        -- Create address and contactinfo
        SELECT CREATE_CONTACTINFO_IF_NOT_EXISTS(email_, phonenumber_) INTO contactinfo_id;
        SELECT CREATE_ADDRESS_IF_NOT_EXISTS(cityname_, address_, street_, postalcode_) INTO address_id;
        -- Insert new restaurant
        INSERT INTO restaurants(id, contactinfoid, name, addressid)
            VALUES (restaurant_id, contactinfo_id, restaurantname_, address_id);
        -- Add dishes to new restaurant
        FOREACH dish_ SLICE 1 IN ARRAY dishes_ LOOP
            SELECT MAX(id)+1 INTO dish_id FROM dishes;
            INSERT INTO dishes
                       (id, name, price, waittime, restaurantid)
                VALUES (dish_id, dish_[1], CAST(dish_[2] AS int), CAST(dish_[3] AS int), restaurant_id);
        END LOOP;

    END IF;
END;$$;
--CALL RESTAURANTS_CREATE_RESTAURANT_IF_NOT_EXISTS('Woda i mąka',
--                                                 'wodaimaka@gmail.com',
--                                                 '123456111', '12A',
--                                                 'Popiełuszki',
--                                                 '38000',
--                                                 'Rzeszów',
--                                                 ARRAY[
--                                                     ARRAY['Naleśniki', '12', '15'],
--                                                     ARRAY['Panini', '10', '15']
--                                                 ]);


CREATE OR REPLACE PROCEDURE RESTAURANTS_ADD_CUISNE_TO_RESTAURANT(restaurantname_ VARCHAR,
                                                                 cuisne_ VARCHAR)
    LANGUAGE plpgsql as $$
DECLARE
    restaurant_id int;
    cuisne_id int;
BEGIN
    -- Check if restaurant exists
    SELECT cuisnes.id INTO cuisne_id
        FROM cuisnes
        WHERE cuisnes.name = cuisne_;
    SELECT restaurants.id INTO restaurant_id
        FROM restaurants
        WHERE restaurants.name = restaurantname_;
    IF cuisne_id is null THEN
        SELECT MAX(id)+1 INTO cuisne_id FROM cuisnes;
        INSERT INTO cuisnes (id, name)
            VALUES (cuisne_id, cuisne_);
    END IF;
    INSERT INTO cuisnesinrestaurants (cuisneid, restaurantid)
        VALUES (cuisne_id, restaurant_id);
END;$$;
-- CALL RESTAURANTS_ADD_CUISNE_TO_RESTAURANT('Woda i mąka', 'Polska');
