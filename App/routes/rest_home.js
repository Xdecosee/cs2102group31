/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Global Variable
var restID = null;
var queryYear = 0;
var queryMonth = 0;
var months = [ "January", "February", "March", "April", "May", "June", 
           "July", "August", "September", "October", "November", "December" ];


function restInfo(req, res, next) {

	if(req.query.selectedmonth !== undefined){
		queryYear = parseInt(req.query.selectedmonth.slice(0,4));
		queryMonth = parseInt(req.query.selectedmonth.slice(5));
	}

	caller.query(sql.query.restIdInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(err);
        }
		req.restInfo = data.rows;
		restID = data.rows[0].restaurantid;
        return next();
	});
}

function restSummary(req, res, next) {

	if(queryMonth == 0 || queryYear == 0){
		req.restSummary = {};
		return next();
	}
	else {
		caller.query(sql.query.restSummary, [restID, queryYear, queryMonth], (err, data) => {
			if(err){
				return next(err);
			}
			req.restSummary = data.rows;
			return next();
		});
	}

}

function restFavFood(req, res, next) {

	if(queryMonth == 0 || queryYear == 0){
		req.restFavFood = {};
		return next();
	}
	else {

		caller.query(sql.query.restFavFood, [restID, queryYear, queryMonth], (err, data) => {
			if(err){
				return next(err);
			}
			req.restFavFood = data.rows;
			return next();
		});

	}
	
}


function loadPage(req, res, next) {
	res.render('rest_home', { 
		username: req.user.username, 
		name:req.user.name,
		restInfo: req.restInfo,
		restSummary: req.restSummary,
		restFavFood: req.restFavFood,
		year: queryYear,
		month: months[queryMonth - 1]
	});
}

router.get('/', passport.authMiddleware(), restInfo, restSummary, restFavFood, loadPage );

router.post('/selectmonth', function(req, res, next) {
	
	res.redirect('/rest_home?selectedmonth=' + encodeURIComponent(req.body.month));

});

module.exports = router;