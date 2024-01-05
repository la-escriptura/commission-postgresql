DROP PROCEDURE IF EXISTS com.usp_crudupdateformula;
CREATE PROCEDURE com.usp_crudupdateformula(
	par_formulaid INTEGER
	,par_formulaname VARCHAR(50)
	,par_formulaexpression VARCHAR(100)
	,par_formuladescription VARCHAR(400)
	,par_userid INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
	UPDATE com.formula SET
		formulaname = par_formulaname
		,formulaexpression = par_formulaexpression
		,formuladescription = par_formuladescription
		,updatedby = par_userid
		,updateddate = CURRENT_TIMESTAMP
	WHERE formulaid = par_formulaid;
END; $$
