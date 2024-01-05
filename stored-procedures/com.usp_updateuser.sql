DROP PROCEDURE IF EXISTS com.usp_updateuser;
CREATE PROCEDURE com.usp_updateuser(
	par_userid INTEGER,
	par_newpasswordhash VARCHAR(200)
) LANGUAGE plpgsql AS $$
DECLARE
	var_count INTEGER;
BEGIN
	UPDATE com.users SET
	passwordhash = par_newpasswordhash
	WHERE userid = par_userid;
END; $$
