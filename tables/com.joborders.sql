CREATE TABLE com.joborders (
	joborderid SERIAL NOT NULL
	,joborderno VARCHAR(50) NOT NULL UNIQUE
	,orderref VARCHAR(50) NULL
	,dt TIMESTAMPTZ NOT NULL
	,custid INTEGER NOT NULL REFERENCES com.customers (custid)
	,formtitle VARCHAR(200) NOT NULL
	,quantity INTEGER NOT NULL
	,unitmeasure VARCHAR(50) NOT NULL
	,materialcost NUMERIC NOT NULL
	,processcost NUMERIC NOT NULL
	,othercost NUMERIC NOT NULL DEFAULT 0
	,totaltransfer NUMERIC NOT NULL DEFAULT 0
	,sellingprice NUMERIC NOT NULL
	,docstamps NUMERIC NOT NULL DEFAULT 0
	,discount NUMERIC NOT NULL DEFAULT 0
	,shippingHandling NUMERIC NOT NULL DEFAULT 0
	,callable NUMERIC NOT NULL DEFAULT 0
	,accountmanager INTEGER NOT NULL REFERENCES com.agents (agentid)
	,isfullyinvoiced BOOLEAN NOT NULL DEFAULT false
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (joborderid));
