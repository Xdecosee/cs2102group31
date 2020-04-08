#  FDS Applicaion AY2019/20 Sem 1

## IMPORTANT NOTE
This FDS application is not meant to be realistic like food delivery apps in real life. It is not meant to be secure as well.

For team: 
1. Run "npm install" again to reinstall all packages again!
2. I didn't implement any async or synchonization codes. (Just in case you all need to know)

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
Sign in to restaurant staff home page with Ariela's account to see the demo.
I tag important parts with IMPT and useful parts with USEFUL.

Main Files to reference:
1. /app.js - adding webpages and traversing
2. /views/rest_home.ejs - frontend (demo both insert and select)
3. /views/partials/navbar_rest.ejs - navigation bar
4. /routes/rest_home.js - backend (NODE.js codes to connect to database using Express node module)
5. /db/dbsql.js - sql statements (insert and select)
6. /db - sql files for setting up psql
7. /public/javascripts/rest.js - validating input

Other Files to reference if have issues:
1. /db/dbcaller.js 
2. /auth folder
3. HTML: /views/partials/footer.js, /views/partials/header.ejs
4. Login matters: /routes/main_login.js, /views/main_login.ejs

## Coding Guide for Team 

A guide on how to insert pages and coding tips. 

### [IMPT] Creating Files

1. Create frontend page under /views with .ejs extension. Skeleton codes needed:

```
<%- include('partials/header') %>
<%- include('partials/navbar_[role]') %>
<!-- Your content will be here ---->
<%- include('partials/footer') %>
```

2. Create backend script under /routes with .js extension with same name as .ejs file. Skeleton codes needed:

```
var express = require('express');
var router = express.Router();

/*for page authentication*/
const passport = require('passport');

/*Modules to interact with DB*/ 
const sql = require('../db/dbsql');
const caller = require('../db/dbcaller');
```

3. t


mini app vs main app

Lets create lesser pages by using multiple sql statements on one page (see restaurant staff example). 


### [IMPT] Frontend : HTML, EJS, <script> javascript(js)
css, navbar, header, footer
calling externel scripts
1. Navigation Bar Customization (if want additional stuff
like dropdown can refer here to): https://www.w3schools.com/bootstrap4/bootstrap_navbar.asp
```<%%>```
### [IMPT] Backend: Linking to database (Node.js)

dbcaller dbsql

### [IMPT] SQL Select + HTML Table

/*get & post */
/*res.redirect - redirect to another page
res.render - display your current page*/
console.log

### [IMPT] SQL Insert + HTML Forms

### [USEFUL] Validation - can implement after finishing impt parts
console.log


### [USEFUL] Authentication - can implement after finishing impt parts

## REFERENCES
1. App.js traverse pages: https://stackoverflow.com/questions/41322217/i-want-to-navigate-to-another-page-in-ejs-using-a-link
2. Header and Footer partial folder: https://medium.com/@henslejoseph/ejs-partials-f6f102cb7433
3. Past Sem #1: https://github.com/thisisadiyoga/cs2102_ay1819_s2
4. Past Sem #2: https://github.com/ndhuu/Restaurant-Simple-Web









