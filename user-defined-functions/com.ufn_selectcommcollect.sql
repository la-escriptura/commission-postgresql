DROP FUNCTION IF EXISTS com.ufn_selectcommcollect;
CREATE FUNCTION com.ufn_selectcommcollect(
	par_truncmonth TIMESTAMPTZ
) RETURNS TABLE (
	"SR" VARCHAR(250)
	,"JO No." VARCHAR(50)
	,"Inv. No." VARCHAR(50)
	,"Date of Invoice" TIMESTAMPTZ
	,"OR No." VARCHAR(50)
	,"Date of O.R." TIMESTAMPTZ
	,"Customer" VARCHAR(250)
	,"Form" VARCHAR(200)
	,"T/Cost" NUMERIC
	,"D/Stamps" NUMERIC
	,"Transfer" NUMERIC
	,"VAT" NUMERIC
	,"Amount of Invoice" NUMERIC
	,"Deductions" NUMERIC
	,"Amount Received" NUMERIC
	,"Com/Basis" NUMERIC
	,"Margin" NUMERIC -- ,"Aging" INTEGER
) LANGUAGE plpgsql AS $$
DECLARE vat VARCHAR(100);
DECLARE marginfinal VARCHAR(100);
DECLARE commisionbasis VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'VAT' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGINFINAL' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISIONBASIS' THEN formulaexpression ELSE NULL END)
	INTO vat, marginfinal, commisionbasis
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('VAT', 'MARGINFINAL','COMMISIONBASIS')
	) pvt;

	RETURN QUERY(
		SELECT CONCAT(LEFT(a.first_name,1),LEFT(a.middle_name,1),LEFT(a.last_name,1))::VARCHAR(250) AS "SR"
		,j.joborderno AS "JO No."
		,i.invoiceno AS "Inv. No."
		,i.dt AS "Date of Invoice"
		,o.orno AS "OR No."
		,o.dt AS "Date of O.R."
		,c.custname AS "Customer"
		,j.formtitle AS "Form"
		,ROUND((j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity,2) AS "T/Cost"
		,ROUND(j.docstamps / j.quantity * i.quantity,2) AS "D/Stamps"
		,ROUND(f."transfer",2) AS "Transfer"
		,ROUND((j.sellingprice / j.quantity * i.quantity) / (1 + vat::NUMERIC) * vat::NUMERIC,2) AS "VAT"
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity,2) AS "Amount of Invoice"
		,ROUND(j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2,2) AS "Deductions"
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2) AS "Amount Received"
		,ROUND(f."Com/Basis",2) AS "Com/Basis"
		,ROUND(e."Margin",2) AS "Margin" -- ,e.Aging
		FROM com.receipts o
		INNER JOIN com.accounts b ON o.receiptid = b.receiptid
		INNER JOIN com.invoices i ON b.invoiceid = i.invoiceid
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.agents a ON j.accountmanager = a.agentid
		INNER JOIN com.customers c ON j.custid = c.custid
		LEFT JOIN LATERAL (
			SELECT CASE WHEN j.callable = 0 THEN com.f(CONCAT('{"PaidAmount":',ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity - (j.discount / j.quantity * i.quantity + b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2),',"DocsStamps":',ROUND(j.docstamps / j.quantity * i.quantity,2),',"VatRate":',vat::NUMERIC,'}')::JSON,commisionbasis)
			ELSE com.f(CONCAT('{"PaidAmount":',ROUND((j.callable - j.shippingHandling) / j.quantity * i.quantity - (b.rebate + b.retention + b.penalty + b.govshare + b.withheld0 + b.withheld1 + b.withheld2),2),',"DocsStamps":',ROUND(j.docstamps / j.quantity * i.quantity,2),',"VatRate":',vat::NUMERIC,'}')::JSON,commisionbasis) END AS "Com/Basis"
		) d ON true
		LEFT JOIN LATERAL (
			SELECT EXTRACT(DAY FROM o.dt - i.dt)::INTEGER AS Aging
			,com.f(CONCAT('{"TotalCost":',ROUND((j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity,2),',"CommisionBasis":',ROUND(d."Com/Basis",2),'}')::JSON,marginfinal) AS "Margin"
		) e ON true
		LEFT JOIN LATERAL (
			SELECT com.transfer(j.totaltransfer / j.quantity * i.quantity, (j.materialcost + j.processcost + j.othercost) / j.quantity * i.quantity) AS "transfer"
			,com.commissionbasis(j.joborderid, e.Aging, e."Margin", d."Com/Basis") AS "Com/Basis"
		) f ON true
		WHERE i.isfullypaid = true
		AND DATE_TRUNC('MONTH', o.dt) = par_truncmonth
		ORDER BY "SR", c.custname, o.dt, o.orno, i.invoiceno, j.joborderno
	);
END; $$
