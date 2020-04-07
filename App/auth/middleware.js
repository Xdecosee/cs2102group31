/*Useful for pages that need authentication before access*/
function authMiddleware () {
    return function (req, res, next) {
      if (req.isAuthenticated()) {
        return next()
      }
      res.redirect('/')
    }
}
/*Still buggy: can access other pages even authenticated*/

module.exports = authMiddleware