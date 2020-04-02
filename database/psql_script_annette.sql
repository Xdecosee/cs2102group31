CREATE EXTENSION "pgcrypto";
CREATE EXTENSION "btree_gist";

DROP TABLE IF EXISTS Promotion CASCADE;
DROP TABLE IF EXISTS FDSpromo CASCADE;
DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Restpromo CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Food CASCADE;
DROP TABLE IF EXISTS Menu CASCADE;
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
DROP TABLE IF EXISTS MonthlyDeliveryBonus CASCADE;
DROP TABLE IF EXISTS Delivers CASCADE; 

CREATE TABLE Promotion ( 
    promoID     uuid PRIMARY KEY DEFAULT gen_random_uuid(),
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
	restaurantID    uuid DEFAULT gen_random_uuid(),
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
	availability    INTEGER              NOT NULL,
	price           NUMERIC              NOT NULL CHECK (price > 0),
	dailyLimit      INTEGER DEFAULT '50' NOT NULL,
	RestaurantID    uuid,
	category        VARCHAR(255)		 NOT NULL,
	PRIMARY KEY (RestaurantID, foodName),
	/*THIS PART*/
	FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID) ON DELETE CASCADE,
	FOREIGN KEY	(category) REFERENCES Categories (category)
);

/*CREATE TABLE Menu (
	restaurantID    uuid         NOT NULL,
	foodName        VARCHAR(100)    NOT NULL,
	Unique (restaurantID, foodName),
	FOREIGN KEY	(restaurantID) REFERENCES Restaurants (restaurantID) ON DELETE CASCADE,
	FOREIGN KEY	(restaurantID, foodName) REFERENCES Food (restaurantID,foodname) ON DELETE CASCADE
);*/

CREATE TABLE PaymentOption (
    payOption   VARCHAR(100),
    PRIMARY KEY (payOption)
);

CREATE TABLE Orders (
	orderID             uuid DEFAULT gen_random_uuid() NOT NULL,
	deliveryFee         INTEGER                           NOT NULL,
	cost                INTEGER                           NOT NULL,
	location            VARCHAR(255)                      NOT NULL,
	date                DATE                              NOT NULL,
	payOption	    	VARCHAR(50)			    		  NOT NULL,
	orderStatus         VARCHAR(50) DEFAULT 'Pending'     NOT NULL CHECK (orderStatus in ('Pending','Confirmed','Completed','Failed')),
	deliveryDuration    INTEGER     					  NOT NULL,
	timeOrderPlace      TIME DEFAULT Now(),
	timeDepartToRest    TIME,
	timeArriveRest      TIME,
	timeDepartFromRest  TIME,
	timeOrderDelivered  TIME,
	PRIMARY KEY (orderID),
	FOREIGN KEY (payOption) REFERENCES PaymentOption (payOption)
);

CREATE TABLE FromMenu (
	promotionID     uuid,
	quantity        INTEGER         NOT NULL,
	orderID         uuid         NOT NULL,
	restaurantID    uuid         NOT NULL,
	foodName        VARCHAR(100)    NOT NULL,
	PRIMARY KEY (restaurantID,foodName,orderID),
	FOREIGN KEY (promotionID) REFERENCES Restpromo (promoID),
	FOREIGN KEY (orderID) REFERENCES Orders (orderID),
	FOREIGN KEY (restaurantID, foodName) REFERENCES Food (restaurantID, foodName) ON DELETE CASCADE
);

CREATE TABLE Users (
	uid         uuid DEFAULT gen_random_uuid(),
	name        VARCHAR(255)     NOT NULL,
	username    VARCHAR(255)     NOT NULL,
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
	baseDeliveryFee NUMERIC NOT NULL DEFAULT 4,
	deliveryBonus   NUMERIC NOT NULL default 3,
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
	uid             uuid,
	workDate        DATE NOT NULL,
	shiftID         INTEGER NOT NULL,
	numCompleted    INTEGER DEFAULT 0,
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

INSERT INTO Users(name, username,password, type) values('Tan Xiao Maing', 'TXM', '1234', 'DeliveryRiders');
INSERT INTO Users(name, username,password, type) values('Koh Beng Soon', 'KBS', '1234', 'DeliveryRiders');


INSERT INTO DeliveryRiders(uid, type) values ('acfdda78-9935-4bbc-9d60-3f0712f08560', 'FullTime');
INSERT INTO DeliveryRiders(uid, type) values ('4d4847a5-f67d-479f-a439-1efe82916995', 'PartTime');

INSERT INTO PartTime(uid) values ('4d4847a5-f67d-479f-a439-1efe82916995');
INSERT INTO FullTime(uid) values ('acfdda78-9935-4bbc-9d60-3f0712f08560');

INSERT INTO ShiftOptions(shiftID, shiftDetails) values (1, '1pm-9pm');
INSERT INTO ShiftOptions(shiftID, shiftDetails) values (2, '12pm-8pm');
INSERT INTO ShiftOptions(shiftID, shiftDetails) values (3, '12am-8am');
INSERT INTO ShiftOptions(shiftID, shiftDetails) values (4, '1am-9am');


Insert into WorkingDays(uid, workDate, intervalStart, intervalEnd, numCompleted) 
values('4d4847a5-f67d-479f-a439-1efe82916995', '1999-01-08', '04:05', '07:40', 10);
Insert into WorkingWeeks(uid, workDate, shiftID, numCompleted) 
values('acfdda78-9935-4bbc-9d60-3f0712f08560', '1999-01-08', 3, 13);


Insert into WorkingWeeks(uid, workDate, shiftID, numCompleted) 
values('acfdda78-9935-4bbc-9d60-3f0712f08560', '1999-01-09', 1, 15);