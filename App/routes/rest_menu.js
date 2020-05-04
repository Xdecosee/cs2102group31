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

    if(req.query.food !== undefined){
		caller.query(sql.query.restFoodInfo, [restID, req.query.food], (err, data) => {
			if(err){
				return next(err);
			}
			res.render('rest_update', { 
				categories: req.categories,
				foodname: req.query.food,
				price: data.rows[0].price, 
				category: data.rows[0].category,
				limit: Number(data.rows[0].dailylimit)
			});
		});
	}

	else {
		res.render('rest_menu', { 
			menuInfo: req.menuInfo,
			categories: req.categories,
			archiveInfo: req.archives
		});
	}

	
}

router.get('/', passport.authMiddleware(), restInfo, menuInfo, categoriesInfo, archiveInfo, loadPage );



router.post('/insertfood', function(req, res, next) {

	var foodname  = req.body.foodname;
	var price  = req.body.price;
	var category = req.body.category;
	var limit = req.body.limit;

	caller.query(sql.query.restInsertFood,[foodname, price, category, limit, restID], (err, data) => {
		if(err) {
			return next(new Error('Failed to add food! Maybe there is another food with the same name in your menu or food archives!'));
		}
        res.redirect('/rest_menu?success=' + encodeURIComponent('insert'));
	});
});


router.post('/archive', function(req, res, next) {

	var foodname  = req.body.archive;

	caller.query(sql.query.restArchive,[restID, foodname], (err, data) => {
		if(err) {
			return next(err);
		}
		res.redirect('/rest_menu?success=' + encodeURIComponent('archive'));
	});
});


router.post('/restore', function(req, res, next) {

	var foodname  = req.body.restore;

	caller.query(sql.query.restRestore,[restID, foodname], (err, data) => {
		if(err) {
			return next(err);
		}
		res.redirect('/rest_menu?success=' + encodeURIComponent('restore'));
	});
});


router.post('/updatepage', function(req, res, next) {

	var foodname  = req.body.update;
	res.redirect('/rest_menu?food=' + encodeURIComponent(foodname));
});


router.post('/update/(:foodname)', function(req, res, next) {

	var foodname  = req.params.foodname;
	var price  = req.body.price;
	var category = req.body.category;
	var limit = req.body.limit;

	caller.query(sql.query.restUpdate,[price, category, limit, restID, foodname], (err, data) => {
		if(err) {
			return next(err);
		}
        res.redirect('/rest_menu?success=' + encodeURIComponent('update'));
	});
});

module.exports = router;