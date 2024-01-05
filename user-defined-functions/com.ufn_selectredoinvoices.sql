DROP FUNCTION IF EXISTS com.ufn_selectredoinvoices;
CREATE FUNCTION com.ufn_selectredoinvoices(
) RETURNS TABLE (
	"invoiceid" INTEGER,
	"invoiceno" VARCHAR(50),
	"joborderno" VARCHAR(50),
	"dt" TIMESTAMPTZ,
	"custname" VARCHAR(250),
	"formtitle" VARCHAR(200),
	"deliveryreceipt" VARCHAR(50),
	"qtyremaining" INTEGER,
	"qtyjoborder" INTEGER,
	"qtyinvoice" INTEGER,
	"unitmeasure" VARCHAR(50),
	"sellingprice" NUMERIC,
	"docstamps" NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT i.invoiceid,
		i.invoiceno,
		j.joborderno,
		i.dt,
		c.custname,
		j.formtitle,
		i.deliveryreceipt,
		j.quantity - (t.sumqtyinvoice - i.quantity),
		j.quantity,
		i.quantity,
		j.unitmeasure,
		j.sellingprice,
		j.docstamps
		FROM com.invoices i
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.customers c ON j.custid = c.custid
		LEFT JOIN LATERAL (
			SELECT COALESCE(SUM(h.quantity)::INTEGER,0) AS sumqtyinvoice FROM com.invoices h WHERE h.joborderid = j.joborderid
		) t ON true
		WHERE i.isfullypaid = false
		ORDER BY j.joborderid, i.invoiceid
	);
END; $$
