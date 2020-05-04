/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var queryYear = 0;
var queryMonth = 0;

function riderSummary(req, res, next) {

	if (req.query.selecteddate !== undefined) {
		queryYear = parseInt(req.query.selecteddate.slice(0, 4));
		queryMonth = parseInt(req.query.selecteddate.slice(5));
		console.log(queryYear);
		console.log(queryMonth);

	} else if (queryMonth == 0 || queryYear == 0) {
		req.riderSummary = {};
		//return next();
		next();
	}
	caller.query(sql.query.riderSummary, [queryYear, queryMonth], (err, data) => {
		if (err) {
			return next(err);
		}
		confirm.log(data.rows[0].uid);
		console.log(queryYear);
		console.log(queryMonth);
		req.riderSummary = data.rows;
		return next();
	});

}

function loadPage(req, res, next) {
	res.render('fds_rider', {
		riderSummary: req.riderSummary
	});
}

router.get('/', passport.authMiddleware(), riderSummary, loadPage);


router.post('/selectdate', function (req, res, next) {

	res.redirect('/fds_rider?selecteddate=' + encodeURIComponent(req.body.date));

});

module.exports = router;