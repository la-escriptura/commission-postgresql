CREATE TABLE com.agents (
	agentid SERIAL NOT NULL
	,first_name VARCHAR(50) NOT NULL
	,middle_name VARCHAR(50) NULL
	,last_name VARCHAR(50) NULL
	,isactive BOOLEAN NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (agentid));
