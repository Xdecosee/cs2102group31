/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

function loadPage(req, res, next) {
	res.render('fds_home', {
		name: req.user.name
	});
}

router.post('/go_cust',function(req,res,next){

	var type = req.body.goCust;
	console.log(type);
		res.redirect('/fds_cust');
});

router.post('/go_rest',function(req,res,next){

	var type = req.body.goRest;
	console.log(type);
		res.redirect('/fds_rest');
});

router.post('/go_rider',function(req,res,next){

	var type = req.body.goRider;
	console.log(type);
		res.redirect('/fds_rider');
});

router.post('/go_promo',function(req,res,next){

	var type = req.body.goPromo;
	console.log(type);
		res.redirect('/fds_promo');
});

router.get('/', passport.authMiddleware(), loadPage);
module.exports = router;