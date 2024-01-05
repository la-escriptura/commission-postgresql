CREATE TABLE com.accountspreedit (
	accountpreeditid SERIAL NOT NULL
	,accountid INTEGER NOT NULL REFERENCES com.accounts (accountid)
	,receiptpreeditid INTEGER NOT NULL REFERENCES com.receiptspreedit (receiptpreeditid)
	,invoiceid INTEGER NOT NULL REFERENCES com.invoices (invoiceid)
	,rebate NUMERIC NOT NULL DEFAULT 0
	,retention NUMERIC NOT NULL DEFAULT 0
	,penalty NUMERIC NOT NULL DEFAULT 0
	,govshare NUMERIC NOT NULL DEFAULT 0
	,withheld0 NUMERIC NOT NULL DEFAULT 0
	,withheld1 NUMERIC NOT NULL DEFAULT 0
	,withheld2 NUMERIC NOT NULL DEFAULT 0
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (accountpreeditid));
