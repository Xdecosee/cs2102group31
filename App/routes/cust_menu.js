/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

restId = null;
var OrderInfo = [];

function restInfo(req,res,next){
	caller.query(sql.query.restInfo, (err, data) => {
		if (err) {
			return next(err);
		}
		req.restInfo = data.rows;
		return next();
	});
}

function avgRating(req, res, next) {
	caller.query(sql.query.avgRating, [restId], (err, data) => {
		if (err) {
			req.avgRating = null;
			return next(err);
		}
		req.avgRating = data.rows[0].avg;
		return next();
	});
}

function reviewInfo(req, res, next) {
	caller.query(sql.query.restReview, [restId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.reviewInfo = data.rows;
		return next();
	});
}

function menuInfo(req, res, next) {
	caller.query(sql.query.menuInfo, [restId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.menuInfo = data.rows;
		return next();
	});
}

function loadPage(req, res, next) {
	res.render('cust_menu',{
		restInfo : req.restInfo,
		reviewInfo : req.reviewInfo,
		avgRating : req.avgRating,
		menuInfo : req.menuInfo,
		orderInfo : OrderInfo
	});
}

router.get('/', passport.authMiddleware(), restInfo, avgRating, reviewInfo, menuInfo, loadPage);

router.post('/getRest', function(req, res, next) {
	restId  = req.body.restName;
	console.log(restId);
	res.redirect('/cust_menu');
});

router.post('/addOrder', function(req, res, next) {

	console.log(req.body.orderAmount);

	caller.query(sql.query.addfood, [req.body.orderItem, restId, req.body.orderAmount], (err, data) => {
		if (err) {
			return next(err);
		}
		OrderInfo.push(data.rows[0]);
	});
	res.redirect('/cust_menu');
});


module.exports = router;