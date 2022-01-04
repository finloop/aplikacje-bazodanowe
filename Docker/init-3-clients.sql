CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_ADDRESS(client_name varchar(50),
											city_ varchar(50),
											address_ varchar, 
											street_ varchar,
											postalcode_ varchar(5)
										   )
    LANGUAGE plpgsql as $$
DECLARE
	address_id int;
	
BEGIN
   SELECT create_address_if_not_exists(city_ , address_ , street_ , postalcode_ ) INTO  address_id;
	
	UPDATE clients
		SET addressid = address_id
		WHERE clients.name=client_name;
	
END;$$;
--CALL CLIENT_CHANGE_ADDRESS('Adrian Szmyd', 'Toruń','21','Gagarina', '59100');




CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_CONTACTINFO(client_name varchar(50),email_ varchar(50),phonenumber_ varchar(9)
										   )
    LANGUAGE plpgsql as $$
DECLARE
	contactinfo_id int;
	
BEGIN
   SELECT create_contactinfo_if_not_exists(email_, phonenumber_) INTO  contactinfo_id;
	
	UPDATE clients
		SET contactinfoid = contactinfo_id
		WHERE clients.name=client_name;
	
END;$$;


--CALL CLIENTS_CHANGE_CONTACTINFO('Adrian Szmyd', 'szad@o2.pl', '131131131');




CREATE OR REPLACE PROCEDURE CLIENTS_CHANGE_NAME(client_name varchar(50),new_client_name varchar(50))
    LANGUAGE plpgsql as $$

	
BEGIN
   	UPDATE clients
		SET name = new_client_name
		WHERE clients.name = client_name;
	
END;$$;


--CALL CLIENTS_CHANGE_NAME('Adrian Szmyd', 'Karol Tetmajer');




CREATE OR REPLACE FUNCTION CLIENTS_AVAILABLE_RESTAURANTS(client_name varchar(50))
    RETURNS TABLE(restaurant_name varchar(50))
    LANGUAGE 'plpgsql' AS $$

DECLARE
	city_id int;
		
BEGIN

SELECT address.cityid INTO city_id
     FROM address
	 INNER JOIN clients ON address.id = clients.addressid
	 WHERE clients.name = client_name;

RETURN QUERY SELECT restaurants.name
FROM cities 
	INNER JOIN address ON cities.id = address.cityid 
	INNER JOIN restaurants ON address.id = restaurants.addressid
WHERE cities.id=city_id;

	
    
END;$$;

--SELECT * FROM CLIENTS_AVAILABLE_RESTAURANTS('Adrian Szmyd');




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
END;$$;

--SELECT * FROM CREATE_CLIENT_IF_NOT_EXISTS('Oskar Wróblewski' ,'abcd@cba.pl','123698745','55','Kwiatowa','74163','Suwałki') 







CREATE OR REPLACE FUNCTION CLIENTS_LIST_ORDERS(client_name varchar(30))
    RETURNS
        TABLE (            
            name varchar(60)            
        )
    LANGUAGE plpgsql as $$
DECLARE
    client_id int;
BEGIN
    SELECT clients.id INTO client_id
        FROM clients
        WHERE
            clients.name = client_name;

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

--SELECT * FROM CLIENTS_LIST_ORDERS('Michał Ptaszyński')



CREATE OR REPLACE FUNCTION PAYMENT_TYPE_AVG_ORDER_COST()
    RETURNS
        TABLE (
            paymnt_type_name varchar(50),
            avg_price double precision
        )
    LANGUAGE plpgsql as $$

BEGIN

RETURN QUERY SELECT paymenttypes.name, Avg(dishes.price*dishesinorder.qty)
FROM dishes INNER JOIN ((paymenttypes INNER JOIN orders ON paymenttypes.paymenttypesid = orders.paymenttypeid) 
INNER JOIN dishesinorder ON orders.id = dishesinorder.orderid) ON dishes.id = dishesinorder.dishid
GROUP BY paymenttypes.name;

END;$$;

--SELECT * FROM PAYMENT_TYPE_AVG_ORDER_COST()







