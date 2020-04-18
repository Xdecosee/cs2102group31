/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var promoId = null;

function promoInfo(req, res, next) {
	caller.query(sql.query.promoInfo, (err, data) => {
		if (err) {
			return next(err);
		}
		req.promoInfo = data.rows;
		return next();
	});
}

function loadPage(req, res, next) {
	res.render('fds_promo', {
		promoInfo: req.promoInfo
	});
}

// function insertPromo(req, res, next) {
// 	caller.query(sql.query.fdsInsertPromo, [promoid], (err, data) => {
// 		if (err) {
// 			console.log("Error in adding FDS promotion!");
// 			console.log(err);
// 		}
// 	});
// }

router.get('/', passport.authMiddleware(), promoInfo, loadPage);

router.post('/insertpromo', function (req, res, next) {

	var startDate = req.body.startdate;
	var endDate = req.body.enddate;
	var type = req.body.type;
	var discount = req.body.discount;
	var selectedquery = null;

	if (type == "percentage") {
		selectedquery = sql.query.fdsPercPromo;
	} else if (type == "fixed") {
		selectedquery = sql.query.fdsAmtPromo;
	} else {
		res.redirect('/fds_promo');
	}

	caller.query(selectedquery, [startDate, endDate, discount], (err, data) => {
		if (err) {
			console.log("Error in adding fds promotion!");
			console.log(err);
		}
		else {
			promoId = data.rows[0].promoid;
			console.log(data.rows[0].promoid);
			console.log(promoId);
			caller.query(sql.query.fdsInsertPromo, [promoId], (err, data) => {
				if (err) {
					console.log("Error in adding FDS promotion!");
					console.log(err);
				}
			});
			res.redirect('/fds_promo');
		}
	});
});

module.exports = router;
// router.get('/', passport.authMiddleware(), loadPage);
// module.exports = router;