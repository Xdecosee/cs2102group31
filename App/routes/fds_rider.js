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
var ddate = 0;
var start = 0;
var end = 0;
var uuid = 0;

function riderSummary(req, res, next) {

	if (req.query.selecteddate !== undefined) {
		queryYear = parseInt(req.query.selecteddate.slice(0, 4));
		queryMonth = parseInt(req.query.selecteddate.slice(5));
		console.log(queryYear);
		console.log(queryMonth);

	} else if (queryMonth == 0 || queryYear == 0) {
		req.riderSummary = {};
		next();
	}
	caller.query(sql.query.riderSummary, [queryYear, queryMonth], (err, data) => {
		if (err) {
			return next(err);
		}

		// console.log(queryYear);
		// console.log(queryMonth);
		req.riderSummary = data.rows;
		return next();
	});

}

function riderSchedule(req, res, next) {

	if (queryMonth == 0 || queryYear == 0) {
		req.riderSchedule = {};
		return next();
	} else {
		caller.query(sql.query.riderSchedule, [queryYear, queryMonth], (err, data) => {
			if (err) {
				return next(err);
			}
			req.riderSchedule = data.rows;
			return next();
		});
	}
}

function riderName(req, res, next) {

	if (ddate == null || start == 0 || end == 0) {
		req.riderName = {};
		return next();
	} else {
		caller.query(sql.query.riderName, [ddate,start,end], (err, data) => {
			if (err) {
				return next(err);
			}
			req.riderName = data.rows;
			return next();
		});
	}
}

function loadPage(req, res, next) {
	res.render('fds_rider', {
		riderSummary: req.riderSummary,
		riderSchedule: req.riderSchedule,
		rider : req.riderName
	});
}

router.get('/', passport.authMiddleware(), riderSummary, riderSchedule, riderName, loadPage);


router.post('/selectdate', function (req, res, next) {

	res.redirect('/fds_rider?selecteddate=' + encodeURIComponent(req.body.date));

});

router.post('/selectname', function(req, res, next){
	ddate = req.body.day1;
	start = req.body.start1;
	end = req.body.end1;
	console.log(ddate);
	console.log(start);
	console.log(end);

	res.redirect('/fds_rider');

});

router.post('/assign', function(req, res, next){

	var dddate = new Date(ddate);

	uuid = req.body.assignR;
	console.log(uuid);
	caller.query(sql.query.disableTrigger, (err, data) =>{
		if (err) {
			return next(err);
		}
	});

	caller.query(sql.query.ptschedInsert,[uuid, dddate, start,end], (err, data) =>{
		if (err) {
			return next(err);
		}
	});

	caller.query(sql.query.enableTrigger, (err, data) =>{
		if (err) {
			return next(err);
		}

	});
	res.redirect('/fds_rider');
});

module.exports = router;