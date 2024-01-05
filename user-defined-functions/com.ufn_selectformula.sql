DROP FUNCTION IF EXISTS com.ufn_selectformula;
CREATE FUNCTION com.ufn_selectformula(
) RETURNS TABLE (
	formulaname VARCHAR(50),
	formulaexpression VARCHAR(100),
	formuladescription VARCHAR(400)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT t.formulaname, t.formulaexpression, t.formuladescription
		FROM com.formula t
	);
END; $$
