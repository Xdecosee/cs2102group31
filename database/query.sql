/* I will just follow the example code when they insert values into it*/

/* General Functions*/
/* add_user      */ INSERT INTO Users(name,username,password,type) VALUES ($1,$2,$3,$4);
/* add_cust      */ INSERT INTO Customers(uid,cardDetails) VALUES ($1,$2);
/* add_FDSman    */ INSERT INTO FDSManagers(uid) VALUES ($1);
/* add_reststaff */ INSERT INTO RestaurantStaff(uid,restaurantID) VALUES ($1,$2);
/* add_riders    */ INSERT INTO DeliveryRiders(uid, type) VALUES ($1,$2);
/* add_PTriders  */ INSERT INTO PartTime(uid) VALUES ($1);
/* add_FTriders  */ INSERT INTO FullTime(uid) VALUES ($1);
/* del_users     */ DELETE FROM Users WHERE uid = $1;


/* Customer Functions*/
/* view_pastreview*/ SELECT DISTINCT O.date as orderDate, R.name as Restaurant, P.review as Review ,P.star as Rating FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1;
/* view_pastorders*/ SELECT DISTINCT O.date as orderDate ,R.name as Restaurant, F.foodName as Food, F.quantity as Quantity FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu F USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1;
/* view_restaurant*/ SELECT DISTINCT name as Restaurant,location as Location, minThreshold as MinimumOrder FROM Restaurants;
/* view_restreview*/ SELECT DISTINCT O.Date as orderDate, P.review as Review,P.star as Rating FROM Restaurants R JOIN FromMenu USING (restaurantID) JOIN Orders O USING (orderID) JOIN Place P USING (orderID) WHERE R.restaurantID = $1;
/* view_restmenue*/  SELECT DISTINCT foodName as Food,category as Category FROM Food WHERE restaurantID = $1; 
/* view_catfood*/    SELECT R.name as Restaurant,F.foodName as Food FROM Food F JOIN Restaurants R USING (restaurantID) WHERE F.category = $1; 
/* view_rewardp*/    SELECT (rewardPts) FROM Customers WHERE uid=$1;
/* view_5lateloc*/   SELECT (O.location) FROM Place P JOIN Orders O USING (orderID) WHERE P.uid = $1 ORDER BY O.Date DESC LIMIT 5;
/* update_card*/     UPDATE Customers SET cardDetails = $2 WHERE uid = $1;
/* del_card */       UPDATE Customers SET cardDetauks = NULL WHERE uid = $1; 

 /* add_order,add_from Menu,add_place*/
INSERT INTO Orders(cost,location,date,deliveryDuration,payOption) VALUES (0,$1,$2,0,$3); /* orderID auto generaetd */
INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES ($1,$2,$3,$4,$5);
INSERT INTO Place (uid,orderID,review,star,promoid) VALUES ($1,$2,$3,$4,$5); /* Insert data into place */
/* Update costs*/
UPDATE Orders SET cost = (SELECT sum(M.quantity*F.price) FROM FromMenu M JOIN Food F USING (restaurantID,foodName) WHERE M.orderID = $1) WHERE orderID = $1; /*Food costs*/
UPDATE Orders SET cost = cost*(1-(SELECT COALESCE(P.discPerc,0) FROM FromMenu M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = $1 LIMIT 1)) WHERE orderID = $1; /*For percentage promo*/
UPDATE Orders SET cost = cost-(SELECT COALESCE(P.discAmt,0) FROM Place M LEFT JOIN Promotion P USING (promoID) WHERE M.orderID = $1 LIMIT 1) WHERE orderID = $1; /*For amt promo*/
UPDATE Orders SET orderStatus = 'Confirmed' WHERE orderID = $1; /* after driver is assigned to order*/


/* Delivery Riders Function*/
/* view_ratings*/     SELECT CAST(avg(rating) AS DECIMAL(10,2)) FROM Delivers GROUP BY (uid) HAVING uid = $1;
/* update_orderstat*/ UPDATE Orders SET orderStatus = $1 WHERE orderID = $2
/* update_place*/     UPDATE Orders SET timeOrderPlace = $1 WHERE orderID = $2
/* update_departto*/  UPDATE Orders SET timeDepartToRest = $1 WHERE orderID = $2
/* update_arriverest*/UPDATE Orders SET timeArriveRest = $1 WHERE orderID = $2
/* update_departfrom*/UPDATE Orders SET timeDepartFromRest = $1 WHERE orderID = $2
/* update_delivered*/ UPDATE Orders SET timeOrderDelivered = $1 WHERE orderID = $2

/*Part Time*/ 
/* view_salary*/     SELECT CP.pYear as year, CP.pMonth as month, CP.pComplete * DR.baseDeliveryFee + CP.pComplete * DR.deliveryBonus + CP.totalWeeksWorked * CP.pBasePay as monthSalary FROM ConsolidateP CP RIGHT JOIN DeliveryRiders DR on DR.uid = CP.pUid WHERE CP.pUid = $1 ;
/* view_futsched*/   SELECT * FROM WorkingDays WHERE workDate>=NOW() AND uid = $2;
/* view_pastsched*/  SELECT * FROM WorkingDays WHERE workDate<NOW() AND uid = $2;
/* view_numOrder*/   SELECT pYear as year,pMonth as month, pComplete as ordersCompelete FROM ConsolidateP WHERE pUid = $1;
/* view_hourswork*/  SELECT DISTINCT P.uid, EXTRACT(YEAR FROM WD.workDate) as year, EXTRACT(MONTH FROM WD.workDate) as month, sum(DATE_PART('hour', WD.intervalEnd - WD.intervalStart) * 60  + DATE_PART('minute', WD.intervalEnd - WD.intervalStart))::decimal / 60 as totalHours FROM PartTime P INNER JOIN WorkingDays WD on P.uid = WD.uid WHERE WD.numCompleted > 0 GROUP BY P.uid, EXTRACT(YEAR FROM WD.workDate), EXTRACT(MONTH FROM WD.workDate) HAVING P.uid = $1;
/* add_schedule*/    INSERT INTO WorkingDays(uid,workDate,intervalStart,intervalEnd) VALUES ($1,$2,$3,$4); /*will have to trigger work hours*/

/*Full Time*/
/* view_salary*/     SELECT CF.fYear as year, CF.fMonth as month, CF.fCompleted * DR.baseDeliveryFee + CF.fCompleted * DR.deliveryBonus + CF.fBasePay as monthSalary FROM DeliveryRiders DR LEFT JOIN ConsolidateF CF on DR.uid = CF.fUid WHERE CF.fuid = $1;
/* view_futsched*/   SELECT W.workDate as wDate, S.shiftDetails as Shifts FROM WorkingWeeks W JOIN ShiftOptions S USING (shiftID) WHERE workDate>=NOW() AND uid = $1;
/* view_pastsched*/  SELECT W.workDate as wDate, S.shiftDetails as Shifts FROM WorkingWeeks W JOIN ShiftOptions S USING (shiftID) WHERE workDate<NOW() AND uid = $1;
/* view_numOrder*/   SELECT fYear as Year,fMonth as Month, fCompleted as ordersComplete FROM ConsolidateF WHERE fUid = $1;
/* view_hourswork*/  SELECT distinct EXTRACT(YEAR FROM WW.workDate) as year, EXTRACT(MONTH FROM WW.workDate) as month, count(shiftID) * 8 as totalHours FROM FullTime F INNER JOIN WorkingWeeks WW on F.uid = WW.uid WHERE WW.numCompleted > 0 GROUP BY F.uid, EXTRACT(YEAR FROM WW.workDate), EXTRACT(MONTH FROM WW.workDate) HAVING F.uid = $1;
/* add_schedule*/    INSERT INTO WorkingWeeks(uid,workDate,shiftID) VALUES ($1,$2,$3); /*trigger work hour*/