select * FROM sma_TRN_Notes stn order BY stn.saga

SELECT 
    saga,
    COUNT(*) AS DuplicateCount
FROM 
    sma_TRN_Notes
GROUP BY 
    saga
HAVING 
    COUNT(*) > 1;

-- 846A19B2-E97D-47DE-A259-ACD8012298AE

select * FROM sma_TRN_Notes stn where saga = '846A19B2-E97D-47DE-A259-ACD8012298AE'