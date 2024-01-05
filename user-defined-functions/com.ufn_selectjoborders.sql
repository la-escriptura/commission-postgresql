DROP FUNCTION IF EXISTS com.ufn_selectjoborders;
CREATE FUNCTION com.ufn_selectjoborders(
) RETURNS TABLE (
	custname VARCHAR(250),
	formtitle VARCHAR(200),
	qtyremaining INTEGER,
	qtyjoborder INTEGER,
	unitmeasure VARCHAR(50),
	sellingprice NUMERIC,
	docstamps NUMERIC,
	joborderno VARCHAR(50)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT c.custname, j.formtitle,
		j.quantity - COALESCE(SUM(i.quantity)::INTEGER,0),
		j.quantity, j.unitmeasure, j.sellingprice, j.docstamps, j.joborderno
		FROM com.joborders j
		INNER JOIN com.customers c ON c.custid = j.custid
		LEFT JOIN com.invoices i ON i.joborderid = j.joborderid
		WHERE j.isfullyinvoiced = false
		GROUP BY j.joborderid, c.custname, j.formtitle, j.quantity, j.unitmeasure, j.sellingprice, j.docstamps, j.joborderno
		ORDER BY j.joborderno
	);
END; $$
