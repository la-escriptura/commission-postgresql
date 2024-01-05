DROP FUNCTION IF EXISTS com.ufn_selectcustomers;
CREATE FUNCTION com.ufn_selectcustomers(
) RETURNS TABLE (
	custid INTEGER,
	custname VARCHAR(250)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT t.custid, t.custname
		FROM com.customers t
		WHERE t.isactive = true
		ORDER BY t.custname
	);
END; $$
