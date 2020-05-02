/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication. See antimiddle.js (passport.antiMiddleware) and middleware.js(passport.authMiddleware)*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Global Variable
var restID = null;
var promoid = null;

function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		restID = data.rows[0].restaurantid;
        return next();
	});
}

function percInfo(req, res, next) {
	caller.query(sql.query.restPercSummary, [restID, restID], (err, data) => {
        if(err){
            return next(error);
        }
		req.percInfo = data.rows;
        return next();
	});
}

function fixedInfo(req, res, next) {
	caller.query(sql.query.restAmtSummary, [restID, restID], (err, data) => {
        if(err){
            return next(error);
        }
        req.fixedInfo = data.rows;
        return next();
	});
}

function loadPage(req, res, next) {
	res.render('rest_promo', { 
        percInfo: req.percInfo,
        fixedInfo: req.fixedInfo
	});
}

function insertPromo(req, res, next){

    caller.query(sql.query.restInsertPromo,[promoid, restID], (err, data) => {
        if(err) {
            console.log ("Error in adding restaurant promotion!");
            console.log (err);
        } 
       
    });   

}

router.get('/', passport.authMiddleware(), restInfo, percInfo, fixedInfo, loadPage );

router.post('/insertpromo', function(req, res, next) {

	var startDate = req.body.startdt.slice(0,10);
    var endDate  = req.body.enddt.slice(0,10);
    var startTime = req.body.startdt.slice(11);
    var endTime = req.body.enddt.slice(11);
    var type = req.body.type;
    var discount = req.body.discount;
    var selectedquery = null;
   

    if(type == "percentage"){
        selectedquery = sql.query.restPercPromo;
    } else if(type == "fixed"){
        selectedquery = sql.query.restAmtPromo;
    } else {
        res.redirect('/rest_promo');
    }
        
    caller.query(selectedquery,[startDate, endDate, startTime, endTime, discount], (err, data) => {
        if(err) {
            console.log ("Error in adding restaurant promotion!");
            console.log (err);
        }
        else {
            promoid = data.rows[0].promoid;
            insertPromo();
            res.redirect('/rest_promo');
        }
      
    });   


});


module.exports = router;