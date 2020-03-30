/*Compulsory Header */
var express = require('express');
var router = express.Router();
const { Pool } = require('pg')
const pool = new Pool({
	connectionString: process.env.DATABASE_URL
});


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'GROUP31' });
});


module.exports = router;