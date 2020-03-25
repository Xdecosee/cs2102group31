/* I will just follow the example code when they insert values into it*/


/* General Functions*/

/* add_user      */ INSERT INTO Users(uid,name,username,password) VALUES ($1,$2,$3,$4);
/* add_cust      */ INSERT INTO Customers(uid,signUpDate,cardDetails) VALUES ($1,$2,$3);
/* add_FDSman    */ INSERT INTO FDSManagers(uid) VALUES ($1);
/* add_reststaff */ INSERT INTO RestaurantStaff(uid) VALUES ($1);

/* del_users     */ DELETE FROM Users WHERE uid = $1;


/* Customer Functions*/

/* view_pastreview*/ SELECT (R.name, P.review,P.star) FROM Place P JOIN Order USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1;
/* view_pastorders*/ SELECT (O.date,R.name,F.foodName,F.quantity) FROM Place P JOIN Order O USING (orderID) JOIN FromMenu F USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1;
/* view_restaurant*/ SELECT (name,location,minThreshold) FROM Restaurants;
/* view_restreview*/ SELECT (P.review,P.star) FROM Restaurants R JOIN FromMenu USING (restaurantID) JOIN Order USING (orderID) JOIN Place P USING (orderID) WHERE R.restaurantID = $1;
/* view_restmenue*/  SELECT (foodName) FROM Menu WHERE restaurantID = $1; 
/* view_catfood*/    SELECT (R.name,F.foodName) FROM Food F JOIN Restaurants R USING (restaurantID) WHERE F.category = $1; 
/* view_rewardp*/    SELECT (rewardPts) FROM Customers WHERE uid=$1;
/* view_5lateloc*/   SELECT (O.location) Place P JOIN Orders O USING (orderID) WHERE P.uid = $1 ORDER BY O.Date DESC LIMIT 5;


/* update_card*/     UPDATE Customers SET cardDetails = $2 WHERE uid = $1;
/* del_card */       UPDATE Customers SET cardDetauks = NULL WHERE uid = $1; 
/* add_order */      INSERT INTO Order(orderID,cost,location,date,deliveryDuration) VALUES ($1,$2,$3,$4);
/* add_fromMenu*/    INSERT INTO FromMenu(promoID,quantity,orderID,restaurantID,foodName) VALUES ($1,$2,$3,$4,$5);
/* add_payby*/       INSERT INTO Payby (orderID,payOption) VALUES ($1,$2);

/* Have an issue with order and menu, head and tail problem, which one come first
   Step 1: compile food and cost
   Step 2: Generate orderID
   Step 3: Link both?
*/

/* Delivery Riders Function*/

/*Part Time*/ 
/* view_futsched*/   SELECT * FROM WorkingDays WHERE workDate>=$1;
/* view_pastsched*/  SELECT * FROM WorkingDays WHERE workDate<$1;
/* view_salary*/     SELECT (M.monthYear,P.weeklyBasePay*4 as Basepay,D.baseDeliveryfee*M.numCompleted as Bonus,Bonus+basepay as Totalpay) FROM PartTime P JOIN DeliveryRiders D USING (uid) JOIN MonthlyDeliveryBonus M USING (uid) WHERE P.uid = $1 GROUP BY (M.monthYear);
/*need to find out when he worked to know the n for weeklybasepay*/
/* add_schedule*/    INSERT INTO WorkingDays(uid,workDate,intervalStart,intervalEnd) VALUES ($1,$2,$3,$4); 

/*Full Time*/
/* view_futsched*/   SELECT * FROM WorkingWeeks W JOIN ShiftOptions S WHERE W.workDate>=$1;
/* view_pastsched*/  SELECT * FROM WorkingWeeks W JOIN ShiftOptions S WHERE W.workDate<$1;
/* view_salary*/     SELECT (M.monthYear,F.monthlyBasePay as Basepay,D.baseDeliveryfee*M.numCompleted as Bonus, Bonus+basepay as Totalpay) FROM FullTime F JOIN DeliveryRiders D USING (uid) JOIN MonthlyDeliveryBonus M USING (uid) WHERE P.uid = $1 GROUP BY (M.monthYear);
/* add_schedule*/    INSERT INTO WorkingWeeks(uid,workDate,shiftID) VALUES ($1,$2,$3); 


/* view_numOrder*/   SELECT (monthYear,numCompleted) FROM MonthlyDeliveryBonus WHERE uid = $1;
/* view_ratings*/    SELECT (avg(rating)) FROM DELIVERS GROUP BY (uid) HAVING uid = $1;
/* view_hourswork*/  SELECT 

/* update_orderstat*/ UPDATE Orders SET orderStatus = $1 WHERE orderID = $2
/* update_place*/     UPDATE Orders SET timeOrderPlace = $1 WHERE orderID = $2
/* update_departto*/  UPDATE Orders SET timeDepartToRest = $1 WHERE orderID = $2
/* update_arriverest*/UPDATE Orders SET timeArriveRest = $1 WHERE orderID = $2
/* update_departfrom*/UPDATE Orders SET timeDepartFromRest = $1 WHERE orderID = $2
/* update_delivered*/ UPDATE Orders SET timeOrderDelivered = $1 WHERE orderID = $2
