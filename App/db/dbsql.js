/*------ List of SQL Statements ---*/
const sql = {}


sql.query = {

    /*--------Login-----------*/
    login: 'SELECT * FROM Users WHERE username=$1',

    /*------Restaurant Staff--------*/
    restInfo: 'SELECT * FROM Restaurants R INNER JOIN RestaurantStaff RS on R.restaurantID =  RS.restaurantID WHERE RS.uid = $1 LIMIT 1',
    menuInfo: 'SELECT * FROM Food F INNER JOIN Restaurants R on F.restaurantID = R.restaurantID WHERE R.restaurantID = $1',
    // by default category is selected as 'Indian Cusine' by using \'
    insertFood: 'INSERT INTO Food(foodName, price, category, RestaurantID) Values($1, $2, \'Indian Cuisine\', $3)',

    /*----------FDS MANAGER-----------*/
    totalOrders: 'Select X.num From ( SELECT EXTRACT(MONTH FROM (date)) AS month, COUNT(orderid) AS num FROM Orders GROUP BY EXTRACT(MONTH FROM (date))) as X Where CAST(X.month as INT) = $1',
    totalCost: 'Select X.num From ( SELECT EXTRACT(MONTH FROM (date)) AS month, SUM(cost) AS num FROM Orders GROUP BY EXTRACT(MONTH FROM (date))) as X Where CAST(X.month as INT) = $1',
    totalNewCus: 'Select X.num From ( SELECT EXTRACT(MONTH FROM (signupDate)) AS month, COUNT(distinct uid) AS num FROM Customers GROUP BY EXTRACT(MONTH FROM (signupDate))) as X Where CAST(X.month as INT) = $1',
    totalOrderEachCust: 'Select x.customer, x.totalcost, x.num From ( SELECT EXTRACT(MONTH FROM (date)) AS month, uid as Customer, SUM(cost) AS totalcost, count(cost) as num FROM (Orders natural join (Place natural join Customers)) GROUP BY uid,EXTRACT(MONTH FROM (Date))) as X Where CAST(X.month as INT) = $1',
    //totalSpendingEachCust: 'Select X.customer, x.totalcost From ( SELECT EXTRACT(MONTH FROM (date)) AS month, uid as Customer, SUM(cost) AS totalcost FROM Orders natural join (Place natural join Customers) GROUP BY uid,EXTRACT(MONTH FROM (Date))) as X Where CAST(X.month as INT) = $1',
    activeCus: 'Select X.num From ( SELECT EXTRACT(MONTH FROM (date)) AS month, COUNT(uid) as num FROM Place natural join Orders GROUP BY EXTRACT(MONTH FROM (date))) as X Where CAST(X.month as INT) = $1',

    viewArea: 'Select X.area, X.hour, X.num From(SELECT EXTRACT(HOUR FROM (timeorderplace)) AS hour, area, COUNT(*) AS num FROM Orders GROUP BY EXTRACT(HOUR FROM (timeorderplace)), area) as X WHERE X.area = $1', 
    viewCat: 'Select * from categories',

    insertCat: 'INSERT INTO categories(category) Values($1)',
}

module.exports = sql;