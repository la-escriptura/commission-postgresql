CREATE TABLE com.formula (
	formulaid SERIAL NOT NULL
	,formulaname VARCHAR(50) NULL UNIQUE
	,formulaexpression VARCHAR(100) NULL
	,formuladescription VARCHAR(400) NULL
	,updatedby INTEGER NULL
	,updateddate TIMESTAMPTZ NULL
	,PRIMARY KEY (formulaid));
