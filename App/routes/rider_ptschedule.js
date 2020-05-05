/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

//Global variable to store info
var uuid = null;
var queryYear = 0;
var queryMonth = 0;
var months = [ "January", "February", "March", "April", "May", "June", 
           "July", "August", "September", "October", "November", "December" ];

function preload(req, res, next){
	if (req.query.selecteddate !== undefined) {
		queryYear = parseInt(req.query.selecteddate.slice(0, 4));
		queryMonth = parseInt(req.query.selecteddate.slice(5));
	}
	uuid = req.user.uid;
	return next();
}


function indshedInfo(req, res, next) {

	if (queryMonth == 0 || queryYear == 0) {
		req.indshedInfo = {};
		return next();
	} else {
		caller.query(sql.query.indshedInfo, [queryYear,queryMonth,req.user.uid],(err, data) => {
			if(err){
				return next(error);
			}
	
			req.indshedInfo = data.rows;
			return next();
		});
	}
}

function loadPage(req, res, next) {
	/*-- IMPT: How to send data to your frontend ejs file --- */
	res.render('rider_ptschedule',{
		username:req.user.username, 
		name:req.user.name,
		type:req.user.ridertype,
		indshedInfo:req.indshedInfo,
		year: queryYear,
		month: months[queryMonth - 1]

		
	});
}



/* USEFUL: passport.authMiddleware() make sure user is autheticated before accessing page*/
router.get('/', passport.authMiddleware(), preload, indshedInfo, loadPage);

router.post('/selectdate', function (req, res, next) {
	console.log(req.body.date);

	res.redirect('/rider_ptschedule?selecteddate=' + encodeURIComponent(req.body.date));

});


router.post('/addsched', function(req, res, next){
	var day1 = new Date(req.body.day1);
	var day2 = new Date(req.body.day2);
	var day3 = new Date(req.body.day3);;
	var day4 = new Date(req.body.day4);
	var day5 = new Date(req.body.day5);

	var start1 = req.body.start1;
	var start2 = req.body.start2;
	var start3 = req.body.start3;
	var start4 = req.body.start4;
	var start5 = req.body.start5;

	var end1 = req.body.end1;
	var end2 = req.body.end2;
	var end3 = req.body.end3;
	var end4 = req.body.end4;
	var end5 = req.body.end5;
	
	var check = true;

	const shouldAbort = err => {
		if (err) {
		console.error('Error in transaction', err.stack)
		caller.query('ROLLBACK', err => {
			if (err) {
			console.error('Error rolling back client', err.stack)
			}
		})
		check = false;
		}
	}
	
	caller.query('BEGIN',err=>{
		if (shouldAbort(err)) return
	
		caller.query(sql.query.ptschedInsert,[uuid, day1, start1,end1], (err, data) =>{
			if (shouldAbort(err)) return

			if (req.body.day2!="" & start2!="" & end2!=""){
				caller.query(sql.query.ptschedInsert,[uuid, day2, start2,end2], (err, data) =>{
					if (shouldAbort(err)) return
				
					if (req.body.day3!="" & start3!="" & end3!=""){
						caller.query(sql.query.ptschedInsert,[uuid, day3, start3,end3], (err, data) =>{
							if (shouldAbort(err)) return
							
							if (req.body.day4!="" & start4!="" & end4!=""){
								caller.query(sql.query.ptschedInsert,[uuid, day4, start4,end4], (err, data) =>{
									if (shouldAbort(err)) return
									
									if (req.body.day5!="" & start5!="" & end5!=""){
										caller.query(sql.query.ptschedInsert,[uuid, day5, start5,end5], (err, data) =>{
											if (shouldAbort(err)) return

											caller.query('COMMIT', err=>{
												if(err){
													console.error("Error in adding schedule",err.stack)
													res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
												} else if(check){
													res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('success'));	
												} else{
													res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
												}
											})	
										})
									} else{
										caller.query('COMMIT', err=>{
											if(err){
												console.error("Error in adding schedule",err.stack)
												res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
											} else if(check){
												res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('success'));	
											} else{
												res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
											}
										})
									}
								})
							} else{
								caller.query('COMMIT', err=>{
									if(err){
										console.error("Error in adding schedule",err.stack)
										res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
									} else if(check){
										res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('success'));	
									} else{
										res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
									}
								})
							}
						})
					} else {
						caller.query('COMMIT', err=>{
							if(err){
								console.error("Error in adding schedule",err.stack)
								res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
							} else if(check){
								res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('success'));	
							} else{
								res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
							}
						})
					}
				})
			} else {
				caller.query('COMMIT', err=>{
					if(err){
						console.error("Error in adding schedule",err.stack)
						res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
					} else if(check){
						res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('success'));	
					} else{
						res.redirect('/rider_ptschedule?schedule=' + encodeURIComponent('fail'))
					}
				})
			}
		})
	})
})


module.exports = router;