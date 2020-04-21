const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;

const authMiddleware = require('./middleware');
const antiMiddleware = require('./antimiddle');

/*-----Find users by username during login and sets up session values ---*/
function findUser (username, callback) {
	caller.query(sql.query.login, [username], (err, data) => {
		if(err) {
			console.error("Cannot find user");
			return callback(null);
		}
		
		if(data.rows.length == 0) {
			console.error("User does not exists?");
			return callback(null)
		} else if(data.rows.length == 1) {
      /*-------- IMPT: Useful session values for using in pages -----*/
			return callback(null, {
				username    : data.rows[0].username,
				password    : data.rows[0].password,
				name  : data.rows[0].name,
				uid   : data.rows[0].uid,
        type     : data.rows[0].type,
        ridertype: data.rows[0].ridertype
			});
		} else {
			console.error("More than one user?");
			return callback(null);
		}
	});
}

passport.serializeUser(function (user, cb) {
  cb(null, user.username);
})

passport.deserializeUser(function (username, cb) {
  findUser(username, cb);
})

/*--------Find users by username during login and sets up session values -----*/
function initPassport () {
  passport.use(new LocalStrategy(
    (username, password, done) => {
      findUser(username, (err, user) => {
        if (err) {
          return done(err);
        }

        // User not found
        if (!user) {
          console.error('User not found');
          return done(null, false);
        }

        if(password != user.password ){
            return done(null, false);
        }

        return done(null, user);

      })
    }
  ));

  passport.authMiddleware = authMiddleware;
  passport.antiMiddleware = antiMiddleware;
  passport.findUser = findUser;
}

module.exports = initPassport;