#  FDS Applicaion AY2019/20 Sem 1
## Tutorial for Team

### IMPORTANT NOTE
Completed the guide. The tutorials below only cover some selected stuff in all sections of the guide. Not adding database folder stuff into App/db folder yet until queries settled and stuff under the below section "still need to figure out" are done. 

### Setting Up this repo
1. Download NodeJS at https://nodejs.org/en/
2. In a terminal (from vscode or cmd) change directory (cd) to  the folder .../App folder and run 'npm install'. 'npm install' can be useful if having any missing packages required for the application.

A "node_modules" folder should be created in your directory and as this folder shouldn't be pushed to github, I have added it in a gitignore file. 

If gitignore isn't working for you, do these steps: http://www.codeblocq.com/2016/01/Untrack-files-already-added-to-git-repository-based-on-gitignore/. In vscode, the ignored files should be greyed out

3. Following section 8 of the guide, create a .env file under the /App folder and insert with a single line: DATABASE URL=postgres://username:password@host address:port/database_name
For example. DATABASE_URL=postgres://postgres:1@localhost:5432/postgres

This .env should be ignored through .gitignore and not pushed to github. 

### Ejs and js file Tutorial
1. Ejs file are like the front end pages (i.e. html page). Stored under views folder.
2. Js file are like files to connect to your database and retrieve info. Stored under routes folder.
3. For every (page).ejs, there must be a (page).js.

4. At app.js in under comments of "IMPT(Section 1):" and "IMPT(Section 2):" have to write 
*var (page)Router = require('./routes/(page)');* and *app.use('/(page)', (page)Router);* RESPECTIVELY.
*app.get* under "IMPT(Section 3):" is required to render the various pages when traversing through nav bar.

5. The guide js files use *res.render(’/’, {title: ’Page’});* Additional ARGUMENTS are pass in after "title". Since we gonna use sql tables, in select.js, res.render is enclosed in a pool function and the "usersInfo: data.rows" will retrieve all data from the select statement. "usersInfo" is an argument I give to store the data retrieved.  

6. The guide ejs files references arguments from js files through these <%%> . 

7. Links to bootstrap is included in every ejs. I think that the file design are automatically linked through them? 

8. The current nav bar can be edited under ../views/partials/navbar.ejs. I used this: https://medium.com/@henslejoseph/ejs-partials-f6f102cb7433 so that we don't to repeat a chunk of code for every new page created. Temporarily is just one navbar for now as guide. We will need create multiple nav bars for different user roles. The only code to repeat on every page is:

```
<%- include(partials/header) %>
<%- include('partials/navbar') %>
<!-- Your HTML Forms and Content Here -->
<%- include('partials/footer') %>
```

Read the past sem guide for more detailed stuff. 

### Running the App
1. In your terminal (at .../App), type 'npm start'. I added a 'console.log' in App.js that will show your database connection string at your terminal if successful connected to postgres. 
2. Open http://localhost:3000 in your browser for index.ejs. You can use the nav bar to traverse pages too.
3. Go to http://localhost:3000/insert to insert some fake data into users table. Created entries are Customers. Postgres may not generate warnings at your terminal if the data inserted was wrong. (Guide section 6 and 7 explains how the code work.)
4. Opening http://localhost:3000/select to see your data inserted.
5. To stop running the app, aside from closing your browser, remember to Ctrl + C in your terminal to terminate the server. 

Supposedly, you forget to Ctrl + C, just kill the process at port 3000. For windows, go your task manager
select the 'Processes tab', search for 'Node.js: Server-side JavaScript', select it and click on 'End task' button.

### Still need to Figure Out [Stuff that will apply to everyone]
1. How to structure the folders such that Pool and Queries can be accessed from db folder instead of individual js files (those codes in complusory statements in js files) [Done a little - sort of figure out from
[this](https://github.com/thisisadiyoga/cs2102_ay1819_s2/blob/master/sql/index.js) and 
[this](https://github.com/thisisadiyoga/cs2102_ay1819_s2/blob/master/routes/init.js) but need
to learn how to structure the js files to  respond to different multiple queries/actions on page]
2. How to do session values for userid i.e. how pass session values from page to page. User id need to be used in many js files in the sql statement parameters!
3. How to retreive user input from html forms into sql parameters. [DONE - See Insert.js, Insert.ejs and InsertScript.js]
4. How to link page to page. [DONE? - see the nav section of each ejs the "a href" and "app.get" in app.js is what connects pages together]


### OTHER USEFUL REFERENCES
1. BootStrap Nav Reference(if want additional stuff
like dropdown can refer here to): https://www.w3schools.com/bootstrap4/bootstrap_navbar.asp
2. Node js navigation between pages: https://stackoverflow.com/questions/41322217/i-want-to-navigate-to-another-page-in-ejs-using-a-link

Hopefully the guide can address some of these ^

