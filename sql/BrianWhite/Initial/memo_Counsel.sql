
IF EXISTS (SELECT * FROM sys.objects where name='counsel_Indexed' and type='U')
BEGIN
	DROP TABLE [counsel_Indexed]
END
GO

CREATE TABLE [counsel_Indexed](
		TableIndex [int] IDENTITY(1,1) NOT NULL,
		id	uniqueidentifier,
		entry_id	int,
		counselnamesid	uniqueidentifier,
		casesid	uniqueidentifier,
		representingnamesid	uniqueidentifier,
		comments	varchar(500),
		cert_of_srv_order	int,
		case_status	bit,
		date_created	datetime2,
		date_modified	datetime2,
		staffcreatedid	uniqueidentifier,
		staffmodifiedid	uniqueidentifier,
		CONSTRAINT IOC_Clustered_Index_counsel PRIMARY KEY CLUSTERED ( TableIndex )
)ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_counsel_Indexed ON [counsel_Indexed] (id);   
GO  

INSERT INTO [counsel_Indexed] (
		id,
		entry_id,
		counselnamesid,
		casesid,
		representingnamesid,
		comments,
		cert_of_srv_order,
		case_status,
		date_created,
		date_modified,
		staffcreatedid,
		staffmodifiedid
)
SELECT 
		id,
		entry_id,
		counselnamesid,
		casesid,
		representingnamesid,
		comments,
		cert_of_srv_order,
		case_status,
		date_created,
		date_modified,
		staffcreatedid,
		staffmodifiedid
FROM [Counsel]
GO

DBCC DBREINDEX('counsel_Indexed',' ',90) 
GO

