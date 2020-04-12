/*------ List of SQL Statements ---*/
const sql = {}


sql.query = {

    /*--------Login-----------*/
    login: 'SELECT DISTINCT * FROM Users WHERE username=$1',

    /*------Restaurant Staff--------*/
    restInfo:   'SELECT DISTINCT * FROM Restaurants R ' +
                'INNER JOIN RestaurantStaff RS on R.restaurantID =  RS.restaurantID ' +
                'WHERE RS.uid = $1 LIMIT 1',
    restMenuInfo:   'SELECT DISTINCT * FROM Food F ' +
                    'INNER JOIN Restaurants R on F.restaurantID = R.restaurantID ' +
                    'WHERE R.restaurantID = $1',
    restInsertFood: 'INSERT INTO Food(foodName, price, category, restaurantID) ' +
                    'Values($1, $2, \'Western\', $3)',
    restOrders:     'SELECT DISTINCT FM.orderID, O.date, O.timeOrderPlace, FM.FoodName, FM.quantity ' +
                    'FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Confirmed\'  AND O.timeDepartFromRest IS NULL AND FM.restaurantID = $1 ' + 
                    'ORDER BY O.date, O.timeOrderPlace, FM.orderID',
    restSummary:    'SELECT year, month, COUNT(orderID) AS totalorders, SUM(cost) ' +
                    'FROM (SELECT DISTINCT EXTRACT(Year FROM (O.date)) AS year, to_char(O.date, \'Month\') as month, '+
                    'O.orderid, O.cost FROM Orders O INNER JOIN FromMenu FM on O.orderID = FM.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1) TMP ' +
                    'GROUP BY year, month ORDER BY year DESC, to_date(month, \'Month \') DESC',
    restFavFood:    'With FoodOrders as ( SELECT EXTRACT(Year FROM (O.date)) AS year,  to_char(O.date, \'Month\') as month, ' +
                    'FM.foodName as food, SUM(FM.quantity) as totalOrders FROM FromMenu FM INNER JOIN Orders O on FM.orderID = O.orderID ' +
                    'WHERE O.orderStatus = \'Completed\' AND FM.restaurantID = $1 ' +
                    'GROUP BY EXTRACT(Year FROM (O.date)),  to_char(O.date, \'Month\'), FM.foodName) ' +
                    'SELECT DISTINCT * FROM ( SELECT year, month, to_date(month, \'Month \’) as month2, food, totalOrders, '+
                    'row_number() OVER (PARTITION BY year, month) as rownum FROM FoodOrders ' +
                    ')Tmp WHERE rownum < 6 ORDER BY year DESC, month2 DESC, totalOrders DESC'


}

module.exports = sql;