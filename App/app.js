/* --- Don't need to touch--- */
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

/* --- Using dotenv     --- */
require('dotenv').config();

/* --- Don't need to touch: view engine setup ----*/
var app = express();
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

/* --- Will log in your terminal whether you are connected to the db ---*/
console.log("Your database connection: " + process.env.DATABASE_URL);

/* --- IMPT(Section 1): Adding Web Pages --- */
var main_login = require('./routes/main_login');




/* --- IMPT(Section 2): Adding Web Pages --- */
app.use('/', main_login);


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

/* --- IMPT(Section 3): Traverse Sections (those in navbar confirm need)--- */
app.get('/', (req, res) => {
	res.render('main_login');
});

module.exports = app;
