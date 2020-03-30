const sql = {}


sql.query = {

    all_users: 'SELECT uid, name, username FROM Users',
    insert_customer: 'INSERT INTO Users(name, username, password, type) Values($1, $2, $3, \'Customers\')'


}

module.exports = sql