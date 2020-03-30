/*Compulsory Header */
var express = require('express');
var router = express.Router();
const sql_query = require('../database/sqlList');
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});

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
	
	//Redirect after database success
	pool.query(sql_query.query.insert_customer,[name, username, password], (err, data) => {
		if(err) {
			console.error("Error in adding customer");
		} else {
			res.redirect('/select');
		}

	});
});


module.exports = router;
