/*check availability*/ --problem
CREATE OR REPLACE FUNCTION check_availability()
RETURNS TRIGGER AS $$
DECLARE currAvailability INTEGER;
DECLARE qtyOrdered INTEGER;

BEGIN
    qtyOrdered := NEW.quantity;

    SELECT dailyLimit into currAvailability 
    FROM Food 
    WHERE Food.foodname = NEW.foodName
    AND Food.restaurantID = NEW.restaurantID;

    IF NEW.quantity > currAvailability THEN
        RAISE NOTICE 'Exceed Daily Limit';
        UPDATE Orders SET orderStatus = 'Failed' WHERE Orders.orderID = NEW.orderID;
        RETURN NULL; -- abort inserted row
    ELSE 
        UPDATE Orders SET orderStatus = 'Confirmed' WHERE Orders.orderID = NEW.orderID;
        UPDATE Food SET dailyLimit = dailyLimit - qtyOrdered WHERE Food.foodname = NEW.foodName AND Food.restaurantID = NEW.restaurantID;
        
        RAISE NOTICE 'Order Confirmed';
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER availability_trigger
BEFORE INSERT ON FromMenu
FOR EACH ROW
EXECUTE PROCEDURE check_availability();




/*check whether order placed during operational hours*/
CREATE OR REPLACE FUNCTION check_operational_hours() --after operating hours, insertion continuessss
RETURNS TRIGGER AS $$
DECLARE currHour NUMERIC;
DECLARE openingHour NUMERIC;
DECLARE closingHour NUMERIC;

BEGIN
    openingHour := 10; --10am
    closingHour := 22; --10pm
    
    SELECT EXTRACT(HOUR from timeOrderPlace) INTO currHour
    FROM Orders
    WHERE NEW.orderID = Orders.OrderID;

    IF currHour < openingHour THEN
        UPDATE Orders SET orderStatus = 'Failed' WHERE NEW.orderID = Orders.OrderID;
        RAISE NOTICE 'Not within Opening Hours';
        RETURN NULL; 
    ELSIF currHour >= closingHour THEN
        UPDATE Orders SET orderStatus = 'Failed' WHERE NEW.orderID = Orders.OrderID; 
        RAISE NOTICE 'Not within Opening Hours';
        RETURN NULL; --RETURN NULL instead of RETURN NEW to just abort the inserted row silently without raising an exception and without rolling anything back.
    ELSE 
        RAISE NOTICE 'Within Opening Hours';
        RETURN NEW; 
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER operating_trigger
BEFORE INSERT ON Place
FOR EACH ROW
EXECUTE PROCEDURE check_operational_hours();




/*ISA check for delivery riders*/
CREATE OR REPLACE FUNCTION check_riders()
RETURNS TRIGGER AS $$
DECLARE count NUMERIC;

BEGIN
    IF (NEW.type = 'FullTime') THEN
        SELECT COUNT(*) INTO count 
        FROM PartTime 
        WHERE NEW.uid = PartTime.uid;
        IF (count > 0) THEN 
            RETURN NULL;
        ELSE
            INSERT INTO FullTime VALUES (NEW.uid, DEFAULT);
            RAISE NOTICE 'Full time rider added';
            RETURN NEW;
        END IF;

    ELSIF (NEW.type = 'PartTime') THEN
        SELECT COUNT(*) INTO count 
        FROM FullTime 
        WHERE NEW.uid = FullTime.uid;

        IF (count > 0) THEN 
            RETURN NULL;
        ELSE
            INSERT INTO PartTime VALUES (NEW.uid, DEFAULT);
            RAISE NOTICE 'Part time rider added';
            RETURN NEW;
        END IF;
    ELSE RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER riders_trigger
AFTER INSERT ON DeliveryRiders /* return value of row-level trigger fired AFTER is always ignored */
FOR EACH ROW
EXECUTE PROCEDURE check_riders();




/*ISA check for users*/
CREATE OR REPLACE FUNCTION check_user()
RETURNS TRIGGER AS $$
DECLARE count NUMERIC;
BEGIN 
	IF (NEW.type = 'Customers') THEN
		SELECT COUNT(*) INTO count 
        FROM FDSManagers, RestaurantStaff, DeliveryRiders
        WHERE NEW.uid = FDSManagers.uid
        OR NEW.uid = RestaurantStaff.uid
        OR NEW.uid = DeliveryRiders.uid;
        
		IF (count > 0) THEN 
            RETURN NULL;
		ELSE
            INSERT INTO Customers VALUES (NEW.uid,DEFAULT,DEFAULT,NEW.cardDetails);
            RAISE NOTICE 'Customers added';
			RETURN NEW;

		END IF;
	ELSIF (NEW.type = 'FDSManagers') THEN
		SELECT COUNT(*) INTO count 
        FROM Customers, RestaurantStaff, DeliveryRiders
        WHERE NEW.uid = Customers.uid
        OR NEW.uid = RestaurantStaff.uid
        OR NEW.uid = DeliveryRiders.uid;

		IF (count > 0) THEN RETURN NULL;
		ELSE
			INSERT INTO FDSManagers VALUES (NEW.uid);
            RAISE NOTICE 'FDSManagers added';
			RETURN NEW;
		
		END IF;	
    ELSIF (NEW.type = 'RestaurantStaff') THEN
        SELECT COUNT(*) INTO count 
        FROM Customers, FDSManagers, DeliveryRiders
        WHERE NEW.uid = Customers.uid
        OR NEW.uid = FDSManagers.uid
        OR NEW.uid = DeliveryRiders.uid;

		IF (count > 0) THEN RETURN NULL;
		ELSE
			
				INSERT INTO RestaurantStaff VALUES (NEW.uid,NEW.restaurantID);
                RAISE NOTICE 'RestaurantStaff added';
				RETURN NEW;
			
		END IF;	
    ELSIF (NEW.type = 'DeliveryRiders') THEN
        SELECT COUNT(*) INTO count 
        FROM Customers, FDSManagers, RestaurantStaff
        WHERE NEW.uid = Customers.uid
        OR NEW.uid = FDSManagers.uid
        OR NEW.uid = RestaurantStaff.uid;

		IF (count > 0) THEN 
            RETURN NULL;
		ELSE
            INSERT INTO DeliveryRiders(uid,type) VALUES (NEW.uid, NEW.riderType);
            RAISE NOTICE 'DeliveryRiders added';
		    RETURN NEW;
		END IF;	
	END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_trigger
AFTER INSERT ON Users
FOR EACH ROW
EXECUTE PROCEDURE check_user();



/*Update reward point after order completion*/
CREATE OR REPLACE FUNCTION update_rewards()
RETURNS TRIGGER AS $$
DECLARE currStatus VARCHAR(50);
DECLARE customerId INTEGER;

BEGIN 
    currStatus := NEW.orderStatus;

    SELECT uid INTO customerId
    FROM Place
    WHERE NEW.orderid = Place.orderid;

    IF currStatus = 'Completed' THEN
        UPDATE Customers 
        SET rewardPts = rewardPts + TRUNC(NEW.cost)
        WHERE customerId = Customers.uid;
    END IF;
    RETURN NULL;


END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reward_trigger
AFTER UPDATE of orderStatus ON Orders
FOR EACH ROW
EXECUTE PROCEDURE update_rewards();




/*Update delivery rider number of complete orders after order completion*/
CREATE OR REPLACE FUNCTION update_bonus()
RETURNS TRIGGER AS $$
DECLARE currStatus VARCHAR(50);
DECLARE riderId INTEGER;
DECLARE riderType VARCHAR(255);

BEGIN
    currStatus := NEW.orderStatus;

    SELECT uid INTO riderId
    FROM Delivers
    WHERE NEW.orderid = Delivers.orderid;

    SELECT type INTO riderType
    FROM DeliveryRiders
    WHERE riderId = DeliveryRiders.uid;

    IF currStatus = 'Completed' THEN
        IF riderType = 'FullTime' THEN
            UPDATE WorkingWeeks
            SET numCompleted = numCompleted + 1
            WHERE riderId = WorkingWeeks.uid;
        ELSIF riderType = 'PartTime' THEN
            UPDATE WorkingDays 
            SET numCompleted = numCompleted + 1
            WHERE riderId = WorkingDays.uid;
        END IF;
    END IF;
    RETURN NULL;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER bonus_trigger
AFTER UPDATE of orderStatus ON Orders
FOR EACH ROW
EXECUTE PROCEDURE update_bonus();


/*ISA check for Promotion*/
CREATE OR REPLACE FUNCTION check_promotion()
RETURNS TRIGGER AS $$
DECLARE count NUMERIC;

BEGIN
    IF (NEW.type = 'FDSpromo') THEN
        SELECT COUNT(*) INTO count 
        FROM Restpromo 
        WHERE NEW.promoID = Restpromo.promoID;
        IF (count > 0) THEN 
            RETURN NULL;
        ELSE
            INSERT INTO FDSpromo VALUES (NEW.promoID);
            RAISE NOTICE 'FDSpromo added';
            RETURN NEW;
        END IF;

    ELSIF (NEW.type = 'Restpromo') THEN
        SELECT COUNT(*) INTO count 
        FROM FDSpromo
        WHERE NEW.promoID = FDSpromo.promoID;

        IF (count > 0) THEN 
            RETURN NULL;
        ELSE
            INSERT INTO Restpromo VALUES (NEW.promoID, NEW.promoID);
            RAISE NOTICE 'Restpromo added';
            RETURN NEW;
        END IF;
    ELSE RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER promo_trigger
AFTER INSERT ON Promotion
FOR EACH ROW
EXECUTE PROCEDURE check_promotion();


/*Check restaurant staff account creation*/
CREATE OR REPLACE FUNCTION check_reststaff()
RETURNS TRIGGER AS $$
DECLARE count NUMERIC;

BEGIN
    SELECT COUNT(*) INTO count 
    FROM RestaurantStaff
    WHERE RestaurantStaff.restaurantID = NEW.restaurantID;

    IF (count < 0) THEN
        RAISE NOTICE 'No Restaurant Staff Account Created'; 
        RETURN NULL; -- abort inserted row
    ELSE
        RAISE NOTICE 'Restaurant Staff available';
        RETURN NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_rest_trigger
BEFORE INSERT ON Restaurants
FOR EACH ROW
EXECUTE PROCEDURE check_reststaff();

/*ensure one hour shift, check overlap*/
CREATE OR REPLACE FUNCTION check_shift()
RETURNS TRIGGER AS $$
DECLARE currShiftEnd NUMERIC;
DECLARE newShiftStart NUMERIC;

BEGIN
    IF EXISTS(
          SELECT 1 
          FROM workingDays W 
          WHERE (W.intervalStart <= NEW.intervalEnd 
          AND NEW.intervalStart <=  W.intervalEnd)
          AND NEW.uid = W.uid
          AND NOT (W.intervalStart = NEW.intervalStart OR NEW.intervalEnd = W.intervalEnd))
    THEN
        RAISE NOTICE 'Overlap shifts';
        RETURN NULL;
    ELSE 
        RAISE NOTICE 'One hour break between shifts';
        RETURN NEW;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER add_shift_trigger
BEFORE UPDATE OR INSERT ON WorkingDays
FOR EACH ROW
EXECUTE PROCEDURE check_shift();
