DROP FUNCTION IF EXISTS com.f;
CREATE FUNCTION com.f(
	par_json JSON,
	par_formula VARCHAR(100)
) RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE i INTEGER := 0;
DECLARE arr NUMERIC[10];
DECLARE rec RECORD;
DECLARE ret NUMERIC;
BEGIN
	FOR rec IN SELECT * FROM json_each(par_json)
	LOOP
		i = i + 1;
		par_formula = REGEXP_REPLACE(par_formula, CONCAT('\m',rec.key,'\M'), CONCAT('$',i), 'g');
		arr[i] = rec.value::TEXT::NUMERIC;
	END LOOP;
	EXECUTE 'SELECT ' || par_formula
	INTO ret
	USING arr[1], arr[2], arr[3], arr[4], arr[5], arr[6], arr[7], arr[8], arr[9];
    RETURN ret;
END; $$
