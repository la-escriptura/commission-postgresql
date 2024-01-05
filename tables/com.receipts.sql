CREATE TABLE com.receipts (
	receiptid SERIAL NOT NULL
	,orno VARCHAR(50) NOT NULL UNIQUE
	,dt TIMESTAMPTZ NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (receiptid));
