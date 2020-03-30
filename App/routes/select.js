/*Compulsory Header */
var express = require('express');
var router = express.Router();
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


router.get('/', function(req, res, next) {
	pool.query('SELECT uid, name, username FROM Users', (err, data) => {
		res.render('select', { title: 'Database Connect', usersInfo: data.rows });
	});
});

module.exports = router;
