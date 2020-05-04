/*---- Connects to Database to execute your query ---*/
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

module.exports = {
  query: (text, params, callback) => {
    return pool.query(text, params, callback);
  },
  
  pool: pool,

  getClient: (callback) => {
    pool.connect((err, client, done) => {
      callback(err, client, done)
    })
  }
  
};