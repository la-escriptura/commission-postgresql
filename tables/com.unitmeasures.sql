CREATE TABLE com.unitmeasures (
	unitmeasureid SERIAL NOT NULL
	,unitmeasurename VARCHAR(50) NULL UNIQUE
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (unitmeasureid));
