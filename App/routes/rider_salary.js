/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

function salaryInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.salaryInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.salaryInfo = data.rows;
        return next();
	});
}

function loadPage(req, res, next) {
	/*-- IMPT: How to send data to your frontend ejs file --- */
	res.render('rider_salary',{
		username:req.user.username, 
		name:req.user.name,
		type:req.user.ridertype,
		salaryInfo:req.salaryInfo	
	});
}

/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
router.get('/', passport.authMiddleware(), salaryInfo, loadPage);
module.exports = router;