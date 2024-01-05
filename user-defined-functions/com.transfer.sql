DROP FUNCTION IF EXISTS com.transfer;
CREATE FUNCTION com.transfer(
	par_totaltransfer NUMERIC,
	par_totalcost NUMERIC
) RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE vat VARCHAR(100);
DECLARE transferamount VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'VAT' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'TRANSFERAMOUNT' THEN formulaexpression ELSE NULL END)
	INTO vat, transferamount
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('VAT', 'TRANSFERAMOUNT')
	) pvt;
	RETURN CASE WHEN par_totaltransfer = 0 THEN com.f(CONCAT('{"TotalCost":',ROUND(par_totalcost,2),',"VatRate":',vat::NUMERIC,'}')::JSON,transferamount) ELSE par_totaltransfer END;
END; $$
