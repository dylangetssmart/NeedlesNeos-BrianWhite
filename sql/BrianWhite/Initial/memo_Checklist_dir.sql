use BrianWhiteNeos

IF EXISTS (SELECT * FROM sys.objects WHERE name='checklist_dir_indexed' and type='U')
BEGIN
	DROP TABLE [checklist_dir_indexed]
END
GO



CREATE TABLE [checklist_dir_indexed](
		[UID] [int] IDENTITY(1,1) NOT NULL,
		id	uniqueidentifier,
		code	varchar(10),
		[description]	varchar(200),
		phase	int,
		ref	varchar(20),
		repeat_period	int,
		auto_repeat	bit,
		repeat_days	int,
		lim	bit,
		matterid	uniqueidentifier,
		litigationtitleid	uniqueidentifier,
		staffroleid	uniqueidentifier,
		datelabelid	uniqueidentifier,
		wpdocumentsid	uniqueidentifier,
		pdfdocumentsid	uniqueidentifier,
		parent	bit,
		referencechecklistid	uniqueidentifier,
		case_status	bit,
		text_color	char(9),
		background_color	char(9),
		active	bit,
		auxiliary	bit,
		notes	varchar(max),
		action_type	int,
		date_created	datetime2,
		staffcreatedid	uniqueidentifier,
		date_modified	datetime2,
		staffmodifiedid	uniqueidentifier,
		long_description	varchar(1000),
		CONSTRAINT IOC_Clustered_Index_checklist_dir PRIMARY KEY CLUSTERED ( UID )
)ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_checklist_dir_indexed ON [checklist_dir_indexed] ([UID]);   

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_checklist_dir_indexed_Matcode ON [checklist_dir_indexed] (matterid);   
GO

INSERT INTO [checklist_dir_indexed] (
		id,
		code,
		[description],
		phase,
		ref,
		repeat_period,
		auto_repeat,
		repeat_days,
		lim,
		matterid,
		litigationtitleid,
		staffroleid,
		datelabelid,
		wpdocumentsid,
		pdfdocumentsid,
		parent,
		referencechecklistid,
		case_status,
		text_color,
		background_color,
		active,
		auxiliary,
		notes,
		action_type,
		date_created,
		staffcreatedid,
		date_modified,
		staffmodifiedid,
		long_description
)
SELECT 
		id,
		code,
		[description],
		phase,
		ref,
		repeat_period,
		auto_repeat,
		repeat_days,
		lim,
		matterid,
		litigationtitleid,
		staffroleid,
		datelabelid,
		wpdocumentsid,
		pdfdocumentsid,
		parent,
		referencechecklistid,
		case_status,
		text_color,
		background_color,
		active,
		auxiliary,
		notes,
		action_type,
		date_created,
		staffcreatedid,
		date_modified,
		staffmodifiedid,
		long_description
FROM [checklist_dir]
GO


DBCC DBREINDEX('checklist_dir_indexed',' ',90)
GO