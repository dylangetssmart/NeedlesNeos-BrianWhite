select * FROM [BrianWhiteNeos]..cases c WHERE c.casenum = 209953
--E64F1A1E-D877-4FE4-B82C-B07C0125BB83

select * FROM [BrianWhiteNeos]..user_tab6_data td
JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE td.casesid = '3D9804C9-E8B1-42F3-BCF1-B144015841B0' AND ucf.field_title = 'State';
		--order by ucf.field_title


	--select distinct st.data--, st.data
	SELECT
		s.data
		,st.data
		,CASE
			WHEN s.[data] IS NOT NULL
				THEN (
						SELECT
							[sttnStateID]
						FROM [sma_MST_States]
						WHERE [sttsDescription] = s.[data]
					)
			-- Match st.data to sttsDescription
			WHEN st.data IS NOT NULL AND
				EXISTS (
					SELECT
						1
					FROM sma_MST_States
					WHERE sttsDescription = st.data
				)
				THEN (
						SELECT
							sttnStateID
						FROM sma_MST_States
						WHERE sttsDescription = st.data
					)
			-- Match st.data to sttsCode
			WHEN st.data IS NOT NULL AND
				EXISTS (
					SELECT
						1
					FROM sma_MST_States
					WHERE sttsCode = st.data
				)
				THEN (
						SELECT
							sttnStateID
						FROM sma_MST_States
						WHERE sttsCode = st.data
					)
			ELSE (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE sttsCode = 'TX'
				)
		END AS [StateID]
	FROM [BrianWhiteNeos].[dbo].[cases] C
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_case_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title = 'State of Suit'
	) s
		ON s.casesid = c.id
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_tab6_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title IN ('Time of Accident', 'Time of Assault')
	) a
		ON a.casesid = c.id
	LEFT JOIN (
		SELECT
			td.casesid
		   ,td.[data]
		FROM [BrianWhiteNeos]..user_tab6_data td
		JOIN [BrianWhiteNeos]..user_case_fields ucf
			ON ucf.id = td.usercasefieldid
		WHERE field_title IN ('State')
	) st
		ON st.casesid = c.id
	JOIN [sma_TRN_cases] CAS
		ON CAS.neos_saga = CONVERT(VARCHAR(50), C.id)
	--where [StateID] <> 46
	WHERE cas.cassCaseNumber = 209953 


	select * FROM [sma_MST_States]

----------------------------------------------------------------------------------

select * FROM [sma_TRN_Incidents] WHERE CaseId = 9413
select * FROM [sma_TRN_Incidents] WHERE StateID is NULL
--1920



SELECT
	inc.StateID
	,s.data
   ,st.data
   ,st.casesid
   ,CASE
		WHEN s.[data] IS NOT NULL
			THEN (
					SELECT
						[sttnStateID]
					FROM [sma_MST_States]
					WHERE [sttsDescription] = s.[data]
				)
		-- Match st.data to sttsDescription
		WHEN st.data IS NOT NULL AND
			EXISTS (
				SELECT
					1
				FROM sma_MST_States
				WHERE sttsDescription = st.data
			)
			THEN (
					SELECT
						sttnStateID
					FROM sma_MST_States
					WHERE sttsDescription = st.data
				)
		-- Match st.data to sttsCode
		WHEN st.data IS NOT NULL AND
			EXISTS (
				SELECT
					1
				FROM sma_MST_States
				WHERE sttsCode = st.data
			)
			THEN (
					SELECT
						sttnStateID
					FROM sma_MST_States
					WHERE sttsCode = st.data
				)
		ELSE (
				SELECT
					[sttnStateID]
				FROM [sma_MST_States]
				WHERE sttsCode = 'TX'
			)
	END AS [StateID]
FROM [sma_TRN_Incidents] inc
JOIN sma_trn_cases cas
	ON inc.CaseId = cas.casnCaseID
JOIN [BrianWhiteNeos].[dbo].[cases] C
	ON CAS.neos_saga = CONVERT(VARCHAR(50), C.id)
LEFT JOIN (
	SELECT
		td.casesid
	   ,td.[data]
	FROM [BrianWhiteNeos]..user_case_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	WHERE field_title = 'State of Suit'
) s
	ON s.casesid = c.id
LEFT JOIN (
	SELECT
		td.casesid
	   ,td.[data]
	FROM [BrianWhiteNeos]..user_tab6_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	WHERE field_title IN ('State')
) st
	ON st.casesid = c.id
WHERE StateID IS NULL


---------------------------------------------------------------------------------

select * FROM [sma_TRN_Incidents] WHERE StateID is NULL

UPDATE inc
SET StateId =
CASE
	WHEN s.[data] IS NOT NULL
		THEN (
				SELECT
					[sttnStateID]
				FROM [sma_MST_States]
				WHERE [sttsDescription] = s.[data]
			)
	-- Match st.data to sttsDescription
	WHEN st.data IS NOT NULL AND
		EXISTS (
			SELECT
				1
			FROM sma_MST_States
			WHERE sttsDescription = st.data
		)
		THEN (
				SELECT
					sttnStateID
				FROM sma_MST_States
				WHERE sttsDescription = st.data
			)
	-- Match st.data to sttsCode
	WHEN st.data IS NOT NULL AND
		EXISTS (
			SELECT
				1
			FROM sma_MST_States
			WHERE sttsCode = st.data
		)
		THEN (
				SELECT
					sttnStateID
				FROM sma_MST_States
				WHERE sttsCode = st.data
			)
	ELSE (
			SELECT
				[sttnStateID]
			FROM [sma_MST_States]
			WHERE sttsCode = 'TX'
		)
END
FROM [sma_TRN_Incidents] inc
JOIN sma_trn_cases cas
	ON inc.CaseId = cas.casnCaseID
JOIN [BrianWhiteNeos].[dbo].[cases] C
	ON CAS.neos_saga = CONVERT(VARCHAR(50), C.id)
LEFT JOIN (
	SELECT
		td.casesid
	   ,td.[data]
	FROM [BrianWhiteNeos]..user_case_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	WHERE field_title = 'State of Suit'
) s
	ON s.casesid = c.id
LEFT JOIN (
	SELECT
		td.casesid
	   ,td.[data]
	FROM [BrianWhiteNeos]..user_tab6_data td
	JOIN [BrianWhiteNeos]..user_case_fields ucf
		ON ucf.id = td.usercasefieldid
	WHERE field_title IN ('State')
) st
	ON st.casesid = c.id
WHERE StateID IS NULL
