/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Gloabl Variable
var restID = null;

function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		restID = data.rows[0].restaurantid;
        return next();
	});
}

function menuInfo(req, res, next) {
	caller.query(sql.query.menuInfo, [restID], (err, data) => {
        if(err){
            return next(error);
		}
        req.menuInfo = data.rows;
        return next();
	});
}


function loadPage(req, res, next) {
	res.render('rest_menu', { 
		menuInfo: req.menuInfo
	});
}

router.get('/', passport.authMiddleware(), restInfo, menuInfo, loadPage );



router.post('/insertfood', function(req, res, next) {

	var foodname  = req.body.foodname;
	var price  = Number(req.body.price);

	caller.query(sql.query.insertFood,[foodname, price, restID], (err, data) => {
		if(err) {
			console.log ("Error in adding food!");
			console.log (err);
		}
        res.redirect('/rest_menu');
	});
});

module.exports = router;