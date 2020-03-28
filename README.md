#  FDS Applicaion AY2019/20 Sem 1
## Tutorial for Team

### IMPORTANT NOTE
So far completed up to section 5 of past sem guide. Left with section 6 and 7. The tutorials below only cover some selected stuff between section 1 and section 5. Not adding database folder stuff into App/db folder yet until queries settled and stuff under the below section "still need to figure out" are done.

### Setting Up this repo
1. Download NodeJS at https://nodejs.org/en/
2. In a terminal (from vscode or cmd) change directory (cd) to  the folder .../App folder and run 'npm install'. 'npm install' can be useful if having any missing packages required for the application.

A "node_modules" folder should be created in your directory and as this folder shouldn't be pushed to github, I have added it in a gitignore file. 

3. Go to select.js and change the password field at the Pool code to your postgres password. Change the database name as well. Remember not to push your password into github and change it back to ****.

### Ejs and js file Tutorial
1. Ejs file are like the front end pages (i.e. html page). Stored under views folder.
2. Js file are like files to connect to your database and retrieve info. Stored under routes folder.
3. For every (page).ejs, there must be a (page).js.

4. At app.js in under comments of "IMPT(Section 1):" and "IMPT(Section 2):" have to write 
*var (page)Router = require('./routes/(page)');* and *app.use('/(page)', (page)Router);* RESPECTIVELY.

5. The guide js files use *res.render(’/’, {title: ’Page’});* Additional ARGUMENTS are pass in after "title". Since we gonna use sql tables, in select.js, res.render is enclosed in a pool function and the "usersInfo: data.rows" will retrieve all data from the select statement. "usersInfo" is an argument I give to store the data retrieved.  

6. The guide ejs files references arguments from js files through these <%%> . 

7. Links to bootstrap is included in every ejs. I think that the file design are automatically linked through them? 

Read the past sem guide for more detailed stuff. 

### Running the App
1. In your terminal (at .../App), type 'node bin\www'. 
2. Open http://localhost:3001 in your browser for index.ejs. 
3. To run select.ejs, go to psql to insert some fake data in users table before opening http://localhost:3001/select 
4. To stop running the app, aside from closing your browser, remember to Ctrl + C in your terminal to terminate the server. 

### Still need to Figure Out
1. How to structure the folders such that Pool and Queries can be accessed from db folder instead of individual js files (those codes in select.js)
2. How to do session values for userid i.e. how pass session values from page to page. User id need to be used in many js files in the sql statement parameters.
3. How to retreive user input from html forms into sql parameters. 

Hopefully the guide can address some of these ^

