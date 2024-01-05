DROP PROCEDURE IF EXISTS com.usp_crudselectformula;
CREATE PROCEDURE com.usp_crudselectformula(
	OUT resultSet REFCURSOR
	,OUT totalRowCount INTEGER
	,INOUT pageNo INTEGER
	,rowCountPerPage INTEGER
	,par_formulaname VARCHAR(50) DEFAULT NULL
	,par_formulaexpression VARCHAR(100) DEFAULT NULL
	,par_formuladescription VARCHAR(400) DEFAULT NULL
	,sort VARCHAR(300) DEFAULT NULL
) LANGUAGE plpgsql AS $$
DECLARE sqlCount VARCHAR(2000);
DECLARE sqlString VARCHAR(2000);
BEGIN
	sqlCount = 'SELECT COUNT(*) '
		|| 'FROM com.formula y '
		|| 'WHERE true ';

	sqlString = 'SELECT '
		|| 'y.formulaid '
		|| ',y.formulaname '
		|| ',y.formulaexpression '
		|| ',y.formuladescription '
		|| 'FROM com.formula y '
		|| 'WHERE true ';

	IF (par_formulaname IS NOT NULL) THEN
		sqlCount  = sqlCount  || 'AND LOWER(y.formulaname) LIKE ''%' || LOWER(par_formulaname) || '%'' ';
		sqlString = sqlString || 'AND LOWER(y.formulaname) LIKE ''%' || LOWER(par_formulaname) || '%'' ';
	END IF;
	IF (par_formulaexpression IS NOT NULL) THEN
		sqlCount  = sqlCount  || 'AND LOWER(y.formulaexpression) LIKE ''%' || LOWER(par_formulaexpression) || '%'' ';
		sqlString = sqlString || 'AND LOWER(y.formulaexpression) LIKE ''%' || LOWER(par_formulaexpression) || '%'' ';
	END IF;
	IF (par_formuladescription IS NOT NULL) THEN
		sqlCount  = sqlCount  || 'AND LOWER(y.formuladescription) LIKE ''%' || LOWER(par_formuladescription) || '%'' ';
		sqlString = sqlString || 'AND LOWER(y.formuladescription) LIKE ''%' || LOWER(par_formuladescription) || '%'' ';
	END IF;

	IF (sort IS NOT NULL) THEN
		sqlString = sqlString || 'ORDER BY ' || sort || ' ';
	ELSE
		sqlString = sqlString || 'ORDER BY y.formulaid ';
	END IF;

	EXECUTE sqlCount INTO totalRowCount;
	IF (((pageNo - 1) * rowCountPerPage) >= totalRowCount) THEN
		pageNo = CEILING(CAST(totalRowCount AS REAL) / CAST(rowCountPerPage AS REAL));
		IF (pageNo < 1) THEN
			pageNo = 1;
		END IF;
	END IF;

	sqlString = sqlString || 'OFFSET (' || CAST(pageNo AS VARCHAR(10)) || ' - 1) * ' || CAST(rowCountPerPage AS VARCHAR(10)) || ' LIMIT ' || CAST(rowCountPerPage AS VARCHAR(10)) || '; ';

	OPEN resultSet FOR EXECUTE sqlString;
END; $$
