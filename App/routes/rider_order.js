/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');


function cOrderInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.cOrderInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.cOrderInfo = data.rows;
        return next();
	});
}

function pOrderInfo(req, res, next) {
	/*----- IMPT: Stuff in [] is for your sql parameters ($) ----- */
	caller.query(sql.query.pOrderInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		req.pOrderInfo = data.rows;
        return next();
	});
}

function loadPage(req, res, next) {
	/*-- IMPT: How to send data to your frontend ejs file --- */
	res.render('rider_order',{
		username:req.user.username, 
		name:req.user.name,
		type:req.user.ridertype,
		cOrderInfo:req.cOrderInfo,
		pOrderInfo:req.pOrderInfo
	});
}

/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
router.get('/', passport.authMiddleware(), cOrderInfo, pOrderInfo, loadPage);


/*---- IMPT: Retrieve HTML EJS Form Information ----- */
router.post('/updateOrder', function(req, res, next) {
	//from <form> in ejs file
	var orderid  = req.body.orderid;
	var step  = req.body.step;
	
	if(step == 'Depart To Resturant'){
		caller.query(sql.query.departtoUpdate,[orderid], (err, data) => {
			if(err) {
				console.error("Error in updating order");
			} else {
				// this redirects to same page (i.e. refresh this page) after db success
				res.redirect('/rider_order?update=' + encodeURIComponent('success'));
			}
		});
	}
	else if(step == 'Arrive At Resturant'){
		caller.query(sql.query.arriveUpdate,[orderid], (err, data) => {
			if(err) {
				console.error("Error in updating order");
			} else {
				// this redirects to same page (i.e. refresh this page) after db success
				res.redirect('/rider_order?update=' + encodeURIComponent('success'));
			}
		});
	}
	else if(step == 'Depart From Resturant'){
		caller.query(sql.query.departfrUpdate,[orderid], (err, data) => {
			if(err) {
				console.error("Error in updating order");
			} else {
				// this redirects to same page (i.e. refresh this page) after db success
				res.redirect('/rider_order?update=' + encodeURIComponent('success'));
			}
		});
	}
	else if(step == 'Order Delivered'){
		caller.query(sql.query.deliverUpdate,[orderid], (err, data) => {
			if(err) {
				console.error("Error in updating order");
			} else {
				caller.query(sql.query.statusUpdate,[orderid], (err, data) => {
					if(err) {
						console.error("Error in updating order");
					} else {
						caller.query(sql.query.durationUpate,[orderid], (err, data) => {
							if(err) {
								console.error("Error in updating order");
							} else {
								// this redirects to same page (i.e. refresh this page) after db success
								res.redirect('/rider_order?update=' + encodeURIComponent('success'));
							}
						});
					}
				});
			}
		});
	}
	else if(step == 'Order Failed'){
		caller.query(sql.query.orderFailed,[orderid], (err, data) => {
			if(err) {
				console.error("Error in updating order");
			} else {
				// this redirects to same page (i.e. refresh this page) after db success
				res.redirect('/rider_order?update=' + encodeURIComponent('success'));
			}
		});
	}
	else{
		console.log('invalid input for Order Update');
	}
});

module.exports = router;