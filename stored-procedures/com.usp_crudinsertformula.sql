DROP PROCEDURE IF EXISTS com.usp_crudinsertformula;
CREATE PROCEDURE com.usp_crudinsertformula(
	par_formulaname VARCHAR(50)
	,par_formulaexpression VARCHAR(100)
	,par_formuladescription VARCHAR(400)
	,par_userid INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
	INSERT INTO com.formula (
		formulaname
		,formulaexpression
		,formuladescription
		,updatedby
		,updateddate
	) VALUES (
		par_formulaname
		,par_formulaexpression
		,par_formuladescription
		,par_userid
		,CURRENT_TIMESTAMP
	);
END; $$
