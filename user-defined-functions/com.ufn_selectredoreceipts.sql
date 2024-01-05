DROP FUNCTION IF EXISTS com.ufn_selectredoreceipts;
CREATE FUNCTION com.ufn_selectredoreceipts(
) RETURNS TABLE (
	"receiptid" INTEGER
	,"orno" VARCHAR(50)
	,"dateor" TIMESTAMPTZ
	,"custname" VARCHAR(250)
	,"accountid" INTEGER
	,"invoiceno" VARCHAR(50)
	,"dateinvoice" TIMESTAMPTZ
	,"joborderno" VARCHAR(50)
	,"qtyinvoice" INTEGER
	,"qtyjoborder" INTEGER
	,"materialcost" NUMERIC
	,"processcost" NUMERIC
	,"othercost" NUMERIC
	,"sellingprice" NUMERIC
	,"docstamps" NUMERIC
	,"rebate" NUMERIC
	,"retention" NUMERIC
	,"penalty" NUMERIC
	,"govshare" NUMERIC
	,"withheld0" NUMERIC
	,"withheld1" NUMERIC
	,"withheld2" NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT o.receiptid
		,o.orno
		,o.dt
		,c.custname
		,b.accountid
		,i.invoiceno
		,i.dt
		,j.joborderno
		,i.quantity AS qtyinvoice
		,j.quantity AS qtyjoborder
		,j.materialcost
		,j.processcost
		,j.othercost
		,j.sellingprice
		,j.docstamps
		,b.rebate
		,b.retention
		,b.penalty
		,b.govshare
		,b.withheld0
		,b.withheld1
		,b.withheld2
		FROM com.receipts o
		INNER JOIN com.accounts b ON o.receiptid = b.receiptid
		INNER JOIN com.invoices i ON b.invoiceid = i.invoiceid
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.customers c ON j.custid = c.custid
		ORDER BY o.receiptid, b.accountid
	);
END; $$
