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
	res.render('cust_home');
}

router.get('/', passport.authMiddleware(), loadPage );
module.exports = router;