/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Global variable to store restID
var restId = null;

function restInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.restInfo = data.rows;
		restId = data.rows[0].restaurantid;
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
	/*-- IMPT: How to send data to your frontend ejs file --- */
	res.render('rest_home', { 
		username: req.user.username, 
		name:req.user.name,
		menuInfo: req.menuInfo,
		restInfo: req.restInfo
	});
}

/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
/* IMPT: For page to load. Order of functions is impt based on which should be called first.*/
router.get('/', passport.authMiddleware(), restInfo, menuInfo, loadPage );


/*---- IMPT: Retrieve HTML EJS Form Information ----- */
router.post('/insertfood', function(req, res, next) {
	//from <form> in ejs file
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