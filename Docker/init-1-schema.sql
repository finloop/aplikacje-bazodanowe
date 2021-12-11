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

CREATE SEQUENCE app.cuisnes_id_seq;

CREATE TABLE app.Cuisnes (
                Id INTEGER NOT NULL DEFAULT nextval('app.cuisnes_id_seq'),
                Name VARCHAR(50) NOT NULL,
                CONSTRAINT cuisnesid PRIMARY KEY (Id)
);


ALTER SEQUENCE app.cuisnes_id_seq OWNED BY app.Cuisnes.Id;

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


CREATE TABLE app.CuisnesInRestaurants (
                CuisneId INTEGER NOT NULL,
                RestaurantId INTEGER NOT NULL,
                CONSTRAINT cuisnesinrestaurantsid PRIMARY KEY (CuisneId, RestaurantId)
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
                EmployeeId INTEGER DEFAULT NULL,
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

INSERT INTO app.Cuisnes VALUES
(1,'Polska'),
(2,'Meksykańska'),
(3,'Włoska'),
(4,'Pizze'),
(5,'Hamburgery'),
(6,'Sałatki'),
(7,'Fast food'),
(8,'Kebab'),
(9,'Chińska');

INSERT INTO  app.Cities VALUES
(13,'Jarosław'),
(15,'Rzeszów'),
(16,'Warszawa'),
(17,'Poznań'),
(18,'Szczecin'),
(20,'Lublin'),
(21,'Kielce'),
(22,'Wrocław'),
(23,'Katowice'),
(19,'Gdańsk'),
(24,'Radom'),
(25,'Toruń'),
(26,'Kraków'),
(27,'Leszno'),
(28,'Leżajsk'),
(29,'Sosnowiec'),
(30,'Łódź'),
(31,'Białystok'),
(34,'Bydgoszcz');

INSERT INTO app.Address VALUES
(6,13,456,'Szwedzka',11111),
(9,16,1,'Mickiewicza',00001),
(10,15,7,'Akademicka',35550),
(11,18,11,'Architektów',35555),
(17,16,7,'Rzeszowska',40546),
(18,25,87,'Gagarina',85951),
(19,26,5,'Marszałkowska',77965),
(20,27,7,'Witosa',25698),
(21,28,17,'Turkusowa',25425),
(22,29,65,'Jasna',26758),
(23,18,52,'Poznańska',75958),
(24,31,12,'Niemiecka',23568),
(27,34,123,'Lubelska',85963),
(28,23,23,'Francuska',85963),
(29,17,71,'Bydgoska',12546),
(30,18,52,'Austriacka',25368),
(31,13,59,'Turecka',96362),
(32,15,25,'Amerykańska',35085),
(33,25,88,'Sienkiewicza',81666),
(34,18,91,'Słodowa',00123),
(35,16,11,'Katowicka',89020),
(36,29,21,'Chorzowska',21358),
(37,18,15,'Ustronna',25693),
(38,19,15,'Jesienna',55082),
(39,25,85,'Cmentarna',99636),
(40,13,9,'Zamkowa',22685),
(41,16,82,'Podlaska',77441),
(42,18,7,'Podhalańska',99644),
(43,29,9,'Śląska',75955),
(44,16,25,'Karkonoska',22338),
(45,31,8,'Złota',23658);

INSERT INTO app.Clients VALUES
(7,5,'Michał Ptaszyński',11),
(8,6,'Tomasz Górny',17),
(9,7,'Wacław Potocki',18),
(10,8,'Edward Borowiec',19),
(11,9,'Jan Dąbrowski',20),
(12,10,'Janusz Pawlikowski',21),
(13,11,'Ireneusz Wątroba',22),
(14,12,'Urszula Janik',23),
(15,13,'Cecylia Kot',24),
(18,16,'Paweł Jodłowiec',27);

INSERT INTO app.ContactInfo VALUES
(1,'aa@gmail.com',333333333),
(3,'www@gmail.com',123456789),
(4,'piotr@gmail.com',515111111),
(5,'MP@gmail.com',777555333),
(6,'TG@interia.pl',111444777),
(7,'WP@o2.pl',753951852),
(8,'EB@gmail.com',751953555),
(9,'JD@onet.pl',214896325),
(10,'JP@interia.pl',256856854),
(11,'IW@gmail.com',525589965),
(12,'UJ@wp.pl',854753963),
(13,'CK@onet.pl',536298741),
(16,'PJ@onet.pl',123654787),
(17,'sajgon@gmail.com',789888555),
(18,'BurgKing@burgerking.com',758362),
(19,'PizHut@hutpiz.com',125478963),
(20,'Makar@onet.pl',357222333),
(21,'MacTac@gmail.com',777888999),
(22,'War@wp.pl',963555719),
(23,'Man@onet.pl',503070809),
(24,'Zahir@gmail.com',603540000),
(25,'Basia@interia.pl',889955623),
(26,'MichalSum@onet.pl',789523641),
(27,'PawkoJakub@gmail.com',789321852),
(28,'Pat@wp.pl',741236987),
(29,'Jarek@op.pl',852367415),
(30,'Rado@interia.pl',887898998),
(31,'Irek@wp.pl',786934545),
(32,'Edi@o2.pl',457389823),
(33,'Nat@gmail.com',234506723),
(34,'Zuza@o2.pl',258951749);

INSERT INTO app.CuisnesInRestaurants VALUES
(1,2),
(9,3),
(5,4),
(4,5),
(3,6),
(2,7),
(7,8),
(6,9),
(8,10),
(1,11);

INSERT INTO app.Dishes VALUES
(1,'Zupa mleczna',2,11,15),
(2,'Sajgonki',3,10,30),
(3,'King Burger',4,22,60),
(4,'Duża Pizza',5,30,90),
(5,'Carbonara',6,15,20),
(6,'Taco',7,15,15),
(7,'Cheeseburger z frytkami',8,25,15),
(8,'Sałatka jarzynowa',9,10,10),
(9,'Sałatka cesarska',9,15,16),
(10,'Doner Kebab',10,15,5),
(11,'Kebab z baraniną',10,20,5),
(12,'Schabowy z ziemniakami',11,10,20),
(13,'Kapusta kiszona',11,5,2),
(14,'Płatki zbożowe na mleku',2,5,10),
(15,'Kaczka po Pekińsku',3,25,30),
(16,'Kurczak Burger',4,15,18),
(17,'Big King',4,50,30),
(18,'Średnia Pizza',5,20,20),
(19,'Penne ze szpinakiem',6,10,15),
(20,'Tortilla',7,16,10),
(21,'Warsztat Burger',8,30,20);

INSERT INTO app.DishesInOrder VALUES
(1,3,1),
(14,7,1),
(10,6,1),
(11,8,1),
(4,4,1),
(18,9,1),
(8,10,1),
(9,11,1),
(1,7,1),
(11,6,1),
(4,9,5),
(18,12,2),
(4,12,1);

INSERT INTO app.Employees VALUES
(1,4,'Piotr','Krawiec',10),
(2,26,'Michał','Sumiec',37),
(3,27,'Paweł','Jakubowski',38),
(4,28,'Patryk','Michalski',39),
(5,29,'Jarosław','Rogalski',40),
(6,30,'Radosław','Klimczak',41),
(7,31,'Ireneusz','Jeleń',42),
(8,32,'Edyta','Gieroń',43),
(9,33,'Natalia','Gierek',44),
(10,34,'Zuzanna','Górna',45);

INSERT INTO app.Orders VALUES
(3,1,6,2,10,'True','2020-12-11 00:00:00',NULL,'True'),
(4,3,2,5,7,'True','2021-01-03 00:00:00','2021-01-04 00:00:00','True'),
(6,1,NULL,10,10,'True','2021-01-03 00:00:00',NULL,'False'),
(7,4,NULL,2,8,'True','2021-01-03 00:00:00',NULL,'True'),
(8,4,9,10,8,'True','2021-01-03 00:00:00','2021-01-03 00:00:00','True'),
(9,2,2,5,14,'False','2021-01-03 00:00:00',NULL,'False'),
(10,2,7,9,14,'False','2021-01-03 00:00:00',NULL,'True'),
(11,3,NULL,9,7,'True','2021-01-03 00:00:00',NULL,'True'),
(12,1,7,5,14,'True','2021-01-04 00:00:00','2021-01-04 00:00:00','True');

INSERT INTO app.PaymentTypes VALUES
(1,'Karta'),
(2,'Gotówka'),
(3,'Przelew'),
(4,'Prepaid');

INSERT INTO app.Restaurants VALUES
(2,3,'Warszawianka',9),
(3,17,'Ching Chong',28),
(4,18,'Burger King',29),
(5,19,'PizzaHut',30),
(6,20,'Makron',31),
(7,21,'MacoTaco',32),
(8,22,'Warsztat',33),
(9,23,'Manekin',34),
(10,24,'Zahir Kebab',35),
(11,25,'U Basi',36);

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

ALTER TABLE app.CuisnesInRestaurants ADD CONSTRAINT cuisnes_cuisnesinrestaurants_fk
FOREIGN KEY (CuisneId)
REFERENCES app.Cuisnes (Id)
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

ALTER TABLE app.CuisnesInRestaurants ADD CONSTRAINT restaurants_cuisnesinrestaurants_fk
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

ALTER USER postgres SET search_path = app, public;
