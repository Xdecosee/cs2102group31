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

function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(err);
        }
		restID = data.rows[0].restaurantid;
        return next();
	});
}

function currentOrders(req, res, next) {
	caller.query(sql.query.restOrders, [restID], (err, data) => {
        if(err){
            return next(err);
		}
        req.restOrders = data.rows;
        return next();
	});
}


function loadPage(req, res, next) {
	res.render('rest_order', { 
		restOrders: req.restOrders
	});
}

router.get('/', passport.authMiddleware(), restInfo, currentOrders, loadPage );


router.post('/cooked/(:orderid)/(:foodname)', function(req, res, next) {

	var orderid = req.params.orderid;
	var foodname = req.params.foodname;

	caller.query(sql.query.restCooked,[orderid, foodname], (err, data) => {
		if(err) {
			return next(new Error("Error in hiding order"));
		}
        res.redirect('/rest_order');
	});
});

module.exports = router;

