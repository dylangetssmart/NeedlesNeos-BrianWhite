
IF EXISTS (SELECT * FROM sys.objects WHERE name='insurance_Indexed' and type='U')
BEGIN
	DROP TABLE [insurance_Indexed]
END
GO

CREATE TABLE [insurance_Indexed](
		TableIndex [int] IDENTITY(1,1) NOT NULL,
		id	uniqueidentifier,
		entry_id	int,
		[policy]	varchar(100),
		claim	varchar(100),
		insured	varchar(50),
		limits	varchar(50),
		agent	varchar(30),
		accept	bit,
		comments	varchar(500),
		minimum_amount	decimal(9),
		maximum_amount	decimal(9),
		actual	decimal(9),
		date_settled	date,
		insurer_namesid	uniqueidentifier,
		insurancetypeid	uniqueidentifier,
		adjuster_namesid	uniqueidentifier,
		partyid	uniqueidentifier,
		casesid	uniqueidentifier,
		resolutionid	uniqueidentifier,
		case_status	bit,
		date_created	datetime2,
		date_modified	datetime2,
		staffcreatedid	uniqueidentifier,
		staffmodifiedid	uniqueidentifier,
		CONSTRAINT IOC_Clustered_Index_insurance PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY] 
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurance_Indexed ON [insurance_Indexed] (id);   

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_insurance_Indexed_case_num ON [insurance_Indexed] (casesid);   
GO


INSERT INTO [insurance_Indexed] (
		id,
		entry_id,
		[policy],
		claim,
		insured,
		limits,
		agent,
		accept,
		comments,
		minimum_amount,
		maximum_amount,
		actual,
		date_settled,
		insurer_namesid,
		insurancetypeid,
		adjuster_namesid,
		partyid,
		casesid,
		resolutionid,
		case_status,
		date_created,
		date_modified,
		staffcreatedid,
		staffmodifiedid
)
SELECT 
		id,
		entry_id,
		[policy],
		claim,
		insured,
		limits,
		agent,
		accept,
		comments,
		minimum_amount,
		maximum_amount,
		actual,
		date_settled,
		insurer_namesid,
		insurancetypeid,
		adjuster_namesid,
		partyid,
		casesid,
		resolutionid,
		case_status,
		date_created,
		date_modified,
		staffcreatedid,
		staffmodifiedid
FROM [Insurance]
GO

DBCC DBREINDEX('Insurance_Indexed',' ',90) 
GO
