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

CREATE TABLE FDSpromo (
    promoID     uuid,
    PRIMARY KEY (promoID),
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE
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
	/*THIS PART*/
	FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID) ON DELETE CASCADE,
	FOREIGN KEY	(category) REFERENCES Categories (category)
);

CREATE TABLE PaymentOption (
    payOption   VARCHAR(100),
    PRIMARY KEY (payOption)
);

CREATE TABLE Orders (
	orderID             uuid ,
	deliveryFee         INTEGER                           DEFAULT 3,
	cost                INTEGER                           NOT NULL,
	location            VARCHAR(255)                      NOT NULL,
	date                DATE                              NOT NULL,
	payOption	    	VARCHAR(50)			    		  NOT NULL,
	orderStatus         VARCHAR(50) DEFAULT 'Pending'     NOT NULL CHECK (orderStatus in ('Pending','Confirmed','Completed','Failed')),
	deliveryDuration    VARCHAR(50)     				  NOT NULL,
	timeOrderPlace      TIME DEFAULT Now(),
	timeDepartToRest    TIME,
	timeArriveRest      TIME,
	timeDepartFromRest  TIME,
	timeOrderDelivered  TIME,
	PRIMARY KEY (orderID),
	FOREIGN KEY (payOption) REFERENCES PaymentOption (payOption)
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

CREATE TABLE Customers (
	uid         uuid,
	rewardPts   INTEGER DEFAULT '0' NOT NULL,
	signUpDate  DATE    DEFAULT Now() NOT NULL,
	cardDetails VARCHAR(255),
	PRIMARY KEY (uid),
	FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE FDSManagers (
	uid         uuid,
	PRIMARY KEY (uid),
	FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE RestaurantStaff (
	uid         uuid,
	restaurantID    uuid  NOT NULL UNIQUE,
	PRIMARY KEY (uid),
	FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE,
	FOREIGN KEY (restaurantID) REFERENCES Restaurants ON DELETE CASCADE
);

CREATE TABLE Place (
	uid            uuid,
	orderid        uuid,  
	review         VARCHAR(255)     NOT NULL,
	star           INTEGER      DEFAULT NULL CHECK (star >= 0 AND star <= 5), 
	promoid        uuid,
	PRIMARY KEY (orderid),
	FOREIGN KEY (uid) REFERENCES Customers ON DELETE CASCADE,
	FOREIGN KEY (promoID) REFERENCES FDSpromo(promoID) ON DELETE CASCADE,
	FOREIGN KEY (orderid) REFERENCES Orders ON DELETE CASCADE
);

CREATE TABLE DeliveryRiders (
    uid             uuid PRIMARY KEY,
	baseDeliveryFee NUMERIC NOT NULL DEFAULT 2,
	type    VARCHAR(255)  NOT NULL CHECK (type in ('FullTime', 'PartTime')),
    FOREIGN KEY (uid) REFERENCES Users(uid) ON DELETE CASCADE
);

CREATE TABLE PartTime (
	uid             uuid PRIMARY KEY,
	weeklyBasePay   NUMERIC NOT NULL DEFAULT 100, /* $10 times minimum 10 hours in each WWS*/
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

CREATE TABLE FullTime (
	uid              uuid PRIMARY KEY,
	monthlyBasePay   INTEGER NOT NULL DEFAULT 1800,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

CREATE TABLE  WorkingDays(
	uid             uuid,
	workDate        DATE NOT NULL,
	intervalStart   TIME NOT NULL,
	intervalEnd     TIME NOT NULL,
	numCompleted	INTEGER DEFAULT 0,
	PRIMARY KEY (uid, workDate, intervalStart, intervalEnd),
	FOREIGN KEY (uid) REFERENCES PartTime(uid) ON DELETE CASCADE,
	CHECK (intervalEnd > intervalStart),
	CHECK (intervalStart>='10:00:00' and intervalEnd<='22:00:00'),
	CHECK (CAST(CONCAT(CAST(EXTRACT(HOUR from intervalStart) AS VARCHAR),':00:00') AS TIME)=intervalStart),
	CHECK (CAST(CONCAT(CAST(EXTRACT(HOUR from intervalEnd) AS VARCHAR),':00:00') AS TIME)=intervalEnd),
	CHECK (EXTRACT(HOUR FROM intervalEnd) - EXTRACT(HOUR FROM intervalStart)<=4)
);

CREATE TABLE ShiftOptions (
	shiftID         INTEGER, 
	shiftDetail1    VARCHAR(30) NOT NULL,
	shiftDetail2    VARCHAR(30) NOT NULL,
	PRIMARY KEY (shiftID)
);

CREATE TABLE  WorkingWeeks (
	uid             uuid,
	workDate        DATE NOT NULL,
	shiftID         INTEGER NOT NULL,
	numCompleted	INTEGER DEFAULT 0,
	PRIMARY KEY (uid, workDate),
	FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE,
	FOREIGN KEY (shiftID) REFERENCES ShiftOptions(shiftID)
);


CREATE TABLE Delivers (
    orderID         uuid,
    uid             uuid,
    rating          INTEGER      DEFAULT NULL CHECK (rating >= 0 AND rating <= 5), 
    PRIMARY KEY (orderID,uid),
    FOREIGN KEY (orderID) REFERENCES Orders(orderID) ON DELETE CASCADE,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);


/* Insert Data for Users*/
INSERT INTO Users (uid, name, username, password, type) VALUES ('3c3e0d34-c815-4d80-8058-9eaab0669f39', 'Alano', 'asunock0', 'SuKnMdGlSZv', 'Customers');
INSERT INTO Users (uid, name, username, password, type) VALUES ('6053f822-eb74-43cc-bb5f-5f7d839cb774', 'Ugo', 'uhumphery5', 'zzWtpV6x1W5', 'Customers');
INSERT INTO Users (uid, name, username, password, type) VALUES ('73bfb94d-4f90-4440-a2e8-2c35630fd318', 'Theo', 'tadkina', 'mXQVb8fG', 'Customers');
INSERT INTO Users (uid, name, username, password, type) VALUES ('694ab979-fad3-4f6b-8394-f4167cc74f01', 'Jocelyn', 'jdodshund', '8XnPDwZN', 'Customers');
INSERT INTO Users (uid, name, username, password, type) VALUES ('e9badf36-bfc1-4ee3-8bb4-b44565cfb4f7', 'Paddie', 'ppaulline', 'Ake9PyGlLEh6', 'Customers');

INSERT INTO Users (uid, name, username, password, type) VALUES ('7893fd85-41f3-4481-8d7d-dfb953266140', 'Ariela', 'arodolfi1', '6W8jV0Un', 'RestaurantStaff');
INSERT INTO Users (uid, name, username, password, type) VALUES ('c8103a4e-4bac-486f-8003-5294a0c46293', 'Kitti', 'kbelding6', 'CDvLeT', 'RestaurantStaff');
INSERT INTO Users (uid, name, username, password, type) VALUES ('6eb1f6d8-6765-4eb9-a208-69c6159cb51d', 'Antony', 'aclausenthue4', 'LS5CtMmb', 'RestaurantStaff');

INSERT INTO Users (uid, name, username, password, type) VALUES ('540028e9-0e27-44e6-aa4b-db1960e5962b', 'Taddeusz', 'tmanketell2', 'PjIpgl7J', 'FDSManagers');
INSERT INTO Users (uid, name, username, password, type) VALUES ('3dd244b6-257b-4208-90e8-4b98897cd314', 'Dodie', 'dfermerb', 'SLKtg2Q7kGn', 'FDSManagers');

INSERT INTO Users (uid, name, username, password, type) VALUES ('d15945e8-42e9-4e00-a1fc-c5858260465f','Adrea', 'aveldens3', 'cdqUwd81YzX', 'DeliveryRiders');
INSERT INTO Users (uid, name, username, password, type) VALUES ('50c834fa-6f90-40b2-9308-93d948ba589c', 'Adan', 'alaise7', 'blVy4LzR', 'DeliveryRiders');
INSERT INTO Users (uid, name, username, password, type) VALUES ('f99f2870-c8fa-43fd-96ed-9ecbea1eb11d', 'Elenore', 'epiatto8', 'jiWxXTs4Jjp', 'DeliveryRiders');
INSERT INTO Users (uid, name, username, password, type) VALUES ('f8f75acf-89ed-4d88-b036-24101928607d', 'Gary', 'gtarrier9', 'G92FSUJuvL9e', 'DeliveryRiders');
INSERT INTO Users (uid, name, username, password, type) VALUES ('8205c525-bf60-485a-ab24-93cb3aaae5cd', 'Oona', 'oprevettc', 'xeLkYRLNSkJ', 'DeliveryRiders');


/* Insert Data for Customers*/
INSERT INTO Customers(uid,cardDetails) VALUES ('3c3e0d34-c815-4d80-8058-9eaab0669f39','3560449280162335');
INSERT INTO Customers(uid,cardDetails) VALUES ('6053f822-eb74-43cc-bb5f-5f7d839cb774','201863401712888');
INSERT INTO Customers(uid,cardDetails) VALUES ('73bfb94d-4f90-4440-a2e8-2c35630fd318','3564256576222368');
INSERT INTO Customers(uid,cardDetails) VALUES ('694ab979-fad3-4f6b-8394-f4167cc74f01',NULL);
INSERT INTO Customers(uid,cardDetails) VALUES ('e9badf36-bfc1-4ee3-8bb4-b44565cfb4f7',NULL);

/* Insert Data for FDSManager*/
INSERT INTO FDSManagers(uid) VALUES ('540028e9-0e27-44e6-aa4b-db1960e5962b');
INSERT INTO FDSManagers(uid) VALUES ('3dd244b6-257b-4208-90e8-4b98897cd314');

/* Insert Data for Riders */ 
INSERT INTO DeliveryRiders(uid, type) VALUES ('d15945e8-42e9-4e00-a1fc-c5858260465f', 'FullTime');
INSERT INTO DeliveryRiders(uid, type) VALUES ('50c834fa-6f90-40b2-9308-93d948ba589c', 'FullTime');
INSERT INTO DeliveryRiders(uid, type) VALUES ('f99f2870-c8fa-43fd-96ed-9ecbea1eb11d', 'FullTime');
INSERT INTO DeliveryRiders(uid, type) VALUES ('f8f75acf-89ed-4d88-b036-24101928607d', 'PartTime');
INSERT INTO DeliveryRiders(uid, type) VALUES ('8205c525-bf60-485a-ab24-93cb3aaae5cd', 'PartTime');

INSERT INTO FullTime(uid) VALUES ('d15945e8-42e9-4e00-a1fc-c5858260465f');
INSERT INTO FullTime(uid) VALUES ('50c834fa-6f90-40b2-9308-93d948ba589c');
INSERT INTO FullTime(uid) VALUES ('f99f2870-c8fa-43fd-96ed-9ecbea1eb11d');
INSERT INTO PartTime(uid) VALUES ('f8f75acf-89ed-4d88-b036-24101928607d');
INSERT INTO PartTime(uid) VALUES ('8205c525-bf60-485a-ab24-93cb3aaae5cd');

/*Insert Shifts for Full Time Schedule */
INSERT INTO ShiftOptions(shiftID, shiftDetail1, shiftDetail2) VALUES (1, '10am-2pm','3pm-7pm');
INSERT INTO ShiftOptions(shiftID, shiftDetail1, shiftDetail2) VALUES (2, '11am-3pm','4pm-8pm');
INSERT INTO ShiftOptions(shiftID, shiftDetail1, shiftDetail2) VALUES (3, '12pm-4pm','5pm-9pm');
INSERT INTO ShiftOptions(shiftID, shiftDetail1, shiftDetail2) VALUES (4, '1pm-5pm','6pm-10pm');

/*Insert Schedule for Riders */
INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd, numCompleted) VALUES('f8f75acf-89ed-4d88-b036-24101928607d', '2020-01-08', '11:00', '15:00', 10);
INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd, numCompleted) VALUES('f8f75acf-89ed-4d88-b036-24101928607d', '2020-03-20', '16:00', '20:00', 10);
INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd, numCompleted) VALUES('f8f75acf-89ed-4d88-b036-24101928607d', '2020-04-20', '16:00', '20:00', 10);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES('d15945e8-42e9-4e00-a1fc-c5858260465f', '2020-01-08', 3, 13);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES('d15945e8-42e9-4e00-a1fc-c5858260465f', '2020-01-09', 1, 15);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES('d15945e8-42e9-4e00-a1fc-c5858260465f', '2020-03-15', 1, 15);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES('d15945e8-42e9-4e00-a1fc-c5858260465f', '2020-04-20', 3, 15);

/* Insert Data for restaurants */
INSERT INTO Restaurants (restaurantID, name, location, minThreshold) VALUES ('70500444-ad6b-4bad-926f-b2d0de01f6db', 'Noma', '14 Texas Plaza', 6);
INSERT INTO Restaurants (restaurantID, name, location, minThreshold) VALUES ('6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Odette', '240 Vernon Hill', 7);
INSERT INTO Restaurants (restaurantID, name, location, minThreshold) VALUES ('85fc4ba8-fe52-4a40-9504-66663d3660c1', 'Wolfgang Puck', '90 Mcguire Crossing', 7);

/* Insert Data for categories */
INSERT INTO Categories(category) VALUES ('Malay Cuisine');
INSERT INTO Categories(category) VALUES ('Chinese Cuisine');
INSERT INTO Categories(category) VALUES ('Indian Cuisine');
INSERT INTO Categories(category) VALUES ('Japanese Cuisine');
INSERT INTO Categories(category) VALUES ('Korean Cuisine');

/* Insert Data for food */
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Nasi Briyani', 12.9, '70500444-ad6b-4bad-926f-b2d0de01f6db', 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tandoori Chicken', 22.8, '70500444-ad6b-4bad-926f-b2d0de01f6db', 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Butter Chicken', 27.3, '70500444-ad6b-4bad-926f-b2d0de01f6db', 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tikka Masala', 27.8, '70500444-ad6b-4bad-926f-b2d0de01f6db', 'Indian Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Ayam Penyet', 5.0, '85fc4ba8-fe52-4a40-9504-66663d3660c1', 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Gado Gado', 13.0, '85fc4ba8-fe52-4a40-9504-66663d3660c1', 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Lontong', 6.3, '85fc4ba8-fe52-4a40-9504-66663d3660c1', 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Nasi Lemak', 9.2, '85fc4ba8-fe52-4a40-9504-66663d3660c1', 'Malay Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Sushi', 29.9, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Japanese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tempura', 19.7, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Japanese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Char Siew Ramen', 8.5, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Japanese Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tteokbokki', 14.9, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Korean Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Kimchi Fried Rice', 10.5, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Korean Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Yang Zhou Fried Rice', 21.1, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Sweet and Sour Pork', 20.6, '6fcfcc21-f44d-4fe1-a920-d13440a8c334', 'Chinese Cuisine');

/* Insert Data for Restaurantstaff link to rest*/
INSERT INTO RestaurantStaff (uid,restaurantID) VALUES ('7893fd85-41f3-4481-8d7d-dfb953266140','70500444-ad6b-4bad-926f-b2d0de01f6db');
INSERT INTO RestaurantStaff (uid,restaurantID) VALUES ('c8103a4e-4bac-486f-8003-5294a0c46293','6fcfcc21-f44d-4fe1-a920-d13440a8c334');
INSERT INTO RestaurantStaff (uid,restaurantID) VALUES ('6eb1f6d8-6765-4eb9-a208-69c6159cb51d','85fc4ba8-fe52-4a40-9504-66663d3660c1');

/* Insert Data for Promo */
INSERT INTO Promotion (promoID, startDate,endDate,discPerc,discAmt) VALUES ('f7452026-1814-4df6-b64c-d50468f53a48','2020-02-01','2020-02-28',NULL,5);
INSERT INTO Promotion (promoID, startDate,endDate,discPerc,discAmt) VALUES ('13572c4d-3970-4ddf-b416-7f3e62e3ab86','2020-03-01','2020-05-30',0.2,NULL);
INSERT INTO Promotion (promoID, startDate,endDate,discPerc,discAmt) VALUES ('fd7fb708-519a-4348-82d5-2cdb112cd9dc','2020-03-01','2020-05-30',NULL,5);
INSERT INTO Promotion (promoID, startDate,endDate,discPerc,discAmt) VALUES ('82972390-fa42-4243-a00f-5d8b078c3aaf','2020-03-01','2020-05-30',0.2,NULL);
INSERT INTO Promotion (promoID, startDate,endDate,discPerc,discAmt) VALUES ('0f754981-6832-44f5-8bc4-4d17eac2673b','2020-06-01','2020-07-01',0.2,NULL);

/* Insert Data for promorest (link to promo)*/
INSERT INTO Restpromo (promoID,restID) VALUES ('13572c4d-3970-4ddf-b416-7f3e62e3ab86','70500444-ad6b-4bad-926f-b2d0de01f6db');
INSERT INTO Restpromo (promoID,restID) VALUES ('fd7fb708-519a-4348-82d5-2cdb112cd9dc','70500444-ad6b-4bad-926f-b2d0de01f6db');
INSERT INTO Restpromo (promoID,restID) VALUES ('0f754981-6832-44f5-8bc4-4d17eac2673b','6fcfcc21-f44d-4fe1-a920-d13440a8c334');

/* Insert Data for promofds (link to promo)*/
INSERT INTO FDSpromo (promoID) VALUES ('f7452026-1814-4df6-b64c-d50468f53a48');
INSERT INTO FDSpromo (promoID) VALUES ('82972390-fa42-4243-a00f-5d8b078c3aaf');


/* Insert Data into Payment Option */
INSERT INTO PaymentOption(payOption) VALUES ('Cash');
INSERT INTO PaymentOption(payOption) VALUES ('Credit');

/* Insert Data into orders and fromMenue think of how to make it happen*/ 
/* Order 1: Confirmed */
INSERT INTO Orders(orderID,cost,location,date,deliveryDuration,payOption) VALUES ('3572e685-81c6-432d-8175-dcff6d0f7363',0,'81 Goodland Road','2020-04-20',0,'Cash'); /* let cost be initially deffered*/
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (NULL,1,'3572e685-81c6-432d-8175-dcff6d0f7363','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Tteokbokki');
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (NULL,1,'3572e685-81c6-432d-8175-dcff6d0f7363','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Kimchi Fried Rice');   
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (NULL,2,'3572e685-81c6-432d-8175-dcff6d0f7363','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Yang Zhou Fried Rice');        
/* Insert data into place */
INSERT INTO Place (uid,orderID,review,star,promoid) VALUES ('3c3e0d34-c815-4d80-8058-9eaab0669f39','3572e685-81c6-432d-8175-dcff6d0f7363','no comments',5,'f7452026-1814-4df6-b64c-d50468f53a48');

UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = '3572e685-81c6-432d-8175-dcff6d0f7363') WHERE orderID = '3572e685-81c6-432d-8175-dcff6d0f7363'; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = '3572e685-81c6-432d-8175-dcff6d0f7363' LIMIT 1)) WHERE orderID = '3572e685-81c6-432d-8175-dcff6d0f7363'; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = '3572e685-81c6-432d-8175-dcff6d0f7363' LIMIT 1) WHERE orderID = '3572e685-81c6-432d-8175-dcff6d0f7363'; /*For amt promo*/

UPDATE Orders SET orderStatus = 'Confirmed' WHERE orderID = '3572e685-81c6-432d-8175-dcff6d0f7363';
UPDATE Orders SET timeDepartToRest = '21:05:00' WHERE orderID = '3572e685-81c6-432d-8175-dcff6d0f7363';

/*Order 2: Completed by .... */
INSERT INTO Orders(orderID,cost,location,date,deliveryDuration,payOption) VALUES ('39ab1c25-b912-4800-a920-0434af1b6218',0,'346 Dennis Trail','2020-01-28',0,'Credit'); /* let cost be initially deffered*/
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES ('0f754981-6832-44f5-8bc4-4d17eac2673b',1,'39ab1c25-b912-4800-a920-0434af1b6218','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Tteokbokki');
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES ('0f754981-6832-44f5-8bc4-4d17eac2673b',1,'39ab1c25-b912-4800-a920-0434af1b6218','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Sushi');   
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES ('0f754981-6832-44f5-8bc4-4d17eac2673b',3,'39ab1c25-b912-4800-a920-0434af1b6218','6fcfcc21-f44d-4fe1-a920-d13440a8c334','Yang Zhou Fried Rice');        
/* Insert data into place */
INSERT INTO Place (uid,orderID,review,star) VALUES ('3c3e0d34-c815-4d80-8058-9eaab0669f39','39ab1c25-b912-4800-a920-0434af1b6218','Nice food',4);

UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = '39ab1c25-b912-4800-a920-0434af1b6218') WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218'; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = '39ab1c25-b912-4800-a920-0434af1b6218' LIMIT 1)) WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218'; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = '39ab1c25-b912-4800-a920-0434af1b6218' LIMIT 1) WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218'; /*For amt promo*/

UPDATE Orders SET orderStatus = 'Completed' WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218';
UPDATE Orders SET timeDepartToRest = '21:00:00' WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218';
UPDATE Orders SET timeArriveRest = '21:15:00' WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218';
UPDATE Orders SET timeDepartFromRest = '21:30:00' WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218';
UPDATE Orders SET timeOrderDelivered = '21:45:00'  WHERE orderID = '39ab1c25-b912-4800-a920-0434af1b6218';


/* Insert Data into delivers */
INSERT INTO Delivers (orderID,uid,rating) VALUES ('3572e685-81c6-432d-8175-dcff6d0f7363','f8f75acf-89ed-4d88-b036-24101928607d',2);
INSERT INTO Delivers (orderID,uid,rating) VALUES ('39ab1c25-b912-4800-a920-0434af1b6218','d15945e8-42e9-4e00-a1fc-c5858260465f',5);



/* Add back column id default*/
/*
ALTER TABLE Users ALTER COLUMN uid SET DEFAULT gen_random_uuid();
ALTER TABLE Restaurants ALTER COLUMN restaurantID SET DEFAULT gen_random_uuid();
ALTER TABLE Promotion ALTER COLUMN promoID SET DEFAULT gen_random_uuid();
ALTER TABLE Orders ALTER COLUMN orderID SET DEFAULT gen_random_uuid();
*/


/* Create views */

/*PARTTIME. Consolidate shows for each parttime rider, how many weeks they actually worked in a month (If they
work one day in a week, it will be counted in totalWeeksWorked) and how many deliveries completed in a month */
CREATE VIEW ConsolidateP AS (
SELECT distinct P1.uid as pUid, 
P1.weeklyBasePay as pBasePay, 
EXTRACT(YEAR FROM WD1.workDate) as pYear, 
EXTRACT(Month FROM WD1.workDate) as pMonth,
count( distinct EXTRACT(WEEK FROM WD1.workDate)) as totalWeeksWorked, 
sum(WD1.numCompleted) as pComplete
FROM PartTime P1
INNER JOIN WorkingDays WD1 on P1.uid = WD1.uid
WHERE WD1.numCompleted > 0 /**Filter out weeks without any worked days at all for count(Extract(WEEK FROM WD.workDate))**/
GROUP BY P1.uid, EXTRACT(YEAR FROM WD1.workDate), EXTRACT(Month FROM WD1.workDate)
);

/*FULLTIME. ConsolidateF shows for each fulltime rider, how many months they actually worked (even if they worked one day in a month) 
and how many deliveries completed in a month */
CREATE VIEW ConsolidateF AS (
SELECT distinct F1.uid as fUid,
F1.monthlyBasePay as fBasePay,
EXTRACT(YEAR FROM WW1.workDate) as fYear,
EXTRACT(MONTH FROM WW1.workDate) as fMonth,
sum(WW1.numCompleted) as fCompleted
FROM FullTime F1
INNER JOIN WorkingWeeks WW1 on F1.uid = WW1.uid
WHERE WW1.numCompleted > 0  /**Filter out months without any worked days at all**/
GROUP BY F1.uid, EXTRACT(YEAR FROM WW1.workDate), EXTRACT(MONTH FROM WW1.workDate) 
);

CREATE VIEW workDetails AS(
SELECT DISTINCT p.uid as uid,
		EXTRACT(YEAR FROM WD.workDate) as year, 
        EXTRACT(Month FROM WD.workDate) as month, 
        sum(DATE_PART('hour', WD.intervalEnd - WD.intervalStart)) as totalHours,
		sum(WD.numCompleted) as numCompleted
FROM PartTime P INNER JOIN WorkingDays WD USING (uid) 
WHERE WD.numCompleted > 0 
GROUP BY P.uid, EXTRACT(YEAR FROM WD.workDate), EXTRACT(Month FROM WD.workDate)
UNION
SELECT distinct F.uid as uid,
		EXTRACT(YEAR FROM WW.workDate) as year, 
		EXTRACT(Month FROM WW.workDate) as month, 
		count(shiftID) * 8 as totalHours,
		sum(WW.numCompleted) as numCompleted
FROM FullTime F INNER JOIN WorkingWeeks WW USING (uid) 
WHERE WW.numCompleted > 0 
GROUP BY F.uid, EXTRACT(YEAR FROM WW.workDate), EXTRACT(Month FROM WW.workDate)
);

CREATE VIEW driverSalary AS (
SELECT CP.puid as uid,
	   CP.pYear as year, 
       CP.pMonth as month, 
       CP.pComplete * DR.baseDeliveryFee + CP.totalWeeksWorked * CP.pBasePay as monthSalary 
FROM ConsolidateP CP RIGHT JOIN DeliveryRiders DR on DR.uid = CP.pUid 
UNION
SELECT CF.fuid as uid,
       CF.fYear as year, 
       CF.fMonth as month, 
       CF.fCompleted * DR.baseDeliveryFee + CF.fBasePay as monthSalary 
FROM DeliveryRiders DR LEFT JOIN ConsolidateF CF on DR.uid = CF.fUid 
);

/* Triggers */

/*Update delivery rider number of complete orders after order completion*/
CREATE OR REPLACE FUNCTION update_bonus()
RETURNS TRIGGER AS $$
DECLARE currStatus VARCHAR(50);
DECLARE riderId uuid;
DECLARE riderType VARCHAR(255);
DECLARE dateO DATE;
DECLARE timeO TIME;

BEGIN
    currStatus := NEW.orderStatus;
	dateO := NEW.date;
	timeO := NEW.timeOrderPlace;

    SELECT uid INTO riderId
    FROM Delivers
    WHERE NEW.orderid = Delivers.orderid;

    SELECT type INTO riderType
    FROM DeliveryRiders
    WHERE riderId = DeliveryRiders.uid;

    IF (currStatus = 'Completed') THEN
        IF (riderType = 'FullTime') THEN
            UPDATE WorkingWeeks
            SET numCompleted = numCompleted + 1
            WHERE riderId = WorkingWeeks.uid
			AND dateO = WorkingWeeks.workDate;
        ELSIF (riderType = 'PartTime') THEN
            UPDATE WorkingDays 
            SET numCompleted = numCompleted + 1
            WHERE riderId = WorkingDays.uid
			AND dateO = WorkingDays.workDate
			AND timeO >= WorkingDays.intervalStart
			AND timeO <= WorkingDays.intervalEnd;
        END IF;
    END IF;
    RETURN NULL;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER bonus_trigger
AFTER UPDATE of orderStatus ON Orders
FOR EACH ROW
EXECUTE PROCEDURE update_bonus();