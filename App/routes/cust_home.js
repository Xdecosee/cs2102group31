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
	res.render('cust_home',{
        username: req.user.username,
		name: req.user.name,
    });
}
router.post('/go_profile',function(req,res,next){

	var type = req.body.goProfile;
	console.log(type);
		res.redirect('/cust_profile');
});

router.post('/go_rest',function(req,res,next){

	var type = req.body.goRest;
	console.log(type);
		res.redirect('/cust_menu');
		
});

router.post('/go_orderInfo',function(req,res,next){

	var type = req.body.goOrderInfo;
	console.log(type);
		res.redirect('/cust_orderInfo');
		
});

router.get('/', passport.authMiddleware(), loadPage);
module.exports = router;