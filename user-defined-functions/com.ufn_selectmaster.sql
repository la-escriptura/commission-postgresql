DROP FUNCTION IF EXISTS com.ufn_selectmaster;
CREATE FUNCTION com.ufn_selectmaster(
	par_json JSON
) RETURNS TABLE (
	"SR" VARCHAR(250)
	,"JO No" VARCHAR(50)
	,"JO Date" DATE
	,"Order Ref" VARCHAR(50)
	,"Invoice No" VARCHAR(50)
	,"Invoice Date" DATE
	,"DR" VARCHAR(50)
	,"OR No" VARCHAR(50)
	,"OR Date" DATE
	,"Customer" VARCHAR(250)
	,"Form" VARCHAR(200)
	,"Unit" VARCHAR(50)
	,"JO Qty" VARCHAR(50)
	,"Invoice Qty" VARCHAR(50)
	,"Remaining Balance" VARCHAR(50)
	,"Material Cost" VARCHAR(50)
	,"Process Cost" VARCHAR(50)
	,"Other Cost" VARCHAR(50)
	,"Transfer" VARCHAR(50)
	,"Selling Price" VARCHAR(50)
	,"Docs Stamps" VARCHAR(50)
	,"Discount" VARCHAR(50)
	,"Shipping" VARCHAR(50)
	,"Commission Basis" VARCHAR(50)
	,"Rebate" VARCHAR(50)
	,"Retention" VARCHAR(50)
	,"Penalty" VARCHAR(50)
	,"Gov Share" VARCHAR(50)
	,"1% withholding" VARCHAR(50)
	,"2% withholding" VARCHAR(50)
	,"5% withholding" VARCHAR(50)
) LANGUAGE plpgsql AS $$
DECLARE var_joborderno VARCHAR(50);
DECLARE var_invoiceno VARCHAR(50);
DECLARE var_orno VARCHAR(50);
BEGIN
	SELECT j."joborderno"
		,j."invoiceno"
		,j."orno"
	INTO
		var_joborderno
		,var_invoiceno
		,var_orno
	FROM json_to_record(par_json)j (
		"joborderno" TEXT
		,"invoiceno" TEXT
		,"orno" TEXT
	);

	RETURN QUERY(
		SELECT w."SR"
		,w."JO No"
		,w."JO Date"
		,w."Order Ref"
		,w."Invoice No"
		,w."Invoice Date"
		,w."DR"
		,w."OR No"
		,w."OR Date"
		,w."Customer"
		,w."Form"
		,w."Unit"
		,TO_CHAR(w."JO Qty", 'fm999G999G999')::VARCHAR(50)
		,TO_CHAR(w."Invoice Qty", 'fm999G999G999')::VARCHAR(50)
		,TO_CHAR(w."JO Qty" - (t.sumqtyinvoice), 'fm999G999G999')::VARCHAR(50) AS "Remaining Balance"
		,TO_CHAR(w."Material Cost", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Process Cost", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Other Cost", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Transfer", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Selling Price", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Docs Stamps", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Discount", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Shipping", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Commission Basis", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Rebate", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Retention", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Penalty", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."Gov Share", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."1% withholding", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."2% withholding", 'fm999G999G990D00')::VARCHAR(50)
		,TO_CHAR(w."5% withholding", 'fm999G999G990D00')::VARCHAR(50)
		FROM com.vw_master w
		LEFT JOIN LATERAL (
			SELECT COALESCE(SUM(h.quantity)::INTEGER,0) AS sumqtyinvoice FROM com.invoices h WHERE h.joborderid = w.joborderid
		) t ON true

		WHERE (CASE WHEN TRIM(var_joborderno) = '' THEN false ELSE (w."JO No" IN (SELECT REGEXP_SPLIT_TO_TABLE(var_joborderno, E'\\s+')) OR
		LPAD(REPLACE(w."JO No",'.',''), GREATEST(LENGTH(REPLACE(w."JO No",'.','')), 6), '0') IN (SELECT REGEXP_SPLIT_TO_TABLE(var_joborderno, E'\\s+')) OR RIGHT(REPLACE(w."JO No",'.',''), 5) IN (SELECT REGEXP_SPLIT_TO_TABLE(var_joborderno, E'\\s+'))) END)

		OR (CASE WHEN TRIM(var_invoiceno) = '' THEN false ELSE (w."Invoice No" IN (SELECT REGEXP_SPLIT_TO_TABLE(var_invoiceno, E'\\s+')) OR
		LPAD(REPLACE(w."Invoice No",'.',''), GREATEST(LENGTH(REPLACE(w."Invoice No",'.','')), 6), '0') IN (SELECT REGEXP_SPLIT_TO_TABLE(var_invoiceno, E'\\s+')) OR RIGHT(REPLACE(w."Invoice No",'.',''), 5) IN (SELECT REGEXP_SPLIT_TO_TABLE(var_invoiceno, E'\\s+'))) END)

		OR (CASE WHEN TRIM(var_orno) = '' THEN false ELSE (w."OR No" IN (SELECT REGEXP_SPLIT_TO_TABLE(var_orno, E'\\s+')) OR
		LPAD(REPLACE(w."OR No",'.',''), GREATEST(LENGTH(REPLACE(w."OR No",'.','')), 6), '0') IN (SELECT REGEXP_SPLIT_TO_TABLE(var_orno, E'\\s+')) OR RIGHT(REPLACE(w."OR No",'.',''), 5) IN (SELECT REGEXP_SPLIT_TO_TABLE(var_orno, E'\\s+'))) END)

		ORDER BY w."SR", w."JO No", w."Invoice No", w."OR No"
	);
END; $$
