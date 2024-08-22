USE NeosBrianWhite
GO

--------------------------------
--USER CASE PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserCase')
begin
	drop table NeosUserCase
end

select casesid, [Aff 118001 Due Date],[Affs Deadline Due Date],[Arbitrator],[Counter Aff Due Date],[County of Suit],[Court Reporter],[Def Answer Due Date],[Defendant Caption],[Defendant],[Judicial District],
[JURY],[Mediator],[NON JURY],[Offensive Disc Due Date],[Plaintiff Caption],[Plaintiff],[Process Service],[Resp to RFD's Due Date],[State of Suit],[Type of Case],[Type of Court]
INTO NeosUserCase
FROM (SELECT casesid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_case_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ( [Aff 118001 Due Date],[Affs Deadline Due Date],[Arbitrator],[Counter Aff Due Date],[County of Suit],[Court Reporter],[Def Answer Due Date],[Defendant Caption],[Defendant],[Judicial District],
								[JURY],[Mediator],[NON JURY],[Offensive Disc Due Date],[Plaintiff Caption],[Plaintiff],[Process Service],[Resp to RFD's Due Date],[State of Suit],[Type of Case],[Type of Court])  
	)
piv;
--select * From NeosUserCase

--------------------------------
--USER INSURANCE INFO PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserInsurance')
begin
	drop table NeosUserInsurance
end

select insuranceid, [Insurance Information],[MedPay Coverage],[Other Household Vehicles],[PIP Coverage],[PIP Exhausted],[PIP Waiver],[UM/UIM Adjuster],[UM/UIM Coverage]
INTO NeosUserInsurance
FROM (SELECT insuranceid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
from NeosBrianWhite..user_insurance_data id
JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ([Insurance Information],[MedPay Coverage],[Other Household Vehicles],[PIP Coverage],[PIP Exhausted],[PIP Waiver],[UM/UIM Adjuster],[UM/UIM Coverage])  
	)
piv;


--------------------------------
--USER COUNSEL PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserCounsel')
begin
	drop table NeosUserCounsel
end

select counselid, [Depo Date(s)],[Due Date]
INTO NeosUserCounsel
FROM (SELECT counselid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_counsel_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ( [Depo Date(s)],[Due Date] )  
	)
piv;


--------------------------------
--USER PARTY PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserParty')
begin
	drop table NeosUserParty
end

select partyid, [Accidents/Injuries],[Agent for Service],[Answers],[ANY SUBSEQUENT SURGERIES],[Are You a US Citizen?],[Arrested?],[Attorney],[Breed of Animal],[Burning Eyes],
[Burning Skin],[Business Type],[Case Title],[Cause of Death],[Charge-When-Where(County)],[Charges],[Chest Pain],[Chest Tightness],[Child Support],[Convicted of a Crime],
[Coughing],[Criminal History],[DA Log #],[Date of Surgery],[Date Seen?],[Death Certificate],[Diagnosis],[Dizziness],[DL/ID Number],[Drowsiness],[Education],[Headaches],
[HEALTH INSURANCE],[Hospital],[How Much Time?],[If Yes, Whom],[Initial Surgery Date],[Initial Surgery Type],[Injured Party deceased?],[Injuries on Demand],[Injuries],
[Legal Status?],[Lenght of Time at Working],[Loss of Consciousness],[Marital Status],[MEDICAID],[MEDICARE],[Minor Children],[Missed Time from Work],[MRI(s) Findings],
[Name of Employer],[Name of Hospital],[Name of Insurance Company],[Name of Parent(s)],[Name of Spouse],[Nausea],[Nosebleed(s)],[Occupation],[Other Employment],[Pathology/Lab],
[Pending Bankruptcy?],[Pharmacy],[Place of Birth],[Place of Death],[Place of Treatment],[Position],[Prescriptions/RX],[Previous Complaints],[Prior Accidents/Injuries],[Prior Lawsuits],
[Priors/Subsequents],[Radiology],[Rapid/Irregular Heartbeat],[Rash],[Registered Agent],[Relationship to Driver],[Request From],[Role in Accident],[Role],[Scanned?],[Scope of Employment],
[Shortness of Breath],[Signed up By],[SPN],[Spouse, Parent or Child],[State],[Surgeon Name:],[Surgeon],[Testing],[Tin #],[Transported by EMS],[Type of Animal],[Type of Surgery],
[US DOT #],[Value Code],[Vomiting],[Wheezing],[Workers' Comp Claim?]
INTO NeosUserParty
FROM (SELECT partyid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_party_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ( [Accidents/Injuries],[Agent for Service],[Answers],[ANY SUBSEQUENT SURGERIES],[Are You a US Citizen?],[Arrested?],[Attorney],[Breed of Animal],[Burning Eyes],
				[Burning Skin],[Business Type],[Case Title],[Cause of Death],[Charge-When-Where(County)],[Charges],[Chest Pain],[Chest Tightness],[Child Support],[Convicted of a Crime],
				[Coughing],[Criminal History],[DA Log #],[Date of Surgery],[Date Seen?],[Death Certificate],[Diagnosis],[Dizziness],[DL/ID Number],[Drowsiness],[Education],[Headaches],
				[HEALTH INSURANCE],[Hospital],[How Much Time?],[If Yes, Whom],[Initial Surgery Date],[Initial Surgery Type],[Injured Party deceased?],[Injuries on Demand],[Injuries],
				[Legal Status?],[Lenght of Time at Working],[Loss of Consciousness],[Marital Status],[MEDICAID],[MEDICARE],[Minor Children],[Missed Time from Work],[MRI(s) Findings],
				[Name of Employer],[Name of Hospital],[Name of Insurance Company],[Name of Parent(s)],[Name of Spouse],[Nausea],[Nosebleed(s)],[Occupation],[Other Employment],[Pathology/Lab],
				[Pending Bankruptcy?],[Pharmacy],[Place of Birth],[Place of Death],[Place of Treatment],[Position],[Prescriptions/RX],[Previous Complaints],[Prior Accidents/Injuries],[Prior Lawsuits],
				[Priors/Subsequents],[Radiology],[Rapid/Irregular Heartbeat],[Rash],[Registered Agent],[Relationship to Driver],[Request From],[Role in Accident],[Role],[Scanned?],[Scope of Employment],
				[Shortness of Breath],[Signed up By],[SPN],[Spouse, Parent or Child],[State],[Surgeon Name:],[Surgeon],[Testing],[Tin #],[Transported by EMS],[Type of Animal],[Type of Surgery],
				[US DOT #],[Value Code],[Vomiting],[Wheezing],[Workers' Comp Claim?] )  
	)
piv;


--------------------------------
--USER TAB1 PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserTab1')
begin
	drop table NeosUserTab1
end

select casesid,tablistid, [Court Reporter Cost],[Court Reporter],[CV on File?],[Depo Date],[Depo Prep Date],[Depo Prep Time],[Depo Time],[Interpreter],[Location of Deposition],
[Notes],[Type of Expert],[Type of Witness],[Video?],[Videographer],[Witness Name]
INTO NeosUserTab1
FROM (SELECT casesid, tablistid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_tab1_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid 
	JOIN NeosBrianWhite..user_tab1_list tl on tl.id = id.tablistid) i
pivot (
	max(fieldVal) for field_title in ( [Court Reporter Cost],[Court Reporter],[CV on File?],[Depo Date],[Depo Prep Date],[Depo Prep Time],[Depo Time],[Interpreter],[Location of Deposition],
										[Notes],[Type of Expert],[Type of Witness],[Video?],[Videographer],[Witness Name] )  
	)
piv;

--------------------------------
--USER TAB2 PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserTab2')
begin
	drop table NeosUserTab2
end

select casesid, tablistid, [Alternate Provider],[Comments],[Date Received],[Date Requested],[Findings],[Medical Bill],[Memo],[Method],[Ordered By],[Pre-Payment Required],
[Provider Name],[Type of Record],[Value Code]
INTO NeosUserTab2
FROM (SELECT casesid, tablistid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_tab2_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid
	JOIN NeosBrianWhite..user_tab2_list tl on tl.id = id.tablistid ) i
pivot (
	max(fieldVal) for field_title in ( [Alternate Provider],[Comments],[Date Received],[Date Requested],[Findings],[Medical Bill],[Memo],[Method],[Ordered By],[Pre-Payment Required],
										[Provider Name],[Type of Record],[Value Code] )  
	)
piv;



--------------------------------
--USER TAB5 PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserTab5')
begin
	drop table NeosUserTab5
end

select casesid, tablistid, [All Counsel Copied],[Answered Date],[Document Name],[Due Date],[Filed Date],[Filing Party],[Litigation Document],
[Medical Provider],[Note],[Party Receiving],[Received Date],[Service Date]
INTO NeosUserTab5
FROM (SELECT casesid, tablistid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_tab5_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid
	JOIN NeosBrianWhite..user_tab5_list tl on tl.id = id.tablistid) i
pivot (
	max(fieldVal) for field_title in ( [All Counsel Copied],[Answered Date],[Document Name],[Due Date],[Filed Date],[Filing Party],[Litigation Document],
[Medical Provider],[Note],[Party Receiving],[Received Date],[Service Date] )  
	)
piv;


--------------------------------
--USER TAB6 PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserTab6')
begin
	drop table NeosUserTab6
end

select casesid, [Accident Report?],[Address of Incident],[Airbag Deployed],[Animal Control Contacted?],[Animal Restrained?],[Assault?],[Badge],[Citation Info],[City],
[County],[Day of Week],[Def 2 License Plate],[Def 2 Veh Yr/Make/Model],[Def 2 Vehicle Drivable],[Def Description of Damage],[Def License Plate],[Def on Cell Phone],
[Def Vehicle Drivable],[Def Vehicle Yr/Make/Model],[Description of Animal],[Description of Damage],[Disposition of Animal],[Incident Report],[Injuries],[Lenght of Assault],
[Lighting Conditions],[Location of Accident],[Location of Assault],[Location of Incident],[Maintenance Schedule],[Name of Institution],[Notes],[Number of Vehicles],
[Officer],[Ordered & Rec'd],[Photographs],[Photos of Bed Bugs],[Photos of Injuries],[Photos Taken At Accident],[Pl # of People in Car],[Pl Car Drivable],[Pl Description of Damage],
[Pl Vehicle Yr/Make/Model],[Plt on Cell Phone],[Police Dept],[Police Report Scanned?],[Police Report?],[Prior Complaint on Animal],[Reason on Property],[Relationship to Assaulter],
[Report Number],[Scanned?],[Seatbelt],[State],[Statement Context],[Statement Taken?],[Surface Conditions],[Suspected Malpractice],[Tested for Rabies?],[Time of Accident],
[Time of Assault],[To Whom was it Reported],[Type of Assault],[Type of Institution],[Type of Shoes Worn],[Warnings]
INTO NeosUserTab6
FROM (SELECT casesid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_tab6_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ( [Accident Report?],[Address of Incident],[Airbag Deployed],[Animal Control Contacted?],[Animal Restrained?],[Assault?],[Badge],[Citation Info],[City],
							[County],[Day of Week],[Def 2 License Plate],[Def 2 Veh Yr/Make/Model],[Def 2 Vehicle Drivable],[Def Description of Damage],[Def License Plate],[Def on Cell Phone],
							[Def Vehicle Drivable],[Def Vehicle Yr/Make/Model],[Description of Animal],[Description of Damage],[Disposition of Animal],[Incident Report],[Injuries],[Lenght of Assault],
							[Lighting Conditions],[Location of Accident],[Location of Assault],[Location of Incident],[Maintenance Schedule],[Name of Institution],[Notes],[Number of Vehicles],
							[Officer],[Ordered & Rec'd],[Photographs],[Photos of Bed Bugs],[Photos of Injuries],[Photos Taken At Accident],[Pl # of People in Car],[Pl Car Drivable],[Pl Description of Damage],
							[Pl Vehicle Yr/Make/Model],[Plt on Cell Phone],[Police Dept],[Police Report Scanned?],[Police Report?],[Prior Complaint on Animal],[Reason on Property],[Relationship to Assaulter],
							[Report Number],[Scanned?],[Seatbelt],[State],[Statement Context],[Statement Taken?],[Surface Conditions],[Suspected Malpractice],[Tested for Rabies?],[Time of Accident],
							[Time of Assault],[To Whom was it Reported],[Type of Assault],[Type of Institution],[Type of Shoes Worn],[Warnings] )  
	)
piv;

--------------------------------
--USER TAB7 PIVOT
--------------------------------
if exists (select * from sys.tables where name = 'NeosUserTab7')
begin
	drop table NeosUserTab7
end

select casesid, [Agreement Sent],[Date Dropped],[Date Rejected],[Dropped By],[Fee Terms],[Reason Dropped],[Reason for Rejection],[Received Signed Agreement],
[Referral Source Code],[Referring Attorney],[Rejected By],[SOL Issue],[Star Case]
INTO NeosUserTab7
FROM (SELECT casesid, isnull(isnull( convert(varchar(max),id.namesid), convert(varchar(max),picklistID)), convert(varchar(max),id.[data]) ) as FieldVal, field_title
	--select distinct '['+f.field_title+'],'
	--select id.*
	from NeosBrianWhite..user_tab7_data id
	JOIN NeosBrianWhite..user_case_fields f on f.id = id.usercasefieldid ) i
pivot (
	max(fieldVal) for field_title in ( [Agreement Sent],[Date Dropped],[Date Rejected],[Dropped By],[Fee Terms],[Reason Dropped],[Reason for Rejection],[Received Signed Agreement],
										[Referral Source Code],[Referring Attorney],[Rejected By],[SOL Issue],[Star Case] )  
	)
piv;