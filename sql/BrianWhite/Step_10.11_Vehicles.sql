USE SANeosBrianWhite
GO

--truncate table [sma_TRN_Vehicles]

/*
select casesid, [Def 2 Veh Yr/Make/Model], [Def 2 License Plate], [Def 2 Vehicle Drivable]
FROM NeosBrianWhite..neosuserTab6
WHERE isnull([Def 2 License Plate],'') <> ''
or isnull([Def 2 Veh Yr/Make/Model],'') <> ''

select casesid, [Def Vehicle Yr/Make/Model], [Def License Plate], [Def Vehicle Drivable],[Def on Cell Phone]
FROM NeosBrianWhite..neosuserTab6
WHERE isnull([Def License Plate],'') <> ''
or isnull([Def Vehicle Yr/Make/Model],'') <> ''

select casesid, [Pl Vehicle Yr/Make/Model], [Plt on Cell Phone], [Pl Car Drivable],[Pl Description of Damage]
FROM NeosBrianWhite..neosuserTab6
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
ALTER column vehsPlateNo varchar(15);
GO

---------------------------------------------------------
--PLAINTIFF VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	,[vehnVehicleMake],[vehnYear],[vehnModelID],[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo])
SELECT DISTINCT
		cas.casnCaseID,			--[vehnCaseID],
		1,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		p.plnnPlaintiffID,		--[vehnPlntDefID],
		NULL,					--[vehnOwnerID],
		NULL, 					--[vehnOwnerCtg],
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo],  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left([Pl Vehicle Yr/Make/Model],4))=1 then left([Pl Vehicle Yr/Make/Model],4) 
			when isnumeric(left([Pl Vehicle Yr/Make/Model],2)) = 1 and [Pl Vehicle Yr/Make/Model] not like '18 wheel%' then left([Pl Vehicle Yr/Make/Model],2)
			else '' end ,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		null,					--[vehsPlateNo],
		null,					--[vehsColour],  30
		null,					--[vehnVehicleStateID],
		null,					--[vehsVINNo],   25
		NULL,					--[vehdRegExpDt],
		NULL, 					--[vehnIsLeased],
		NULL,					--[vehnDamageClaim],
		NULL, 					--[vehdEstReqdOn],
		NULL, 					--[vehdEstRecvdOn],
		NULL, 					--[vehdPhotoReqdOn],
		NULL, 					--[vehdPhotoRecvdOn],
		NULL, 					--[vehbRepairs],
		NULL, 					--[vehbTotalLoss],
		NULL, 					--[vehnCostOfRepairs],
		NULL, 					--[vehnValueBefAcdnt],
		NULL, 					--[vehnRentalExpense],
		NULL, 					--[vehnOthExpense],
		NULL, 					--[vehnSalvage],
		NULL, 					--[vehnTLRentalExpense],
		NULL, 					--[vehnTLOthExpense],
		NULL, 					--[vehnLoss],
		NULL, 					--[vehnNetLoss],
		NULL, 					--[vehnLicenseHistory],
		NULL, 					--[vehnPlateSearch],
		NULL, 					--[vehnTitlesearch],
		NULL, 					--[vehnMV104],
		NULL, 					--[vehdOprLicHistory],
		NULL, 					--[vehdPlateSearchOn],
		NULL, 					--[vehdTitleSearchOn],
		NULL, 					--[vehdMV104On],
		NULL, 					--[vehdOprLicHistoryRecd],
		NULL, 					--[vehdPlateSearchOnRecd],
		NULL, 					--[vehdTitleSearchOnRecd],
		NULL, 					--[vehdMV104OnRecd],
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),ud.[Pl Vehicle Yr/Make/Model]),'') + CHAR(13),'' ) + 
		isnull('Description of Damage: ' + nullif(convert(varchar(MAX),ud.[Pl Description of Damage]),'') + CHAR(13),'' ) + 
		isnull('Plt on Cell Phone: ' + nullif(convert(varchar(MAX),ud.[Plt on Cell Phone]),'') + CHAR(13),'' ) + 
		isnull('Pl Car Drivable: ' + nullif(convert(varchar(MAX),ud.[Pl Car Drivable]),'') + CHAR(13),'' ) + 
		isnull('Airbag Deployed: ' + nullif(convert(varchar(MAX),ud.[Airbag Deployed]),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select ymm.[data], vm.vmksDscrptn, vmo.vmdsModelDscrptn
FROM NeosBrianWhite..neosuserTab6 ud
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(50),ud.casesid)
LEFT JOIN sma_TRN_Plaintiff p on p.plnnCaseID = cas.casnCaseID and p.plnbIsPrimary = 1
LEFT JOIN sma_MST_VehicleMake vm ON [Pl Vehicle Yr/Make/Model] like case when vm.vmksdscrptn like '%chevr%' then '%Chev%' 
														when vm.vmksdscrptn like '%merce%' then '%Merc%' 
														when vm.vmksdscrptn like '%volksw%' then '%Volk%' 
														when vm.vmksdscrptn like '%Porsche%' then '%Por%' 
														when vm.vmksdscrptn like '%Infin%' then '%Infin%' 
														else '%'+vm.vmksDscrptn+'%' end
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and [Pl Vehicle Yr/Make/Model] like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull([Pl Vehicle Yr/Make/Model],'') <> ''
or isnull([Pl Description of Damage],'') <> ''
GO

---------------------------------------------------------
--DEFENDANT VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	,[vehnVehicleMake],[vehnYear],[vehnModelID],[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo])
SELECT DISTINCT
		cas.casnCaseID,			--[vehnCaseID],
		0,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		d.defnDefendentID,		--[vehnPlntDefID],
		NULL,					--[vehnOwnerID],
		NULL, 					--[vehnOwnerCtg],
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo],  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left([Def Vehicle Yr/Make/Model],4) )=1 then left([Def Vehicle Yr/Make/Model],4) 
			when  isnumeric(left([Def Vehicle Yr/Make/Model],2) )=1 and [Def Vehicle Yr/Make/Model] not like '18 wheel%' then left([Def Vehicle Yr/Make/Model],2) 
		else '' end,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		[Def License Plate],	--[vehsPlateNo],	10
		null, 					--[vehsColour],  30
		NULL,					--[vehnVehicleStateID],
		null,					--[vehsVINNo],   25
		NULL,					--[vehdRegExpDt],
		NULL, 					--[vehnIsLeased],
		NULL,					--[vehnDamageClaim],
		NULL, 					--[vehdEstReqdOn],
		NULL, 					--[vehdEstRecvdOn],
		NULL, 					--[vehdPhotoReqdOn],
		NULL, 					--[vehdPhotoRecvdOn],
		NULL, 					--[vehbRepairs],
		NULL, 					--[vehbTotalLoss],
		NULL, 					--[vehnCostOfRepairs],
		NULL, 					--[vehnValueBefAcdnt],
		NULL, 					--[vehnRentalExpense],
		NULL, 					--[vehnOthExpense],
		NULL, 					--[vehnSalvage],
		NULL, 					--[vehnTLRentalExpense],
		NULL, 					--[vehnTLOthExpense],
		NULL, 					--[vehnLoss],
		NULL, 					--[vehnNetLoss],
		NULL, 					--[vehnLicenseHistory],
		NULL, 					--[vehnPlateSearch],
		NULL, 					--[vehnTitlesearch],
		NULL, 					--[vehnMV104],
		NULL, 					--[vehdOprLicHistory],
		NULL, 					--[vehdPlateSearchOn],
		NULL, 					--[vehdTitleSearchOn],
		NULL, 					--[vehdMV104On],
		NULL, 					--[vehdOprLicHistoryRecd],
		NULL, 					--[vehdPlateSearchOnRecd],
		NULL, 					--[vehdTitleSearchOnRecd],
		NULL, 					--[vehdMV104OnRecd],
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),[Def Vehicle Yr/Make/Model]),'') + CHAR(13),'' ) + 
		isnull('Def Vehicle Drivable: ' + nullif(convert(varchar(MAX),[Def Vehicle Drivable]),'') + CHAR(13),'' ) + 
		isnull('Def on Cell Phone: ' + nullif(convert(varchar(MAX),[Def on Cell Phone]),'') + CHAR(13),'' ) + 
		isnull('Def Description of Damage: ' + nullif(convert(varchar(MAX),[Def Description of Damage]),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select max(len([Def License Plate]))
FROM NeosBrianWhite..neosuserTab6 ud
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(50),ud.casesid)
LEFT JOIN sma_TRN_Defendants d on d.defnCaseID = cas.casnCaseID and d.defbIsPrimary = 1
LEFT JOIN sma_MST_VehicleMake vm ON [Def Vehicle Yr/Make/Model] like case when vm.vmksdscrptn like '%chevr%' then '%Chev%' 
														when vm.vmksdscrptn like '%merce%' then '%Merc%' 
														when vm.vmksdscrptn like '%volksw%' then '%Volk%' 
														when vm.vmksdscrptn like '%Porsche%' then '%Por%' 
														when vm.vmksdscrptn like '%Infin%' then '%Infin%' 
														else '%'+vm.vmksDscrptn+'%' end
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and [Def Vehicle Yr/Make/Model] like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull([Def License Plate],'') <> ''
or isnull([Def Vehicle Yr/Make/Model],'') <> ''
GO


---------------------------------------------------------
--DEFENDANT 2 VEHICLE INFORMATION
---------------------------------------------------------
INSERT INTO [sma_TRN_Vehicles]
	([vehnCaseID],[vehbIsPlaintiff],[vehnPlntDefID],[vehnOwnerID],[vehnOwnerCtg],[vehnRegistrantID],[vehnRegistrantCtg],[vehnOperatorID],[vehnOperatorCtg],[vehsLicenceNo],[vehnLicenceStateID],[vehdLicExpDt]
	,[vehnVehicleMake],[vehnYear],[vehnModelID],[vehnBodyTypeID],[vehsPlateNo],[vehsColour],[vehnVehicleStateID],[vehsVINNo],[vehdRegExpDt],[vehnIsLeased],[vehnDamageClaim],[vehdEstReqdOn],[vehdEstRecvdOn],[vehdPhotoReqdOn]
	,[vehdPhotoRecvdOn],[vehbRepairs],[vehbTotalLoss],[vehnCostOfRepairs],[vehnValueBefAcdnt],[vehnRentalExpense],[vehnOthExpense],[vehnSalvage],[vehnTLRentalExpense],[vehnTLOthExpense],[vehnLoss],[vehnNetLoss],[vehnLicenseHistory]
	,[vehnPlateSearch],[vehnTitlesearch],[vehnMV104],[vehdOprLicHistory],[vehdPlateSearchOn],[vehdTitleSearchOn],[vehdMV104On],[vehdOprLicHistoryRecd],[vehdPlateSearchOnRecd],[vehdTitleSearchOnRecd],[vehdMV104OnRecd],[vehsComments]
	,[vehbPhotoAttached],[vehnRecUserID],[vehdDtCreated],[vehnModifyUserID],[vehdDtModified],[vehnLevelNo])
SELECT DISTINCT
		cas.casnCaseID,			--[vehnCaseID],
		0,		--case when isnull(cpd.defendant,'') ='' then 1 else 0 end,					--[vehbIsPlaintiff],
		def.Defendant2,		--[vehnPlntDefID],
		NULL,					--[vehnOwnerID],
		NULL, 					--[vehnOwnerCtg],
		NULL, 					--[vehnRegistrantID],
		NULL,					--[vehnRegistrantCtg],
		NULL, 					--[vehnOperatorID],
		NULL, 					--[vehnOperatorCtg],
		NULL,					--[vehsLicenceNo],  --varchar 25
		NULL,					--[vehnLicenceStateID],
		NULL,					--[vehdLicExpDt],
		vm.vmknMakeID,			--[vehnVehicleMake],
		case when isnumeric(left([Def 2 Veh Yr/Make/Model],4) )=1 then left([Def 2 Veh Yr/Make/Model],4) 
			when  isnumeric(left([Def 2 Veh Yr/Make/Model],2) )=1 and [Def 2 Veh Yr/Make/Model] not like '18 wheel%' then left([Def 2 Veh Yr/Make/Model],2) 
		else '' end,		--[vehnYear],  varchar 4
		vmo.vmdnModelID,		--[vehnModelID],
		NULL, 					--[vehnBodyTypeID],
		[Def 2 License Plate],	--[vehsPlateNo],
		null, 					--[vehsColour],  30
		NULL,					--[vehnVehicleStateID],
		null,					--[vehsVINNo],   25
		NULL,					--[vehdRegExpDt],
		NULL, 					--[vehnIsLeased],
		NULL,					--[vehnDamageClaim],
		NULL, 					--[vehdEstReqdOn],
		NULL, 					--[vehdEstRecvdOn],
		NULL, 					--[vehdPhotoReqdOn],
		NULL, 					--[vehdPhotoRecvdOn],
		NULL, 					--[vehbRepairs],
		NULL, 					--[vehbTotalLoss],
		NULL, 					--[vehnCostOfRepairs],
		NULL, 					--[vehnValueBefAcdnt],
		NULL, 					--[vehnRentalExpense],
		NULL, 					--[vehnOthExpense],
		NULL, 					--[vehnSalvage],
		NULL, 					--[vehnTLRentalExpense],
		NULL, 					--[vehnTLOthExpense],
		NULL, 					--[vehnLoss],
		NULL, 					--[vehnNetLoss],
		NULL, 					--[vehnLicenseHistory],
		NULL, 					--[vehnPlateSearch],
		NULL, 					--[vehnTitlesearch],
		NULL, 					--[vehnMV104],
		NULL, 					--[vehdOprLicHistory],
		NULL, 					--[vehdPlateSearchOn],
		NULL, 					--[vehdTitleSearchOn],
		NULL, 					--[vehdMV104On],
		NULL, 					--[vehdOprLicHistoryRecd],
		NULL, 					--[vehdPlateSearchOnRecd],
		NULL, 					--[vehdTitleSearchOnRecd],
		NULL, 					--[vehdMV104OnRecd],
		isnull('Year/Make/Model: ' + nullif(convert(varchar(MAX),[Def 2 Veh Yr/Make/Model]),'') + CHAR(13),'' ) + 
		isnull('Def 2 Vehicle Drivable: ' + nullif(convert(varchar(MAX),[Def 2 Vehicle Drivable]),'') + CHAR(13),'' ) + 
		'', 					--[vehsComments],  200
		NULL, 					--[vehbPhotoAttached],
		368, 					--[vehnRecUserID],
		getdate(), 				--[vehdDtCreated],
		NULL, 					--[vehnModifyUserID],
		NULL, 					--[vehdDtModified],
		1						--[vehnLevelNo]
--Select *
FROM NeosBrianWhite..neosuserTab6 ud
JOIN sma_trn_Cases cas on cas.Neos_saga = convert(varchar(50),ud.casesid)
LEFT JOIN (select d.defncaseid, min(d2.defnDefendentID) Defendant2
			FROM sma_TRN_Defendants d
			LEFT JOIN sma_TRN_Defendants d2 on d2.defnCaseID = d.defnCaseID and d2.defnDefendentID <> d.defnDefendentID and d.defbIsPrimary = 1
			GROUP BY d.defncaseid) def on def.defnCaseID = cas.casnCaseID 
LEFT JOIN sma_MST_VehicleMake vm ON [Def 2 Veh Yr/Make/Model] like case when vm.vmksdscrptn like '%chevr%' then '%Chev%' 
														when vm.vmksdscrptn like '%merce%' then '%Merc%' 
														when vm.vmksdscrptn like '%volksw%' then '%Volk%' 
														when vm.vmksdscrptn like '%Porsche%' then '%Por%' 
														when vm.vmksdscrptn like '%Infin%' then '%Infin%' 
														else '%'+vm.vmksDscrptn+'%' end
LEFT JOIN sma_MST_VehicleModels vmo ON vmo.vmdnMakeID = vm.vmknMakeID and [Def 2 Veh Yr/Make/Model] like '%'+vmo.vmdsModelDscrptn+'%'
WHERE isnull([Def 2 License Plate],'') <> ''
or isnull([Def 2 Veh Yr/Make/Model],'') <> ''
GO


