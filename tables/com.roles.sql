CREATE TABLE com.roles (
	roleid SERIAL NOT NULL
	,rolename VARCHAR(50) NULL UNIQUE
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (roleid));
