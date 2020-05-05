/*------ List of SQL Statements ---*/
const sql = {}


sql.query = {

   /*--------Login-----------*/
    login:  'SELECT DISTINCT U.username, U.password, U.name, U.uid, U.type As type , DR.type As ridertype ' +
            'FROM Users U Left Join DeliveryRiders DR on U.uid = DR.uid WHERE U.username = $1',

    /*--------Sign Up ------- */
    signupUserWithId: 'INSERT INTO Users(name, username, password, type) VALUES($1, $2, $3, $4) RETURNING uid',
    signupRest: 'INSERT INTO Restaurants(name, location, minthreshold) VALUES($1, $2, Round($3::NUMERIC, 2)) RETURNING restaurantID',
    signupRestStaff: 'INSERT INTO RestaurantStaff(uid,restaurantID) VALUES($1, $2)',
    signupCustomer: 'INSERT INTO Customers(uid) VALUES($1)',
    signupFDS: 'INSERT INTO FDSManagers(uid) VALUES($1)',
    signupRider: 'INSERT INTO DeliveryRiders(uid, type) VALUES($1, $2)',

    /*------Restaurant Staff--------*/
    restIdInfo:   'SELECT DISTINCT R.restaurantID, name, location, Round(minThreshold::NUMERIC, 2) as minthreshold FROM Restaurants R ' +
                'INNER JOIN RestaurantStaff RS on R.restaurantID =  RS.restaurantID ' +
                'WHERE RS.uid = $1 LIMIT 1',
    restOrders:     'SELECT DISTINCT FM.orderID, to_char(O.date, \'DD/MM/YYYY\') as date, O.timeOrderPlace, FM.FoodName, FM.quantity ' +
                    'FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Confirmed\'  AND O.timeDepartFromRest IS NULL AND FM.restaurantID = $1 ' + 
                    'AND FM.hide = \'false\' ' +
                    'ORDER BY date, O.timeOrderPlace, FM.orderID',
    restCooked:     'UPDATE FromMenu SET hide = \'true\' WHERE orderID = $1 and foodName = $2',
    restSummary:    'SELECT year, month, COUNT(orderID) AS totalorders, SUM(cost) As totalcost FROM ( ' +
                    'SELECT DISTINCT EXTRACT(Year FROM (O.date)) AS year, to_char(O.date, \'Month\') as month, ' +
                    'O.orderid, O.cost ' + 
                    'FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1 AND ' +
                    'EXTRACT(Year FROM (O.date)) = $2 AND EXTRACT(Month FROM (O.date)) = $3 ) TMP ' +
                    'GROUP BY year, month',
    restFavFood:    'SELECT DISTINCT EXTRACT(Year FROM (O.date)) AS year,  to_char(O.date, \'Month\') as month, ' +
                    'FM.foodName as food, SUM(FM.quantity) as totalOrders ' +
                    'FROM FromMenu FM INNER JOIN Orders O on FM.orderID = O.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1 ' +
                    'AND EXTRACT(Year FROM (O.date)) = $2 AND EXTRACT(Month FROM (O.date)) = $3 ' +
                    'GROUP BY year, month, food ' +
                    'ORDER BY totalOrders DESC ' +
                    'LIMIT 5',
    restPercPromo:      'INSERT INTO Promotion(startDate, endDate, startTime, endTime, discPerc, type) ' +
                        'Values($1, $2, $3, $4, Round($5/100::NUMERIC, 2), \'Restpromo\') RETURNING promoID',
    restAmtPromo:       'INSERT INTO Promotion(startDate, endDate, startTime, endTime, discAmt, type) ' +
                        'Values($1, $2, $3, $4, Round($5::NUMERIC, 2), \'Restpromo\') RETURNING promoID',
    restInsertPromo:    'INSERT INTO Restpromo(promoID, restID) VALUES($1, $2)',
    restPercSummary:    'With PromoInfo AS ( ' +
                        'SELECT DISTINCT P.promoID, startDate + startTime as startDT, ' +
                        'endDate + endTime as endDT, discPerc, ' +
                        'DATE_PART(\'day\', (endDate + endTime) - (startDate + startTime)) as dayPart, ' +
                        'DATE_PART(\'hour\',(endDate + endTime) - (startDate + startTime)) as hourPart ' +
                        'FROM Restpromo R INNER JOIN Promotion P on R.promoID = P.promoID ' +
                        'WHERE P.discPerc IS NOT NULL  AND R.restID = $1), ' +
                        'OrderInfo As ( ' +
                        'SELECT DISTINCT P.promoID, COUNT(DISTINCT orderID) as totalOrders ' +
                        'FROM Promotion P LEFT JOIN FromMenu FM on P.promoID = FM.promoID ' +
                        'WHERE P.discPerc IS NOT NULL AND FM.restaurantID = $2 ' +
                        'GROUP BY P.promoID ) ' + 
                        'SELECT DISTINCT PI.promoID, discPerc * 100 as discPerc, totalOrders, ' + 
                        'to_char(startDT, \'YYYY-MM-DD HH24:MI:SS\') as startDT, to_char(endDT, \'YYYY-MM-DD HH24:MI:SS\') as endDT, ' +
                        'to_char(endDT-startDT, \'DDD HH24:MI:SS\') as duration,  ' +
                        'CASE WHEN dayPart > 0 THEN ROUND(totalOrders/dayPart::NUMERIC, 2) ELSE NULL END AS dayAvg, ' +
                        'CASE WHEN dayPart = 0 AND hourPart = 0 then NULL ELSE ROUND(totalOrders/(dayPart * 24 + hourPart)::NUMERIC, 2) END AS hourAvg  ' +
                        'FROM PromoInfo PI LEFT JOIN OrderInfo O on PI.promoID = O.promoID ' +
                        'ORDER BY  startDT DESC, endDT DESC',
     restAmtSummary:    'With PromoInfo AS ( ' +
                        'SELECT DISTINCT P.promoID, startDate + startTime as startDT, ' +
                        'endDate + endTime as endDT, discAmt, ' +
                        'DATE_PART(\'day\', (endDate + endTime) - (startDate + startTime)) as dayPart,  ' +
                        'DATE_PART(\'hour\',(endDate + endTime) - (startDate + startTime)) as hourPart  ' +
                        'FROM Restpromo R INNER JOIN Promotion P on R.promoID = P.promoID ' +
                        'WHERE P.discAmt IS NOT NULL  AND R.restID = $1), ' +
                        'OrderInfo As ( ' +
                        'SELECT DISTINCT P.promoID, COUNT(DISTINCT orderID) as totalOrders ' +
                        'FROM Promotion P LEFT JOIN FromMenu FM on P.promoID = FM.promoID ' +
                        'WHERE P.discAmt IS NOT NULL AND FM.restaurantID = $2 ' +
                        'GROUP BY P.promoID ) ' + 
                        'SELECT DISTINCT PI.promoID, discAmt, totalOrders, ' +
                        'to_char(startDT, \'YYYY-MM-DD HH24:MI:SS\') as startDT, to_char(endDT, \'YYYY-MM-DD HH24:MI:SS\') as endDT,' +
                        'to_char(endDT-startDT, \'DDD HH24:MI:SS\') as duration,  ' +
                        'CASE WHEN dayPart > 0 THEN ROUND(totalOrders/dayPart::NUMERIC, 2) ELSE NULL END AS dayAvg, ' +
                        'CASE WHEN dayPart = 0 AND hourPart = 0 then NULL ELSE ROUND(totalOrders/(dayPart * 24 + hourPart)::NUMERIC, 2) END AS hourAvg ' +
                        'FROM PromoInfo PI LEFT JOIN OrderInfo O on PI.promoID = O.promoID ' +
                        'ORDER BY  startDT DESC, endDT DESC',
    restInsertFood:     'INSERT INTO Food(foodName, price, category, dailyLimit, restaurantID) ' +
                        'Values($1, ROUND($2::NUMERIC,2), $3, $4, $5)',
    restMenuInfo:       'SELECT DISTINCT * FROM Food F ' +
                        'INNER JOIN Restaurants R on F.restaurantID = R.restaurantID ' +
                        'WHERE R.restaurantID = $1 AND archive = \'FALSE\'',
    restArchiveInfo:    'SELECT DISTINCT foodname FROM Food F ' +
                        'INNER JOIN Restaurants R on F.restaurantID = R.restaurantID ' +
                        'WHERE R.restaurantID = $1 AND archive = \'TRUE\'',
    restFoodInfo:       'SELECT DISTINCT * FROM Food F ' +
                        'INNER JOIN Restaurants R on F.restaurantID = R.restaurantID ' +
                        'WHERE R.restaurantID = $1 AND foodname = $2',
    restSelectCategories:   'SELECT * FROM Categories',
    restArchive:   'UPDATE Food SET archive =  \'TRUE\' WHERE restaurantID = $1 and foodname = $2',
    restRestore:   'UPDATE Food SET archive =  \'FALSE\' WHERE restaurantID = $1 and foodname = $2',
    restUpdate:   'UPDATE Food SET price =  ROUND($1::NUMERIC,2) , category = $2, dailylimit = $3 WHERE restaurantID = $4 and foodname = $5',
                        
         
    /*------FDS Manager--------*/
    fds_custInfo:'With activeCus as (Select EXTRACT(YEAR FROM (date)) as year, EXTRACT(MONTH FROM (date)) AS month, COUNT(distinct uid) as activeCus FROM Place natural join Orders WHERE EXTRACT(YEAR FROM (date)) = $1 AND EXTRACT(MONTH FROM (date)) = $2 GROUP BY EXTRACT(YEAR FROM (date)), EXTRACT(MONTH FROM (date))), newCus as (SELECT EXTRACT(YEAR FROM (signupDate)) AS year, EXTRACT(MONTH FROM (signupDate)) AS month, COUNT(distinct uid) AS newCus FROM Customers WHERE EXTRACT(YEAR FROM (signupDate)) =  $1 AND EXTRACT(MONTH FROM (signupDate)) = $2 GROUP BY EXTRACT(YEAR FROM (signupDate)), EXTRACT(MONTH FROM (signupDate))) SELECT * FROM newCus natural full join activeCus ',
    totalOrderEachCust:'SELECT EXTRACT(YEAR FROM (Date)) as Year, EXTRACT(MONTH FROM (date)) AS month, uid as Customer, SUM(cost) AS totalcost, count(cost) as num FROM (Orders natural join (Place natural join Customers)) WHERE EXTRACT(YEAR FROM (Date)) = $1 AND EXTRACT(MONTH FROM (Date)) = $2 GROUP BY uid, EXTRACT(YEAR FROM (Date)), EXTRACT(MONTH FROM (Date))',
    fds_allRestInfo:'SELECT EXTRACT(YEAR FROM (date)) AS year, EXTRACT(MONTH FROM (date)) AS month, COUNT(orderid) AS totalOrders, sum(Cost) as totalCost FROM Orders WHERE EXTRACT(YEAR FROM (date)) = $1 AND  EXTRACT(MONTH FROM (date)) = $2 GROUP BY EXTRACT(YEAR FROM (date)),  EXTRACT(MONTH FROM (date))',
    fds_eachRestInfo:'SELECT EXTRACT(YEAR FROM (date)) AS year, EXTRACT(MONTH FROM (date)) AS month,FM.restaurantID, COUNT(distinct O.orderid) AS totalOrders, sum(Cost) as totalCost FROM (Select distinct orderid, restaurantId from frommenu) as FM natural join Orders O WHERE EXTRACT(YEAR FROM (date)) = $1 AND  EXTRACT(MONTH FROM (date)) = $2 GROUP BY restaurantID, EXTRACT(YEAR FROM (date)),  EXTRACT(MONTH FROM (date))',
    viewArea: 'Select X.area, X.hour, X.num From(SELECT EXTRACT(HOUR FROM (timeorderplace)) AS hour, area, COUNT(*) AS num FROM Orders GROUP BY EXTRACT(HOUR FROM (timeorderplace)), area) as X WHERE X.area = $1',
    viewCat: 'Select * from categories',
    insertCat: 'INSERT INTO categories(category) Values($1)',
    fdsPercentPromo: 'INSERT INTO Promotion(startDate, endDate, discPerc, type) Values($1, $2, $3, \'FDSpromo\') RETURNING promoID',
    fdsAmtPromo: 'INSERT INTO Promotion(startDate, endDate, discAmt, type) ' +
        'Values($1, $2, $3, \'FDSpromo\') RETURNING promoID',
    fdsInsertPromo: 'INSERT INTO FDSpromo(promoID) VALUES($1)',
    //promoInfo: 'SELECT p.promoID, to_char(p.startdate,\'DD-Mon-YYYY\') as startdate, to_char(p.enddate,\'DD-Mon-YYYY\') as enddate, p.discperc,p.discamt,p.type,rp.restid from Promotion p left join restpromo rp on rp.promoid = p.promoid',
    currentPromoInfo:'SELECT P.promoID, to_char(P.startdate,\'DD-Mon-YYYY\') as startdate, to_char(P.enddate,\'DD-Mon-YYYY\') as enddate, P.discperc, P.discamt, P.type, RP.restid FROM Promotion P left join restpromo RP on RP.promoid = P.promoid WHERE (P.enddate - current_date >= 0)',
    expiredPromoInfo:'SELECT P.promoID, to_char(P.startdate,\'DD-Mon-YYYY\') as startdate, to_char(P.enddate,\'DD-Mon-YYYY\') as enddate, P.discperc, P.discamt, P.type, RP.restid FROM Promotion P left join restpromo RP on RP.promoid = P.promoid WHERE (P.enddate - current_date < 0)',
    //riderSummary: 'With reviewInfo as (SELECT distinct DR.uid, EXTRACT(Year FROM (O.date)) AS year, EXTRACT(Month FROM (O.date)) as month, count(D.rating) as totalRatings, ROUND(avg(D.rating),1) as avgRatings,to_char(avg(timeOrderDelivered - timeOrderPlace), \'HH24:MI:SS\') as avgDuration FROM DeliveryRiders DR LEFT JOIN Delivers D on DR.uid = D.uid LEFT JOIN Orders O on D.orderID = O.orderID WHERE EXTRACT(Year FROM (O.date)) = $1 AND EXTRACT(Month FROM (O.date)) = $2 GROUP BY DR.uid, year, month),totalOrdersDelivered as ( SELECT distinct F.uid, EXTRACT(YEAR FROM WW.workDate) as year,EXTRACT(Month FROM (WW.workdate)) as month, SUM(WW.numCompleted) as totalOrders FROM FullTime F INNER JOIN WorkingWeeks WW ON F.uid = WW.uid WHERE EXTRACT(Year FROM (WW.workdate)) = $1 AND EXTRACT(Month FROM (WW.workdate)) = $2  GROUP BY F.uid,year, month UNION SELECT distinct P.uid, EXTRACT(YEAR FROM WD.workDate) as year, EXTRACT(Month FROM (WD.workdate)) as month, SUM(WD.numCompleted) as totalOrders FROM PartTime P INNER JOIN WorkingDays WD ON P.uid = WD.uid WHERE EXTRACT(Year FROM (WD.workdate)) = $1 AND EXTRACT(Month FROM (WD.workdate)) = $2 GROUP BY P.uid, year,month), hoursInfo as (SELECT distinct F.uid, EXTRACT(YEAR FROM WW.workDate) as year, EXTRACT(Month FROM (WW.workdate)) as month, ROUND(count(shiftID) * 8,0) as totalHours FROM FullTime F INNER JOIN WorkingWeeks WW on F.uid = WW.uid WHERE (WW.numCompleted > 0)  AND EXTRACT(Year FROM (WW.workdate)) = $1 AND EXTRACT(Month FROM (WW.workdate)) = $2 GROUP BY F.uid, year, month UNION SELECT distinct P.uid, EXTRACT(YEAR FROM WD.workDate) as year, EXTRACT(Month FROM (WD.workdate)) as month, ROUND(sum(DATE_PART(\'hour\', intervalEnd - intervalStart) * 60 + DATE_PART(\'minute\', intervalEnd - intervalStart))::decimal / 60,0) as totalHours FROM PartTime P INNER JOIN WorkingDays WD on P.uid = WD.uid WHERE (WD.numCompleted > 0) AND EXTRACT(Year FROM (WD.workdate)) = $1 AND EXTRACT(Month FROM (WD.workdate)) = $2 GROUP BY P.uid, year, month) Select * From totalOrdersDelivered natural join reviewInfo natural join hoursInfo natural join driversalary',
    riderSummary:'SELECT * from WorkDetails NATURAL FULL JOIN DriverSalary NATURAL FULL JOIN ReviewInfo WHERE Year = $1 AND Month = $2 AND UID IS NOT NULL',
    riderSchedule:'SELECT to_char(D.ddate,\'DD-Mon-YYYY\') as ddate,t10,t11,t12,t13,t14,t15,t16,t17,t18,t19,t20,t21 from overview D where EXTRACT(Year from D.ddate) = $1 AND EXTRACT(Month from D.ddate) = $2',

    /*------Delivery Riders--------*/
    riderInfo: 'SELECT * FROM DeliveryRiders WHERE uid = $1',
    ratingInfo: 'SELECT COALESCE(CAST(avg(rating) AS DECIMAL(10,2)),0.00) AS rating FROM Delivers WHERE uid = $1',
    workdInfo:    'SELECT year AS year,to_char(to_timestamp (month::text, \'MM\'), \'Month\') AS month, numCompleted AS com, totalHours as hour FROM workDetails WHERE uid = $1 ORDER BY (year,month) DESC LIMIT 10',
    salaryInfo: 'SELECT year AS year,to_char(to_timestamp (month::text, \'MM\'), \'Month\') AS month, monthSalary AS salary FROM driverSalary WHERE uid = $1 ORDER BY (year,month) DESC',
    cOrderInfo: 'SELECT cast(orderID as varchar) as orderID, to_char(date,\'DD-Mon-YYYY\') as date, to_char(timeorderplace, \'HH24:MI:SS\') as timeplace, location, deliveryduration, orderstatus, rating FROM Orders O JOIN Delivers D USING (orderID) WHERE D.uid = $1 and (O.orderstatus = \'Completed\' or O.orderstatus = \'Failed\') ORDER BY (EXTRACT(Year FROM O.date),EXTRACT(Month FROM O.date),EXTRACT(Day FROM O.date), O.timeOrderPlace) DESC',
    pOrderInfo: 'SELECT orderID as orderid, to_char(date,\'DD-Mon-YYYY\') as date, location, to_char(timeorderplace, \'HH24:MI:SS\') as timeplace,to_char(timedeparttorest, \'HH24:MI:SS\') as timetorest,to_char(timearriverest, \'HH24:MI:SS\') as timearrive,to_char(timedepartfromrest, \'HH24:MI:SS\') as timedepart,to_char(timeorderdelivered, \'HH24:MI:SS\') as timedelivered, orderstatus FROM Orders O JOIN Delivers D USING (orderID) WHERE D.uid = $1 and (O.orderstatus = \'Confirmed\' or O.orderstatus = \'Pending\') ORDER BY (EXTRACT(Year FROM O.date),EXTRACT(Month FROM O.date),EXTRACT(Day FROM O.date), O.timeOrderPlace) DESC',
    ftshedInfo: 'SELECT to_char(W.workDate,\'Mon-YYYY\') as period, to_char(W.workDate,\'DD-Mon-YYYY\') as wDate, S.shiftDetail1 as shifts1, S.shiftDetail2 as shifts2 FROM WorkingWeeks W JOIN ShiftOptions S USING (shiftID) WHERE uid = $1 ORDER BY (EXTRACT(Year FROM W.workDate),EXTRACT(Month FROM W.workDate),EXTRACT(Day FROM W.workDate)) DESC',
    ptshedInfo: 'SELECT to_char(workDate,\'Mon-YYYY\') as period, to_char(workDate,\'DD-Mon-YYYY\') as date, to_char(intervalStart, \'HH24:MI:SS\') as intervstart, to_char(intervalEnd, \'HH24:MI:SS\') as intervend FROM WorkingDays WHERE uid = $1 ORDER BY (EXTRACT(Year FROM workDate),EXTRACT(Month FROM workDate),EXTRACT(Day FROM workDate)) DESC',
    ftShiftInfo: 'SELECT * FROM ShiftOptions',

    statusUpdate: 'UPDATE Orders SET orderStatus = \'Completed\' WHERE orderID = $1',
    orderFailed: 'UPDATE Orders SET orderStatus = \'Failed\' WHERE orderID = $1',
    departtoUpdate: 'UPDATE Orders SET timeDepartToRest = NOW() WHERE orderID = $1',
    arriveUpdate: 'UPDATE Orders SET timeArriveRest = NOW() WHERE orderID = $1',
    departfrUpdate: 'UPDATE Orders SET timeDepartFromRest = NOW() WHERE orderID = $1',
    deliverUpdate: 'UPDATE Orders SET timeOrderDelivered = NOW() WHERE orderID = $1',
    durationUpate: 'UPDATE Orders SET deliveryduration = (SELECT to_char((timeOrderDelivered - timeOrderPlace), \'HH24 h MI \"min\"\') FROM Orders WHERE orderID = $1) WHERE orderID = $1',

    ftschedInsert: 'INSERT INTO WorkingWeeks(uid, workDate, shiftID) VALUES($1, $2, $3)',
    ptschedInsert: 'INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd) VALUES ($1, $2, $3, $4)',

    /*------Customers--------*/
    custInfo: 'SELECT * FROM Customers WHERE uid = $1',
    updateUserCard: 'UPDATE Users SET cardDetails = $2 WHERE uid = $1',
    updateCustomerCard: 'UPDATE Customers SET cardDetails = $2 WHERE uid = $1',

    reviewInfo :'SELECT DISTINCT  to_char(O.date,\'DD-Mon-YYYY\') as date, P.review, P.star FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1',
    orderInfo:'SELECT  to_char(O.date,\'DD-Mon-YYYY\') as date, R.name, F.foodName, F.quantity FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu F USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1',
    restInfo: 'SELECT * FROM restaurants',
    restReview :'SELECT DISTINCT  to_char(O.date,\'DD-Mon-YYYY\') as date, R.name, P.review, P.star FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE R.name = $1',
    avgRating : 'SELECT Round(AVG(ALL p.star),2) as avg FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE R.name = $1',
    menuInfo : 'SELECT distinct f.foodname, f.category, R.name, f.price, f.dailylimit from Restaurants R JOIN Food f using (restaurantid) where r.name = $1',
    addfood: 'SELECT f.foodname, (f.price * $3) as price ,$3 as amount from food f join restaurants r using(restaurantid) where f.foodname = $1 and r.name = $2',
}

module.exports = sql;