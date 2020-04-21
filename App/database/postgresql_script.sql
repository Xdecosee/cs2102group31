DROP TABLE IF EXISTS Users CASCADE;

-- MySQL retrieves and displays DATE values in 'YYYY-MM-DD' format
-- MySQL retrieves and displays TIME values in 'hh:mm:ss' format 
CREATE TABLE Users(
	username             varchar(255)    NOT NULL,
	name            varchar(255)    NOT NULL,
	password        varchar(255)    NOT NULL,
	type            varchar(255)    NOT NULL
);