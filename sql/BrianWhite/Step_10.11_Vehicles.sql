USE BrianWhiteSANeos
GO

--truncate table [sma_TRN_Vehicles]

/*
select casesid, [Def 2 Veh Yr/Make/Model], [Def 2 License Plate], [Def 2 Vehicle Drivable]
FROM BrianWhiteNeos..neosuserTab6
WHERE isnull([Def 2 License Plate],'') <> ''
or isnull([Def 2 Veh Yr/Make/Model],'') <> ''

select casesid, [Def Vehicle Yr/Make/Model], [Def License Plate], [Def Vehicle Drivable],[Def on Cell Phone]
FROM BrianWhiteNeos..neosuserTab6
WHERE isnull([Def License Plate],'') <> ''
or isnull([Def Vehicle Yr/Make/Model],'') <> ''

select casesid, [Pl Vehicle Yr/Make/Model], [Plt on Cell Phone], [Pl Car Drivable],[Pl Description of Damage]
FROM BrianWhiteNeos..neosuserTab6
WHERE isnull([Pl Vehicle Yr/Make/Model],'') <> ''
or isnull([Pl Description of Damage],'') <> ''
*/
-------------------------------
--INSERT VEHICLE MAKES
-------------------------------
/*
INSERT INTO sma_MST_VehicleMake (vmksDscrptn)
SELECT DISTINCT [Make]
EXCEPT
SELECT vmksDscrptn from sma_MST_VehicleMake

-------------------------------
--INSERT VEHICLE MODELS
-------------------------------
INSERT INTO sma_MST_VehicleModels (vmdnMakeID, vmdsModelDscrptn)
SELECT DISTINCT (select vmknMakeID From sma_MST_VehicleMake where vmksDscrptn=[Make]), model
FROM CasePeerSheehan..Carpropertydamage 
WHERE isnull([Model],'') <>''
EXCEPT SELECT vmdnMakeID, vmdsModelDscrptn FROM sma_MST_VehicleModels
*/
/*
ALTER TABLE sma_trn_Vehicles
ALTER COLUMN vehsComments varchar(300)
GO
*/
ALTER TABLE sma_trn_Vehicles
ALTER COLUMN vehsPlateNo VARCHAR(15);
GO

---------------------------------------------------------
--PLAINTIFF VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	(
	[vehnCaseID]
   ,[vehbIsPlaintiff]
   ,[vehnPlntDefID]
   ,[vehnOwnerID]
   ,[vehnOwnerCtg]
   ,[vehnRegistrantID]
   ,[vehnRegistrantCtg]
   ,[vehnOperatorID]
   ,[vehnOperatorCtg]
   ,[vehsLicenceNo]
   ,[vehnLicenceStateID]
   ,[vehdLicExpDt]
   ,[vehnVehicleMake]
   ,[vehnYear]
   ,[vehnModelID]
   ,[vehnBodyTypeID]
   ,[vehsPlateNo]
   ,[vehsColour]
   ,[vehnVehicleStateID]
   ,[vehsVINNo]
   ,[vehdRegExpDt]
   ,[vehnIsLeased]
   ,[vehnDamageClaim]
   ,[vehdEstReqdOn]
   ,[vehdEstRecvdOn]
   ,[vehdPhotoReqdOn]
   ,[vehdPhotoRecvdOn]
   ,[vehbRepairs]
   ,[vehbTotalLoss]
   ,[vehnCostOfRepairs]
   ,[vehnValueBefAcdnt]
   ,[vehnRentalExpense]
   ,[vehnOthExpense]
   ,[vehnSalvage]
   ,[vehnTLRentalExpense]
   ,[vehnTLOthExpense]
   ,[vehnLoss]
   ,[vehnNetLoss]
   ,[vehnLicenseHistory]
   ,[vehnPlateSearch]
   ,[vehnTitlesearch]
   ,[vehnMV104]
   ,[vehdOprLicHistory]
   ,[vehdPlateSearchOn]
   ,[vehdTitleSearchOn]
   ,[vehdMV104On]
   ,[vehdOprLicHistoryRecd]
   ,[vehdPlateSearchOnRecd]
   ,[vehdTitleSearchOnRecd]
   ,[vehdMV104OnRecd]
   ,[vehsComments]
   ,[vehbPhotoAttached]
   ,[vehnRecUserID]
   ,[vehdDtCreated]
   ,[vehnModifyUserID]
   ,[vehdDtModified]
   ,[vehnLevelNo]
	)
	SELECT DISTINCT
		cas.casnCaseID
	   ,			--[vehnCaseID],
		1
	   ,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		p.plnnPlaintiffID
	   ,		--[vehnPlntDefID],
		NULL
	   ,					--[vehnOwnerID],
		NULL
	   , 					--[vehnOwnerCtg],
		NULL
	   , 					--[vehnRegistrantID],
		NULL
	   ,					--[vehnRegistrantCtg],
		NULL
	   , 					--[vehnOperatorID],
		NULL
	   , 					--[vehnOperatorCtg],
		NULL
	   ,					--[vehsLicenceNo],  --varchar 25
		NULL
	   ,					--[vehnLicenceStateID],
		NULL
	   ,					--[vehdLicExpDt],
		vm.vmknMakeID
	   ,			--[vehnVehicleMake],
		CASE
			WHEN ISNUMERIC(LEFT([Pl Vehicle Yr/Make/Model], 4)) = 1
				THEN LEFT([Pl Vehicle Yr/Make/Model], 4)
			WHEN ISNUMERIC(LEFT([Pl Vehicle Yr/Make/Model], 2)) = 1 AND
				[Pl Vehicle Yr/Make/Model] NOT LIKE '18 wheel%'
				THEN LEFT([Pl Vehicle Yr/Make/Model], 2)
			ELSE ''
		END
	   ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID
	   ,		--[vehnModelID],
		NULL
	   , 					--[vehnBodyTypeID],
		NULL
	   ,					--[vehsPlateNo],
		NULL
	   ,					--[vehsColour],  30
		NULL
	   ,					--[vehnVehicleStateID],
		NULL
	   ,					--[vehsVINNo],   25
		NULL
	   ,					--[vehdRegExpDt],
		NULL
	   , 					--[vehnIsLeased],
		NULL
	   ,					--[vehnDamageClaim],
		NULL
	   , 					--[vehdEstReqdOn],
		NULL
	   , 					--[vehdEstRecvdOn],
		NULL
	   , 					--[vehdPhotoReqdOn],
		NULL
	   , 					--[vehdPhotoRecvdOn],
		NULL
	   , 					--[vehbRepairs],
		NULL
	   , 					--[vehbTotalLoss],
		NULL
	   , 					--[vehnCostOfRepairs],
		NULL
	   , 					--[vehnValueBefAcdnt],
		NULL
	   , 					--[vehnRentalExpense],
		NULL
	   , 					--[vehnOthExpense],
		NULL
	   , 					--[vehnSalvage],
		NULL
	   , 					--[vehnTLRentalExpense],
		NULL
	   , 					--[vehnTLOthExpense],
		NULL
	   , 					--[vehnLoss],
		NULL
	   , 					--[vehnNetLoss],
		NULL
	   , 					--[vehnLicenseHistory],
		NULL
	   , 					--[vehnPlateSearch],
		NULL
	   , 					--[vehnTitlesearch],
		NULL
	   , 					--[vehnMV104],
		NULL
	   , 					--[vehdOprLicHistory],
		NULL
	   , 					--[vehdPlateSearchOn],
		NULL
	   , 					--[vehdTitleSearchOn],
		NULL
	   , 					--[vehdMV104On],
		NULL
	   , 					--[vehdOprLicHistoryRecd],
		NULL
	   , 					--[vehdPlateSearchOnRecd],
		NULL
	   , 					--[vehdTitleSearchOnRecd],
		NULL
	   , 					--[vehdMV104OnRecd],
		ISNULL('Year/Make/Model: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Pl Vehicle Yr/Make/Model]), '') + CHAR(13), '') +
		ISNULL('Description of Damage: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Pl Description of Damage]), '') + CHAR(13), '') +
		ISNULL('Plt on Cell Phone: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Plt on Cell Phone]), '') + CHAR(13), '') +
		ISNULL('Pl Car Drivable: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Pl Car Drivable]), '') + CHAR(13), '') +
		ISNULL('Airbag Deployed: ' + NULLIF(CONVERT(VARCHAR(MAX), ud.[Airbag Deployed]), '') + CHAR(13), '') +
		''
	   , 					--[vehsComments],  200
		NULL
	   , 					--[vehbPhotoAttached],
		368
	   , 					--[vehnRecUserID],
		GETDATE()
	   , 				--[vehdDtCreated],
		NULL
	   , 					--[vehnModifyUserID],
		NULL
	   , 					--[vehdDtModified],
		1						--[vehnLevelNo]
	--Select ymm.[data], vm.vmksDscrptn, vmo.vmdsModelDscrptn
	FROM BrianWhiteNeos..neosuserTab6 ud
	JOIN sma_trn_Cases cas
		ON cas.Neos_saga = CONVERT(VARCHAR(50), ud.casesid)
	LEFT JOIN sma_TRN_Plaintiff p
		ON p.plnnCaseID = cas.casnCaseID
			AND p.plnbIsPrimary = 1
	LEFT JOIN sma_MST_VehicleMake vm
		ON [Pl Vehicle Yr/Make/Model] LIKE CASE
				WHEN vm.vmksdscrptn LIKE '%chevr%'
					THEN '%Chev%'
				WHEN vm.vmksdscrptn LIKE '%merce%'
					THEN '%Merc%'
				WHEN vm.vmksdscrptn LIKE '%volksw%'
					THEN '%Volk%'
				WHEN vm.vmksdscrptn LIKE '%Porsche%'
					THEN '%Por%'
				WHEN vm.vmksdscrptn LIKE '%Infin%'
					THEN '%Infin%'
				ELSE '%' + vm.vmksDscrptn + '%'
			END
	LEFT JOIN sma_MST_VehicleModels vmo
		ON vmo.vmdnMakeID = vm.vmknMakeID
			AND [Pl Vehicle Yr/Make/Model] LIKE '%' + vmo.vmdsModelDscrptn + '%'
	WHERE ISNULL([Pl Vehicle Yr/Make/Model], '') <> ''
		OR ISNULL([Pl Description of Damage], '') <> ''
GO

---------------------------------------------------------
--DEFENDANT VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	(
	[vehnCaseID]
   ,[vehbIsPlaintiff]
   ,[vehnPlntDefID]
   ,[vehnOwnerID]
   ,[vehnOwnerCtg]
   ,[vehnRegistrantID]
   ,[vehnRegistrantCtg]
   ,[vehnOperatorID]
   ,[vehnOperatorCtg]
   ,[vehsLicenceNo]
   ,[vehnLicenceStateID]
   ,[vehdLicExpDt]
   ,[vehnVehicleMake]
   ,[vehnYear]
   ,[vehnModelID]
   ,[vehnBodyTypeID]
   ,[vehsPlateNo]
   ,[vehsColour]
   ,[vehnVehicleStateID]
   ,[vehsVINNo]
   ,[vehdRegExpDt]
   ,[vehnIsLeased]
   ,[vehnDamageClaim]
   ,[vehdEstReqdOn]
   ,[vehdEstRecvdOn]
   ,[vehdPhotoReqdOn]
   ,[vehdPhotoRecvdOn]
   ,[vehbRepairs]
   ,[vehbTotalLoss]
   ,[vehnCostOfRepairs]
   ,[vehnValueBefAcdnt]
   ,[vehnRentalExpense]
   ,[vehnOthExpense]
   ,[vehnSalvage]
   ,[vehnTLRentalExpense]
   ,[vehnTLOthExpense]
   ,[vehnLoss]
   ,[vehnNetLoss]
   ,[vehnLicenseHistory]
   ,[vehnPlateSearch]
   ,[vehnTitlesearch]
   ,[vehnMV104]
   ,[vehdOprLicHistory]
   ,[vehdPlateSearchOn]
   ,[vehdTitleSearchOn]
   ,[vehdMV104On]
   ,[vehdOprLicHistoryRecd]
   ,[vehdPlateSearchOnRecd]
   ,[vehdTitleSearchOnRecd]
   ,[vehdMV104OnRecd]
   ,[vehsComments]
   ,[vehbPhotoAttached]
   ,[vehnRecUserID]
   ,[vehdDtCreated]
   ,[vehnModifyUserID]
   ,[vehdDtModified]
   ,[vehnLevelNo]
	)
	SELECT DISTINCT
		cas.casnCaseID
	   ,			--[vehnCaseID],
		0
	   ,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		d.defnDefendentID
	   ,		--[vehnPlntDefID],
		NULL
	   ,					--[vehnOwnerID],
		NULL
	   , 					--[vehnOwnerCtg],
		NULL
	   , 					--[vehnRegistrantID],
		NULL
	   ,					--[vehnRegistrantCtg],
		NULL
	   , 					--[vehnOperatorID],
		NULL
	   , 					--[vehnOperatorCtg],
		NULL
	   ,					--[vehsLicenceNo],  --varchar 25
		NULL
	   ,					--[vehnLicenceStateID],
		NULL
	   ,					--[vehdLicExpDt],
		vm.vmknMakeID
	   ,			--[vehnVehicleMake],
		CASE
			WHEN ISNUMERIC(LEFT([Def Vehicle Yr/Make/Model], 4)) = 1
				THEN LEFT([Def Vehicle Yr/Make/Model], 4)
			WHEN ISNUMERIC(LEFT([Def Vehicle Yr/Make/Model], 2)) = 1 AND
				[Def Vehicle Yr/Make/Model] NOT LIKE '18 wheel%'
				THEN LEFT([Def Vehicle Yr/Make/Model], 2)
			ELSE ''
		END
	   ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID
	   ,		--[vehnModelID],
		NULL
	   , 					--[vehnBodyTypeID],
		[Def License Plate]
	   ,	--[vehsPlateNo],	10
		NULL
	   , 					--[vehsColour],  30
		NULL
	   ,					--[vehnVehicleStateID],
		NULL
	   ,					--[vehsVINNo],   25
		NULL
	   ,					--[vehdRegExpDt],
		NULL
	   , 					--[vehnIsLeased],
		NULL
	   ,					--[vehnDamageClaim],
		NULL
	   , 					--[vehdEstReqdOn],
		NULL
	   , 					--[vehdEstRecvdOn],
		NULL
	   , 					--[vehdPhotoReqdOn],
		NULL
	   , 					--[vehdPhotoRecvdOn],
		NULL
	   , 					--[vehbRepairs],
		NULL
	   , 					--[vehbTotalLoss],
		NULL
	   , 					--[vehnCostOfRepairs],
		NULL
	   , 					--[vehnValueBefAcdnt],
		NULL
	   , 					--[vehnRentalExpense],
		NULL
	   , 					--[vehnOthExpense],
		NULL
	   , 					--[vehnSalvage],
		NULL
	   , 					--[vehnTLRentalExpense],
		NULL
	   , 					--[vehnTLOthExpense],
		NULL
	   , 					--[vehnLoss],
		NULL
	   , 					--[vehnNetLoss],
		NULL
	   , 					--[vehnLicenseHistory],
		NULL
	   , 					--[vehnPlateSearch],
		NULL
	   , 					--[vehnTitlesearch],
		NULL
	   , 					--[vehnMV104],
		NULL
	   , 					--[vehdOprLicHistory],
		NULL
	   , 					--[vehdPlateSearchOn],
		NULL
	   , 					--[vehdTitleSearchOn],
		NULL
	   , 					--[vehdMV104On],
		NULL
	   , 					--[vehdOprLicHistoryRecd],
		NULL
	   , 					--[vehdPlateSearchOnRecd],
		NULL
	   , 					--[vehdTitleSearchOnRecd],
		NULL
	   , 					--[vehdMV104OnRecd],
		ISNULL('Year/Make/Model: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def Vehicle Yr/Make/Model]), '') + CHAR(13), '') +
		ISNULL('Def Vehicle Drivable: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def Vehicle Drivable]), '') + CHAR(13), '') +
		ISNULL('Def on Cell Phone: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def on Cell Phone]), '') + CHAR(13), '') +
		ISNULL('Def Description of Damage: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def Description of Damage]), '') + CHAR(13), '') +
		''
	   , 					--[vehsComments],  200
		NULL
	   , 					--[vehbPhotoAttached],
		368
	   , 					--[vehnRecUserID],
		GETDATE()
	   , 				--[vehdDtCreated],
		NULL
	   , 					--[vehnModifyUserID],
		NULL
	   , 					--[vehdDtModified],
		1						--[vehnLevelNo]
	--Select max(len([Def License Plate]))
	FROM BrianWhiteNeos..neosuserTab6 ud
	JOIN sma_trn_Cases cas
		ON cas.Neos_saga = CONVERT(VARCHAR(50), ud.casesid)
	LEFT JOIN sma_TRN_Defendants d
		ON d.defnCaseID = cas.casnCaseID
			AND d.defbIsPrimary = 1
	LEFT JOIN sma_MST_VehicleMake vm
		ON [Def Vehicle Yr/Make/Model] LIKE CASE
				WHEN vm.vmksdscrptn LIKE '%chevr%'
					THEN '%Chev%'
				WHEN vm.vmksdscrptn LIKE '%merce%'
					THEN '%Merc%'
				WHEN vm.vmksdscrptn LIKE '%volksw%'
					THEN '%Volk%'
				WHEN vm.vmksdscrptn LIKE '%Porsche%'
					THEN '%Por%'
				WHEN vm.vmksdscrptn LIKE '%Infin%'
					THEN '%Infin%'
				ELSE '%' + vm.vmksDscrptn + '%'
			END
	LEFT JOIN sma_MST_VehicleModels vmo
		ON vmo.vmdnMakeID = vm.vmknMakeID
			AND [Def Vehicle Yr/Make/Model] LIKE '%' + vmo.vmdsModelDscrptn + '%'
	WHERE ISNULL([Def License Plate], '') <> ''
		OR ISNULL([Def Vehicle Yr/Make/Model], '') <> ''
GO


---------------------------------------------------------
--DEFENDANT 2 VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	(
	[vehnCaseID]
   ,[vehbIsPlaintiff]
   ,[vehnPlntDefID]
   ,[vehnOwnerID]
   ,[vehnOwnerCtg]
   ,[vehnRegistrantID]
   ,[vehnRegistrantCtg]
   ,[vehnOperatorID]
   ,[vehnOperatorCtg]
   ,[vehsLicenceNo]
   ,[vehnLicenceStateID]
   ,[vehdLicExpDt]
   ,[vehnVehicleMake]
   ,[vehnYear]
   ,[vehnModelID]
   ,[vehnBodyTypeID]
   ,[vehsPlateNo]
   ,[vehsColour]
   ,[vehnVehicleStateID]
   ,[vehsVINNo]
   ,[vehdRegExpDt]
   ,[vehnIsLeased]
   ,[vehnDamageClaim]
   ,[vehdEstReqdOn]
   ,[vehdEstRecvdOn]
   ,[vehdPhotoReqdOn]
   ,[vehdPhotoRecvdOn]
   ,[vehbRepairs]
   ,[vehbTotalLoss]
   ,[vehnCostOfRepairs]
   ,[vehnValueBefAcdnt]
   ,[vehnRentalExpense]
   ,[vehnOthExpense]
   ,[vehnSalvage]
   ,[vehnTLRentalExpense]
   ,[vehnTLOthExpense]
   ,[vehnLoss]
   ,[vehnNetLoss]
   ,[vehnLicenseHistory]
   ,[vehnPlateSearch]
   ,[vehnTitlesearch]
   ,[vehnMV104]
   ,[vehdOprLicHistory]
   ,[vehdPlateSearchOn]
   ,[vehdTitleSearchOn]
   ,[vehdMV104On]
   ,[vehdOprLicHistoryRecd]
   ,[vehdPlateSearchOnRecd]
   ,[vehdTitleSearchOnRecd]
   ,[vehdMV104OnRecd]
   ,[vehsComments]
   ,[vehbPhotoAttached]
   ,[vehnRecUserID]
   ,[vehdDtCreated]
   ,[vehnModifyUserID]
   ,[vehdDtModified]
   ,[vehnLevelNo]
	)
	SELECT DISTINCT
		cas.casnCaseID
	   ,			--[vehnCaseID],
		0
	   ,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		def.Defendant2
	   ,		--[vehnPlntDefID],
		NULL
	   ,					--[vehnOwnerID],
		NULL
	   , 					--[vehnOwnerCtg],
		NULL
	   , 					--[vehnRegistrantID],
		NULL
	   ,					--[vehnRegistrantCtg],
		NULL
	   , 					--[vehnOperatorID],
		NULL
	   , 					--[vehnOperatorCtg],
		NULL
	   ,					--[vehsLicenceNo],  --varchar 25
		NULL
	   ,					--[vehnLicenceStateID],
		NULL
	   ,					--[vehdLicExpDt],
		vm.vmknMakeID
	   ,			--[vehnVehicleMake],
		CASE
			WHEN ISNUMERIC(LEFT([Def 2 Veh Yr/Make/Model], 4)) = 1
				THEN LEFT([Def 2 Veh Yr/Make/Model], 4)
			WHEN ISNUMERIC(LEFT([Def 2 Veh Yr/Make/Model], 2)) = 1 AND
				[Def 2 Veh Yr/Make/Model] NOT LIKE '18 wheel%'
				THEN LEFT([Def 2 Veh Yr/Make/Model], 2)
			ELSE ''
		END
	   ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID
	   ,		--[vehnModelID],
		NULL
	   , 					--[vehnBodyTypeID],
		[Def 2 License Plate]
	   ,	--[vehsPlateNo],
		NULL
	   , 					--[vehsColour],  30
		NULL
	   ,					--[vehnVehicleStateID],
		NULL
	   ,					--[vehsVINNo],   25
		NULL
	   ,					--[vehdRegExpDt],
		NULL
	   , 					--[vehnIsLeased],
		NULL
	   ,					--[vehnDamageClaim],
		NULL
	   , 					--[vehdEstReqdOn],
		NULL
	   , 					--[vehdEstRecvdOn],
		NULL
	   , 					--[vehdPhotoReqdOn],
		NULL
	   , 					--[vehdPhotoRecvdOn],
		NULL
	   , 					--[vehbRepairs],
		NULL
	   , 					--[vehbTotalLoss],
		NULL
	   , 					--[vehnCostOfRepairs],
		NULL
	   , 					--[vehnValueBefAcdnt],
		NULL
	   , 					--[vehnRentalExpense],
		NULL
	   , 					--[vehnOthExpense],
		NULL
	   , 					--[vehnSalvage],
		NULL
	   , 					--[vehnTLRentalExpense],
		NULL
	   , 					--[vehnTLOthExpense],
		NULL
	   , 					--[vehnLoss],
		NULL
	   , 					--[vehnNetLoss],
		NULL
	   , 					--[vehnLicenseHistory],
		NULL
	   , 					--[vehnPlateSearch],
		NULL
	   , 					--[vehnTitlesearch],
		NULL
	   , 					--[vehnMV104],
		NULL
	   , 					--[vehdOprLicHistory],
		NULL
	   , 					--[vehdPlateSearchOn],
		NULL
	   , 					--[vehdTitleSearchOn],
		NULL
	   , 					--[vehdMV104On],
		NULL
	   , 					--[vehdOprLicHistoryRecd],
		NULL
	   , 					--[vehdPlateSearchOnRecd],
		NULL
	   , 					--[vehdTitleSearchOnRecd],
		NULL
	   , 					--[vehdMV104OnRecd],
		ISNULL('Year/Make/Model: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def 2 Veh Yr/Make/Model]), '') + CHAR(13), '') +
		ISNULL('Def 2 Vehicle Drivable: ' + NULLIF(CONVERT(VARCHAR(MAX), [Def 2 Vehicle Drivable]), '') + CHAR(13), '') +
		''
	   , 					--[vehsComments],  200
		NULL
	   , 					--[vehbPhotoAttached],
		368
	   , 					--[vehnRecUserID],
		GETDATE()
	   , 				--[vehdDtCreated],
		NULL
	   , 					--[vehnModifyUserID],
		NULL
	   , 					--[vehdDtModified],
		1						--[vehnLevelNo]
	--Select *
	FROM BrianWhiteNeos..neosuserTab6 ud
	JOIN sma_trn_Cases cas
		ON cas.Neos_saga = CONVERT(VARCHAR(50), ud.casesid)
	LEFT JOIN (
		SELECT
			d.defncaseid
		   ,MIN(d2.defnDefendentID) Defendant2
		FROM sma_TRN_Defendants d
		LEFT JOIN sma_TRN_Defendants d2
			ON d2.defnCaseID = d.defnCaseID
			AND d2.defnDefendentID <> d.defnDefendentID
			AND d.defbIsPrimary = 1
		GROUP BY d.defncaseid
	) def
		ON def.defnCaseID = cas.casnCaseID
	LEFT JOIN sma_MST_VehicleMake vm
		ON [Def 2 Veh Yr/Make/Model] LIKE CASE
				WHEN vm.vmksdscrptn LIKE '%chevr%'
					THEN '%Chev%'
				WHEN vm.vmksdscrptn LIKE '%merce%'
					THEN '%Merc%'
				WHEN vm.vmksdscrptn LIKE '%volksw%'
					THEN '%Volk%'
				WHEN vm.vmksdscrptn LIKE '%Porsche%'
					THEN '%Por%'
				WHEN vm.vmksdscrptn LIKE '%Infin%'
					THEN '%Infin%'
				ELSE '%' + vm.vmksDscrptn + '%'
			END
	LEFT JOIN sma_MST_VehicleModels vmo
		ON vmo.vmdnMakeID = vm.vmknMakeID
			AND [Def 2 Veh Yr/Make/Model] LIKE '%' + vmo.vmdsModelDscrptn + '%'
	WHERE ISNULL([Def 2 License Plate], '') <> ''
		OR ISNULL([Def 2 Veh Yr/Make/Model], '') <> ''
GO


