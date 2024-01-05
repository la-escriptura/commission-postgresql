DROP PROCEDURE IF EXISTS com.usp_cruddeleteformula;
CREATE PROCEDURE com.usp_cruddeleteformula(
	par_formulaids VARCHAR(4000)
	,par_userid INTEGER
) LANGUAGE plpgsql AS $$
BEGIN
	UPDATE com.formula SET
		isactive = false
		,updatedby = par_userid
		,updateddate = CURRENT_TIMESTAMP
	WHERE formulaid IN (SELECT UNNEST(STRING_TO_ARRAY(par_formulaids, ','))::INTEGER);
END; $$
