DROP PROCEDURE IF EXISTS com.usp_insertjoborder;
CREATE PROCEDURE com.usp_insertjoborder(
	par_json JSON,
	par_userid INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
	var_joborderpreeditid INTEGER;
	var_jobOrder VARCHAR(50);
	var_isEditJobOrder BOOLEAN;
	var_orderRef VARCHAR(50);
	var_dt TIMESTAMPTZ;
	var_customerName INTEGER;
	var_isNewCustomerName BOOLEAN;
	var_formTitle VARCHAR(200);
	var_quantity INTEGER;
	var_unitMeasure VARCHAR(50);
	var_materialCost NUMERIC;
	var_processCost NUMERIC;
	var_otherCost NUMERIC;
	var_totalTransfer NUMERIC;
	var_sellingPrice NUMERIC;
	var_docStamps NUMERIC;
	var_discount NUMERIC;
	var_shippingHandling NUMERIC;
	var_callable NUMERIC;
	var_accountManager INTEGER;
BEGIN
	SELECT j."jobOrder"
		,j."isEditJobOrder"
		,j."orderRef"
		,j."dt"
		,j."customerName"
		,j."isNewCustomerName"
		,j."formTitle"
		,j."quantity"
		,j."unitMeasure"
		,j."materialCost"
		,j."processCost"
		,j."otherCost"
		,j."totalTransfer"
		,j."sellingPrice"
		,j."docStamps"
		,j."discount"
		,j."shippingHandling"
		,j."callable"
		,j."accountManager"
	INTO
		var_jobOrder
		,var_isEditJobOrder
		,var_orderRef
		,var_dt
		,var_customerName
		,var_isNewCustomerName
		,var_formTitle
		,var_quantity
		,var_unitMeasure
		,var_materialCost
		,var_processCost
		,var_otherCost
		,var_totalTransfer
		,var_sellingPrice
		,var_docStamps
		,var_discount
		,var_shippingHandling
		,var_callable
		,var_accountManager
	FROM json_to_record(par_json)j (
		"jobOrder" VARCHAR(50)
		,"isEditJobOrder" BOOLEAN
		,"orderRef" VARCHAR(50)
		,"dt" TIMESTAMPTZ
		,"customerName" INTEGER
		,"isNewCustomerName" BOOLEAN
		,"formTitle" VARCHAR(200)
		,"quantity" INTEGER
		,"unitMeasure" VARCHAR(50)
		,"materialCost" NUMERIC
		,"processCost" NUMERIC
		,"otherCost" NUMERIC
		,"totalTransfer" NUMERIC
		,"sellingPrice" NUMERIC
		,"docStamps" NUMERIC
		,"discount" NUMERIC
		,"shippingHandling" NUMERIC
		,"callable" NUMERIC
		,"accountManager" INTEGER
	);

	IF (var_isNewCustomerName) THEN
		INSERT INTO com.customers(
			custname
			,isactive
			,updatedby
			,updateddate
		) VALUES (
			TRIM(FROM var_customerName)
			,true
			,par_userid
			,CURRENT_TIMESTAMP
		) RETURNING custid INTO var_customerName;
	END IF;

	INSERT INTO com.unitmeasures (unitmeasurename, updatedby, updateddate)
	VALUES (UPPER(var_unitmeasure), par_userid, CURRENT_TIMESTAMP)
	ON CONFLICT DO NOTHING;

	IF (var_isEditJobOrder) THEN
		WITH tbl AS (UPDATE com.joborders k SET
			orderref = var_orderRef
			,dt = var_dt
			,custid = var_customerName::INTEGER
			,formtitle = var_formTitle
			,quantity = var_quantity
			,unitmeasure = var_unitMeasure
			,materialcost = var_materialCost
			,processcost = var_processCost
			,othercost = var_otherCost
			,totaltransfer = var_totalTransfer
			,sellingprice = var_sellingPrice
			,docstamps = var_docStamps
			,discount = var_discount
			,shippingHandling = var_shippingHandling
			,callable = var_callable
			,accountmanager = var_accountManager
		FROM (
			SELECT joborderid
			,joborderno
			,orderref
			,dt
			,custid
			,formtitle
			,quantity
			,unitmeasure
			,materialcost
			,processcost
			,othercost
			,totaltransfer
			,sellingprice
			,docstamps
			,discount
			,shippingHandling
			,callable
			,accountmanager
			,isfullyinvoiced
			FROM com.joborders
			WHERE joborderid = var_jobOrder::INTEGER
			FOR UPDATE) j
		WHERE k.joborderid = j.joborderid
		RETURNING j.joborderno
			,j.orderref
			,j.dt
			,j.custid
			,j.formtitle
			,j.quantity
			,j.unitmeasure
			,j.materialcost
			,j.processcost
			,j.othercost
			,j.totaltransfer
			,j.sellingprice
			,j.docstamps
			,j.discount
			,j.shippingHandling
			,j.callable
			,j.accountmanager
			,j.isfullyinvoiced)
		INSERT INTO com.joborderspreedit (
			joborderid
			,joborderno
			,orderref
			,dt
			,custid
			,formtitle
			,quantity
			,unitmeasure
			,materialcost
			,processcost
			,othercost
			,totaltransfer
			,sellingprice
			,docstamps
			,discount
			,shippingHandling
			,callable
			,accountmanager
			,isfullyinvoiced
			,updatedby
			,updateddate
		) SELECT var_jobOrder::INTEGER
			,joborderno
			,orderref
			,dt
			,custid
			,formtitle
			,quantity
			,unitmeasure
			,materialcost
			,processcost
			,othercost
			,totaltransfer
			,sellingprice
			,docstamps
			,discount
			,shippingHandling
			,callable
			,accountmanager
			,isfullyinvoiced
			,par_userid
			,CURRENT_TIMESTAMP
		FROM tbl RETURNING joborderpreeditid INTO var_joborderpreeditid;

		INSERT INTO com.salesrepspreedit (
			joborderpreeditid
			,agentid
			,rate
			,updatedby
			,updateddate
		) SELECT var_joborderpreeditid
			,agentid
			,rate
			,updatedby
			,updateddate
		FROM com.salesreps
		WHERE joborderid = var_jobOrder::INTEGER
		AND agentid NOT IN (
			SELECT CAST(j."agent" AS INTEGER)
			FROM json_to_recordset(par_json->'salesReps')j ("agent" INTEGER));
	ELSE
		INSERT INTO com.joborders (
			joborderno
			,orderref
			,dt
			,custid
			,formtitle
			,quantity
			,unitmeasure
			,materialcost
			,processcost
			,othercost
			,totaltransfer
			,sellingprice
			,docstamps
			,discount
			,shippingHandling
			,callable
			,accountmanager
			,updatedby
			,updateddate
		) VALUES (
			var_jobOrder
			,var_orderRef
			,var_dt
			,var_customerName::INTEGER
			,var_formTitle
			,var_quantity
			,var_unitMeasure
			,var_materialCost
			,var_processCost
			,var_otherCost
			,var_totalTransfer
			,var_sellingPrice
			,var_docStamps
			,var_discount
			,var_shippingHandling
			,var_callable
			,var_accountManager
			,par_userid
			,CURRENT_TIMESTAMP
		) RETURNING joborderid INTO var_jobOrder;
	END IF;

	DELETE FROM com.salesreps WHERE joborderid = var_jobOrder::INTEGER;

	INSERT INTO com.salesreps (joborderid, agentid, rate, updatedby, updateddate)
	SELECT var_jobOrder::INTEGER, CAST(j."agent" AS INTEGER), j."rate", par_userid, CURRENT_TIMESTAMP
	FROM json_to_recordset(par_json->'salesReps')j ("agent" INTEGER, "rate" NUMERIC);
END; $$
