/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules: dbsql (sql statements), dbcaller(just used to call db)*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Global variable to store restID
var restId = null;

function restInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for you sql parameters ($) ----- */
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.restInfo = data.rows;
		restId = data.rows[0].restaurantid;
		/*------ USEFUL: Print variable values in your terminal  for debugging -----*/
		console.log(req.restInfo);
        return next();
	});
}

function menuInfo(req, res, next) {
	//Reuse restID from restInfo to retrieve menu info
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

/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
/* IMPT: Order of functions is impt based on which should be called first when page loads*/
router.get('/', passport.authMiddleware(), restInfo, menuInfo, loadPage );

/*Alternatively for authentication, you can try sth like this (not tested, but seen in Nadiah's repo)*/
/*router.get('/', function(req, res, next) {
	var auth = req.isAuthenticated();
	if (!req.isAuthenticated()) {
		res.redirect('/');
	}
	res.render('rest_home');
});*/


router.post('/insertfood', function(req, res, next) {
	/*---- IMPT: Retrieve HTML EJS Form Information ----- */
	var foodname  = req.body.foodname;
	var price  = Number(req.body.price);

	caller.query(sql.query.insertFood,[foodname, price, restId], (err, data) => {
		if(err) {
			console.error("Error in adding food");
		} else {
			// this redirects to same page (i.e. refresh this page) after db success
			res.redirect('/rest_home');
		}

	});
});

module.exports = router;