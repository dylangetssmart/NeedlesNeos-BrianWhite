USE SANeosBrianWhite
GO


IF NOT EXISTS (
		SELECT
			*
		FROM [sma_MST_OrgContacts]
		WHERE consName = 'Unidentified Court'
			AND saga = -1
	)
BEGIN

	INSERT INTO [sma_MST_OrgContacts]
		(
		[consName]
	   ,[connContactCtg]
	   ,[connContactTypeID]
	   ,[connRecUserID]
	   ,[condDtCreated]
	   ,[saga]
		)
		SELECT
			'Unidentified Court' AS [consName]
		   ,2					 AS [connContactCtg]
		   ,(
				SELECT
					octnOrigContactTypeID
				FROM [sma_MST_OriginalContactTypes]
				WHERE octnContactCtgID = 2
					AND octsDscrptn = 'Court'
			)					 
			AS [connContactTypeID]
		   ,368					 AS [connRecUserID]
		   ,GETDATE()			 AS [condDtCreated]
		   ,-1					 AS [saga]
END

