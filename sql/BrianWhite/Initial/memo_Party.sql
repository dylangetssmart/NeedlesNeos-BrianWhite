

IF EXISTS (SELECT * FROM sys.objects WHERE name='party_Indexed' and type='U')
BEGIN
	DROP TABLE [Party_Indexed]
END
GO


CREATE TABLE [Party_Indexed] (
	TableIndex int IDENTITY(1,1) NOT NULL,
	id	uniqueidentifier,
	record_num	int	,
	namesid	uniqueidentifier,
	casesid	uniqueidentifier,
	partyrolelistid	uniqueidentifier,
	our_client	bit,
	minor	bit,
	incapacitated	bit,
	incapacity	varchar(30),
	responsibility	bit,
	relationship	varchar(100),
	date_of_majority	date,
	date_created	datetime2,
	staffcreatedid	uniqueidentifier,
	date_modified	datetime2,
	staffmodifiedid	uniqueidentifier,
	CONSTRAINT IOC_Clustered_Index PRIMARY KEY CLUSTERED (TableIndex)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_Party_ID ON [party_Indexed] (id);
GO

INSERT INTO [Party_Indexed]
(	id,
	record_num,
	namesid,
	casesid,
	partyrolelistid,
	our_client,
	minor,
	incapacitated,
	incapacity,
	responsibility,
	relationship,
	date_of_majority,
	date_created,
	staffcreatedid,
	date_modified,
	staffmodifiedid
)
SELECT 
	id,
	record_num,
	namesid,
	casesid,
	partyrolelistid,
	our_client,
	minor,
	incapacitated,
	incapacity,
	responsibility,
	relationship,
	date_of_majority,
	date_created,
	staffcreatedid,
	date_modified,
	staffmodifiedid
FROM Party
GO

DBCC DBREINDEX('Party_Indexed',' ', 90)
GO