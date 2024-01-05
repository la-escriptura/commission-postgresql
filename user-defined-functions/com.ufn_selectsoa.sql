DROP FUNCTION IF EXISTS com.ufn_selectsoa;
CREATE FUNCTION com.ufn_selectsoa(
) RETURNS TABLE (
	"Invoices To" VARCHAR(250)
	,"Description" VARCHAR(200)
	,"Quantity" INTEGER
	,"Unit" VARCHAR(50)
	,"Ord. Ref" VARCHAR(50)
	,"Inv. Date" TIMESTAMPTZ
	,"Inv. No." VARCHAR(50)
	,"Amount" NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT c.custname AS "Invoices To"
		,j.formtitle AS "Description"
		,i.quantity AS "Quantity"
		,j.unitmeasure AS "Unit"
		,j.orderref AS "Ord. Ref"
		,i.dt AS "Inv. Date"
		,i.invoiceno AS "Inv. No."
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity,2) AS "Amount"
		FROM com.invoices i
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.customers c ON j.custid = c.custid
		WHERE i.isfullypaid = false
		ORDER BY c.custname, i.dt, i.invoiceno
	);
END; $$
