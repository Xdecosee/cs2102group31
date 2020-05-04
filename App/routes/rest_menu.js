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

function menuInfo(req, res, next) {
	caller.query(sql.query.restMenuInfo, [restID], (err, data) => {
        if(err){
            return next(err);
		}
        req.menuInfo = data.rows;
        return next();
	});
}


function categoriesInfo(req, res, next) {
	caller.query(sql.query.restSelectCategories, (err, data) => {
        if(err){
            return next(err);
		}
		req.categories = data.rows;
        return next();
	});
}

function archiveInfo(req, res, next) {
	caller.query(sql.query.restArchiveInfo, [restID], (err, data) => {
        if(err){
            return next(err);
		}
		req.archives = data.rows;
        return next();
	});
}


function loadPage(req, res, next) {
	res.render('rest_menu', { 
		menuInfo: req.menuInfo,
		categories: req.categories,
		archiveInfo: req.archives
	});
	
}

router.get('/', passport.authMiddleware(), restInfo, menuInfo, categoriesInfo, archiveInfo, loadPage );



router.post('/insertfood', function(req, res, next) {

	var foodname  = req.body.foodname;
	var price  = req.body.price;
	var category = req.body.category;
	var limit = req.body.limit;

	caller.query(sql.query.restInsertFood,[foodname, price, category, limit, restID], (err, data) => {
		if(err) {
			return next(new Error('Error in adding food! Maybe there is another food with the same name' +
			' in your menu or your food archives!'));
		}
        res.redirect('/rest_menu');
	});
});


router.post('/archive', function(req, res, next) {

	var foodname  = req.body.archive;

	caller.query(sql.query.restArchive,[restID, foodname], (err, data) => {
		if(err) {
			return next(new Error('Error in archiving food!'));
		}
        res.redirect('/rest_menu');
	});
});


router.post('/restore', function(req, res, next) {

	var foodname  = req.body.restore;

	caller.query(sql.query.restRestore,[restID, foodname], (err, data) => {
		if(err) {
			return next(new Error('Error in restoring food!'));
		}
        res.redirect('/rest_menu');
	});
});


module.exports = router;