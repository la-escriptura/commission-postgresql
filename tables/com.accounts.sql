CREATE TABLE com.accounts (
	accountid SERIAL NOT NULL
	,receiptid INTEGER NOT NULL REFERENCES com.receipts (receiptid)
	,invoiceid INTEGER NOT NULL UNIQUE REFERENCES com.invoices (invoiceid)
	,rebate NUMERIC NOT NULL DEFAULT 0
	,retention NUMERIC NOT NULL DEFAULT 0
	,penalty NUMERIC NOT NULL DEFAULT 0
	,govshare NUMERIC NOT NULL DEFAULT 0
	,withheld0 NUMERIC NOT NULL DEFAULT 0
	,withheld1 NUMERIC NOT NULL DEFAULT 0
	,withheld2 NUMERIC NOT NULL DEFAULT 0
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (accountid));
