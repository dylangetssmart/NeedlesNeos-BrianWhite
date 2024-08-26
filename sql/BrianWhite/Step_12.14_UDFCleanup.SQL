USE BrianWhiteSA
GO

ALTER TABLE sma_trn_udfvalues DISABLE TRIGGER ALL
GO

--UPDATE FORMAT OF DATE
UPDATE sma_trn_udfvalues
SET udvsUDFValue =
CASE
	WHEN ISDATE(udvsudfvalue) = 1 AND
		CONVERT(DATETIME, udvsudfvalue) BETWEEN '1/1/1900' AND '6/6/2079'
		THEN CONVERT(VARCHAR, CONVERT(DATETIME, udvsUDFValue), 101)
	ELSE udvsudfvalue
END
FROM sma_trn_udfvalues v
JOIN sma_MST_UDFDefinition d
	ON v.udvnUDFID = d.udfnUDFID
WHERE udfsType = 'Date'
AND ISNULL(udvsudfvalue, '') <> ''


--UPDATE FORMAT OF checkbox
UPDATE sma_trn_udfvalues
SET udvsUDFValue =
CASE
	WHEN udvsUDFValue = 'true'
		THEN 1
	WHEN udvsUDFValue = 'false'
		THEN 0
	ELSE ''
END
--Select *
FROM sma_trn_udfvalues v
JOIN sma_MST_UDFDefinition d
	ON v.udvnUDFID = d.udfnUDFID
WHERE udfsType = 'Checkbox'
AND ISNULL(udvsUDFValue, '') IN ('true', 'false')


ALTER TABLE sma_trn_udfvalues ENABLE TRIGGER ALL
GO

UPDATE sma_MST_UDFDefinition
SET udfstype = 'Date'
WHERE udfsType = 'date'

UPDATE sma_MST_UDFDefinition
SET udfstype = 'Time'
WHERE udfsType = 'time'

UPDATE sma_MST_UDFDefinition
SET udfstype = 'Number'
WHERE udfsType = 'number'

UPDATE sma_MST_UDFDefinition
SET udfstype = 'CheckBox'
WHERE udfsType = 'checkbox'

UPDATE sma_MST_UDFDefinition
SET udfstype = 'Text'
WHERE udfsType IN ('text', 'Staff')
