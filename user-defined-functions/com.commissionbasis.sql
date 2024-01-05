DROP FUNCTION IF EXISTS com.commissionbasis;
CREATE FUNCTION com.commissionbasis(
	par_joborderid INTEGER,
	par_aging INTEGER,
	par_margin NUMERIC,
	par_commbasis NUMERIC
) RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE agecommissionzero VARCHAR(100);
DECLARE margincommissionthreshold VARCHAR(100);
DECLARE margincommissionmultiplier VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'AGECOMMISSIONZERO' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGINCOMMISSIONTHRESHOLD' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGINCOMMISSIONMULTIPLIER' THEN formulaexpression ELSE NULL END)
	INTO agecommissionzero, margincommissionthreshold, margincommissionmultiplier
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('AGECOMMISSIONZERO', 'MARGINCOMMISSIONTHRESHOLD', 'MARGINCOMMISSIONMULTIPLIER')
	) pvt;
	RETURN CASE
			WHEN par_aging > agecommissionzero::INTEGER THEN 0
			WHEN par_margin < 0 THEN 0
			WHEN par_margin < margincommissionthreshold::INTEGER THEN par_commbasis * margincommissionmultiplier::NUMERIC
			ELSE par_commbasis
		END;
END; $$
