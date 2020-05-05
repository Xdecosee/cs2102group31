#  FDS Application AY2019/20 Sem 1

## IMPORTANT NOTE!
This FDS application is not meant to be realistic like food delivery apps in real life. It is not meant to be secure as well. This README and code is available at https://github.com/Xdecosee/cs2102group31 for easier readability!

For NUS CS2102 graders, please look at the following sections:
1. Setting Up Repo
2. Running and Testing the App

## Setting Up Repo
1. Download Node js at https://nodejs.org/en/. Download the version that is under "Recommended for most users". The version used for creating this repo is v12.16.1.
2. In a terminal, change directory to the /App folder and run 'npm install'. A "node_modules" folder should be created in your /App directory.

3. Import psql_script_with_insert.sql under /App/db folder to psql. Recommended: psql version 12.1.

4. Create a .env file under the /App folder and insert with a single line: 
DATABASE_URL=postgres://username:password@host address:port/database_name
For example. DATABASE_URL=postgres://postgres:12345@localhost:5432/postgres

5. For Developers: This .env and node_modules folder should be ignored through .gitignore and not pushed to github. If gitignore isn't working for you, do these steps: http://www.codeblocq.com/2016/01/Untrack-files-already-added-to-git-repository-based-on-gitignore/. In vscode, the ignored files should be greyed out

## Running and Testing the App
1. Please test the application between 10am to 10pm as customer accounts can only make food orders within 10am to 10pm. In addition, Safari and Firefox currently doesn't support certain html form features in this repo. Recommended to use Chrome for testing the pages. 

2. In your terminal (at /App), type 'npm start'. Your database connection string in .env will be shown at your terminal. 

3. Open http://localhost:3000 in your browser.

4. As no two users should have the same username, here are some usernames available use for sign up:
testrider, testrest, testcust, testfds 

5. The prepopulated data from psql script is solely for developers to test their pages. Hence, it may be incompelete e.g. not every rider has a existing schedule. Nonetheless, you may see part of sample/testing data for restaurant staff and delivery riders through these accounts:

Restaurant Staff
Username: minestrone
Password: 12345

Full Time Delivery Rider
Username: aveldens3
Password: cdqUwd81YzX

Part Time Delivery Rider
Username: gtarrier9
Password: G92FSUJuvL9e

6. Sql Statements used throughout the application is complied under /App/db/dbsql.js


7. To stop running the app, Ctrl + C in your terminal to terminate the server after using the website. Supposedly, you forget to Ctrl + C, just kill the process at port 3000. For windows, go your task manager, select the 'Processes tab', search for 'Node.js: Server-side JavaScript', select it and click on 'End task' button.

## File Name Prefixes
Files are differentiated with these naming:
1. cust - Customers related files
2. rider - Delivery Riders related files
3. fds - FDS Manager related files
4. rest - Restaurant Staff related files

## Coding Guide for Team - Restaurant Staff Home Page Example
I put some skeleton codes for you all to understand how to code. Sign in to restaurant staff home page with Ariela's account to see the demo and then would be easier to understand the codes behind as well. I tag important parts with IMPT and useful parts with USEFUL. I have added comments to the files if you all need help understanding the codes. 

Main Files to see:
1. /app.js - adding webpages and traversing
2. /views/rest_home.ejs - frontend (demo both insert and select)
3. /views/partials/navbar_rest.ejs - navigation bar
4. /routes/rest_home.js - backend (NODE.js codes to connect to database using Express node module)
5. /db/dbsql.js - sql statements (insert and select)
6. /db - sql files for setting up psql
7. /public/javascripts/rest.js - validating input

Other Files to see:
1. /db/dbcaller.js 
2. /auth folder
3. HTML: /views/partials/footer.js, /views/partials/header.ejs
4. Login matters: /routes/main_login.js, /views/main_login.ejs


### [IMPT] Creating Page

1. Create frontend page under /views with .ejs extension. Skeleton codes needed:

```
<%- include('partials/header') %>
<%- include('partials/navbar_[role]') %>
<!-- Your content will be here ---->
<%- include('partials/footer') %>
```

2. Create Node js backend script under /routes with .js extension with same name as .ejs file. Skeleton codes needed:

```
var express = require('express');
var router = express.Router();

/*Modules to interact with DB*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');

/*Load Page*/
function loadPage(req, res, next) {
	res.render('page');
}

/*Define Router for page*/
router.get('/', loadPage );


module.exports = router;
```

3. Add the two files to app.js under the IMPT sections.

```
/* --- IMPT(Section 1): Adding Web Pages --- */
var pageRouter = require('./routes/page');
...
/* --- IMPT(Section 2): Adding Web Pages --- */
app.use('/page', pageRouter);
```

Lets create lesser pages by using multiple sql statements on one page (see restaurant staff example).

How is the router file (.js) in step 2 different from app.js? See [this stackoverflow](https://stackoverflow.com/questions/28305120/differences-between-express-router-and-app-get)

### [IMPT] Frontend : HTML, EJS, <script> javascript(js)

#### HTML and Frontend

Most of the frontend matters (things that user can see) will be using ejs (a node.js templating module) and html. Ejs stuff usually in this tag ```<%%>```.  

Usual HTML Reference (for me): Aside from stackoverflow or other code snippets website, usually I refer to this website https://www.w3schools.com/. 

E.g. Date Time Picker for your forms https://www.w3schools.com/tags/att_input_type_datetime-local.asp

#### Repeating HTML CODES 
I optimized repeating codes through [this guide](https://medium.com/@henslejoseph/ejs-partials-f6f102cb7433) by createing the /views/partials folder. Currently,
for each user role, have their individual navigation bars. 

#### Navigation Bar
Use this guide to build your own nav bar: https://www.w3schools.com/bootstrap4/bootstrap_navbar.asp

#### Styling (CSS)
All pages are  currently using Bootstrap4 css script as seen in header.ejs. I left the default
stylesheet *style.css* under public/stylesheets if required.

#### Javascript Functions
Supposedly you need to include javascript functions for frontend. You may put the codes in either way:
1. put codes in ```<script> ``` tag
2. put codes in a javascript file under public/javascripts and reference the file in your ejs file through ```<script src="javascripts/[filename].js"></script>```

Example is being shown in rest_staff.ejs.


### [IMPT] Backend: Linking to database (Node.js)

As seen in the example files under /routes folder, this is general format of query:
```
caller.query(sql.query.{query_name}, [{param1}, {param2}], (err, data) => {...});
```
1. **sql** is list of database queries from /db/dbsql.js.
2. **caller** is to execute the database query through /db/dbcaller.js.
3. Access the data you retrieved through **data.rows**

4. I implemented multiple calls to select statements on rest_home using [this guide](https://stackoverflow.com/questions/28128323/rendering-view-after-multiple-select-queries-in-express) by
calling various functions when the page loads through ```router.get('/')```

5. Node Modules related to database are pg and dotenv(for keeping database url).

6. **Session values** (e.g. user uid) can be requested though using req.user.{field_name} in your js files for the parameters of the sql statements. A list of session values can be found under /auth/init.js  

### [IMPT] SQL Select + HTML Table, SQL Insert + HTML Forms

For an easy start, use HTML Tables for select statments and HTML Forms to do insert, update, delete statements.

### [IMPT] Debugging Tip

Use **console.log** in your javascript codes (any js files) to check if your variables are taking in the correct values. i.e. console.log(variable_name)

It simply prints varaible contents in your terminal. You can use it to print notifications for youself in the terminal as well e.g. console.log("data inserted into db successfully!); 

### [USEFUL] Validation - can implement after finishing impt parts
Our database has some constraints on attributes e.g. 255 character limit for the attribut value. Like in the example files, you can implement several functions in ```<script>``` tag  to validate the user input before sending it to database.

### [USEFUL] Authentication - can implement after finishing impt parts
Authentication and login matters are user through Passport.js node module. As seen in the example files under /routes folder, ```passport.authMiddleware()``` is called
to check if a user is authorized to access a page. 

Alternatively for authentication, you can try sth like this to test authentication when page loads(not tested, but seen in Nadiah's repo)

```
router.get('/', function(req, res, next) {
	var auth = req.isAuthenticated();
	if (!req.isAuthenticated()) {
		res.redirect('/');
	}
	res.render('page');
});
```


## REFERENCES
1. App.js traverse pages: https://stackoverflow.com/questions/41322217/i-want-to-navigate-to-another-page-in-ejs-using-a-link
2. Past Sem #1: https://github.com/thisisadiyoga/cs2102_ay1819_s2
3. Past Sem #2: https://github.com/ndhuu/Restaurant-Simple-Web
4. Past Sem guide: The first code I did following the guide is in https://github.com/Xdecosee/cs2102group31/tree/backup_one









