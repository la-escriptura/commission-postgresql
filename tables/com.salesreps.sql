CREATE TABLE com.salesreps (
	salesrepid SERIAL NOT NULL
	,joborderid INTEGER NOT NULL REFERENCES com.joborders (joborderid)
	,agentid INTEGER NOT NULL REFERENCES com.agents (agentid)
	,rate NUMERIC NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (salesrepid));
