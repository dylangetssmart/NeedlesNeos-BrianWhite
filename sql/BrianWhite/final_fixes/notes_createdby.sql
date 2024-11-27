SELECT
	notes.SAGA, notes.notnRecUserID, u.usrnUserID, n.staffcreatedid,s.staff_code, s.full_name
FROM sma_trn_notes notes
JOIN BrianWhiteNeos..case_notes_Indexed n
	ON notes.SAGA = CONVERT(VARCHAR(50), n.ID)
LEFT JOIN [sma_MST_Users] U
	ON U.saga = CONVERT(VARCHAR(50), n.staffcreatedid)
JOIN BrianWhiteNeos..staff s
on s.id = n.staffcreatedid
where notes.SAGA is not null AND u.usrnuserid is not null
-- 287,184 missing saga
-- 317,516 total notes
-- 65,198 where user exists

SELECT * FROM BrianWhiteNeos..staff  where id='B3F96990-147A-4B96-8677-AD4E016C0FD3' ORDER BY  full_name
SELECT * FROM sma_MST_Users smu order BY usrsloginid
SELECT* FROM implementation_users STF order BY full_name

SELECT * FROM sma_TRN_Notes stn WHERE stn.notnRecUserID is null
-- 317,516 total notes


UPDATE sma_TRN_Notes

SET notnRecUserID = u.usrnUserID
SELECT
	notes.SAGA, notes.notnRecUserID, u.usrnUserID, n.staffcreatedid,s.staff_code, s.full_name
FROM sma_trn_notes notes
JOIN BrianWhiteNeos..case_notes_Indexed n
	ON notes.SAGA = CONVERT(VARCHAR(50), n.ID)
LEFT JOIN [sma_MST_Users] U
	ON U.saga = CONVERT(VARCHAR(50), n.staffcreatedid)
JOIN BrianWhiteNeos..staff s
	ON s.id = n.staffcreatedid
WHERE notes.SAGA IS NOT NULL
AND u.usrnuserid IS NOT NULL
-- 287,184 missing saga
-- 317,516 total notes
-- 65,198 where user exists