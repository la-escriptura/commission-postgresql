CREATE TABLE com.salesrepspreedit (
	salesreppreeditid SERIAL NOT NULL
	,joborderpreeditid INTEGER NOT NULL REFERENCES com.joborderspreedit (joborderpreeditid)
	,agentid INTEGER NOT NULL REFERENCES com.agents (agentid)
	,rate NUMERIC NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (salesreppreeditid));
