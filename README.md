#  FDS Applicaion AY2019/20 Sem 1

## IMPORTANT NOTE
This FDS application is not meant to be realistic like food delivery apps in real life. It is not meant to be secure as well.

For team: Run "npm install" again to reinstall all packages again!

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

## Coding Guide for Team (TL;DR)
Main Files to reference:
1. /app.js - adding webpages and traversing
2. /views/rest_home.ejs - frontend
3. /public/javascripts/rest.js - 
4. /views/partials/navbar_rest.ejs - navigation bar
5. /routes/rest_home.js - backend (NODE.js codes to connect to database using Express node module)
6. /db/dbsql.js - sql statements (insert and select)
7. /db - sql files for setting up psql

Other Files to reference if have issues:
1. /db/dbcaller.js 
2. /auth folder
3. HTML: /views/partials/footer.js, /views/partials/header.ejs
4. Login matters: /routes/main_login.js, /views/main_login.ejs

## Coding Guide for Team

A guide on how to insert pages and coding tips. 

### Creating Files
#### File Name Prefixes
Seperating files into subfolders was hard. So I decided to differentiate files with these naming:
1. cust - Customers related files
2. rider - Delivery Riders related files
3. fds - FDS Manager related files
4. rest - Restaurant Staff related files


### IMPT and Useful Codes

### Frontend : HTML, EJS, <script> javascript(js)
css, navbar
calling externel scripts
1. Navigation Bar Customization (if want additional stuff
like dropdown can refer here to): https://www.w3schools.com/bootstrap4/bootstrap_navbar.asp
```<%%>```
### Backend: Linking to database (Node.js)

### SQL Select + HTML Table

/*get & post */
/*res.redirect - redirect to another page
res.render - display your current page*/
console.log

### SQL Insert + HTML Forms

### Validation
console.log


### Authentication


## REFERENCES
1. App.js traverse pages: https://stackoverflow.com/questions/41322217/i-want-to-navigate-to-another-page-in-ejs-using-a-link














