CREATE TABLE com.customers (
	custid SERIAL NOT NULL
	,custname VARCHAR(250) NOT NULL UNIQUE
	,isactive BOOLEAN NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (custid));
