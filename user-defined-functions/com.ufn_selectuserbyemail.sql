DROP FUNCTION IF EXISTS com.ufn_selectuserbyemail;
CREATE FUNCTION com.ufn_selectuserbyemail(
   par_email VARCHAR(50)
) RETURNS TABLE (
	userid INTEGER,
	first_name VARCHAR(50),
	rolename VARCHAR(50),
	passwordhash VARCHAR(200)
) LANGUAGE plpgsql AS $$
BEGIN
	RETURN QUERY(
		SELECT u.userid, u.first_name, (
			SELECT STRING_AGG(r.rolename,',')
			FROM com.roles r
			INNER JOIN com.userroles t
			ON r.roleid = t.roleid
			WHERE t.userid = u.userid
		)::VARCHAR(300), u.passwordhash
		FROM com.users u
		WHERE LOWER(u.email) = LOWER(par_email)
		AND u.isactive = true
	);
END; $$
