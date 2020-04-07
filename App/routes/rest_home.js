/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules: dbsql (sql statements), dbcaller(just used to call db)*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var restId = null;

function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.restInfo = data.rows;
		restId = data.rows[0].restaurantid;
		//Print variable values in your terminal (useful for debugging)
		console.log(req.restInfo);
        return next();
	});
}

function menuInfo(req, res, next) {
	caller.query(sql.query.menuInfo, [restId], (err, data) => {
        if(err){
            return next(error);
        }
		req.menuInfo = data.rows;
        return next();
	});
}


function loadPage(req, res, next) {
	res.render('rest_home', { 
		username: req.user.username, 
		name:req.user.name,
		menuInfo: req.menuInfo,
		restInfo: req.restInfo
	});
}

/*passport.authMiddleware() is just to make sure user is autheticated before accessing page*/
router.get('/', passport.authMiddleware(), restInfo, menuInfo, loadPage );

/*Alternatively for authentication, you can try sth like this (not tested, but seen in Nadiah's repo)*/
/*router.get('/', function(req, res, next) {
	var auth = req.isAuthenticated();
	if (!req.isAuthenticated()) {
		res.redirect('/');
	}
	res.render('rest_home');
});*/

/*Other Commonly Used stuff:*/
/*res.redirect - redirect to another page
res.render - display your current page*/


router.post('/insertfood', function(req, res, next) {
	// Retrieve Information
	var foodname  = req.body.foodname;
	var price  = req.body.price;

	//Redirect after database success
	calle.query(sql_query.query.insertFood,[foodname, price, restId], (err, data) => {
		if(err) {
			console.error("Error in adding food");
		} else {
			//refresh page (i.e. redirect to same page)
			res.redirect('/rest_home');
		}

	});
});

module.exports = router;