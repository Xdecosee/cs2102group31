/* --- Don't need to touch--- */
var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const session = require('express-session')
const passport = require('passport')

/* --- Using dotenv     --- */
require('dotenv').config();

/* --- IMPT(Section 1): Adding Web Pages --- */
var indexRouter = require('./routes/index');
var selectRouter = require('./routes/select');
var usersRouter = require('./routes/users');
var aboutRouter = require('./routes/about');
var insertRouter = require('./routes/insert');

/* --- Don't need to touch: view engine setup ----*/
var app = express();
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//Authentication Setup
require('./auth').init(app);
require('./routes/auth')(app);

app.use('/', indexRouter);
app.use('/users', usersRouter);


/* --- IMPT(Section 2): Adding Web Pages --- */
app.use('/select', selectRouter);
app.use('/insert', insertRouter);


//* --- Don't need to touch: Error Handler ----*/
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

/*Will log in your terminal whether you are connected to the db*/
console.log("Your database connection: " + process.env.DATABASE_URL);


/* --- IMPT(Section 3): Traverse Sections --- */

app.get('/', (req, res) => {
	res.render('index');
});
  
app.get('/select', (req, res) => {
	res.render('select');
});

app.get('/insert', (req, res) => {
	res.render('insert');
});

module.exports = app;
