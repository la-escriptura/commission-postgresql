DROP PROCEDURE IF EXISTS com.usp_insertinvoice;
CREATE PROCEDURE com.usp_insertinvoice(
	par_json JSON,
	par_userid INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
	var_invoice VARCHAR(50);
	var_isEditInvoice BOOLEAN;
	var_jobOrderNo VARCHAR(50);
	var_dt TIMESTAMPTZ;
	var_qtyinvoice INTEGER;
	var_deliveryReceipt VARCHAR(50);
	var_joborderid INTEGER;
	var_qtyjoborder INTEGER;
	var_sumqtyinvoice INTEGER;
BEGIN
	SELECT j."invoice"
		,j."isEditInvoice"
		,j."jobOrderNo"
		,j."dt"
		,j."qtyinvoice"
		,j."deliveryReceipt"
	INTO
		var_invoice
		,var_isEditInvoice
		,var_jobOrderNo
		,var_dt
		,var_qtyinvoice
		,var_deliveryReceipt
	FROM json_to_record(par_json)j (
		"invoice" VARCHAR(50)
		,"isEditInvoice" BOOLEAN
		,"jobOrderNo" VARCHAR(50)
		,"dt" TIMESTAMPTZ
		,"qtyinvoice" INTEGER
		,"deliveryReceipt" VARCHAR(50)
	);

	SELECT j.joborderid, j.quantity
	INTO var_joborderid, var_qtyjoborder
	FROM com.joborders j
	WHERE j.joborderno = var_joborderno;



	SELECT COALESCE(SUM(i.quantity)::INTEGER,0) - (
		CASE WHEN var_isEditInvoice THEN
			(SELECT quantity FROM com.invoices WHERE invoiceid = var_invoice::INTEGER)
		ELSE 0 END
	) INTO var_sumqtyinvoice
	FROM com.invoices i
	WHERE i.joborderid = var_joborderid;

	IF ((var_sumqtyinvoice + var_qtyinvoice) > var_qtyjoborder) THEN
		RAISE EXCEPTION 'Quantity exceeds the remaining value.';
	ELSEIF ((var_sumqtyinvoice + var_qtyinvoice) = var_qtyjoborder) THEN
		UPDATE com.joborders SET isfullyinvoiced = true WHERE joborderid = var_joborderid;
	ELSE
		UPDATE com.joborders SET isfullyinvoiced = false WHERE joborderid = var_joborderid;
	END IF;

	IF (var_isEditInvoice) THEN
		WITH tbl AS (UPDATE com.invoices l SET
			dt = var_dt
			,quantity = var_qtyinvoice
			,deliveryreceipt = var_deliveryReceipt
		FROM (
			SELECT invoiceid
				,invoiceno
				,joborderid
				,dt
				,quantity
				,deliveryreceipt
				,isfullypaid
			FROM com.invoices
			WHERE invoiceid = var_invoice::INTEGER
			FOR UPDATE) j
		WHERE l.invoiceid = j.invoiceid
		RETURNING j.invoiceno
			,j.joborderid
			,j.dt
			,j.quantity
			,j.deliveryreceipt
			,j.isfullypaid)
		INSERT INTO com.invoicespreedit (
			invoiceid
			,invoiceno
			,joborderid
			,dt
			,quantity
			,deliveryreceipt
			,isfullypaid
			,updatedby
			,updateddate
		) SELECT var_invoice::INTEGER
			,invoiceno
			,joborderid
			,dt
			,quantity
			,deliveryreceipt
			,isfullypaid
			,par_userid
			,CURRENT_TIMESTAMP
		FROM tbl;
	ELSE
		INSERT INTO com.invoices (
			invoiceno
			,joborderid
			,dt
			,quantity
			,deliveryreceipt
			,updatedby
			,updateddate
		) VALUES (
			var_invoice
			,var_joborderid
			,var_dt
			,var_qtyinvoice
			,var_deliveryreceipt
			,par_userid
			,CURRENT_TIMESTAMP
		);
	END IF;
END; $$
