/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

function ratingInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.ratingInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.ratingInfo = data.rows;
        return next();
	});
}

function workdInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.workdInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.workdInfo = data.rows;
        return next();
	});
}

function loadPage(req, res, next) {
	/*-- IMPT: How to send data to your frontend ejs file --- */
	res.render('rider_home',{
		username:req.user.username, 
		name:req.user.name,
		type:req.user.ridertype,
		ratingInfo:req.ratingInfo,
		workdInfo:req.workdInfo 
	});
	
}

/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
router.get('/', passport.authMiddleware(), ratingInfo, workdInfo, loadPage);
module.exports = router;