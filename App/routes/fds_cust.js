/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var newCustomers = 0;
var actCustomers = 0;
var custInfo = [];

function loadPage(req, res, next) {
	res.render('fds_cust', {
		username: req.user.username,
		name: req.user.name,
		newCustomers: newCustomers,
		actCustomers: actCustomers,
		custInfo: custInfo
	});
}

router.post('/selectMonth', function (req, res, next) {
	//from <form> in ejs file
	var index = req.body.month;

	caller.query(sql.query.totalNewCus, [index], (err, data) => {
		if (err){
			next(err);
		}
		if (data.rows[0] == null) {
			console.log("new: 0");
			newCustomers = 0;
		} else {
			console.log("new: " + data.rows[0].num);
			newCustomers = data.rows[0].num;
		}
	});

	caller.query(sql.query.activeCus, [index], (err, data) => {
		if (err){
			next(err);
		}
		if (data.rows[0] == null) {
			console.log("active : 0");
			actCustomers = 0;
		} else {
			console.log("active: " + data.rows[0].num);
			actCustomers = data.rows[0].num;
		}
	});

	caller.query(sql.query.totalOrderEachCust, [index], (err, data) => {
		if (err){
			next(err);
		}
		if (data.rows[0] == null) {
			console.log("table : null");
			custInfo = [];
		} else {
			console.log("table: " + data.rows[0].totalcost);
			custInfo = data.rows;
		}
	});

	res.redirect('/fds_cust');
});

router.get('/', passport.authMiddleware(), loadPage);
module.exports = router;