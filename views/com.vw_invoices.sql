DROP VIEW IF EXISTS com.vw_invoices;
CREATE VIEW com.vw_invoices AS
	SELECT i.invoiceid
	,i.joborderid
	,i.invoiceno AS "Invoice No"
	,DATE(i.dt AT TIME ZONE 'Asia/Manila') AS "Invoice Date"
	,i.quantity AS "Invoice Qty"
	,i.deliveryreceipt AS "DR"
	,i.isfullypaid
	,i.updateddate
	FROM com.invoices i
