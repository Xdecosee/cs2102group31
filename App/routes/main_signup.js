/* ------ Compulsory Header ----- */
var express = require('express');
/* A router to handle requests of corressponding page with same name*/
var router = express.Router();
/*for page authentication.*/
const passport = require('passport');
/*Modules for database interaction*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');



function loadPage(req, res, next) {
    var title = null;
    var type = null;

    if(req.query.user == 'cust'){
       res.render('main_custfds', { 
            title: 'Customer',
            type: 'Customers'
	    });
    }
    else if(req.query.user == 'fds'){
       res.render('main_custfds', { 
            title: 'FDS Manager',
            type: 'FDSManagers'
        });

    }
    else if(req.query.user == 'rider'){
        res.render('main_rider',{
            type: 'DeliveryRiders'
        });
    }
    else if(req.query.user == 'rest'){
        res.render('main_rest',{
            type: 'RestaurantStaff'
        });
    }
    else{
        console.log('not a valid user type??');
		res.redirect('/');
    }
    
   
}

router.get('/', passport.antiMiddleware(),  loadPage);


router.post('/signup/(:type)', function(req, res, next) {


    var type = req.params.type;
    var username = req.body.username;
    var name = req.body.name;
    var password = req.body.password;

    if(type == 'Customers'){

        caller.pool.connect((err, client, done) => {

            const shouldAbort = err => {
                if (err) {
                    console.log("Error in transaction!");
                    client.query('ROLLBACK', err => {
                        if (err) {
                            console.log("Error in rollback!");
                            return next(err);
                        }
                        done()
                        res.redirect('/?signup=' + encodeURIComponent('fail'));
                    })
                }
                
               return !!err;
            }

            client.query('BEGIN', err => {
                if (shouldAbort(err)) return
    
                client.query(sql.query.signupUserWithId,[name, username, password, type], (err, data) => {
                  if (shouldAbort(err)) return
    
                    uid = data.rows[0].uid;
    
                    client.query(sql.query.signupCustomer,[uid], (err, data) => {
                        if (shouldAbort(err)) return
                        client.query('COMMIT', err => {
                            if (err) {
                                console.log("Error in committing transaction");
                                return next(err);
                            }
                            done()
                            res.redirect('/?signup=' + encodeURIComponent('success'));
                        })
                       
                    })
    
                })
            })
    
         });
    }

    else if(type == 'FDSManagers'){

        caller.pool.connect((err, client, done) => {

            const shouldAbort = err => {
                if (err) {
                    console.log("Error in transaction!");
                    client.query('ROLLBACK', err => {
                        if (err) {
                            console.log("Error in rollback!");
                            return next(err);
                        }
                        done()
                        res.redirect('/?signup=' + encodeURIComponent('fail'));
                    })
                }
                
               return !!err;
            }

            client.query('BEGIN', err => {
                if (shouldAbort(err)) return
    
                client.query(sql.query.signupUserWithId,[name, username, password, type], (err, data) => {
                  if (shouldAbort(err)) return
    
                    uid = data.rows[0].uid;
    
                    client.query(sql.query.signupFDS,[uid], (err, data) => {
                        if (shouldAbort(err)) return
                        client.query('COMMIT', err => {
                            if (err) {
                                console.log("Error in committing transaction");
                                return next(err);
                            }
                            done()
                            res.redirect('/?signup=' + encodeURIComponent('success'));
                        })
                       
                    })
    
                })
            })
    
         });

    }

    else if(type == 'RestaurantStaff'){


        var restaurant = req.body.restaurant;
        var location = req.body.location;
        var threshold = req.body.threshold;
        var restaurantid = null;
        var uid = null;

        caller.pool.connect((err, client, done) => {

            const shouldAbort = err => {
                if (err) {
                    console.log("Error in transaction!");
                    client.query('ROLLBACK', err => {
                        if (err) {
                            console.log("Error in rollback!");
                            return next(err);
                        }
                        done()
                        res.redirect('/?signup=' + encodeURIComponent('fail') + '&rest=' + encodeURIComponent('fail'));
                    })
                }
                
               return !!err;
            }

            client.query('BEGIN', err => {
                if (shouldAbort(err)) return
    
                client.query(sql.query.signupRest,[restaurant,location, threshold], (err, data) => {
                  if (shouldAbort(err)) return
    
                    restaurantid = data.rows[0].restaurantid;
    
                    client.query(sql.query.signupUserWithId,[name, username, password, type], (err, data) => {
                        if (shouldAbort(err)) return

                        uid = data.rows[0].uid;

                        client.query(sql.query.signupRestStaff,[uid, restaurantid], (err, data) => {
                            if (shouldAbort(err)) return

                            client.query('COMMIT', err => {
                                if (err) {
                                    console.log("Error in committing transaction");
                                    return next(err);
                                }
                                done()
                                res.redirect('/?signup=' + encodeURIComponent('success'));
                            })
                        })
                       
                    })
    
                })
            })
    
         });
                 
    }
    
    else if(type == 'DeliveryRiders'){
        
        var ridertype = req.body.ridertype;

        if(ridertype == 'fulltime'){
            ridertype = 'FullTime';
        }
        else if(ridertype == 'parttime'){
            ridertype = 'PartTime';
        }
        else {
            console.log("rider type does not exist?");
            res.redirect('/main_signup?user=rider');
        }

        caller.pool.connect((err, client, done) => {

            const shouldAbort = err => {
                if (err) {
                    console.log("Error in transaction!");
                    client.query('ROLLBACK', err => {
                        if (err) {
                            console.log("Error in rollback!");
                            return next(err);
                        }
                        done()
                        res.redirect('/?signup=' + encodeURIComponent('fail'));
                    })
                }
                
               return !!err;
            }

            client.query('BEGIN', err => {
                if (shouldAbort(err)) return
    
                client.query(sql.query.signupUserWithId,[name, username, password, type], (err, data) => {
                  if (shouldAbort(err)) return
    
                    uid = data.rows[0].uid;
    
                    client.query(sql.query.signupRider,[uid, ridertype], (err, data) => {
                        if (shouldAbort(err)) return
                        client.query('COMMIT', err => {
                            if (err) {
                                console.log("Error in committing transaction");
                                return next(err);
                            }
                            done()
                            res.redirect('/?signup=' + encodeURIComponent('success'));
                        })
                       
                    })
    
                })
            })
    
         });
          
    }

    else {

        console.log('not a valid user type??');
		res.redirect('/');

    }

});


module.exports = router;