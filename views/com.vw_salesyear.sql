DROP VIEW IF EXISTS com.vw_salesyear;
CREATE VIEW com.vw_salesyear AS
	SELECT TO_CHAR(DATE_TRUNC('MONTH', Mo), 'Mon''YY') AS month, COALESCE(ROUND(SUM(s."Invoice Amount"),0),0) AS sales
	FROM GENERATE_SERIES(CURRENT_TIMESTAMP - INTERVAL '1 YEAR', CURRENT_TIMESTAMP - INTERVAL '1 MONTH', '1 MONTH') AS Mo
	LEFT JOIN com.ufn_selectsales() AS s
	ON DATE_TRUNC('MONTH', Mo) = DATE_TRUNC('MONTH', s."Date")
	GROUP BY DATE_TRUNC('MONTH', Mo)
	ORDER BY DATE_TRUNC('MONTH', Mo);
