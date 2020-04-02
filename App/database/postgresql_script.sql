DROP TABLE IF EXISTS Users CASCADE;

-- MySQL retrieves and displays DATE values in 'YYYY-MM-DD' format
-- MySQL retrieves and displays TIME values in 'hh:mm:ss' format 
CREATE TABLE Users(
	name		varchar(255) 	NOT NULL,
	phoneNum 	varchar(8) 		NOT NULL,
	email 		varchar(255) 	NOT NULL CHECK (email LIKE '%@%.%'),
	uname 		varchar(255) 	PRIMARY KEY,
	password	varchar(255) 	NOT NULL,
	type		varchar(255) 	NOT NULL CHECK (type in ('Worker','Owner','Diner'))
);