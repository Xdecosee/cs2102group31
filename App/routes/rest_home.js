/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');


function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.restInfo = data.rows;
        return next();
	});
}


function loadPage(req, res, next) {
	res.render('rest_home', { 
		username: req.user.username, 
		name:req.user.name,
		restInfo: req.restInfo
	});
}

router.get('/', passport.authMiddleware(), restInfo, loadPage );

module.exports = router;