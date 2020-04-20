/*------ List of SQL Statements ---*/
const sql = {}


sql.query = {

    /*--------Login-----------*/
    login:  'SELECT DISTINCT U.username, U.password, U.name, U.uid, U.type As type , DR.type As ridertype ' +
            'FROM Users U Left Join DeliveryRiders DR on U.uid = DR.uid WHERE U.username = $1',

    /*------Restaurant Staff--------*/
    restInfo: 'SELECT * FROM Restaurants R INNER JOIN RestaurantStaff RS on R.restaurantID =  RS.restaurantID WHERE RS.uid = $1 LIMIT 1',
    menuInfo: 'SELECT * FROM Food F INNER JOIN Restaurants R on F.restaurantID = R.restaurantID WHERE R.restaurantID = $1',
    // by default category is selected as 'Indian Cusine' by using \'
    insertFood: 'INSERT INTO Food(foodName, price, category, RWestaurantID) Values($1, $2, \'Indian Cuisine\', $3)',

    /*------Delivery Riders--------*/
    riderInfo:    'SELECT * FROM DeliveryRiders WHERE uid = $1',
    ratingInfo:   'SELECT CAST(avg(rating) AS DECIMAL(10,2)) AS rating FROM Delivers GROUP BY (uid) HAVING uid = $1',
    workdInfo:    'SELECT year AS year,to_char(to_timestamp (month::text, \'MM\'), \'Month\') AS month, numCompleted AS com, totalHours as hour FROM workDetails WHERE uid = $1 ORDER BY (year,month) DESC LIMIT 10',
    salaryInfo:   'SELECT year AS year,to_char(to_timestamp (month::text, \'MM\'), \'Month\') AS month, monthSalary AS salary FROM driverSalary WHERE uid = $1 ORDER BY (year,month) DESC',
    cOrderInfo:   'SELECT cast(orderID as varchar) as orderID, to_char(date,\'DD-Mon-YYYY\') as date, to_char(timeorderplace, \'HH24:MI:SS\') as timeplace, location, deliveryduration, orderstatus, rating FROM Orders O JOIN Delivers D USING (orderID) WHERE D.uid = $1 and (O.orderstatus = \'Completed\' or O.orderstatus = \'Failed\') ORDER BY (EXTRACT(Year FROM O.date),EXTRACT(Month FROM O.date),EXTRACT(Day FROM O.date), O.timeOrderPlace) DESC',
    pOrderInfo:   'SELECT orderID as orderid, to_char(date,\'DD-Mon-YYYY\') as date, location, to_char(timeorderplace, \'HH24:MI:SS\') as timeplace,to_char(timedeparttorest, \'HH24:MI:SS\') as timetorest,to_char(timearriverest, \'HH24:MI:SS\') as timearrive,to_char(timedepartfromrest, \'HH24:MI:SS\') as timedepart,to_char(timeorderdelivered, \'HH24:MI:SS\') as timedelivered, orderstatus FROM Orders O JOIN Delivers D USING (orderID) WHERE D.uid = $1 and (O.orderstatus = \'Confirmed\' or O.orderstatus = \'Pending\') ORDER BY (EXTRACT(Year FROM O.date),EXTRACT(Month FROM O.date),EXTRACT(Day FROM O.date), O.timeOrderPlace) DESC',
    ftshedInfo:   'SELECT to_char(W.workDate,\'Mon-YYYY\') as period, to_char(W.workDate,\'DD-Mon-YYYY\') as wDate, S.shiftDetail1 as shifts1, S.shiftDetail2 as shifts2 FROM WorkingWeeks W JOIN ShiftOptions S USING (shiftID) WHERE uid = $1 ORDER BY (EXTRACT(Year FROM W.workDate),EXTRACT(Month FROM W.workDate),EXTRACT(Day FROM W.workDate)) DESC',
    ptshedInfo:   'SELECT to_char(workDate,\'Mon-YYYY\') as period, to_char(workDate,\'DD-Mon-YYYY\') as date, to_char(intervalStart, \'HH24:MI:SS\') as intervstart, to_char(intervalEnd, \'HH24:MI:SS\') as intervend FROM WorkingDays WHERE uid = $1 ORDER BY (EXTRACT(Year FROM workDate),EXTRACT(Month FROM workDate),EXTRACT(Day FROM workDate)) DESC',
    ftShiftInfo:  'SELECT * FROM ShiftOptions',
    
    statusUpdate:   'UPDATE Orders SET orderStatus = \'Completed\' WHERE orderID = $1',
    orderFailed:    'UPDATE Orders SET orderStatus = \'Failed\' WHERE orderID = $1',
    departtoUpdate: 'UPDATE Orders SET timeDepartToRest = NOW() WHERE orderID = $1',
    arriveUpdate:   'UPDATE Orders SET timeArriveRest = NOW() WHERE orderID = $1',
    departfrUpdate: 'UPDATE Orders SET timeDepartFromRest = NOW() WHERE orderID = $1',
    deliverUpdate:  'UPDATE Orders SET timeOrderDelivered = NOW() WHERE orderID = $1',
    durationUpate:  'UPDATE Orders SET deliveryduration = (SELECT to_char((timeOrderDelivered - timeOrderPlace), \'HH24 h MI \"min\"\') FROM Orders WHERE orderID = $1) WHERE orderID = $1',
    
    ftschedInsert:  'INSERT INTO WorkingWeeks(uid, workDate, shiftID) VALUES($1, $2, $3)',
    ptschedInsert:  'INSERT INTO WorkingDays(uid, workDate, intervalStart, intervalEnd) VALUES ($1, $2, $3, $4)'               
}

module.exports = sql;