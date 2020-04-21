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

    
    /*------Customers--------*/
    custInfo: 'SELECT * FROM Customers WHERE uid = $1',
    updateUserCard: 'UPDATE Users SET cardDetails = $2 WHERE uid = $1',
    updateCustomerCard: 'UPDATE Customers SET cardDetails = $2 WHERE uid = $1',
    //orderInfo: 'SELECT distinct * FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu F USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1',
    reviewInfo :'SELECT DISTINCT o.date as date, R.name, P.review, P.star FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1',
    orderInfo:'SELECT O.date::timestamp::date, R.name, F.foodName, F.quantity FROM Place P JOIN Orders O USING (orderID) JOIN FromMenu F USING (orderID) JOIN Restaurants R USING (restaurantID) WHERE P.uid = $1',


}

module.exports = sql;