
USE BrianWhiteSA
GO

TRUNCATE TABLE sma_TRN_RoleCaseStuffMainRoles
GO

IF (
		SELECT
			COUNT(*)
		FROM sma_TRN_RoleCaseStuffMainRoles
	)
	= 0
BEGIN
	INSERT INTO sma_TRN_RoleCaseStuffMainRoles
		(
		[CaseID]
	   ,[AttyContactID]
	   ,[ParalegalContactID]
	   ,[CaseManagerContactID]
		)
		SELECT
			cssnCaseID AS CaseID
		   ,[1]
		   ,[2]
		   ,[3]
		FROM (
			SELECT
				SS.cssnCaseID
			   ,SS.cssnStaffID
			   ,RG.RoleGroupID
			FROM sma_TRN_CaseStaff SS
			JOIN sma_MST_RolePriorityGroup RG
				ON RoleID = cssnRoleID
				AND SS.cssdToDate IS NULL
			OUTER APPLY (
				SELECT TOP 1
					cssnCaseID AS CaseID
				   ,RoleGroupID
				   ,PriorityFlag
				   ,cssnStaffID
				   ,cssnPKID
				FROM sma_TRN_CaseStaff sss
				JOIN sma_MST_RolePriorityGroup RF
					ON RoleID = cssnRoleID
				WHERE sss.cssdToDate IS NULL
					AND sss.cssnCaseID IS NOT NULL
					AND sss.cssnCaseID = SS.cssnCaseID
					AND RG.RoleGroupID = RF.RoleGroupID
				ORDER BY CAseID, PriorityFlag, sss.cssdFromDate
			) dddd
			WHERE dddd.CaseID = SS.cssnCaseID
				AND dddd.cssnPKID = ss.cssnPKID
				AND dddd.RoleGroupID IS NOT NULL
		) AS SourceTable
		PIVOT
		(
		AVG(cssnStaffID)
		FOR RoleGroupID IN ([1], [2], [3])
		) AS PivotTable
END
