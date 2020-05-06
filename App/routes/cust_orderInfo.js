/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var orderID = null;


function orderStatus(req, res, next) {
	caller.query(sql.query.orderStatus, [req.user.uid], (err, data) => {
		if (err) {
			return next(err);
		}
		req.orderStatus = data.rows;
		console.log(data.rows.length);
		console.log(data);
		if (data.rows.length == 0) {
			req.orderStatus = [{}];
			console.log("i was here");
		} else {
			orderID = data.rows[0].orderid;
		}
		return next();
	});
}

function loadPage(req, res, next) {
	res.render('cust_orderInfo', {
		username: req.user.username,
		name: req.user.name,
		status: req.orderStatus
	});
}

router.get('/', passport.authMiddleware(), orderStatus, loadPage);

router.post('/addRestReview', function (req, res, next) {
	var review = req.body.restcomment;
	console.log(review);
	var star = req.body.restRating;
	// to prevent cust from adding order from different rest...
	caller.query(sql.query.addRestReview, [review, star, orderID], (err, data) => {
		if (err) {
			return next(err);
		}
	});
	res.redirect('/cust_orderInfo');
});

router.post('/addRiderReview', function (req, res, next) {
	var star = Number(req.body.riderRating);
	orderID = Number(orderID);
	// to prevent cust from adding order from different rest..
	console.log(orderID);
	console.log(star);

	caller.query(sql.query.addRiderReview, [star, orderID], (err, data) => {
		if (err) {
			console.log("i was here");
			return next(err);
		}

	});
	res.redirect('/cust_orderInfo');
});

module.exports = router;