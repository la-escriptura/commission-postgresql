DROP FUNCTION IF EXISTS com.ufn_selectuserbyid;
CREATE FUNCTION com.ufn_selectuserbyid(
   par_userid INTEGER
) RETURNS TABLE (
	passwordhash VARCHAR(200)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT u.passwordhash
		FROM com.users u
		WHERE u.userid = par_userid
	);
END; $$
