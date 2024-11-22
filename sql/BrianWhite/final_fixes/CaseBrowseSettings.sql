USE brianwhitesa

ALTER TABLE sma_TRN_CaseBrowseSettings DISABLE TRIGGER ALL
GO

DECLARE @UserID INT

DECLARE staff_cursor CURSOR FAST_FORWARD FOR SELECT
	usrnUserID
FROM sma_mst_users

OPEN staff_cursor

FETCH NEXT FROM staff_cursor INTO @UserID

SET NOCOUNT ON;
WHILE @@FETCH_STATUS = 0
BEGIN

INSERT INTO sma_TRN_CaseBrowseSettings
	(
	cbsnColumnID, cbsnUserID, cbssCaption, cbsbVisible, cbsnWidth, cbsnOrder, cbsnRecUserID, cbsdDtCreated, cbsn_StyleName
	)
	SELECT DISTINCT
		cbcnColumnID
	   ,@UserID
	   ,cbcsColumnName
	   ,'True'
	   ,200
	   ,cbcnDefaultOrder
	   ,@UserID
	   ,GETDATE()
	   ,'Office2007Blue'
	FROM [sma_MST_CaseBrowseColumns]
	WHERE cbcnColumnID NOT IN (1, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 33)

FETCH NEXT FROM staff_cursor INTO @UserID
END

CLOSE staff_cursor
DEALLOCATE staff_cursor

ALTER TABLE sma_TRN_CaseBrowseSettings ENABLE TRIGGER ALL
GO