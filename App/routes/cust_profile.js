/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

var custId = null;
var rewardPts = null;
var cardDetails = null;

function custInfo(req, res, next) {
	caller.query(sql.query.custInfo, [req.user.uid], (err, data) => {
		if (err) {
			return next(err);
		}
		req.custInfo = data.rows;
		custId = data.rows[0].uid;
		rewardPts = data.rows[0].rewardpts;
		cardDetails = data.rows[0].carddetails;
		return next();
	});
}

function orderInfo(req, res, next) {
	caller.query(sql.query.orderInfo, [custId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.orderInfo = data.rows;
		return next();
	});
}


function reviewInfo(req, res, next) {
	caller.query(sql.query.reviewInfo, [custId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.reviewInfo = data.rows;
		return next();
	});
}

function loadPage(req, res, next) {
	res.render('cust_profile', {
		username: req.user.username,
		name: req.user.name,
		rewardPts: rewardPts,
		cardDetails: cardDetails,
		orderInfo: req.orderInfo,
		reviewInfo: req.reviewInfo
	});
}

router.get('/', passport.authMiddleware(), custInfo, orderInfo, reviewInfo, loadPage);

router.post('/updatecard', function(req, res, next) {
	
	var cardInput  = String(req.body.cardDetails);
	cardDetails = cardInput;
	caller.query(sql.query.updateCustomerCard,[custId,cardInput], (err, data) => {
		if(err) {
			console.error("Error in updating cust card");
		}
	});
	console.log(cardDetails);
	res.redirect('/cust_profile');
});

module.exports = router;