/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules: dbsql (sql statements), dbcaller(just used to call db)*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

function loadPage(req, res, next) {
	res.render('fds_home');
}


router.get('/', passport.authMiddleware(), loadPage );
module.exports = router;