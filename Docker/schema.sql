CREATE SCHEMA app;

CREATE SEQUENCE app.contactinfo_id_seq;

CREATE TABLE app.ContactInfo (
                Id VARCHAR NOT NULL DEFAULT nextval('app.contactinfo_id_seq'),
                Email VARCHAR(50),
                PhoneNumber VARCHAR(9) NOT NULL,
                CONSTRAINT contactinfo_pk PRIMARY KEY (Id)
);


ALTER SEQUENCE app.contactinfo_id_seq OWNED BY app.ContactInfo.Id;

CREATE SEQUENCE app.paymenttypes_paymenttypesid_seq;

CREATE TABLE app.PaymentTypes (
                PaymentTypesId INTEGER NOT NULL DEFAULT nextval('app.paymenttypes_paymenttypesid_seq'),
                Name VARCHAR NOT NULL,
                CONSTRAINT paymenttypes_pk PRIMARY KEY (PaymentTypesId)
);


ALTER SEQUENCE app.paymenttypes_paymenttypesid_seq OWNED BY app.PaymentTypes.PaymentTypesId;

CREATE SEQUENCE app.cusines_id_seq;

CREATE TABLE app.Cusines (
                Id INTEGER NOT NULL DEFAULT nextval('app.cusines_id_seq'),
                Name VARCHAR(50) NOT NULL,
                CONSTRAINT cusinesid PRIMARY KEY (Id)
);


ALTER SEQUENCE app.cusines_id_seq OWNED BY app.Cusines.Id;

CREATE SEQUENCE app.cities_id_seq;

CREATE TABLE app.Cities (
                Id INTEGER NOT NULL DEFAULT nextval('app.cities_id_seq'),
                Name VARCHAR(50) NOT NULL,
                CONSTRAINT citiesid PRIMARY KEY (Id)
);


ALTER SEQUENCE app.cities_id_seq OWNED BY app.Cities.Id;

CREATE TABLE app.Address (
                Id INTEGER NOT NULL,
                CityId INTEGER NOT NULL,
                Address VARCHAR NOT NULL,
                Street VARCHAR,
                PostalCode VARCHAR(5) NOT NULL,
                CONSTRAINT address_pk PRIMARY KEY (Id)
);


CREATE TABLE app.Restaurants (
                Id INTEGER NOT NULL,
                ContactInfoId VARCHAR NOT NULL,
                Name VARCHAR(50) NOT NULL,
                AddressId INTEGER NOT NULL,
                CONSTRAINT restaurantsid PRIMARY KEY (Id)
);


CREATE TABLE app.Dishes (
                Id INTEGER NOT NULL,
                Name VARCHAR(50) NOT NULL,
                RestaurantId INTEGER NOT NULL,
                Price REAL NOT NULL,
                WaitTime INTEGER NOT NULL,
                CONSTRAINT dishes_pk PRIMARY KEY (Id)
);


CREATE TABLE app.CusinesInRestaurants (
                CusineId INTEGER NOT NULL,
                RestaurantId INTEGER NOT NULL,
                CONSTRAINT cusinesinrestaurantsid PRIMARY KEY (CusineId, RestaurantId)
);


CREATE TABLE app.Employees (
                Id INTEGER NOT NULL,
                ContactInfoId VARCHAR NOT NULL,
                FName VARCHAR NOT NULL,
                LName VARCHAR NOT NULL,
                AddressId INTEGER NOT NULL,
                CONSTRAINT employeesid PRIMARY KEY (Id)
);


CREATE TABLE app.Clients (
                Id INTEGER NOT NULL,
                ContactInfoId VARCHAR NOT NULL,
                Name VARCHAR(50) NOT NULL,
                AddressId INTEGER NOT NULL,
                CONSTRAINT clientid PRIMARY KEY (Id)
);


CREATE TABLE app.Orders (
                Id INTEGER NOT NULL,
                PaymentTypeId INTEGER NOT NULL,
                EmployeeId INTEGER NOT NULL,
                RestaurantId INTEGER NOT NULL,
                ClientId INTEGER NOT NULL,
                Paid BOOLEAN DEFAULT false NOT NULL,
                StartDate DATE NOT NULL,
                EndDate DATE DEFAULT NULL,
                ReadyForDelivery BOOLEAN DEFAULT FALSE NOT NULL,
                CONSTRAINT orders_pk PRIMARY KEY (Id)
);


CREATE TABLE app.DishesInOrder (
                DishId INTEGER NOT NULL,
                OrderId INTEGER NOT NULL,
                Qty SMALLINT DEFAULT 1 NOT NULL,
                CONSTRAINT dishesinorder_pk PRIMARY KEY (DishId, OrderId)
);


ALTER TABLE app.Employees ADD CONSTRAINT contactinfo_employees_fk
FOREIGN KEY (ContactInfoId)
REFERENCES app.ContactInfo (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Clients ADD CONSTRAINT contactinfo_clients_fk
FOREIGN KEY (ContactInfoId)
REFERENCES app.ContactInfo (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Restaurants ADD CONSTRAINT contactinfo_restaurants_fk
FOREIGN KEY (ContactInfoId)
REFERENCES app.ContactInfo (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Orders ADD CONSTRAINT paymenttypes_orders_fk
FOREIGN KEY (PaymentTypeId)
REFERENCES app.PaymentTypes (PaymentTypesId)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.CusinesInRestaurants ADD CONSTRAINT cusines_cusinesinrestaurants_fk
FOREIGN KEY (CusineId)
REFERENCES app.Cusines (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Address ADD CONSTRAINT cities_address_fk
FOREIGN KEY (CityId)
REFERENCES app.Cities (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Employees ADD CONSTRAINT address_employees_fk
FOREIGN KEY (AddressId)
REFERENCES app.Address (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Restaurants ADD CONSTRAINT address_restaurants_fk
FOREIGN KEY (AddressId)
REFERENCES app.Address (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Clients ADD CONSTRAINT address_clients_fk
FOREIGN KEY (AddressId)
REFERENCES app.Address (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.CusinesInRestaurants ADD CONSTRAINT restaurants_cusinesinrestaurants_fk
FOREIGN KEY (RestaurantId)
REFERENCES app.Restaurants (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Dishes ADD CONSTRAINT restaurants_dishes_fk
FOREIGN KEY (RestaurantId)
REFERENCES app.Restaurants (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Orders ADD CONSTRAINT restaurants_orders_fk
FOREIGN KEY (RestaurantId)
REFERENCES app.Restaurants (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.DishesInOrder ADD CONSTRAINT dishes_dishesinorder_fk
FOREIGN KEY (DishId)
REFERENCES app.Dishes (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE app.Orders ADD CONSTRAINT employees_orders_fk
FOREIGN KEY (EmployeeId)
REFERENCES app.Employees (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.Orders ADD CONSTRAINT clients_orders_fk
FOREIGN KEY (ClientId)
REFERENCES app.Clients (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;

ALTER TABLE app.DishesInOrder ADD CONSTRAINT orders_dishesinorder_fk
FOREIGN KEY (OrderId)
REFERENCES app.Orders (Id)
ON DELETE NO ACTION
ON UPDATE NO ACTION
NOT DEFERRABLE;