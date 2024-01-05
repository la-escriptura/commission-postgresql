DROP FUNCTION IF EXISTS com.ufn_selectinvoices;
CREATE FUNCTION com.ufn_selectinvoices(
) RETURNS TABLE (
	custid INTEGER,
	custname VARCHAR(250),
	invoiceno VARCHAR(50),
	dateinvoice TIMESTAMPTZ,
	joborderno VARCHAR(50),
	qtyinvoice INTEGER,
	qtyjoborder INTEGER,
	materialcost NUMERIC,
	processcost NUMERIC,
	othercost NUMERIC,
	sellingprice NUMERIC,
	docstamps NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT c.custid, c.custname, i.invoiceno, i.dt, j.joborderno, i.quantity AS qtyinvoice, j.quantity AS qtyjoborder, j.materialcost, j.processcost, j.othercost, j.sellingprice, j.docstamps
		FROM com.invoices i
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.customers c ON j.custid = c.custid
		WHERE i.isfullypaid = false
		ORDER BY c.custname
	);
END; $$
