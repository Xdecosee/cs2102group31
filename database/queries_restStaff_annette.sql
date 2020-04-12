CREATE EXTENSION "pgcrypto";
CREATE EXTENSION "btree_gist";

DROP TABLE IF EXISTS Promotion CASCADE;
DROP TABLE IF EXISTS FDSpromo CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Restpromo CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Food CASCADE;
DROP TABLE IF EXISTS PaymentOption CASCADE;
DROP TABLE IF EXISTS Orders CASCADE;
DROP TABLE IF EXISTS FromMenu CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS FDSManagers CASCADE;
DROP TABLE IF EXISTS RestaurantStaff CASCADE;
DROP TABLE IF EXISTS Place CASCADE;
DROP TABLE IF EXISTS DeliveryRiders CASCADE;
DROP TABLE IF EXISTS PartTime CASCADE;
DROP TABLE IF EXISTS FullTime CASCADE;
DROP TABLE IF EXISTS WorkingDays CASCADE;
DROP TABLE IF EXISTS ShiftOptions CASCADE;
DROP TABLE IF EXISTS WorkingWeeks CASCADE;
DROP TABLE IF EXISTS Delivers CASCADE; 


CREATE TABLE Promotion ( 
    promoID     uuid PRIMARY KEY ,
    startDate   DATE NOT NULL,
    endDate     DATE NOT NULL,
    discPerc    NUMERIC check(discPerc > 0),
    discAmt     NUMERIC check(discAmt > 0)
);

CREATE TABLE Restaurants ( 
	restaurantID    uuid ,
	name            VARCHAR(100)         NOT NULL,
	location        VARCHAR(255)         NOT NUll,
	minThreshold    INTEGER DEFAULT '0'  NOT NULL,
	PRIMARY KEY (RestaurantID)
);

CREATE TABLE Restpromo (
    promoID     uuid, 
    restID      uuid NOT NULL,
    PRIMARY KEY (promoID),
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE,
    FOREIGN KEY (restID) REFERENCES Restaurants(restaurantID) ON DELETE CASCADE
);

CREATE TABLE Categories (
	category    VARCHAR(100),
	PRIMARY KEY (category)
);

CREATE TABLE Food (
	foodName        VARCHAR(100)         NOT NULL,
	availability    BOOLEAN              DEFAULT TRUE,
	price           NUMERIC              NOT NULL CHECK (price > 0),
	dailyLimit      INTEGER DEFAULT '50' NOT NULL,
	RestaurantID    uuid,
	category        VARCHAR(255)		 NOT NULL,
	PRIMARY KEY (RestaurantID, foodName),
	FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID) ON DELETE CASCADE,
	FOREIGN KEY	(category) REFERENCES Categories (category)
);


CREATE TABLE Orders (
	orderID             uuid ,
	cost                NUMERIC                          NOT NULL,
	date                DATE                              NOT NULL,
	orderStatus         VARCHAR(50) DEFAULT 'Pending'     NOT NULL CHECK (orderStatus in ('Pending','Confirmed','Completed','Failed')), 
	timeOrderPlace      TIME DEFAULT Now(),
	timeDepartFromRest  TIME,
	PRIMARY KEY (orderID)
);

CREATE TABLE FromMenu (
	promoID     uuid,
	quantity        INTEGER      NOT NULL CHECK(quantity>0),
	orderID         uuid         NOT NULL,
	restaurantID    uuid         NOT NULL,
	foodName        VARCHAR(100)    NOT NULL,
	PRIMARY KEY (restaurantID,foodName,orderID),
	FOREIGN KEY (promoID) REFERENCES Restpromo (promoID),
	FOREIGN KEY (orderID) REFERENCES Orders (orderID),
	FOREIGN KEY (restaurantID, foodName) REFERENCES Food (restaurantID, foodName) ON DELETE CASCADE
);

CREATE TABLE Users (
	uid         uuid ,
	name        VARCHAR(255)     NOT NULL,
	username    VARCHAR(255)     UNIQUE NOT NULL,
	password    VARCHAR(255)     NOT NULL,
	type    VARCHAR(255)  NOT NULL CHECK (type in ('Customers', 'FDSManagers', 'RestaurantStaff', 'DeliveryRiders')),
	PRIMARY KEY (uid)
);

CREATE TABLE RestaurantStaff (
	uid         uuid,
	restaurantID    uuid  NOT NULL UNIQUE,
	PRIMARY KEY (uid),
	FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE,
	FOREIGN KEY (restaurantID) REFERENCES Restaurants ON DELETE CASCADE
);

INSERT INTO Users(uid, name, username, password, type) VALUES('0acb2fe9-2e48-483b-b45c-9aa246541fc2', 'Mr Minestrone', 'minestrone', '12345', 'RestaurantStaff');
INSERT INTO Restaurants(restaurantID, name, location) VALUES('3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone King', '313 somerset #B2-05');
INSERT INTO RestaurantStaff(uid, restaurantID) VALUES('0acb2fe9-2e48-483b-b45c-9aa246541fc2', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54');
INSERT INTO Categories(category) VALUES ('Western');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Minestrone Soup', 2.50, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Onion Soup', 3.50, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Mushroom Soup', 3.00, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Corn Soup', 3.20, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Chicken Chop', 4.00, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Pork Chop', 4.20, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Steak', 4.50, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Creamy Pasta', 3.50, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tomato Pasta', 3.00, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Aglio Olio', 3.30, '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Western');

/* Test CONFIRMED ORDERS*/
INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace) VALUES('d8e45424-a546-463f-b302-bfca40d2b2b8', 8.00, '2020-04-12', 'Confirmed', '14:20');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(2, 'd8e45424-a546-463f-b302-bfca40d2b2b8', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'd8e45424-a546-463f-b302-bfca40d2b2b8', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace) VALUES('1a894a3e-0457-4c02-9fe4-e594e3a20983', 8.00, '2020-04-12', 'Confirmed', '14:20');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(2, '1a894a3e-0457-4c02-9fe4-e594e3a20983', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Chicken Chop');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace) VALUES('9dee0c9c-0e8e-448c-8521-8aa19acd3caa', 7.40, '2020-04-12', 'Confirmed', '11:15');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '9dee0c9c-0e8e-448c-8521-8aa19acd3caa', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Corn Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '9dee0c9c-0e8e-448c-8521-8aa19acd3caa', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Pork Chop');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('8dd92efe-b230-483e-b51c-72060f06d581', 8.50, '2020-04-12', 'Confirmed', '12:35', '13:00');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '8dd92efe-b230-483e-b51c-72060f06d581', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '8dd92efe-b230-483e-b51c-72060f06d581', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');

/*TEST COmpleted orders X2 */
INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('8b3f5e8e-aa9a-4923-95ad-8b17b423312f', 11.00, '2019-12-25', 'Completed', '11:00', '11:30');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '8b3f5e8e-aa9a-4923-95ad-8b17b423312f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Steak');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '8b3f5e8e-aa9a-4923-95ad-8b17b423312f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Creamy Pasta');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '8b3f5e8e-aa9a-4923-95ad-8b17b423312f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Tomato Pasta');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('4ed9faf3-8327-4b72-90b9-3bb4c0924bbc', 8.00, '2019-12-26', 'Completed', '10:20', '11:15');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '4ed9faf3-8327-4b72-90b9-3bb4c0924bbc', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Steak');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '4ed9faf3-8327-4b72-90b9-3bb4c0924bbc', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Creamy Pasta');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('94df0d57-9e34-4fcc-b81c-3dc9a16600e8', 4.50, '2019-12-13', 'Completed', '16:00', '16:20');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '94df0d57-9e34-4fcc-b81c-3dc9a16600e8', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Steak');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('f06e1399-0231-4521-aada-c9fb6962d39b', 6.80, '2020-03-10', 'Completed', '10:00', '11:00');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'f06e1399-0231-4521-aada-c9fb6962d39b', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Aglio Olio');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'f06e1399-0231-4521-aada-c9fb6962d39b', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Creamy Pasta');


INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('c13b02b9-e695-4d27-9206-62fe6458b77f', 20.40, '2020-01-15', 'Completed', '18:30', '19:00');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Corn Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Chicken Chop');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'c13b02b9-e695-4d27-9206-62fe6458b77f', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Pork Chop');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('a6c631be-4b45-4257-abbd-5292edf27543', 16.20, '2020-01-25', 'Completed', '12:30', '13:00');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'a6c631be-4b45-4257-abbd-5292edf27543', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'a6c631be-4b45-4257-abbd-5292edf27543', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'a6c631be-4b45-4257-abbd-5292edf27543', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'a6c631be-4b45-4257-abbd-5292edf27543', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Corn Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'a6c631be-4b45-4257-abbd-5292edf27543', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Chicken Chop');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('771d98d6-5915-4fd0-ad9d-66557fa9a849', 12.20, '2020-01-06', 'Completed', '10:11', '10:35');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '771d98d6-5915-4fd0-ad9d-66557fa9a849', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '771d98d6-5915-4fd0-ad9d-66557fa9a849', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '771d98d6-5915-4fd0-ad9d-66557fa9a849', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '771d98d6-5915-4fd0-ad9d-66557fa9a849', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Corn Soup');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('aba69107-26a7-4aeb-8d28-d6dfdcf2c9e9', 9.00, '2020-01-01', 'Completed', '15:30', '16:00');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'aba69107-26a7-4aeb-8d28-d6dfdcf2c9e9', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'aba69107-26a7-4aeb-8d28-d6dfdcf2c9e9', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, 'aba69107-26a7-4aeb-8d28-d6dfdcf2c9e9', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Mushroom Soup');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('72ce2416-1220-4658-8347-28c00a80e3ae', 6.00, '2020-01-13', 'Completed', '20:00', '20:30');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '72ce2416-1220-4658-8347-28c00a80e3ae', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '72ce2416-1220-4658-8347-28c00a80e3ae', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Onion Soup');

INSERT INTO Orders(orderID, cost, date, orderStatus, timeOrderPlace, timeDepartFromRest) VALUES('40304577-4fd5-4610-80a2-7c6c8473f07d', 2.50, '2020-01-30', 'Completed', '22:00', '22:30');
INSERT INTO FromMenu(quantity, orderID, restaurantID, foodName) VALUES(1, '40304577-4fd5-4610-80a2-7c6c8473f07d', '3f5c7ba1-01b1-4c9d-887f-28966f06ed54', 'Minestrone Soup');


/*

//CONFIRMED ORDERS - OK
SELECT DISTINCT FM.orderID, O.date, O.timeOrderPlace, FM.FoodName, FM.quantity
FROM Orders O
INNER JOIN FromMenu FM on O.orderID = FM.orderID
WHERE O.orderStatus = 'Confirmed'
AND O.timeDepartFromRest IS NULL
AND FM.restaurantID = $1
ORDER BY O.date, O.timeOrderPlace, FM.orderID;

//Total Orders Completed/ Total Cost - OK
SELECT year, month, COUNT(orderID) AS totalorders, SUM(cost)
FROM (SELECT DISTINCT EXTRACT(Year FROM (O.date)) AS year,  to_char(O.date, 'Month') as month, O.orderid, O.cost
FROM Orders O
INNER JOIN FromMenu FM on O.orderID = FM.orderID
WHERE O.orderStatus = 'Completed'
AND FM.restaurantID = '3f5c7ba1-01b1-4c9d-887f-28966f06ed54') TMP
GROUP BY year, month
ORDER BY year DESC, to_date(month, 'Month’) DESC;

//Top 5 favourite food - 'Completed' Orders - OK
With FoodOrders as ( 
SELECT EXTRACT(Year FROM (O.date)) AS year,  to_char(O.date, 'Month') as month,  FM.foodName as food, SUM(FM.quantity) as totalOrders
FROM FromMenu FM
INNER JOIN Orders O on FM.orderID = O.orderID
WHERE O.orderStatus = 'Completed'
AND FM.restaurantID = $1
GROUP BY EXTRACT(Year FROM (O.date)),  to_char(O.date, 'Month'), FM.foodName
)

SELECT DISTINCT * FROM (
	SELECT year, month, to_date(month, 'Month’) as month2, food, totalOrders, row_number() OVER (PARTITION BY year, month) as rownum FROM FoodOrders
)Tmp
WHERE rownum < 6
ORDER BY year DESC, month2 DESC, totalOrders DESC;
*/
