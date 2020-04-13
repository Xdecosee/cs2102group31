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

function restInfo(req, res, next) {
	caller.query(sql.query.restInfo, [req.user.uid], (err, data) => {
        if(err){
            return next(error);
        }
		restID = data.rows[0].restaurantid;
        return next();
	});
}

function loadPage(req, res, next) {
	res.render('rest_promo', { 
		menuInfo: req.menuInfo
	});
}

router.get('/', passport.authMiddleware(), restInfo, loadPage );

router.post('/insertpromo', function(req, res, next) {

	var start = req.body.startdt;
    var end  = req.body.enddt;
    var type = req.body.type;
    var discount = req.body.discount;

    console.log(Date(req.body.startdt));


});


module.exports = router;