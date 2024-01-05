DROP FUNCTION IF EXISTS com.ufn_crudselectformulabyid;
CREATE FUNCTION com.ufn_crudselectformulabyid(
	par_formulaid INTEGER
) RETURNS TABLE (
	formulaname VARCHAR(50)
	,formulaexpression VARCHAR(100)
	,formuladescription VARCHAR(400)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT y.formulaname
		,y.formulaexpression
		,y.formuladescription
		FROM com.formula y
		WHERE y.formulaid = par_formulaid
	);
END; $$
