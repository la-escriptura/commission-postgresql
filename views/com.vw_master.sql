DROP VIEW IF EXISTS com.vw_master;
CREATE VIEW com.vw_master AS
	SELECT j."SR"
	,j.joborderid
	,j."JO No"
	,j."Order Ref"
	,j."JO Date"
	,j.isfullyinvoiced
	,i.invoiceid
	,i."Invoice No"
	,i."Invoice Date"
	,i.isfullypaid
	,b.receiptid
	,b."OR No"
	,b."OR Date"
	,j."Customer"
	,j."Form"
	,j."Unit"
	,j."JO Qty"
	,i."Invoice Qty"
	,j."Material Cost"
	,j."Process Cost"
	,j."Other Cost"
	,j."Transfer"
	,j."Selling Price"
	,j."Docs Stamps"
	,j."Discount"
	,j."Shipping"
	,j."Commission Basis"
	,i."DR"
	,b."Rebate"
	,b."Retention"
	,b."Penalty"
	,b."Gov Share"
	,b."1% withholding"
	,b."2% withholding"
	,b."5% withholding"
	FROM com.vw_joborders j
	LEFT JOIN com.vw_invoices i ON j.joborderid = i.joborderid
	LEFT JOIN com.vw_accounts b ON i.invoiceid = b.invoiceid
