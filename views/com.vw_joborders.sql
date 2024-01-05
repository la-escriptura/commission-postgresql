DROP VIEW IF EXISTS com.vw_joborders;
CREATE VIEW com.vw_joborders AS
	SELECT j.joborderid
	,CONCAT(LEFT(a.first_name,1),LEFT(a.middle_name,1),LEFT(a.last_name,1))::VARCHAR(250) AS "SR"
	,j.joborderno AS "JO No"
	,j.orderref AS "Order Ref"
	,DATE(j.dt AT TIME ZONE 'Asia/Manila') AS "JO Date"
	,c.custname AS "Customer"
	,j.formtitle AS "Form"
	,j.unitmeasure AS "Unit"
	,j.quantity AS "JO Qty"
	,ROUND(j.materialcost,2) AS "Material Cost"
	,ROUND(j.processcost,2) AS "Process Cost"
	,ROUND(j.othercost,2) AS "Other Cost"
	,ROUND(j.totaltransfer,2) AS "Transfer"
	,ROUND(j.sellingprice,2) AS "Selling Price"
	,ROUND(j.docstamps,2) AS "Docs Stamps"
	,ROUND(j.discount,2) AS "Discount"
	,ROUND(j.shippingHandling,2) AS "Shipping"
	,ROUND(j.callable,2) AS "Commission Basis"
	,j.isfullyinvoiced
	,j.updateddate
	FROM com.joborders j
	INNER JOIN com.agents a ON j.accountmanager = a.agentid
	INNER JOIN com.customers c ON j.custid = c.custid
