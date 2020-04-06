/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*Modules: dbsql (sql statements), dbcaller(just used to call db)*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');


// GET STATEMENTS
function selectUsers(req, res, next) {
	caller.query(sql.query.all_users, (err, data) => {
        if(err){
            return next(error);
        }
        req.usersInfo = data.rows;
        return next();
	});
}

function loadPage(req, res, next) {
	res.render('login', { 
        title: 'Login',
        usersInfo: req.usersInfo 
    });
}

router.get('/', selectUsers, loadPage );
module.exports = router;