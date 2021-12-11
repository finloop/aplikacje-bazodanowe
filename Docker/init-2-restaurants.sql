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
            AND orders.enddate is null;
END; $$;
