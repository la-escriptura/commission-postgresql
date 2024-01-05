CREATE TABLE com.users (
	userid SERIAL NOT NULL
	,first_name VARCHAR(50) NOT NULL
	,middle_name VARCHAR(50) NULL
	,last_name VARCHAR(50) NULL
	,email VARCHAR(50) NOT NULL UNIQUE
	,passwordhash VARCHAR(200) NOT NULL
	,isactive BOOLEAN NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (userid));
