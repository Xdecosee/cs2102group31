/* ----- Useful for pages that don't need authentication to view ---*/
function antiMiddleware () {
    return function (req, res, next) {
      //If user not authenticated, can perform an action  
      if (!req.isAuthenticated()) {
        return next()
      }
      //Redirect to login page if authenticated???
      res.redirect('/')
    }
}
  
module.exports = antiMiddleware