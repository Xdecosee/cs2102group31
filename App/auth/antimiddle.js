/*Useful for pages that don't need authentication to view*/
function antiMiddleware () {
    return function (req, res, next) {
      if (!req.isAuthenticated()) {
        return next()
      }
      res.redirect('/')
    }
}
  
module.exports = antiMiddleware