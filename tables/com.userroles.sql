CREATE TABLE com.userroles (
	userroleid SERIAL NOT NULL
	,userid INTEGER NOT NULL REFERENCES com.users (userid)
	,roleid INTEGER NOT NULL REFERENCES com.roles (roleid)
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (userroleid));
