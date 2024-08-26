
USE BrianWhiteSA
GO
/*
alter table [sma_TRN_PlaintiffDeath] disable trigger all
delete from [sma_TRN_PlaintiffDeath] 
DBCC CHECKIDENT ('[sma_TRN_PlaintiffDeath]', RESEED, 0);
alter table [sma_TRN_PlaintiffDeath] enable trigger all
*/


INSERT INTO [sma_TRN_PlaintiffDeath]
	(
	[pldnCaseID]
   ,[pldnPlaintiffID]
   ,[pldnContactID]
   ,[plddDeathDt]
   ,[pldbAutopsyYN]
	)
	SELECT
		P.plnnCaseID	  AS [pldnCaseID]
	   ,P.plnnPlaintiffID AS [pldnPlaintiffID]
	   ,P.plnnContactID	  AS [pldnContactID]
	   ,I.cindDateOfDeath AS [plddDeathDt]
	   ,0				  AS [pldbAutopsyYN]
	FROM [sma_TRN_Plaintiff] P
	JOIN [sma_MST_IndVContacts] I
		ON I.cinnContactID = P.plnnContactID
	WHERE cindDateOfDeath IS NOT NULL
