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


function orderStatus(req, res, next) {
	caller.query(sql.query.orderStatus, [custId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.orderInfo = data.rows;
		return next();
	});
}


function foodOrder(req, res, next) {
	caller.query(sql.query.foodOrder, [custId], (err, data) => {
		if (err) {
			return next(err);
		}
		req.foodOrder = data.rows;
		return next();
	});
}

function loadPage(req, res, next) {
	console.log(cardDetails);
	res.render('cust_profile', {
		username: req.user.username,
		name: req.user.name,
		rewardPts: rewardPts,
		cardDetails: cardDetails,
		orderInfo: req.orderInfo,
		reviewInfo: req.reviewInfo
	});
}

router.get('/', passport.authMiddleware(), loadPage);

router.post('/restReview', function(req, res, next) {
	
	var cardInput  = String(req.body.cardDetails);
	cardDetails = cardInput;

	caller.query(sql.query.updateUserCard,[custId,cardInput], (err, data) => {
		console.log(custId);
		console.log(cardDetails);
		if(err) {
			console.log("Error in updating user card");
			//console.log(err);
		} 
	});
	
	res.redirect('/cust_orderInfo');
});

router.post('/restReview', function(req, res, next) {
	
	var cardInput  = String(req.body.cardDetails);
	cardDetails = cardInput;

	caller.query(sql.query.updateUserCard,[custId,cardInput], (err, data) => {
		console.log(custId);
		console.log(cardDetails);
		if(err) {
			console.log("Error in updating user card");
			//console.log(err);
		} 
	});
	
	res.redirect('/cust_home');
});

module.exports = router;