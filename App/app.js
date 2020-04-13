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
var custHomeRouter = require('./routes/cust_home');
var fdsHomeRouter = require('./routes/fds_home');
var restHomeRouter = require('./routes/rest_home');
var restMenuRouter = require('./routes/rest_menu');
var restOrderRouter = require('./routes/rest_order');
var restPromoRouter = require('./routes/rest_promo');
var riderHomeRouter = require('./routes/rider_home');






/* --- IMPT(Section 2): Adding Web Pages --- */
app.use('/', mainloginRouter);
app.use('/cust_home', custHomeRouter);
app.use('/fds_home', fdsHomeRouter);
app.use('/rest_home', restHomeRouter);
app.use('/rest_menu', restMenuRouter);
app.use('/rest_order', restOrderRouter);
app.use('/rest_promo', restPromoRouter);
app.use('/rider_home', riderHomeRouter);

/* --- Don't need to touch: Error Handler ----*/
app.use(function(req, res, next) {
  next(createError(404));
});
app.use(function(err, req, res, next) {
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  res.status(err.status || 500);
  res.render('main_error');
});

/* --- IMPT(Section 3): Traverse Sections--- */
app.get('/', (req, res) => {
	res.render('main_login');
});

app.get('/cust_home', (req, res) => {
	res.render('cust_home');
});

app.get('/fds_home', (req, res) => {
	res.render('fds_home');
});

app.get('/rest_home', (req, res) => {
	res.render('rest_home');
});

app.get('/rest_menu', (req, res) => {
	res.render('rest_menu');
});

app.get('/rest_order', (req, res) => {
	res.render('rest_order');
});

app.get('/rest_promo', (req, res) => {
	res.render('rest_promo');
});


app.get('/rider_home', (req, res) => {
	res.render('rider_home');
});



module.exports = app;
