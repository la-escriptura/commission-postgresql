CREATE TABLE com.receiptspreedit (
	receiptpreeditid SERIAL NOT NULL
	,receiptid INTEGER NOT NULL REFERENCES com.receipts (receiptid)
	,orno VARCHAR(50) NOT NULL
	,dt TIMESTAMPTZ NOT NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (receiptpreeditid));
