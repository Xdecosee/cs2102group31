/* --- Don't need to touch--- */
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const session = require('express-session')
const passport = require('passport')

/* --- Using dotenv and login to db     --- */
require('dotenv').config();
//Will log in your terminal whether you are connected to the db
console.log("Your database connection: " + process.env.DATABASE_URL);

/* --- Don't need to touch: view engine setup ----*/
var app = express();
app.use(session({
  secret: process.env.SECRET || 'tired',
  resave: true,
  saveUninitialized: true
}))
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');
app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));


/* --- Don't need to touch: Body Parser --- */
var bodyParser = require('body-parser');
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));


require('./auth').init(app);
app.use(passport.initialize())
app.use(passport.session())


/* --- IMPT(Section 1): Adding Web Pages --- */
var mainloginRouter = require('./routes/main_login');

var mainSignUpRouter = require('./routes/main_signup');

var custHomeRouter = require('./routes/cust_home');
var custProfileRouter = require('./routes/cust_profile');
var custMenuRouter = require('./routes/cust_menu');
var custOrderRouter = require('./routes/cust_orderInfo');

var fdsHomeRouter = require('./routes/fds_home');
//fds
var fdsCustRouter = require('./routes/fds_cust');
var fdsRestRouter = require('./routes/fds_rest');
var fdsRiderRouter = require('./routes/fds_rider');
var fdsPromoRouter = require('./routes/fds_promo');

var restHomeRouter = require('./routes/rest_home');
var restMenuRouter = require('./routes/rest_menu');
var restOrderRouter = require('./routes/rest_order');
var restPromoRouter = require('./routes/rest_promo');
var riderHomeRouter = require('./routes/rider_home');
var riderSalaryRouter = require('./routes/rider_salary');
var riderOrderRouter = require('./routes/rider_order');
var riderftScheduleRouter = require('./routes/rider_ftschedule');
var riderptScheduleRouter = require('./routes/rider_ptschedule');

/* --- IMPT(Section 2): Adding Web Pages --- */
app.use('/', mainloginRouter);
app.use('/main_signup', mainSignUpRouter);
app.use('/cust_home', custHomeRouter);
app.use('/cust_menu', custMenuRouter);
app.use('/cust_profile', custProfileRouter);
app.use('/cust_orderInfo', custOrderRouter);
app.use('/fds_home', fdsHomeRouter);
app.use('/rest_home', restHomeRouter);
app.use('/rest_menu', restMenuRouter);
app.use('/rest_order', restOrderRouter);
app.use('/rest_promo', restPromoRouter);
app.use('/rider_home', riderHomeRouter);
app.use('/rider_salary', riderSalaryRouter);
app.use('/rider_order', riderOrderRouter);
app.use('/rider_ftschedule', riderftScheduleRouter);
app.use('/rider_ptschedule', riderptScheduleRouter);
app.use('/fds_cust', fdsCustRouter);
app.use('/fds_rest', fdsRestRouter);
app.use('/fds_rider', fdsRiderRouter);
app.use('/fds_promo', fdsPromoRouter);


/* --- Don't need to touch: Error Handler ----*/
app.use(function(req, res, next) {
  next(createError(404));
});
app.use(function(err, req, res, next) {
  var type = null;
  if(req.isAuthenticated()){
    type = req.user.type;
  }
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  res.status(err.status || 500);
  res.render('error_app', {error: err, 	type: type});
});

module.exports = app;
