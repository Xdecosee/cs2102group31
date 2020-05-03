/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');


function loadPage(req, res, next) {
	res.render('main_login');
}

function logOut(req, res){
	req.session.destroy()
    req.logout();
	res.redirect('/');
}

router.get('/', passport.antiMiddleware(), loadPage );

router.get('/logout', passport.authMiddleware(), logOut);

router.post('/login', passport.authenticate('local', {failureRedirect: '/?login=' + encodeURIComponent('fail')}), function(req, res) {
	var type = req.user.type;

    if(type == "Customers"){
		res.redirect('/cust_home');
	} 
	else if(type == "FDSManagers"){
		res.redirect('/fds_home');
	}
	else if(type == "RestaurantStaff"){
		res.redirect('/rest_home');
	}
	else if(type == "DeliveryRiders"){
		res.redirect('/rider_home');
	}
	else{
		console.log('not a valid user type??');
		res.redirect('/');
	}
   
});

module.exports = router;