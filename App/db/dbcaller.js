/*---- Connects to Database to execute your query ---*/
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

module.exports = {
  query: (text, params, callback) => {
    return pool.query(text, params, callback);
  },
  
  //Not sure how to convert to getClient to use for transactions
  pool: pool
  
};