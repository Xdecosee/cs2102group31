/*Compulsory Header */
var express = require('express');
var router = express.Router();
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

/* SQL Query */
var sql_query = 'INSERT INTO Users(name, username, password, type) Values';

// GET
router.get('/', function(req, res, next) {
	res.render('insert', { title: 'Customer Sign Up' });
});

// POST
router.post('/', function(req, res, next) {
	// Retrieve Information
	var name  = req.body.name;
	var username    = req.body.username;
	var password = req.body.password;
	
	// Construct Specific SQL Query
	var insert_query = sql_query + "('" + name + "','" + username + "','" + password + "', 'Customers')";
	
	//Redirect after database success
	pool.query(insert_query, (err, data) => {
		res.redirect('/select')
	});
});


module.exports = router;
