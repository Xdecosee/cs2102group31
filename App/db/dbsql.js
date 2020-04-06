const sql = {}


sql.query = {

    //Login
    login: 'SELECT name, username, type FROM Users where name = $1 and password = %2',

    //Guide_files
    all_users: 'SELECT uid, name, username FROM Users',
    insert_customer: 'INSERT INTO Users(name, username, password, type) Values($1, $2, $3, \'Customers\')'


}

module.exports = sql;