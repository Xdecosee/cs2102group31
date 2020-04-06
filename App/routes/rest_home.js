/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*Modules: dbsql (sql statements), dbcaller(just used to call db)*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

function loadPage(req, res, next) {
	res.render('rest_home');
}

router.get('/', loadPage );
module.exports = router;