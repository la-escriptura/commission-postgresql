DROP FUNCTION IF EXISTS com.ufn_selectsalesrepcomm;
CREATE FUNCTION com.ufn_selectsalesrepcomm(
	par_truncmonth TIMESTAMPTZ
) RETURNS TABLE (
	"SR" VARCHAR(250)
	,"Jo No." VARCHAR(50)
	,"Inv. No." VARCHAR(50)
	,"Date" TIMESTAMPTZ
	,"OR No." VARCHAR(50)
	,"Date Paid" TIMESTAMPTZ
	,"Customer" VARCHAR(250)
	,"Form" VARCHAR(200)
	,"Quantity" INTEGER
	,"Doc.Stamps" NUMERIC
	,"Selling" NUMERIC
	,"Com/Basis" NUMERIC
	,"Comm" NUMERIC -- ,"Margin" NUMERIC ,"Aging" INTEGER
) LANGUAGE plpgsql AS $$
DECLARE vat VARCHAR(100);
DECLARE marginfinal VARCHAR(100);
DECLARE commisionbasis VARCHAR(100);
DECLARE commissionratesalesagent VARCHAR(100);
BEGIN
	SELECT MAX(CASE WHEN formulaname = 'VAT' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'MARGINFINAL' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISIONBASIS' THEN formulaexpression ELSE NULL END),
	MAX(CASE WHEN formulaname = 'COMMISSIONRATESALESAGENT' THEN formulaexpression ELSE NULL END)
	INTO vat, marginfinal, commisionbasis, commissionratesalesagent
	FROM (
		SELECT formulaname, formulaexpression
		FROM com.formula
		WHERE formulaname IN ('VAT', 'MARGINFINAL','COMMISIONBASIS','COMMISSIONRATESALESAGENT')
	) pvt;

	RETURN QUERY(
		SELECT p.SR AS "SR"
		,j.joborderno AS "Jo No."
		,i.invoiceno AS "Inv. No."
		,i.dt AS "Date"
		,o.orno AS "OR No."
		,o.dt AS "Date Paid"
		,c.custname AS "Customer"
		,j.formtitle AS "Form"
		,i.quantity AS "Quantity"
		,ROUND(j.docstamps / j.quantity * i.quantity,2) AS "Doc.Stamps"
		,ROUND((j.sellingprice + j.docstamps) / j.quantity * i.quantity,2) AS "Selling"
		,ROUND(f."Com/Basis",2) AS "Com/Basis"
		,ROUND(f."Com/Basis" * commissionratesalesagent::NUMERIC * p.rate,2) AS "Comm" -- ,ROUND(e."Margin",2) AS "Margin" ,e.Aging
		FROM com.receipts o
		INNER JOIN com.accounts b ON o.receiptid = b.receiptid
		INNER JOIN com.invoices i ON b.invoiceid = i.invoiceid
		INNER JOIN com.joborders j ON i.joborderid = j.joborderid
		INNER JOIN com.vw_sr p ON j.joborderid = p.joborderid
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
