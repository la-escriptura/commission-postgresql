DROP FUNCTION IF EXISTS com.ufn_selectcorpcomm;
CREATE FUNCTION com.ufn_selectcorpcomm(
	par_truncmonth TIMESTAMPTZ
) RETURNS TABLE (
	"SR" VARCHAR(250)
	,"JO No." VARCHAR(50)
	,"Invoice No." VARCHAR(50)
	,"Invoice Date" TIMESTAMPTZ
	,"OR No." VARCHAR(50)
	,"OR Date" TIMESTAMPTZ
	,"Client" VARCHAR(250)
	,"Form" VARCHAR(200)
	,"Quantity" INTEGER
	,"D/S" NUMERIC
	,"T/Cost" NUMERIC
	,"Transfer" NUMERIC
	,"Invoice Amount" NUMERIC
	,"Amount Received" NUMERIC
	,"Comm.Basis" NUMERIC
	,"Comm" NUMERIC
	,"RQQ" NUMERIC
	,"RASK" NUMERIC
	,"RMT" NUMERIC
	,"Margin" NUMERIC -- ,"Aging" INTEGER
) LANGUAGE plpgsql AS $$
DECLARE vat VARCHAR(100);
DECLARE marginfinal VARCHAR(100);
DECLARE commisionbasis VARCHAR(100);
DECLARE commissionratedirector VARCHAR(100);
DECLARE commissionitselfdivisor VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'VAT' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGINFINAL' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISIONBASIS' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISSIONRATEDIRECTOR' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISSIONITSELFDIVISOR' THEN formulaexpression ELSE NULL END)
	INTO vat, marginfinal, commisionbasis, commissionratedirector, commissionitselfdivisor
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('VAT', 'MARGINFINAL','COMMISIONBASIS','COMMISSIONRATEDIRECTOR','COMMISSIONITSELFDIVISOR')
	) pvt;

	RETURN QUERY(
		SELECT CONCAT(LEFT(a.first_name,1),LEFT(a.middle_name,1),LEFT(a.last_name,1))::VARCHAR(250) AS "SR"
		,j.joborderno AS "JO No."
		,i.invoiceno AS "Invoice No."
		,i.dt AS "Invoice Date"
		,o.orno AS "OR No."
		,o.dt AS "OR Date"
		,c.custname AS "Client"
		,j.formtitle AS "Form"
		,i.quantity AS "Quantity"
		,ROUND(j.docstamps / j.quantity * i.quantity,2) AS "D/S"
		,ROUND((j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity,2) AS "T/Cost"
		,ROUND(f."transfer",2) AS "Transfer"
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity,2) AS "Invoice Amount"
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2) AS "Amount Received"
		,ROUND(f."Comm.Basis",2) AS "Comm.Basis"
		,ROUND(g."Comm",2) AS "Comm"
		,ROUND(g."Comm" * commissionratedirector::NUMERIC,2) AS "RQQ"
		,ROUND(g."Comm" * commissionratedirector::NUMERIC,2) AS "RASK"
		,ROUND(g."Comm" * commissionratedirector::NUMERIC,2) AS "RMT"
		,ROUND(e."Margin",2) AS "Margin" -- ,e.Aging
		FROM com.receipts o
		INNER JOIN com.accounts b ON o.receiptid = b.receiptid
		INNER JOIN com.invoices i ON b.invoiceid = i.invoiceid
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.agents a ON j.accountmanager = a.agentid
		INNER JOIN com.customers c ON j.custid = c.custid
		LEFT JOIN LATERAL (
			SELECT CASE WHEN j.callable = 0 THEN com.f(CONCAT('{"PaidAmount":',ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2),',"DocsStamps":',ROUND(j.docstamps / j.quantity * i.quantity,2),',"VatRate":',vat::NUMERIC,'}')::JSON,commisionbasis)
			ELSE com.f(CONCAT('{"PaidAmount":',ROUND((j.callable - j.shippingHandling) / j.quantity * i.quantity - (b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2),',"DocsStamps":',ROUND(j.docstamps / j.quantity * i.quantity,2),',"VatRate":',vat::NUMERIC,'}')::JSON,commisionbasis) END AS "Comm.Basis"
		) d ON true
		LEFT JOIN LATERAL (
			SELECT EXTRACT(DAY FROM o.dt - i.dt)::INTEGER AS Aging
			,com.f(CONCAT('{"TotalCost":',ROUND((j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity,2),',"CommisionBasis":',ROUND(d."Comm.Basis",2),'}')::JSON,marginfinal) AS "Margin"
		) e ON true
		LEFT JOIN LATERAL (
			SELECT com.transfer(j.totaltransfer / j.quantity * i.quantity, (j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity) AS "transfer"
			,com.commissionbasis(j.joborderid, e.Aging, e."Margin", d."Comm.Basis") AS "Comm.Basis"
		) f ON true
		LEFT JOIN LATERAL (
			SELECT CASE WHEN (f."Comm.Basis" = 0) OR (((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2)) < f."transfer") THEN 0
			ELSE ((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2) - f."transfer") / commissionitselfdivisor::NUMERIC END AS "Comm"
		) g ON true
		WHERE i.isfullypaid = true
		AND DATE_TRUNC('MONTH', o.dt) = par_truncmonth
		ORDER BY "SR", c.custname, o.dt, o.orno, i.invoiceno, j.joborderno
	);
END; $$
