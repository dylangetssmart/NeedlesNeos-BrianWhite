select * from sma_TRN_Plaintiff p
join duplicate_cases dc
on p.plnncaseid = dc.casncaseid 

select * from sma_TRN_Defendants d
join duplicate_cases dc
ON d.defnCaseID = dc.casncaseid

DELETE p
from sma_TRN_Plaintiff p
join duplicate_cases dc
on p.plnncaseid = dc.casncaseid 

DELETE d
FROM sma_TRN_Defendants d
JOIN duplicate_cases dc
    ON d.defnCaseID = dc.casnCaseID;