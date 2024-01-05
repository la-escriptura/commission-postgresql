DROP FUNCTION IF EXISTS com.ufn_selectagents;
CREATE FUNCTION com.ufn_selectagents(
) RETURNS TABLE (
	agentid INTEGER,
	agentname TEXT
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT t.agentid, CONCAT(t.first_name, ' ', t.middle_name,' ',t.last_name)
		FROM com.agents t
		WHERE t.isactive = true
		ORDER BY CONCAT(t.first_name, ' ', t.middle_name,' ',t.last_name)
	);
END; $$
