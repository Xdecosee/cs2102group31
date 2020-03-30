/*Compulsory Header */
/*Compulsory Header */
var express = require('express');
var router = express.Router();
const sql_query = require('../database/sqlList');
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

router.get('/', function(req, res, next) {
	pool.query(sql_query.query.all_users, (err, data) => {
		res.render('select', { title: 'Select All Users', usersInfo: data.rows });
	});
});

module.exports = router;
