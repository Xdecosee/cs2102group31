/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var queryYear = 0;
var queryMonth = 0;
var areaInfo = {};

function fdsCustInfo(req, res, next) {

	if (req.query.selecteddate !== undefined) {
		queryYear = parseInt(req.query.selecteddate.slice(0, 4));
		queryMonth = parseInt(req.query.selecteddate.slice(5));
	} else if (queryMonth == 0 || queryYear == 0) {
		req.fdsCustInfo = {};
		//next();
	}
	console.log(queryYear);
	console.log(queryMonth);
	caller.query(sql.query.fds_custInfo, [queryYear, queryMonth], (err, data) => {
		if (err) {
			return next(err);
		}

		req.fdsCustInfo = data.rows;
		return next();
	});
}

function totalOrderEachCust(req, res, next) {

	if (queryMonth == 0 || queryYear == 0) {
		req.totalOrderEachCust = {};
		return next();
	} else {
		caller.query(sql.query.totalOrderEachCust, [queryYear, queryMonth], (err, data) => {
			if (err) {
				return next(err);
			}
			req.totalOrderEachCust = data.rows;
			return next();
		});
	}
}

router.post('/selectArea', function (req, res, next) {
	var area = req.body.area;
	caller.query(sql.query.viewArea, [area], (err, data) => {
		if (err){
			next(err);
		}
		if (data.rows[0] == null) {
			console.log("area: null");
			areaInfo = {};
		} else {
			console.log("area: " + data.rows[0].area);
			areaInfo = data.rows;
		}
	});
	res.redirect('/fds_cust');
});

function loadPage(req, res, next) {
	res.render('fds_cust', {
		username: req.user.username,
		name: req.user.name,
		fdsCustInfo: req.fdsCustInfo,
		totalOrderEachCust: req.totalOrderEachCust,
		areaInfo: areaInfo
		
	});
}

router.get('/', passport.authMiddleware(), fdsCustInfo,totalOrderEachCust,loadPage);

router.post('/selectdate', function (req, res, next) {

	res.redirect('/fds_cust?selecteddate=' + encodeURIComponent(req.body.date));

});

module.exports = router;