CREATE TABLE com.invoices (
	invoiceid SERIAL NOT NULL
	,invoiceno VARCHAR(50) NOT NULL UNIQUE
	,joborderid INTEGER NOT NULL REFERENCES com.joborders (joborderid)
	,dt TIMESTAMPTZ NOT NULL
	,quantity INTEGER NOT NULL
	,deliveryreceipt VARCHAR(50) NULL
	,isfullypaid BOOLEAN NOT NULL DEFAULT false
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (invoiceid));
