USE SANeosBrianWhite
GO


INSERT INTO sma_trn_Casevalue (csvncaseid, csvnValueID, csvnValue, csvsComments, csvdFromDate, csvdToDate, 
			csvnRecUserID, csvdDtCreated, csvnMinSettlementValue, csvnExpectedResolutionDate, csvnMaxSettlementValue)
SELECT DISTINCT
	cas.casncaseid			as csvncaseid,
	NULL					as csvnValueID,
	NULL					as csvnValue,
	isnull('Value Notes: ' + nullif(convert(varchar(max),ud.value_notes),'') + CHAR(13),'') +
	isnull('Case Grade Value: ' + nullif(convert(varchar(max),ud.Case_Grade_Value),'') + CHAR(13),'') +
	''						as csvsComments, 
	getdate()				as csvdFromDate,
	null					as csvdToDate,
	368						as csvnRecUserID,
	getdate()				as csvdDtCreated,
	minimum_amount			as csvnMinSettlementValue,
	null					as csvnExpectedResolutionDate,
	ud.Estimated_Value_of_Case		as csvnMaxSettlementValue
--select *
FROM NeosBrianWhite..insurance ii
JOIN sma_trn_Cases cas on cas.Neos_Saga = convert(varchar(50),ii.casesid)
LEFT JOIN NeosBrianWhite..user_tab7_data ud on convert(varchar,ud.case_id) = cas.cassCaseNumber
WHERE isnull(minimum_amount,0) <> 0
or isnull(ud.Estimated_Value_of_Case,0)<> 0