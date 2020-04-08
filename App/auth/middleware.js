/* ----- USEFUL: Useful for pages that need authentication before access ------ */
/* You may implement this after coding all of your functions. */
function authMiddleware () {
    return function (req, res, next) {
      //If user  authenticated, then can perform an action (e.g. view page, insert data etc.)
      if (req.isAuthenticated()) {
        return next()
      }
      res.redirect('/')
    }
}
/*Still not completed: can access others pages even authenticated. 
e.g. rest staff can see customers page*/

module.exports = authMiddleware