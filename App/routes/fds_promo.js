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

function currentPromoInfo(req, res, next) {
	caller.query(sql.query.currentPromoInfo, (err, data) => {
		if (err) {
			return next(err);
		}
		req.currentPromoInfo = data.rows;
		return next();
	});
}

function expiredPromoInfo(req, res, next) {
	caller.query(sql.query.expiredPromoInfo, (err, data) => {
		if (err) {
			return next(err);
		}
		req.expiredPromoInfo = data.rows;
		return next();
	});
}

function loadPage(req, res, next) {
	res.render('fds_promo', {
		name: req.user.name,
		currentPromoInfo: req.currentPromoInfo,
		expiredPromoInfo: req.expiredPromoInfo
	});
}

router.get('/', passport.authMiddleware(), currentPromoInfo, expiredPromoInfo, loadPage);

router.post('/insertpromo', function (req, res, next) {

	var startDate = req.body.startdate;
	var endDate = req.body.enddate;
	var type = req.body.type;
	var discount = req.body.discount;
	var selectedquery = null;

	if (type == "percentage") {
		selectedquery = sql.query.fdsPercentPromo;
	} else if (type == "fixed") {
		selectedquery = sql.query.fdsAmtPromo;
	} else {
		res.redirect('/fds_promo');
	}

	console.log(startDate);
	console.log(endDate);
	console.log(discount);

	caller.query(selectedquery, [startDate, endDate, discount], (err, data) => {
		if (err) {
			console.log("Error in adding FDS promotion!");
			return next(err);
		}
		else {
			promoId = data.rows[0].promoid;
			console.log(data.rows[0].promoid);
			console.log(promoId);
			caller.query(sql.query.fdsInsertPromo, [promoId], (err, data) => {
				if (err) {
					console.log("Error in adding FDS promotion!");
					return next(err);
				}
			});
			res.redirect('/fds_promo');
		}
	});
});

module.exports = router;
// router.get('/', passport.authMiddleware(), loadPage);
// module.exports = router;