/*------ List of SQL Statements ---*/
const sql = {}


sql.query = {

    /*--------Login-----------*/
    login:  'SELECT DISTINCT U.username, U.password, U.name, U.uid, U.type As type , DR.type As ridertype ' +
            'FROM Users U Left Join DeliveryRiders DR on U.uid = DR.uid WHERE U.username = $1',

    /*------Restaurant Staff--------*/
    restInfo:   'SELECT DISTINCT * FROM Restaurants R ' +
                'INNER JOIN RestaurantStaff RS on R.restaurantID =  RS.restaurantID ' +
                'WHERE RS.uid = $1 LIMIT 1',
    restMenuInfo:   'SELECT DISTINCT * FROM Food F ' +
                    'INNER JOIN Restaurants R on F.restaurantID = R.restaurantID ' +
                    'WHERE R.restaurantID = $1',
    restInsertFood: 'INSERT INTO Food(foodName, price, category, restaurantID) ' +
                    'Values($1, $2, \'Western\', $3)',
    restOrders:     'SELECT DISTINCT FM.orderID, to_char(O.date, \'DD/MM/YYYY\') as date, O.timeOrderPlace, FM.FoodName, FM.quantity ' +
                    'FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Confirmed\'  AND O.timeDepartFromRest IS NULL AND FM.restaurantID = $1 ' + 
                    'AND FM.hide = \'false\' ORDER BY date, O.timeOrderPlace, FM.orderID',
    restCooked:     'UPDATE FromMenu SET hide = \'true\' WHERE orderID = $1 and foodName = $2',
    restSummary:    'SELECT year, month, COUNT(orderID) AS totalorders, SUM(cost) As totalCost ' +
                    'FROM (SELECT DISTINCT EXTRACT(Year FROM (O.date)) AS year, to_char(O.date, \'Month\') as month, '+
                    'O.orderid, O.cost FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1) TMP ' +
                    'GROUP BY year, month ORDER BY year DESC, to_date(month, \'Month \') DESC',
    restFavFood:    'With FoodOrders as ( SELECT EXTRACT(Year FROM (O.date)) AS year,  to_char(O.date, \'Month\') as month, ' +
                    'FM.foodName as food, SUM(FM.quantity) as totalOrders FROM FromMenu FM INNER JOIN Orders O on FM.orderID = O.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1 ' +
                    'GROUP BY EXTRACT(Year FROM (O.date)),  to_char(O.date, \'Month\'), FM.foodName) ' +
                    'SELECT DISTINCT * FROM ( SELECT year, month, to_date(month, \'Month \') as month2, food, totalOrders, '+
                    'row_number() OVER (PARTITION BY year, month) as rownum FROM FoodOrders ' +
                    ')Tmp WHERE rownum < 6 ORDER BY year DESC, month2 DESC, totalOrders DESC',
    restPercPromo:      'INSERT INTO Promotion(startDate, endDate, startTime, endTime, discPerc, type) ' +
                        'Values($1, $2, $3, $4, $5, \'Restpromo\') RETURNING promoID',
    restAmtPromo:       'INSERT INTO Promotion(startDate, endDate, startTime, endTime, discAmt, type) ' +
                        'Values($1, $2, $3, $4, $5, \'Restpromo\') RETURNING promoID',
    restInsertPromo:    'INSERT INTO Restpromo(promoID, restID) VALUES($1, $2)',
    restPercSummary:    'With PromoInfo AS (SELECT DISTINCT P.promoID, startDate,  startTime, endDate, endTime, discPerc, ' +
                        'DATE_PART( \'day\',  (startDate + startTime) -  (endDate + endTime)) as dayDuration, ' +
                        'DATE_PART( \'day\', (startDate + startTime) - ( endDate + endTime)) * 24 + ' +
                        'DATE_PART( \'hour\', (startDate + startTime) - (endDate + endTime)) as hourDuration ' +
                        'FROM Restpromo R INNER JOIN Promotion P on R.promoID = P.promoID ' +
                        'WHERE P.discPerc IS NOT NULL  AND R.restID = $1), ' +
                        'OrderInfo As (SELECT DISTINCT P.promoID, COUNT(DISTINCT orderID) as totalOrders ' +
                        'FROM Promotion P INNER JOIN FromMenu FM on P.promoID = FM.promoID ' +
                        'WHERE P.discPerc IS NOT NULL ' +
                        'GROUP BY P.promoID AND FM.restaurantID = $2) ' +
                        'SELECT DISTINCT PI.promoID, startDate, startTime, endDate, endTime, discPerc, totalOrders, dayDuration, hourDuration, ' +
                        'ROUND(totalOrders::decimal / dayDuration) as dayAvg, ROUND(totalOrders::decimal/ hourDuration) as hourAvg ' +
                        'FROM PromoInfo PI INNER JOIN OrderInfo O on PI.promoID = O.promoID',
     restAmtSummary:    'With PromoInfo AS (SELECT DISTINCT P.promoID, startDate,  startTime, endDate, endTime, discAmt, ' +
                        'DATE_PART( \'day\',  (startDate + startTime) -  (endDate + endTime)) as dayDuration, ' +
                        'DATE_PART( \'day\', (startDate + startTime) - ( endDate + endTime)) * 24 + ' +
                        'DATE_PART( \'hour\', (startDate + startTime) - (endDate + endTime)) as hourDuration ' +
                        'FROM Restpromo R INNER JOIN Promotion P on R.promoID = P.promoID ' +
                        'WHERE P.discAmt IS NOT NULL  AND R.restID = $1), ' +
                        'OrderInfo As (SELECT DISTINCT P.promoID, COUNT(DISTINCT orderID) as totalOrders ' +
                        'FROM Promotion P INNER JOIN FromMenu FM on P.promoID = FM.promoID ' +
                        'WHERE P.discAmt IS NOT NULL ' +
                        'GROUP BY P.promoID AND FM.restaurantID = $2) ' +
                        'SELECT DISTINCT PI.promoID, startDate, startTime, endDate, endTime, discAmt, totalOrders, dayDuration, hourDuration, ' +
                        'ROUND(totalOrders::decimal / dayDuration) as dayAvg, ROUND(totalOrders::decimal/ hourDuration) as hourAvg ' +
                        'FROM PromoInfo PI INNER JOIN OrderInfo O on PI.promoID = O.promoID'  
    


}

module.exports = sql;