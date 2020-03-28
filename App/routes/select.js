var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  /* IMPORTANT: Swap **** with your own password and Swap #### with your database name that you
  use to store the project data e.g. postgres */
  database: '####',
  password: '****',
  port: 5432,
})

router.get('/', function(req, res, next) {
	pool.query('SELECT uid, name, username FROM Users', (err, data) => {
		res.render('select', { title: 'Database Connect', usersInfo: data.rows });
	});
});

module.exports = router;
