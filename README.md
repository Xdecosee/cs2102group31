#  FDS Applicaion AY2019/20 Sem 1

## IMPORTANT NOTE
This FDS application is not meant to be realistic like food delivery apps in real life. It is not meant to be secure as well.

For team: 
1. Run "npm install" again to reinstall all packages again!
2. I didn't implement any async or synchonization codes. (Just in case you need to know)
3. I tried to optimise code as much as I can by reducing repeating codes. But if I optimised too much and its affecting your code, do let me know. If I optimise too little, you can just change it.

## Setting Up Repo
1. Download Node js at https://nodejs.org/en/
2. In a terminal (from vscode or cmd) change directory to /App folder and run 'npm install'.

A "node_modules" folder should be created in your directory and as this folder shouldn't be pushed to github, I have added it in a gitignore file. 

3. Import psql_script_with_insert.sql under /App/db folder to psql.

4. Create a .env file under the /App folder and insert with a single line: 
DATABASE_URL=postgres://username:password@host address:port/database_name
For example. DATABASE_URL=postgres://postgres:1@localhost:5432/postgres

This .env should be ignored through .gitignore and not pushed to github. 

If gitignore isn't working for you, do these steps: http://www.codeblocq.com/2016/01/Untrack-files-already-added-to-git-repository-based-on-gitignore/. In vscode, the ignored files should be greyed out

## Running the App
1. In your terminal (at /App), type 'npm start'. 

I added a 'console.log' in app.js that will show your database connection string at your terminal if successful connected to postgres. 

2. Open http://localhost:3000 in your browser. 

For testing subpages that require no authentication, you can access through http://localhost:3000/{page_name}

3. To stop running the app, Ctrl + C in your terminal to terminate the server. 

Supposedly, you forget to Ctrl + C, just kill the process at port 3000. For windows, go your task manager, select the 'Processes tab', search for 'Node.js: Server-side JavaScript', select it and click on 'End task' button.

## File Name Prefixes
Seperating files into subfolders was hard. So I decided to differentiate files with these naming:
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
...
/* --- IMPT(Section 3): Traverse Sections--- */
app.get('/page', (req, res) => {
	res.render('page');
});
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









