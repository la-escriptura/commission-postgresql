DROP VIEW IF EXISTS com.vw_accounts;
CREATE VIEW com.vw_accounts AS
	SELECT b.accountid
	,o.receiptid
	,b.invoiceid
	,o.orno AS "OR No"
	,DATE(o.dt AT TIME ZONE 'Asia/Manila') AS "OR Date"
	,ROUND(b.rebate,2) AS "Rebate"
	,ROUND(b.retention,2) AS "Retention"
	,ROUND(b.penalty,2) AS "Penalty"
	,ROUND(b.govshare,2) AS "Gov Share"
	,ROUND(b.withheld0,2) AS "1% withholding"
	,ROUND(b.withheld1,2) AS "2% withholding"
	,ROUND(b.withheld2,2) AS "5% withholding"
	,b.updateddate
	FROM com.receipts o
	INNER JOIN com.accounts b
	ON o.receiptid = b.receiptid
