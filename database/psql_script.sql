DROP TABLE IF EXISTS Restaurants CASCADE;
DROP TABLE IF EXISTS Food CASCADE;
DROP TABLE IF EXISTS Categories CASCADE;
DROP TABLE IF EXISTS Menu CASCADE;
DROP TABLE IF EXISTS FromMenu CASCADE;
DROP TABLE IF EXISTS Order CASCADE;
DROP TABLE IF EXISTS Users CASCADE;
DROP TABLE IF EXISTS Customers CASCADE;
DROP TABLE IF EXISTS FDSManagers CASCADE;
DROP TABLE IF EXISTS RestaurantStaff CASCADE;
DROP TABLE IF EXISTS Place CASCADE;
DROP TABLE IF EXISTS Promotion CASCADE;
DROP TABLE IF EXISTS Restpromo CASCADE;
DROP TABLE IF EXISTS FDSpromo CASCADE;
DROP TABLE IF EXISTS DeliveryRiders CASCADE;
DROP TABLE IF EXISTS PartTime CASCADE;
DROP TABLE IF EXISTS FullTime CASCADE;
DROP TABLE IF EXISTS WorkingDays CASCADE;
DROP TABLE IF EXISTS ShiftOptions CASCADE;
DROP TABLE IF EXISTS WorkingWeeks CASCADE;
DROP TABLE IF EXISTS MonthlyDeliveryBonus CASCADE;
DROP TABLE IF EXISTS PaymentOption CASCADE;
DROP TABLE IF EXISTS Payby CASCADE;
DROP TABLE IF EXISTS Delivers CASCADE;

CREATE TABLE Restaurants (
    restaurantID    INTEGER,
    name            VARCHAR(100)         NOT NULL,
    location        VARCHAR(255)         NOT NUll,
    minThreshold    INTEGER DEFAULT '0'  NOT NULL,
    PRIMARY KEY (RestaurantID)
);

CREATE TABLE Food(
    foodName        VARCHAR(100)         NOT NULL,
    availability    BOOLEAN              NOT NULL,
    price           INTEGER              NOT NULL,
    dailyLimit      INTEGER DEFAULT '50' NOT NULL,
    RestaurantID    INTEGER,
    category        VARCHAR(100)         NOT NULL,
    PRIMARY KEY (RestaurantID, foodName),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants (RestaurantID) ON DELETE CASCADE,
    FOREIGN KEY (category) REFERENCES Categories(category)
);

CREATE TABLE Categories (
    category    VARCHAR(100),
    PRIMARY KEY (category)
);


CREATE TABLE Menu (
    restaurantID    INTEGER         NOT NULL,
    foodName        VARCHAR(100)    NOT NULL,
    PRIMARY KEY (restaurantID,foodName)
);

CREATE TABLE Order (
orderID             INTEGER                         NOT NULL,
    deliveryFee         INTEGER                         NOT NULL,
    cost                INTEGER                         NOT NULL,
    location            VARCHAR(255)                    NOT NULL,
    date                DATE                            NOT NULL,
    orderStatus         VARCHAR(50) DEFAULT 'Pending'   NOT NULL CHECK (orderStatus in ('Pending','Confirmed','Completed')),
    deliveryDuration    INTEGER         NOT NULL,
    timeOrderPlace      TIME,
    timeDepartToRest    TIME,
    timeArriveRest      TIME,
    timeDepartFromRest  TIME,
    timeOrderDelivered  TIME,

    PRIMARY KEY (orderID),
);

CREATE TABLE FromMenu (
    promoID         INTEGER,
    quantity        INTEGER         NOT NULL,
    orderID         INTEGER         NOT NULL,
    restaurantID    INTEGER         NOT NULL,
    foodName        VARCHAR(100)    NOT NULL,
    PRIMARY KEY (restaurantID,foodName,orderID),
    FOREIGN KEY (promoID) REFERENCES Restpromo (promoID),
    FOREIGN KEY (orderID) REFERENCES Order (orderID),
    FOREIGN KEY (restaurantID, foodName) REFERENCES Menu (restaurantID, foodName) ON DELETE CASCADE
);

CREATE TABLE PaymentOption(
    payOption   VARCHAR(100) PRIMARY KEY
);

CREATE TABLE Payby(
    orderID     INTEGER,
    payOption   VARCHAR(100),
    PRIMARY KEY (orderID,payOption),
    FOREIGN KEY (orderID) REFERENCES Order(orderID) ON DELETE CASCADE,
    FOREIGN KEY (payOption) REFERENCES PaymentOption(payOption) ON DELETE CASCADE
);

CREATE TABLE Users (
    uid         INTEGER,
    name        VARCHAR(255)     NOT NULL,
    username    VARCHAR(255)     NOT NULL,
    password    INTEGER          NOT NULL,
    PRIMARY KEY (uid)
);

CREATE TABLE Customers (
    uid         INTEGER,
    rewardPts   INTEGER DEFAULT '0' NOT NULL,
    signUpDate  DATE                NOT NULL,
    cardDetails VARCHAR(255),
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE FDSManagers (
    uid         INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);

CREATE TABLE RestaurantStaff (
    uid         INTEGER,
    PRIMARY KEY (uid),
    FOREIGN KEY (uid) REFERENCES Users ON DELETE CASCADE
);


CREATE TABLE Place (
    uid            INTEGER,
    orderID        INTEGER,  
    review         VARCHAR(255)     NOT NULL,
    star           INTEGER      DEFAULT NULL CHECK (rating >= 0 AND rating <= 5), 
    promoID        INTEGER,
    PRIMARY KEY (orderID),
    FOREIGN KEY (uid) REFERENCES Users(uid) ON DELETE CASCADE
    FOREIGN KEY (orderID) REFERENCES Order(orderID) ON DELETE CASCADE
    FOREIGN KEY (promoID) REFERENCES FDSpromo(promoID) ON DELETE CASCADE
);


CREATE TABLE Promotion {
    promoID     INTEGER PRIMARY KEY,
    startDate   DATE NOT NULL,
    endDate     DATE NOT NULL,
    discPerc    NUMERIC check(discount > 0),
    discAmt     NUMERIC check(discount > 0)
};


CREATE TABLE Restpromo{
    promoID     INTEGER, 
    restID      INTEGER NOT NULL,
    PRIMARY KEY (promoID,restID),
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE,
    FOREIGN KEY (restID) REFERENCES Restaurants(restaurantID) ON DELETE CASCADE
};


CREATE TABLE FDSpromo{
    promoID     INTEGER,
    PRIMARY KEY promoID,
    FOREIGN KEY (promoID) REFERENCES Promotion(promoID) ON DELETE CASCADE,
};


CREATE TABLE DeliveryRiders (
    uid             INTEGER PRIMARY KEY,
	baseDeliveryFee INTEGER NOT NULL,
    FOREIGN KEY (uid) REFERENCES Users(uid) ON DELETE CASCADE
);

CREATE TABLE Delivers(
    orderID         INTEGER,
    uid             INTEGER,
    rating          INTEGER      DEFAULT NULL CHECK (rating >= 0 AND rating <= 5), 
    PRIMARY KEY (orderID,uid),
    FOREIGN KEY orderID REFERENCES Order(orderID) ON DELETE CASCADE,
    FOREIGN KEY uid REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

CREATE TABLE PartTime (
	uid             INTEGER PRIMARY KEY ,
	weeklyBasePay   INTEGER NOT NULL,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);


CREATE TABLE FullTime (
	uid              INTEGER PRIMARY KEY ,
	monthlyBasePay   INTEGER NOT NULL,
    FOREIGN KEY (uid) REFERENCES DeliveryRiders(uid) ON DELETE CASCADE
);

/*WorkingDays - Used date and time datatypes without timezone*/
/*Need to ensure that the chosen timeslot does not overlap */
CREATE TABLE  WorkingDays(
	uid             INTEGER,
	workDate        DATE NOT NULL,
	intervalStart   TIME NOT NULL,
	intervalEnd     TIME NOT NULL,
	PRIMARY KEY (uid,workDate,intervalStart,intervalEnd),
	FOREIGN KEY (uid) REFERENCES PartTime(uid() ON DELETE CASCADE
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
	PRIMARY KEY (uid,shiftID,workDate),
	FOREIGN KEY (uid) REFERENCES FullTime ON DELETE CASCADE,
	FOREIGN KEY (shiftID) REFERENCES ShiftOptions(shiftID)
);


/*MonthlyDeliveryBonus. monthYear will have bogus date*/
CREATE TABLE MonthlyDeliveryBonus (
	uid             INTEGER,
	monthYear       DATE NOT NULL,
	numCompleted    INTEGER NOT NULL default 0,
	deliveryBonus   INTEGER NOT NULL default 0,
	PRIMARY KEY (uid,monthYear,numCompleted),
	FOREIGN KEY (uid) REFERENCES DeliveryRiders ON DELETE CASCADE
);