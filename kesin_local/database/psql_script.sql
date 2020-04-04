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

CREATE TABLE Restaurants ( 
	restaurantID    INTEGER GENERATED ALWAYS AS IDENTITY,
	name            VARCHAR(100)         NOT NULL,
	location        VARCHAR(255)         NOT NUll,
	minThreshold    INTEGER DEFAULT '0'  NOT NULL,
	PRIMARY KEY (RestaurantID)
);

CREATE TABLE Promotion (
    promoID     INTEGER GENERATED ALWAYS AS IDENTITY,
    startDate   DATE NOT NULL,
    endDate     DATE NOT NULL,
    discPerc    NUMERIC check(discPerc > 0) DEFAULT NULL,
    discAmt     NUMERIC check(discAmt > 0) DEFAULT NULL,
	restaurantID INTEGER,
	type    	VARCHAR(255) NOT NULL CHECK (type in ('FDSpromo', 'Restpromo')),
	PRIMARY KEY (promoID),
	FOREIGN KEY (restaurantID) REFERENCES Restaurants(restaurantID) ON DELETE CASCADE
);

CREATE TABLE FDSpromo (
    promoID     INTEGER,
    PRIMARY KEY (promoID),
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE
);

CREATE TABLE Restpromo (
    promoID     INT, 
    restID      INT NOT NULL,
    PRIMARY KEY (promoID),
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE,
    FOREIGN KEY (restID) REFERENCES Restaurants(restaurantID) ON DELETE CASCADE
);

CREATE TABLE Categories (
	category    VARCHAR(100),
	PRIMARY KEY (category)
);

CREATE TABLE Food ( --availability removed
	foodName        VARCHAR(100)         NOT NULL,
	price           NUMERIC              NOT NULL CHECK (price > 0),
	dailyLimit      INTEGER DEFAULT '50' NOT NULL,
	RestaurantID    INTEGER,
	category        VARCHAR(255)		 NOT NULL,
	PRIMARY KEY (RestaurantID, foodName),
	FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID) ON DELETE CASCADE,
	FOREIGN KEY	(category) REFERENCES Categories (category)
);

CREATE TABLE PaymentOption (
    payOption   VARCHAR(100),
    PRIMARY KEY (payOption)
);

CREATE TABLE Orders ( --deliveryfee not useful
	orderID             INT GENERATED ALWAYS AS IDENTITY,
	deliveryFee         INTEGER                           NOT NULL DEFAULT 4,
	cost                INTEGER      DEFAULT 0            NOT NULL,
	location            VARCHAR(255)                      NOT NULL,
	date                DATE DEFAULT CURRENT_DATE         NOT NULL,
	payOption	    	VARCHAR(50)			    		  NOT NULL,
	orderStatus         VARCHAR(50) DEFAULT 'Pending'     NOT NULL CHECK (orderStatus in ('Pending','Confirmed','Completed','Failed')),
	deliveryDuration    INTEGER  DEFAULT 0				  NOT NULL,
	timeOrderPlace      TIME DEFAULT CURRENT_TIME,
	timeDepartToRest    TIME,
	timeArriveRest      TIME,
	timeDepartFromRest  TIME,
	timeOrderDelivered  TIME,
	PRIMARY KEY (orderID),
	FOREIGN KEY (payOption) REFERENCES PaymentOption (payOption)
);

CREATE TABLE FromMenu (--
	promoID     INT,
	quantity        INTEGER      NOT NULL,
	orderID         INT         NOT NULL,
	restaurantID    INTEGER         NOT NULL,
	foodName        VARCHAR(100)    NOT NULL,
	PRIMARY KEY (restaurantID,foodName,orderID),
	FOREIGN KEY (promoID) REFERENCES Restpromo (promoID),
	FOREIGN KEY (orderID) REFERENCES Orders (orderID),
	FOREIGN KEY (restaurantID, foodName) REFERENCES Food (restaurantID, foodName) ON DELETE CASCADE
);

CREATE TABLE Users (
	uid         INT GENERATED ALWAYS AS IDENTITY,
	name        VARCHAR(255)     NOT NULL,
	username    VARCHAR(255)     NOT NULL,
	password    VARCHAR(255)     NOT NULL,
	cardDetails VARCHAR(255) DEFAULT NULL,
	restaurantID INT DEFAULT NULL,
	riderType  VARCHAR(255) CHECK (type in ('FullTime', 'PartTime', NULL)) ,
	type    VARCHAR(255) NOT NULL CHECK (type in ('Customers', 'FDSManagers', 'RestaurantStaff', 'DeliveryRiders')), 
	UNIQUE (uid, cardDetails),
	UNIQUE (uid, restaurantID),
	UNIQUE (uid, riderType),
	PRIMARY KEY (uid)
);

CREATE TABLE Customers ( --
	uid         INTEGER,
	rewardPts   INTEGER DEFAULT '0' NOT NULL,
	signUpDate  DATE    DEFAULT CURRENT_DATE NOT NULL,
	cardDetails VARCHAR(255),
	PRIMARY KEY (uid),
	FOREIGN KEY (uid, cardDetails) REFERENCES Users(uid, cardDetails) ON DELETE CASCADE
);

CREATE TABLE FDSManagers (
	uid         INTEGER,
	PRIMARY KEY (uid),
	FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE RestaurantStaff (
	uid         INTEGER,
	restaurantID INTEGER NOT NULL, 
	PRIMARY KEY (uid),
	FOREIGN KEY (uid, restaurantID) REFERENCES Users(uid, restaurantID) ON DELETE CASCADE
);

CREATE TABLE DeliveryRiders (
    uid             INTEGER PRIMARY KEY,
	baseDeliveryFee NUMERIC NOT NULL DEFAULT 4,
	deliveryBonus NUMERIC NOT NULL DEFAULT 3,
	availability BOOLEAN DEFAULT TRUE,  -- free by default
	type    VARCHAR(255)  NOT NULL CHECK (type in ('FullTime', 'PartTime')),
    FOREIGN KEY (uid, type) REFERENCES Users(uid, riderType) ON DELETE CASCADE
);

CREATE TABLE Place (
	uid            INT,
	orderid        INT,  
	review         VARCHAR(255)     NOT NULL,
	star           INTEGER      DEFAULT NULL CHECK (star >= 0 AND star <= 5), 
	promoid        INT,
	PRIMARY KEY (orderid),
	FOREIGN KEY (uid) REFERENCES Customers ON DELETE CASCADE,
	FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE,
	FOREIGN KEY (orderid) REFERENCES Orders ON DELETE CASCADE
);

CREATE TABLE PartTime (
	uid            INTEGER PRIMARY KEY,
	weeklyBasePay   NUMERIC NOT NULL DEFAULT 100, /* $10 times minimum 10 hours in each WWS*/
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

CREATE TABLE FullTime (
	uid              INTEGER PRIMARY KEY,
	monthlyBasePay   INTEGER NOT NULL DEFAULT 1800,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

CREATE TABLE  WorkingDays (
	uid             INTEGER,
	workDate        DATE NOT NULL,
	intervalStart   TIME NOT NULL,
	intervalEnd     TIME NOT NULL,
	numCompleted    INTEGER DEFAULT 0,
	PRIMARY KEY (uid, workDate, intervalStart, intervalEnd),
	FOREIGN KEY (uid) REFERENCES PartTime(uid) ON DELETE CASCADE
);

CREATE TABLE ShiftOptions (
	shiftID         INTEGER, 
	shiftDetails    VARCHAR(30) NOT NULL,
	PRIMARY KEY (shiftID)
);

CREATE TABLE  WorkingWeeks (
	uid             INTEGER,
	workDate        DATE NOT NULL,
	shiftID         INTEGER NOT NULL,
	numCompleted    INTEGER DEFAULT 0,
	PRIMARY KEY (uid, workDate),
	FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE,
	FOREIGN KEY (shiftID) REFERENCES ShiftOptions(shiftID)
);


CREATE TABLE Delivers (
    orderID         INTEGER,
    uid             INTEGER,
    rating          INTEGER      DEFAULT NULL CHECK (rating >= 0 AND rating <= 5), 
    PRIMARY KEY (orderID,uid),
    FOREIGN KEY (orderID) REFERENCES Orders(orderID) ON DELETE CASCADE,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

/* Insert Data for Users*/
INSERT INTO Users (name, username, password,cardDetails, type) VALUES ('Alano', 'asunock0', 'SuKnMdGlSZv','3560449280162335', 'Customers');
INSERT INTO Users (name, username, password,cardDetails, type) VALUES ('Ugo', 'uhumphery5', 'zzWtpV6x1W5', '201863401712888','Customers');
INSERT INTO Users (name, username, password,cardDetails, type) VALUES ('Theo', 'tadkina', 'mXQVb8fG','3564256576222368' ,'Customers');
INSERT INTO Users (name, username, password, type) VALUES ('Jocelyn', 'jdodshund', '8XnPDwZN', 'Customers');
INSERT INTO Users (name, username, password, type) VALUES ('Paddie', 'ppaulline', 'Ake9PyGlLEh6', 'Customers');

INSERT INTO Users (name, username, password, restaurantID, type) VALUES ('Ariela', 'arodolfi1', '6W8jV0Un', 1,'RestaurantStaff');
INSERT INTO Users (name, username, password, restaurantID, type) VALUES ('Kitti', 'kbelding6', 'CDvLeT', 2,'RestaurantStaff');
INSERT INTO Users (name, username, password, restaurantID, type) VALUES ('Antony', 'aclausenthue4', 'LS5CtMmb', 3,'RestaurantStaff');

INSERT INTO Users (name, username, password, type) VALUES ('Taddeusz', 'tmanketell2', 'PjIpgl7J', 'FDSManagers');
INSERT INTO Users (name, username, password, type) VALUES ('Dodie', 'dfermerb', 'SLKtg2Q7kGn', 'FDSManagers');

INSERT INTO Users (name, username, password, riderType,type) VALUES ('Adrea', 'aveldens3', 'cdqUwd81YzX', 'FullTime','DeliveryRiders');
INSERT INTO Users (name, username, password, riderType,type) VALUES ('Adan', 'alaise7', 'blVy4LzR','FullTime','DeliveryRiders');
INSERT INTO Users (name, username, password, riderType,type) VALUES ('Elenore', 'epiatto8', 'jiWxXTs4Jjp','FullTime','DeliveryRiders');
INSERT INTO Users ( name, username, password, riderType,type) VALUES ('Gary', 'gtarrier9', 'G92FSUJuvL9e','FullTime','DeliveryRiders');
INSERT INTO Users (name, username, password, riderType,type) VALUES ('Oona', 'oprevettc', 'xeLkYRLNSkJ','FullTime','DeliveryRiders');

INSERT INTO Users (name, username, password, riderType, type) VALUES ('Nyan', 'asdfgh', 'asdfghjkl','PartTime','DeliveryRiders');
INSERT INTO Users (name, username, password, riderType, type) VALUES ('Nadiah', 'wasd', 'zxcvbnm','PartTime','DeliveryRiders');
INSERT INTO Users (name, username, password, riderType, type) VALUES ('Jan', 'qwerty', 'qwertyuiop','PartTime','DeliveryRiders');

/*Insert Shifts for Full Time Schedule */
INSERT INTO ShiftOptions(shiftID, shiftDetails) VALUES (1, '1pm-9pm');
INSERT INTO ShiftOptions(shiftID, shiftDetails) VALUES (2, '12pm-8pm');
INSERT INTO ShiftOptions(shiftID, shiftDetails) VALUES (3, '12am-8am');
INSERT INTO ShiftOptions(shiftID, shiftDetails) VALUES (4, '1am-9am');

/*Insert Schedule for Riders */
INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd, numCompleted) VALUES(18, '2020-01-08', '04:05', '07:40', 10);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES(11, '2020-01-08', 3, 13);
INSERT INTO WorkingWeeks(uid, workDate, shiftID, numCompleted) VALUES(13, '2020-01-09', 1, 15);

/* Insert Data for restaurants */
INSERT INTO Restaurants (name, location, minThreshold) VALUES ('Noma', '14 Texas Plaza', 5);
INSERT INTO Restaurants (name, location, minThreshold) VALUES ('Odette', '240 Vernon Hill', 5);
INSERT INTO Restaurants (name, location, minThreshold) VALUES ('Wolfgang Puck', '90 Mcguire Crossing', 3);
INSERT INTO Restaurants (name, location) VALUES ('Crystal Jade','123 Gowhere Road #01-27 Singapore 123456');
INSERT INTO Restaurants (name, location) VALUES ('What the fries','123 Gowhere Road #02-54 Singapore 123456');
INSERT INTO Restaurants (name, location) VALUES ('Zen food','456 Hungry Road #01-36 Singapore 456789');

/* Insert Data for categories */
INSERT INTO Categories(category) VALUES ('Malay Cuisine');
INSERT INTO Categories(category) VALUES ('Chinese Cuisine');
INSERT INTO Categories(category) VALUES ('Indian Cuisine');
INSERT INTO Categories(category) VALUES ('Japanese Cuisine');
INSERT INTO Categories(category) VALUES ('Korean Cuisine');
INSERT INTO Categories(category) VALUES ('Western Cuisine');

/* Insert Data for food */
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Nasi Briyani', 12.9, 1, 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tandoori Chicken', 22.8, 1, 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Butter Chicken', 27.3, 1, 'Indian Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tikka Masala', 27.8, 1, 'Indian Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Ayam Penyet', 5.0, 2, 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Gado Gado', 13.0, 2, 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Lontong', 6.3, 2, 'Malay Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Nasi Lemak', 9.2, 2, 'Malay Cuisine');

INSERT INTO Food (foodName, price, dailyLimit, RestaurantID, category) VALUES ('Tteokbokki', 14.9,100,3, 'Korean Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Kimchi Fried Rice', 10.5, 3, 'Korean Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Yang Zhou Fried Rice', 8, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Sweet and Sour Pork', 14, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Steam Egg', 5, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Hot and Sour Soup', 7, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Spring Rolls', 5, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Stir Fried Tofu', 5, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Chicken with Chestnuts', 15, 4, 'Chinese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Chicken Soup', 12, 4, 'Chinese Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Cheese Fries', 5, 5, 'Western Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Truffle Fries', 9, 5, 'Western Cuisine');

INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Sushi', 29.9, 6, 'Japanese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Tempura', 19.7, 6, 'Japanese Cuisine');
INSERT INTO Food (foodName, price, RestaurantID, category) VALUES ('Char Siew Ramen', 8.5, 6, 'Japanese Cuisine');

/* Insert Data for Promo */
INSERT INTO Promotion (startDate,endDate,discAmt,type) VALUES ('2020-02-01','2020-02-28',5,'FDSpromo');
INSERT INTO Promotion (startDate,endDate,discPerc,type) VALUES ('2020-03-01','2020-05-30',0.2,'FDSpromo'); --
INSERT INTO Promotion (startDate,endDate,discAmt,type) VALUES ('2020-06-01','2020-06-30',5,'FDSpromo');
INSERT INTO Promotion (startDate,endDate,discPerc,restaurantID,type) VALUES ('2020-03-01','2020-05-30',0.2,1,'Restpromo');
INSERT INTO Promotion (startDate,endDate,discPerc,restaurantID,type) VALUES ('2020-06-01','2020-07-01',0.2,3,'Restpromo');
INSERT INTO Promotion (startDate,endDate,discPerc,restaurantID,type) VALUES ('2020-08-01','2020-09-01',0.15,4,'Restpromo');

/* Insert Data into Payment Option */
INSERT INTO PaymentOption(payOption) VALUES ('Cash');
INSERT INTO PaymentOption(payOption) VALUES ('Credit');


-- deliveryduration is in integer?
/* Insert Data into orders and fromMenu think of how to make it happen*/ 
/* Order 1: Confirmed */
INSERT INTO Orders(cost,location,date,deliveryDuration,payOption) VALUES (0,'81 Goodland Road','2020-03-31',0,'Cash'); /* let cost be initially deffered*/

INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (5,5,1,3,'Tteokbokki');
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (5,3,1,3,'Kimchi Fried Rice');   

/* Insert data into place */
INSERT INTO Place (uid,orderID,review,star,promoid) VALUES (1,1,'no comments',5,5);

UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = 1) WHERE orderID = 1; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 1 LIMIT 1)) WHERE orderID = 1; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 1 LIMIT 1) WHERE orderID = 1; /*For amt promo*/

UPDATE Orders SET orderStatus = 'Completed' WHERE orderID = 1;
UPDATE Orders SET timeDepartToRest = '10:05:00' WHERE orderID = 1;
UPDATE Orders SET timeArriveRest = '10:11:00' WHERE orderID = 1;
UPDATE Orders SET timeDepartFromRest = '10:22:00' WHERE orderID = 1;
UPDATE Orders SET timeOrderDelivered = '10:45:00'  WHERE orderID = 1;

/*Order 2: Completed by .... */ 
INSERT INTO Orders(cost,location,date,deliveryDuration,payOption) VALUES (0,'346 Dennis Trail','2020-03-31',0,'Credit'); /* let cost be initially deffered*/
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (6,1,2,4,'Steam Egg');
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (6,1,2,4,'Sweet and Sour Pork');   
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (6,3,2,4,'Yang Zhou Fried Rice');        
/* Insert data into place */
INSERT INTO Place (uid,orderID,review,star) VALUES (3,2,'Nice food',4);

UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = 2) WHERE orderID = 2; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 2 LIMIT 1)) WHERE orderID = 2; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 2 LIMIT 1) WHERE orderID = 2; /*For amt promo*/

UPDATE Orders SET orderStatus = 'Completed' WHERE orderID = 2;
UPDATE Orders SET timeDepartToRest = '23:00:00' WHERE orderID = 2;
UPDATE Orders SET timeArriveRest = '23:15:00' WHERE orderID = 2;
UPDATE Orders SET timeDepartFromRest = '23:30:00' WHERE orderID = 2;
UPDATE Orders SET timeOrderDelivered = '23:45:00'  WHERE orderID = 2;


/* Order 3: Confirmed */
INSERT INTO Orders(location,payOption) VALUES ('333 Canberra Road','Cash'); 

INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (5,40,3,3,'Tteokbokki'); --insertion into from menu have to be a transaction
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES (5,10,3,3,'Kimchi Fried Rice');  

/* Insert data into place */
INSERT INTO Place (uid,orderID,review,star,promoid) VALUES (1,1,'Tastes great',5,5);

UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = 3) WHERE orderID = 3; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 3 LIMIT 1)) WHERE orderID = 3; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = 3 LIMIT 1) WHERE orderID = 3; /*For amt promo*/

UPDATE Orders SET orderStatus = 'Completed' WHERE orderID = 3;
UPDATE Orders SET timeDepartToRest = '13:05:00' WHERE orderID = 3;
UPDATE Orders SET timeArriveRest = '13:11:00' WHERE orderID = 3;
UPDATE Orders SET timeDepartFromRest = '13:22:00' WHERE orderID = 3;
UPDATE Orders SET timeOrderDelivered = '13:45:00'  WHERE orderID = 3;

/* Insert Data into delivers */
INSERT INTO Delivers (orderID,uid,rating) VALUES (1,12,2);
INSERT INTO Delivers (orderID,uid,rating) VALUES (2,16,5);
INSERT INTO Delivers (orderID,uid,rating) VALUES (3,16,5);


/* Add back column id default*/
/*
ALTER TABLE Users ALTER COLUMN uid SET DEFAULT gen_random_uuid();
ALTER TABLE Restaurants ALTER COLUMN restaurantID SET DEFAULT gen_random_uuid();
ALTER TABLE Promotion ALTER COLUMN promoID SET DEFAULT gen_random_uuid();
ALTER TABLE Orders ALTER COLUMN orderID SET DEFAULT gen_random_uuid();
*/