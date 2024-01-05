DROP FUNCTION IF EXISTS com.ufn_selectunitmeasures;
CREATE FUNCTION com.ufn_selectunitmeasures(
) RETURNS TABLE (
	unitmeasurename VARCHAR(50)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT t.unitmeasurename
		FROM com.unitmeasures t
	);
END; $$
