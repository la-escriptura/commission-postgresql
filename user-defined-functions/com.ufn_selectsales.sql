DROP FUNCTION IF EXISTS com.ufn_selectsales;
CREATE FUNCTION com.ufn_selectsales(
	par_truncmonth TIMESTAMPTZ DEFAULT NULL
) RETURNS TABLE (
	"SR" VARCHAR(250)
	,"JO" VARCHAR(50)
	,"Date" TIMESTAMPTZ
	,"Ord Ref" VARCHAR(50)
	,"Customer" VARCHAR(250)
	,"Form" VARCHAR(200)
	,"Quantity" INTEGER
	,"Unit" VARCHAR(50)
	,"Material" NUMERIC
	,"Process" NUMERIC
	,"Others" NUMERIC
	,"Total" NUMERIC
	,"Doc. Stamps" NUMERIC
	,"Transfer" NUMERIC
	,"Invoice Amount" NUMERIC
	,"Margin" NUMERIC
) LANGUAGE plpgsql AS $$
DECLARE vat VARCHAR(100);
DECLARE margininit VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'VAT' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGININIT' THEN formulaexpression ELSE NULL END)
	INTO vat, margininit
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('VAT', 'MARGININIT')
	) pvt;

	RETURN QUERY(
		SELECT CONCAT(LEFT(a.first_name,1),LEFT(a.middle_name,1),LEFT(a.last_name,1))::VARCHAR(250) AS "SR"
		,j.joborderno AS "JO"
		,j.dt AS "Date"
		,j.orderref AS "Ord Ref"
		,c.custname AS "Customer"
		,j.formtitle AS "Form"
		,j.quantity AS "Quantity"
		,j.unitmeasure AS "Unit"
		,j.materialcost AS "Material"
		,j.processcost AS "Process"
		,j.othercost AS "Others"
		,j.materialcost + j.processcost + j.othercost AS "Total"
		,j.docstamps AS "Doc. Stamps"
		,ROUND(com.transfer(j.totaltransfer, j.materialcost + j.processcost + j.othercost),2) AS "Transfer"
		,j.sellingprice + j.docstamps - j.discount + j.shippingHandling AS "Invoice Amount"
		,ROUND(CASE WHEN j.sellingprice = 0 THEN 0 ELSE com.f(CONCAT('{"TotalCost":',j.materialcost + j.processcost + j.othercost,',"SellingPrice":',j.sellingprice,',"VatRate":',vat::NUMERIC,'}')::JSON,margininit) END,2) AS "Margin"
		FROM com.joborders j
		INNER JOIN com.agents a ON j.accountmanager = a.agentid
		INNER JOIN com.customers c ON j.custid = c.custid
		WHERE CASE WHEN par_truncmonth IS NULL THEN TRUE ELSE DATE_TRUNC('MONTH', j.dt) = par_truncmonth END
	);
END; $$
