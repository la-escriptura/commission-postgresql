DROP PROCEDURE IF EXISTS com.usp_insertreceipt;
CREATE PROCEDURE com.usp_insertreceipt(
	par_json JSON,
	par_userid INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
	var_receiptpreeditid INTEGER;
    var_or VARCHAR(50);
	var_isEditReceipt BOOLEAN;
    var_dt TIMESTAMPTZ;
BEGIN
	SELECT j."OR"
		,j."isEditReceipt"
		,j."dt"
	INTO var_or
		,var_isEditReceipt
		,var_dt
	FROM json_to_record(par_json)j (
		"OR" VARCHAR(50)
		,"isEditReceipt" BOOLEAN
		,"dt" TIMESTAMPTZ
	);

	IF (var_isEditReceipt) THEN
		WITH tbl AS (UPDATE com.receipts m SET
			dt = var_dt
		FROM (
			SELECT receiptid
				,orno
				,dt
			FROM com.receipts
			WHERE receiptid = var_or::INTEGER
			FOR UPDATE) j
		WHERE m.receiptid = j.receiptid
		RETURNING j.orno
			,j.dt)
		INSERT INTO com.receiptspreedit (
			receiptid
			,orno
			,dt
			,updatedby
			,updateddate
		) SELECT var_or::INTEGER
			,orno
			,dt
			,par_userid
			,CURRENT_TIMESTAMP
		FROM tbl RETURNING receiptpreeditid INTO var_receiptpreeditid;

		WITH tbl AS (UPDATE com.accounts n SET
			rebate = t.newrebate
			,retention = t.newretention
			,penalty = t.newpenalty
			,govshare = t.newgovshare
			,withheld0 = t.newwithheld0
			,withheld1 = t.newwithheld1
			,withheld2 = t.newwithheld2
		FROM (SELECT b.accountid AS oldaccountid
			,b.invoiceid AS oldinvoiceid
			,b.rebate AS oldrebate
			,b.retention AS oldretention
			,b.penalty AS oldpenalty
			,b.govshare AS oldgovshare
			,b.withheld0 AS oldwithheld0
			,b.withheld1 AS oldwithheld1
			,b.withheld2 AS oldwithheld2
			,j.rebate AS newrebate
			,j.retention AS newretention
			,j.penalty AS newpenalty
			,j.govshare AS newgovshare
			,j.withheld0 AS newwithheld0
			,j.withheld1 AS newwithheld1
			,j.withheld2 AS newwithheld2
			FROM com.accounts b
			INNER JOIN json_to_recordset(par_json->'invoices')j (
			invoice VARCHAR(50)
			,rebate NUMERIC
			,retention NUMERIC
			,penalty NUMERIC
			,govshare NUMERIC
			,withheld0 NUMERIC
			,withheld1 NUMERIC
			,withheld2 NUMERIC
			) ON b.accountid = j.invoice::INTEGER
			FOR UPDATE) t
		WHERE n.accountid = t.oldaccountid
		RETURNING t.oldaccountid
			,t.oldinvoiceid
			,t.oldrebate
			,t.oldretention
			,t.oldpenalty
			,t.oldgovshare
			,t.oldwithheld0
			,t.oldwithheld1
			,t.oldwithheld2)
		INSERT INTO com.accountspreedit (
			accountid
			,receiptpreeditid
			,invoiceid
			,rebate
			,retention
			,penalty
			,govshare
			,withheld0
			,withheld1
			,withheld2
			,updatedby
			,updateddate
		) SELECT oldaccountid
			,var_receiptpreeditid
			,oldinvoiceid
			,oldrebate
			,oldretention
			,oldpenalty
			,oldgovshare
			,oldwithheld0
			,oldwithheld1
			,oldwithheld2
			,par_userid
			,CURRENT_TIMESTAMP
		FROM tbl;
	ELSE
		INSERT INTO com.receipts (
			orno
			,dt
			,updatedby
			,updateddate
		) VALUES (
			var_or
			,var_dt
			,par_userid
			,CURRENT_TIMESTAMP
		)RETURNING receiptid INTO var_or;

		WITH tbl AS (INSERT INTO com.accounts (receiptid, invoiceid, rebate, retention, penalty, govshare, withheld0, withheld1, withheld2, updatedby, updateddate)
		SELECT var_or::INTEGER, i.invoiceid, j."rebate", j."retention", j."penalty", j."govshare", j."withheld0", j."withheld1", j."withheld2", par_userid, CURRENT_TIMESTAMP
		FROM json_to_recordset(par_json->'invoices')j
		("invoice" VARCHAR(50), "rebate" NUMERIC, "retention" NUMERIC, "penalty" NUMERIC, "govshare" NUMERIC, "withheld0" NUMERIC, "withheld1" NUMERIC, "withheld2" NUMERIC)
		LEFT JOIN com.invoices i ON j."invoice" = i.invoiceno
		RETURNING invoiceid)
		UPDATE com.invoices SET isfullypaid = true WHERE invoiceid IN (SELECT invoiceid FROM tbl);
	END IF;
END; $$
