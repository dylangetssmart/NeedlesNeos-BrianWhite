USE SANeosBrianWhite
GO


IF EXISTS (
		SELECT
			*
		FROM sys.objects
		WHERE name = 'IndvOrgContacts_Indexed'
			AND type = 'U'
	)
BEGIN
	DROP TABLE IndvOrgContacts_Indexed
END
GO

CREATE TABLE IndvOrgContacts_Indexed (
	TableIndex INT IDENTITY (1, 1) NOT NULL
   ,CID INT
   ,CTG INT
   ,AID INT
   ,UNQCID BIGINT
   ,Name VARCHAR(100)
   ,SAGA VARCHAR(100)
   ,saga_ref VARCHAR(100)
	CONSTRAINT IOC_Clustered_Index PRIMARY KEY CLUSTERED (TableIndex)
)
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_CID ON IndvOrgContacts_Indexed (CID);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_CTG ON IndvOrgContacts_Indexed (CTG);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_AID ON IndvOrgContacts_Indexed (AID);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_UNID ON IndvOrgContacts_Indexed (UNQCID);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_SAGA ON IndvOrgContacts_Indexed (SAGA);
GO
CREATE NONCLUSTERED INDEX IX_NonClustered_Index_IndvOrgContacts_Indexed_SAGA_ref ON IndvOrgContacts_Indexed (SAGA_Ref);
GO

INSERT INTO IndvOrgContacts_Indexed
	(
	CID
   ,CTG
   ,AID
   ,UNQCID
   ,Name
   ,SAGA
   ,saga_ref
	)
	SELECT
		IOC.CID				AS CID
	   ,IOC.CTG				AS CTG
	   ,A.addnAddressID		AS AID
	   ,ACF.UniqueContactId AS UNQCID
	   ,IOC.Name			AS Name
	   ,IOC.SAGA			AS SAGA
	   ,ioc.saga_ref
	FROM (
		SELECT
			cinnContactID AS CID
		   ,cinnContactCtg AS CTG
		   ,cinsFirstName + ' ' + cinsLastName AS Name
		   ,saga AS SAGA
		   ,saga_ref AS SAGA_REF
		FROM [sma_MST_IndvContacts]
		UNION
		SELECT
			connContactID AS CID
		   ,connContactCtg AS CTG
		   ,consName AS Name
		   ,saga AS SAGA
		   ,saga_ref AS SAGA_REF
		FROM [sma_MST_OrgContacts]
	) IOC
	JOIN [sma_MST_Address] A
		ON A.addnContactID = IOC.CID
			AND A.addnContactCtgID = IOC.CTG
			AND A.addbPrimary = 1
	JOIN [sma_MST_AllContactInfo] ACF
		ON ACF.ContactId = IOC.CID
			AND ACF.ContactCtg = IOC.CTG
GO

DBCC DBREINDEX ('IndvOrgContacts_Indexed', ' ', 90) WITH NO_INFOMSGS
GO


