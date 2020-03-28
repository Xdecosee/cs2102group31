var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'cs2102',
  /*IMPORTANT: Swap **** with your own password*/
  password: '****',
  port: 5432,
})

router.get('/', function(req, res, next) {
	pool.query('SELECT uid, name, username FROM Users', (err, data) => {
		res.render('select', { title: 'Database Connect', usersInfo: data.rows });
	});
});

module.exports = router;
