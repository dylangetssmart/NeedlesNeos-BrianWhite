use BrianWhiteNeos


IF EXISTS (SELECT * FROM sys.objects WHERE name='value_Indexed' and type='U')
BEGIN
	DROP TABLE [value_Indexed]
END
GO


CREATE TABLE [value_Indexed](
    TableIndex [int] IDENTITY(1,1) NOT NULL,
	id	uniqueidentifier,
	entry_id	int,
	[start_date]	date,
	stop_date	date,
	total_value	decimal(9),
	reduction	decimal(9),
	due	decimal(9), 
	lien	bit,
	valuecodeid	uniqueidentifier,
	partyid	uniqueidentifier,
	casesid	uniqueidentifier,
	namesid	uniqueidentifier,
	memo	varchar(5000),
	settlement_memo	varchar(60),
	report_pending	bit,
	date_requested	date,
	submitted_for_payment	bit,
	submitted_date	date,
	valuereportcategoryid	uniqueidentifier,
	value_reference	varchar(50),
	value_reference2	varchar(50),
	num_periods	decimal(9),
	rate	decimal(9),
	amount_requested	decimal(9),
	[period]	int,
	date_created	datetime2,
	staffcreatedid	uniqueidentifier,
	date_modified	datetime2,
	staffmodifiedid	uniqueidentifier,
	case_status	bit,
	utbms_expense	varchar(50),
	billto	uniqueidentifier,
	no_charge	bit,
	timetrackingid uniqueidentifier,
	approval_status	varchar(24),
	CONSTRAINT IOC_Clustered_Index_value_Indexed PRIMARY KEY CLUSTERED ( TableIndex )
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_NonClustered_Index_value_Indexed ON [value_Indexed] (id);  
GO

INSERT INTO [Value_Indexed](
	id,
	entry_id,
	[start_date],
	stop_date,
	total_value,
	reduction,
	due,
	lien,
	valuecodeid,
	partyid,
	casesid,
	namesid,
	memo,
	settlement_memo,
	report_pending,
	date_requested,
	submitted_for_payment,
	submitted_date,
	valuereportcategoryid,
	value_reference,
	value_reference2,
	num_periods,
	rate,
	amount_requested,
	[period],
	date_created,
	staffcreatedid,
	date_modified,
	staffmodifiedid,
	case_status,
	utbms_expense,
	billto,
	no_charge,
	timetrackingid,
	approval_status)
SELECT 
	id,
	entry_id,
	[start_date],
	stop_date,
	total_value,
	reduction,
	due,
	lien,
	valuecodeid,
	partyid,
	casesid,
	namesid,
	memo,
	settlement_memo,
	report_pending,
	date_requested,
	submitted_for_payment,
	submitted_date,
	valuereportcategoryid,
	value_reference,
	value_reference2,
	num_periods,
	rate,
	amount_requested,
	[period],
	date_created,
	staffcreatedid,
	date_modified,
	staffmodifiedid,
	case_status,
	utbms_expense,
	billto,
	no_charge,
	timetrackingid,
	approval_status
FROM [Value]