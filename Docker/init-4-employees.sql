-- Type: client_details

-- DROP TYPE IF EXISTS client_details;

CREATE TYPE client_details AS
(
    client_name character varying,
    phone character varying,
    street character varying,
    address character varying,
    city_id int,
    order_id int
);

-- Type: client_details

ALTER TYPE client_details
    OWNER TO postgres;

CREATE OR REPLACE FUNCTION employees_list_undelivered_order(employee_id int)
    RETURNS table (client_info client_details)
    LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    client_info client_details;
BEGIN
    RETURN QUERY
    SELECT clients.name, contactinfo.phonenumber, address.street, address.address, cities.id, orders.id
        FROM clients
        INNER JOIN address ON address.id = clients.addressid
        INNER JOIN contactinfo ON contactinfo.id = clients.contactinfoid
        INNER JOIN orders ON orders.clientid = clients.id
        INNER JOIN employees ON employees.id = orders.employeeid
        INNER JOIN cities ON cities.id = address.cityid
        WHERE employees.id  = employee_id
        AND orders.enddate IS NULL;
END;
$BODY$;
-- SELECT * FROM employees_list_undelivered_orders(2)

CREATE OR REPLACE FUNCTION employees_get_available_orders_to_take(cityid_arg int)
    RETURNS table (order_id int,
                   restaurant_name character varying,
                   restaurant_street character varying,
                   restaurant_address character varying)
    LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    RETURN QUERY
    SELECT orders.id "order_id",
           restaurants.name "restaurant_name",
           address.street "restaurant_street",
           address.address "restaurant_address"
    FROM restaurants
    INNER JOIN address ON address.id = restaurants.addressid
    INNER JOIN orders ON orders.restaurantid = restaurants.id
    WHERE orders.employeeid IS NULL
    AND address.cityid = cityid_arg;
END;
$BODY$;

-- SELECT * FROM employees_get_available_orders_to_take(2)


CREATE OR REPLACE FUNCTION employees_get_profit(employee_id int, startdate character varying, enddate character varying)
       RETURNS float
       LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
    startdate_date date;
    enddate_date date;
    sum_of_profit double precision := 0;
BEGIN

    startdate_date = TO_DATE(startdate, 'YYYY-MM-DD');
    enddate_date = TO_DATE(enddate, 'YYYY-MM-DD');
    SELECT CAST(SUM(dishesinorder.qty*dishes.price*0.05) as float), 2 "profit" -- we assume 5% fee
        INTO sum_of_profit
        FROM dishesinorder
        INNER JOIN orders ON dishesinorder.orderid = orders.id
        INNER JOIN dishes ON dishesinorder.dishid = dishes.id
        WHERE orders.enddate BETWEEN startdate_date AND enddate_date
        AND orders.employeeid = employee_id;
    RETURN sum_of_profit;
END;
$BODY$;
-- SELECT * FROM employees_get_profit(2, "2020-01-01", "2021-12-31")



CREATE OR REPLACE PROCEDURE deliver_order(order_id int)
       LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE orders
    SET enddate = CURRENT_DATE
    WHERE orders.id = order_id;
END;
$BODY$;
-- CALL DELIVER_ORDER(2)

CREATE OR REPLACE PROCEDURE batch_deliver(order_ids int[])
       LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
	order_id int;
BEGIN
    FOREACH order_id in array order_ids LOOP
        CALL deliver_order(order_id);
    END LOOP;

END;
$BODY$;
-- CALL batch_deliver(ARRAY[1,2,3]);


CREATE OR REPLACE PROCEDURE take_order_from_restaurant(employee_id int, order_id int)
       LANGUAGE 'plpgsql'
AS $BODY$
BEGIN
    UPDATE orders
    SET employeeid = employee_id
    WHERE orders.id = order_id;
END;
$BODY$;
-- CALL take_order_from_restaurant(1, 3)
