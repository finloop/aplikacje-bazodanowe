CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_ADDRESS(client_id int,
											city_ varchar(50),
											address_ varchar, 
											street_ varchar,
											postalcode_ varchar(5)
										   )
    LANGUAGE plpgsql as $$
DECLARE
	--zadeklarowanie zmiennej address_id której później użyjemy do zmiany adresu
	address_id int;
	
BEGIN
	--wykorzystanie funkcji, która tworzy adres jeśli ten nie istnieje
   SELECT create_address_if_not_exists(city_ , address_ , street_ , postalcode_ ) INTO  address_id;
	--zaktualizowanie tabeli clients o nowy adres dla danego klienta
	UPDATE clients
		SET addressid = address_id
		WHERE clients.id=client_id;
	
END;$$;
--CALL CLIENTS_CHANGE_ADDRESS(19, 'Toruń','21','Gagarina', '59100');




CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_CONTACTINFO(client_id int,email_ varchar(50),phonenumber_ varchar(9)
										   )
    LANGUAGE plpgsql as $$
DECLARE
	contactinfo_id int;
	
BEGIN
	--wykorzystanie funkcji tworzącej informacje kontaktowe danego klienta jeśli te nie istnieją
   SELECT create_contactinfo_if_not_exists(email_, phonenumber_) INTO  contactinfo_id;
	--zaktualizowanie tabeli clients poprzez zmianę informacji kontakowych klienta
	UPDATE clients
		SET contactinfoid = contactinfo_id
		WHERE clients.id=client_id;
	
END;$$;


--CALL CLIENTS_CHANGE_CONTACTINFO(19, 'szad@o2.pl', '131131131');




CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_NAME(client_id int,new_client_name varchar(50))
    LANGUAGE plpgsql as $$

	
BEGIN
	--aktualizacja imienia i nazwiska klienta
   	UPDATE clients
		SET name = new_client_name
		WHERE clients.id = client_id;
	
END;$$;


--CALL CLIENTS_CHANGE_NAME(19, 'Karol Tetmajer');


CREATE OR REPLACE PROCEDURE CLIENTS_NEW_ORDER(client_id int, dish_id int, quantity int,  payment_type varchar(50))
LANGUAGE plpgsql as $$


DECLARE
	--deklaracja zmiennych potrzebnych do utworzenia procedury
	ready BOOLEAN := false;
	order_id int;
	paymenttype_id int;
	rest_id int;
	paid boolean:= false;
	
BEGIN
		--dodanie id nowego zamówienia
		SELECT MAX(orders.id)+1 
		INTO order_id 
		FROM orders;

		--ustalenie typu płatności
		SELECT paymenttypesid 
		INTO paymenttype_id
		FROM paymenttypes
			WHERE paymenttypes.name = payment_type;
			
		--ustalenie dania i restauracji z której zostały one zamówione
			SELECT restaurantid 
			INTO rest_id
			FROM dishes 	
				WHERE dishes.id = dish_id;
		
		--jeśli klient płaci kartą lub przelewem musi zapłącić w trakcie zamawiania, przez co zamówienie jest już opłacone
		IF paymenttype_id = 3 OR paymenttype_id = 4 THEN		
			paid:=true;	
		END IF;
		--dodanie nowego zamówienia do tabeli orders
		INSERT INTO orders(id, paymenttypeid, restaurantid, clientid, paid, startdate, readyfordelivery)
					VALUES (order_id, paymenttype_id, rest_id, client_id, paid , current_date ,ready);
				
		--dodanie dań do tabeli dishes in order
		INSERT INTO dishesinorder(dishid, orderid, qty)
				VALUES(dish_id, order_id, quantity);		
				
		
	
END;$$;

--CALL CLIENTS_NEW_ORDER(19, 6, 7, 'Karta');


CREATE OR REPLACE FUNCTION CLIENTS_AVAILABLE_RESTAURANTS(client_id int)
    RETURNS TABLE(restaurant_id int, restaurant_name varchar(50))
    LANGUAGE 'plpgsql' AS $$

DECLARE
	city_id int;
		
BEGIN
	--ustalenie miasta klienta
	SELECT address.cityid INTO city_id
		 FROM address
		 INNER JOIN clients ON address.id = clients.addressid
		 WHERE clients.id = client_id;
	--zwrócenie tabeli z restauracjami z miasta klienta
	RETURN QUERY SELECT restaurants.id, restaurants.name
	FROM cities 
		INNER JOIN address ON cities.id = address.cityid 
		INNER JOIN restaurants ON address.id = restaurants.addressid
	WHERE cities.id=city_id;

    
END;$$;

--SELECT * FROM CLIENTS_AVAILABLE_RESTAURANTS(19);





CREATE OR REPLACE FUNCTION CREATE_CLIENT_IF_NOT_EXISTS(clientname_ VARCHAR(50),
                                                        email_ VARCHAR(50),
                                                        phonenumber_ VARCHAR(9),
                                                        address_ VARCHAR,
                                                        street_ VARCHAR,
                                                        postalcode_ VARCHAR(5),
                                                        cityname_ VARCHAR(50)
                                                       ) 
	RETURNS int
    LANGUAGE plpgsql as $$
DECLARE
    client_id int;
    contactinfo_id int;
    address_id int;
BEGIN
     -- Check if client exists
    SELECT clients.id INTO client_id
        FROM clients
        WHERE clients.name = clientname_;
    -- Create client if not exists
    IF (client_id is null) THEN
        -- Select next free id
        SELECT MAX(clients.id)+1 INTO client_id FROM clients;
        -- Create address and contactinfo
        SELECT CREATE_CONTACTINFO_IF_NOT_EXISTS(email_, phonenumber_) INTO contactinfo_id;
        SELECT CREATE_ADDRESS_IF_NOT_EXISTS(cityname_, address_, street_, postalcode_) INTO address_id;
        -- Insert new client
        INSERT INTO clients(id, contactinfoid, name, addressid)
            VALUES (client_id, contactinfo_id, clientname_, address_id);
       
    END IF;
	RETURN client_id;
END;$$;

--SELECT * FROM CREATE_CLIENT_IF_NOT_EXISTS('Oskar Wróblewski' ,'abcd@cba.pl','123698745','55','Kwiatowa','74163','Suwałki') 







CREATE OR REPLACE FUNCTION CLIENTS_LIST_ORDERS(client_id int)
    RETURNS
        TABLE (            
            name varchar(60)  
        )
    LANGUAGE plpgsql as $$

BEGIN
	--wypisanie zamóień klienta
    RETURN QUERY SELECT dishes.name
        FROM orders
            INNER JOIN clients ON clients.id = orders.clientid
            INNER JOIN dishesinorder ON orders.id = dishesinorder.orderid
            INNER JOIN dishes ON dishes.id = dishesinorder.dishid
        WHERE
            orders.clientid = client_id
            AND orders.enddate is not null
            AND orders.readyfordelivery is true;
END; $$;

--SELECT * FROM CLIENTS_LIST_ORDERS(7)



CREATE OR REPLACE FUNCTION PAYMENT_TYPE_AVG_ORDER_COST()
    RETURNS
        TABLE (
            paymnt_type_name varchar(50),
            avg_price double precision
        )
    LANGUAGE plpgsql as $$

BEGIN
	--wypisanie metod płatności wraz ze średnim kosztem zamówienia dla danej płatności 
	RETURN QUERY SELECT paymenttypes.name, Avg(dishes.price*dishesinorder.qty)
		FROM dishes 
		INNER JOIN ((paymenttypes INNER JOIN orders ON paymenttypes.paymenttypesid = orders.paymenttypeid) 
		INNER JOIN dishesinorder ON orders.id = dishesinorder.orderid) ON dishes.id = dishesinorder.dishid
		GROUP BY paymenttypes.name;

END;$$;

--SELECT * FROM PAYMENT_TYPE_AVG_ORDER_COST()



CREATE OR REPLACE FUNCTION CLIENTS_AVAILABLE_DISHES(client_id int)
RETURNS
        TABLE (
			dish_id int,
            dish_name varchar(50)            
        )
LANGUAGE plpgsql as $$

DECLARE
	restaurant_id int;
	
BEGIN
	--sprawdzenie jakie restauracje są dostępne dla klienta
	SELECT *
	FROM CLIENTS_AVAILABLE_RESTAURANTS(client_id) 
	INTO restaurant_id;
	--sprawdzenie jakie dania są w tychże restauracjach 
	RETURN QUERY SELECT dishes.id, dishes.name
	FROM dishes 
	INNER JOIN restaurants ON dishes.restaurantid = restaurants.id
	WHERE restaurants.id=restaurant_id;



END;$$;

--SELECT * FROM CLIENTS_AVAILABLE_DISHES(19);