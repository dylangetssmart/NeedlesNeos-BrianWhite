SELECT 
    saga_ref,
    COUNT(*) AS DuplicateCount
FROM 
    sma_MST_IndvContacts
GROUP BY 
    saga_ref 
HAVING 
    COUNT(*) > 1;


select * FROM BrianWhiteNeos..names n WHERE n.last_long_name = 'pennington' and n.first_name = 'tiffany'
select * FROM BrianWhiteNeos..staff n WHERE id = 'BA619E1A-2F20-4271-8EF6-B14A00FB6E10'
-- F941ADB1-6734-4C74-9E2F-B122012DA221

SELECT
	smic.cinnContactID
   ,smic.cinsFirstName
   ,smic.cinsLastName
   ,smic.saga_ref
   ,cinnrecuserid
   ,smic.cindDtCreated
FROM sma_MST_IndvContacts smic
WHERE smic.cinsLastName LIKE '%pennington%'
	AND smic.cinsFirstName = 'tiffany'

select * FROM sma_MST_Users smu WHERE smu.saga = 'BA619E1A-2F20-4271-8EF6-B14A00FB6E10'

select * from sma_MST_IndvContacts smic WHERE smic.saga_ref is null


select *
FROM [BrianWhiteNeos]..[names] N
	LEFT JOIN [BrianWhiteNeos]..[prefix] p
		ON n.prefixid = p.id
	LEFT JOIN [BrianWhiteNeos]..[suffix] s
		ON s.id = n.suffixid
	WHERE N.[person] = 1
	and N.last_long_name = 'pennington'
	 AND NOT EXISTS (
      SELECT 1
      FROM sma_MST_IndvContacts smic
      WHERE smic.saga_ref = n.id
  );

  SELECT N.*
FROM [BrianWhiteNeos]..[names] N
LEFT JOIN [BrianWhiteNeos]..[prefix] p
    ON N.prefixid = p.id
LEFT JOIN [BrianWhiteNeos]..[suffix] s
    ON s.id = N.suffixid
LEFT JOIN [sma_mst_indvcontacts] ic
    ON ic.saga_ref = convert(varchar(50),N.id)
WHERE N.[person] = 1
  AND N.last_long_name = 'pennington'
  AND ic.saga_ref IS NULL; -- Exclude records with matching saga_ref

  select * FROM sma_TRN_CaseStaff stcs
  WHERE  stcs.cssnStaffID =  12734
  --stcs.cssnStaffID = 19 OR


  SELECT * from sma_MST_IndvContacts i
  JOIN sma_MST_Users u
  ON i.cinnContactID = u.usrnContactID
  WHERE i.cinsLastName = 'pennington'


  SELECT 
    cinsFirstName, 
    cinsLastName, 
    COUNT(*) AS DuplicateCount
FROM 
    sma_mst_indvcontacts
where cinsLastName = 'pennington'
GROUP BY 
    cinsFirstName, 
    cinsLastName
HAVING 
    COUNT(*) > 1;


------------------------------------------------------------------------------------------


select * FROM sma_MST_IndvContacts smic WHERE smic.cinsLastName = 'pennington'
and smic.cinsFirstName = 'tiffany'


select * FROM implementation_users iu

select * FROM BrianWhiteNeos..staff n WHERE id = 'F941ADB1-6734-4C74-9E2F-B122012DA221'
select * FROM BrianWhiteNeos..names n WHERE n.last_long_name = 'davis' order BY n.first_name--WHERE id = 'F941ADB1-6734-4C74-9E2F-B122012DA221'

SELECT
	i.cinncontactid
   ,i.cinsFirstName
   ,i.cinsLastName
   ,i.saga_ref
   ,u.*
FROM sma_MST_IndvContacts i
JOIN (
	SELECT
		i.cinncontactid
	   ,i.cinsFirstName
	   ,i.cinsLastName
	   ,i.saga_ref
	FROM sma_mst_Users u
	JOIN sma_MST_IndvContacts i
		ON i.cinncontactid = u.usrnContactID
) u
	ON i.cinsFirstName = u.cinsFirstName
		AND i.cinsLastName = u.cinsLastName
		--AND i.saga_ref IS NULL
		AND i.cinnContactID <> u.cinnContactID
		--join BrianWhiteNeos..staff s
		--on convert(varchar(50),s.id) = i.saga_ref
		JOIN BrianWhiteNeos..names n
		ON convert(varchar(50),n.id) = i.saga_ref
ORDER BY i.cinsFirstName, i.cinsLastName


select * FROM sma_TRN_LawFirms stlf
select * 