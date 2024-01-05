DROP VIEW IF EXISTS com.vw_sr;
CREATE VIEW com.vw_sr AS
	SELECT q.agentid
	,CONCAT(q.first_name, ' ',LEFT(q.middle_name,1), '. ',q.last_name)::VARCHAR(250) AS SR
	,ROUND(s.rate/100,2) AS rate
	,j.joborderid
	FROM com.agents q
	INNER JOIN com.salesreps s ON q.agentid = s.agentid
	INNER JOIN com.joborders j ON s.joborderid = j.joborderid
	WHERE q.isactive = true
	UNION
	SELECT a.agentid
	,CONCAT(a.first_name, ' ',LEFT(a.middle_name,1), '. ',a.last_name)::VARCHAR(250) AS "SR"
	,ROUND((100 - COALESCE(SUM(s.rate)::NUMERIC,0))/100,2) AS "rate"
	,j.joborderid
	FROM com.agents a
	INNER JOIN com.joborders j ON a.agentid = j.accountmanager
	LEFT JOIN com.salesreps s ON j.joborderid = s.joborderid
	GROUP BY a.agentid, j.joborderid;
