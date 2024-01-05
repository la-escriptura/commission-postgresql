DROP FUNCTION IF EXISTS com.ufn_selectredojoborders;
CREATE FUNCTION com.ufn_selectredojoborders(
) RETURNS TABLE (
	"joborderid" INTEGER,
	"joborderno" VARCHAR(50),
	"orderref" VARCHAR(50),
	"dt" TIMESTAMPTZ,
	"custid" INTEGER,
	"formtitle" VARCHAR(200),
	"quantity" INTEGER,
	"unitmeasure" VARCHAR(50),
	"materialcost" NUMERIC,
	"processcost" NUMERIC,
	"othercost" NUMERIC,
	"totaltransfer" NUMERIC,
	"sellingprice" NUMERIC,
	"docstamps" NUMERIC,
	"discount" NUMERIC,
	"shippingHandling" NUMERIC,
	"callable" NUMERIC,
	"accountmanager" INTEGER,
	"agent" INTEGER,
	"rate" NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT j.joborderid
		,j.joborderno
		,j.orderref
		,j.dt
		,j.custid
		,j.formtitle
		,j.quantity
		,j.unitmeasure
		,j.materialcost
		,j.processcost
		,j.othercost
		,j.totaltransfer
		,j.sellingprice
		,j.docstamps
		,j.discount
		,j.shippingHandling
		,j.callable
		,j.accountmanager
		,s.agentid
		,s.rate
		FROM com.joborders j
		LEFT JOIN com.salesreps s ON j.joborderid = s.joborderid
		WHERE j.isfullyinvoiced = false
		ORDER BY j.joborderid
	);
END; $$
