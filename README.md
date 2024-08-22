# SmartAdvocate Conversion Boilerplate
Base project setup for a Needles conversion including generic sql scripts and a python CLI to execute conversion related-tasks quickly.

## Installation
1. [Install python](https://www.python.org/downloads/)
	- Add python to PATH
2. Update `.env` (in the project root)
```py
SERVER=your_server_here # Ex: DylanS\MSSQLSERVER2022
SOURCE_DB=name_of_source_database # Ex: TestClientNeedles
TARGET_DB=name_of_target_SA_db # Ex: TestClientSA
SQL_SCRIPTS_DIR=where_your_SQL_scripts_live # Ex: sql\needles\conv

```
3. Install project dependencies
```bash
$ python -m pip -r install requirements.txt
```

## Usage

- Logs are output to `/logs`
- Backups go to `/backups/`

Invoke `conv.py` with the help flag `-h` to see all available commands
```bash
$ python conv.py -h
```
> [!TIP]
> `-h` or `--help` is available for all subcommands to view any necessary parameters and flags.

**Example:**

The below command invokes the `exec` command for script sequence `0` (initialize) and creates a backup when done `-bu`.
```bash
$ python conv.py exec -s 0 -bu
```

# SQL Scripts

## Key Concepts

The following documentation outlines both generically applicable scripts as well as customizable scripts that may or may not be applicable
> [!NOTE]
> The sql scripts in this repo omit `USE {database}`, as the database is passed as a [sqlcmd option](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16&tabs=go%2Cwindows&pivots=cs1-bash#-d-db_name).
> When running sql scripts manually, be sure to restore the `USE` command.

### Sequence
I use the term "Sequence" to refer to the _step_ or _series_ that a script belongs to.

Sequence|Purpose
:---:|:---
0|Initialize
1|Contacts
2|Cases
3|UDF
4|Intake
5|Misc
P|Post

> [!CAUTION]
> Sequence is baked into my filenaming convention shown below and is a integral part of how the python CLI works. When you invoke the `exec` command, Sequence is a [positional argument](https://docs.python.org/3/library/argparse.html#name-or-flags) that is **required** for the program to know which scripts it should execute.
> 
> When renaming scripts or creating new ones, Sequence must remain in tact as per the table above if you plan to use the python CLI.

### Filenaming Convention
The included SQL scripts use a four-part file naming convention.

**Convention**
1. [Sequence](#sequence)
2. SmartAdvocate Screen
3. Screen Section/sub-section
4. Data source (optional)

My philospohy for this convention is that a script file should:
- Use an appropriate sequence (order matters)
- Indicate what screen and section it affects
- Optionally, include the source of the data if it is unexpected or otherwise relevant.

**Example**

`2.47-Plaintiff_SpDamages-user_tab.sql`
Sequence|Screen|Section|Data Source (optional)
:--|:--|:--|:--
2.47a|Plaintiff|Special Damages|user_tab|

> [!NOTE]
> **Regarding mixing hyphens and underscores:**
>
> Although it looks disgusting, I mix underscores and hyphens for easier filename navigation using `ctrl` + arrow keys. Try renaming a script to see what I mean.



## Sequence 0 - Initialize
**Generic Scripts**
Script|Purpose|Notes
:---|:---|:---
0.0_init_Initialize.SQL|Creates various functions to extract and massage data|--
0.1_init_CaseTypeMixture.SQL|Creates table CaseTypeMixture used to cross reference Caes Types|Harcoded for initial conversion
0.2_init_CaseValueMapping.sql|Creates table CaseValueMapping and populates it with default values|--
0.3_init_ImplementationUsersMap.sql|Creates table implementation_users and populates it with users from `[dbo].[staff]`|Optionally, seed the table with user records from the implementation database
0.5_init_NeedlesUserFields.sql|Creates table NeedlesUserFields|--
0.6_init_PartyRole.sql|Creates table PartyRoles used to cross reference party roles|Harcoded for initial conversion

<details>
<summary>CaseTypeMixture.sql</summary>
To continue with the conversion while waiting the real case type mapping, simply set the SA Case Type to the Needles description.

```xlsx
=CONCAT("SELECT ","'"&B3&"'",", ","'"&C3&"'",", ","'"&D3&"'",", ","'"&D3&"'",", '' UNION")
```
</details>

## Sequence 1 - Contacts
Script|Purpose|Notes
:---|:---|:---
1.00_Contacts.sql|--|--
1.01_contact_Insured.SQL|Creates contacts from `[dbo].[insurance]`|Indv
1.02_contact_PoliceOfficer.SQL|Creates police officer contacts from `[dbo].[police]`|Indv
1.05_contact_EmailWebsite.SQL|Populates `sma_MST_EmailWebsite` from `[dbo].[names]`|Indv + Org
1.06_contact_PhoneNumber.SQL|Populates `sma_MST_ContactNumbers` from `[dbo].[names]`|Indv + Org
1.31_contact_UnidentifiedCourt.sql|Creates Unidentifed Court contact|Org
1.32_contact_UnidentifiedSchool.sql|Creates Unidentifed School contact|Org
1.33_contact_Witness.sql|Creates Indv contacts for witnesses from `[dbo].[user_party_data]`|Custom
1.35_contact_UnassignedStaff.sql|Creates Unassigned Staff contact|Indv _(used for conversion user)_
1.36_contact_AllContacts_ContactPerson.SQL|--|Custom
1.38_contact_Plaintiff_Spouse.sql|--|Custom
1.39_contact_Plaintiff_Employer.sql|--|Custom
1.40_contact_Address.SQL|Populates `sma_MST_Address` from `[dbo].[multi_addresses]`|--
1.89_contact_Uniqueness.sql|--|--
1.90_contact_AllContactInfo.sql|--|--
1.91_Contact_Comment.SQL|--|--
1.91_contact_IndvOrgContacts.sql|--|Must come after `1.90_contact_AllContactInfo.sql`
1.92_Contact_Notes.SQL|--|Must come after `1.91_contact_IndvOrgContacts.sql`

## Sequence 2 - Cases

##### Value Tab
_info about value tab_

###### Medical Providers
_Script name here_
**Code modification instructions:**
- [ ] Update temp table with codes from mapping
```sql
INSERT INTO #MedChargeCodes (code)
VALUES
('MEDICAL')
```

###### Lien Tracking
_Script name here_
**Code modification instructions:**
- [ ] Update temp table with codes from mapping
```sql
INSERT INTO #LienValueCodes (code)
VALUES
('SUBRO')
```

###### Disbursements
_Script name here_
**Code modification instructions:**
- [ ] Update temp table with codes from mapping
```sql
INSERT INTO #DisbursementValueCodes (code)
VALUES
('CEX'), ('DTF')
```

###### Negotiation/Settlement
_Script name here_
**Code modification instructions:**
- [ ] Update temp table with codes from mapping
```sql
INSERT INTO #NegSetValueCodes (code)
VALUES
('FEE'), ('SET')
```
- [ ] Create necessary settlement types
```sql
INSERT INTO [sma_MST_SettlementType] (SettlTypeName)
SELECT 'Recovery'
UNION SELECT 'Attorney Fee'
EXCEPT SELECT SettlTypeName FROM [sma_MST_SettlementType]
GO
```
- [ ] Update `case` for `stlTypeID`
```sql
    ,(
        select ID
        from [sma_MST_SettlementType]
        where SettlTypeName = case
                                    when v.[code] in ('SET')
                                        then 'Settlement Recovery'
			                        when v.[code] in ('MP')
                                        then 'MedPay'
                                    when v.[code] in ('PTC' )
                                        then 'Paid To Client' 
                                    end 
    )                               as stlTypeID
```

## Sequence 3 - UDF

## Sequence 4 - Intake

## Sequence 5 - Misc

## Sequence P - Post 


#### General

##### Summary
##### Case Type

##### Status
1. Create "Grade" status type in sma_mst_CaseStatusType
2. Add distinct Grade values into sma_mst_CaseStatus
3. Update appropriate cases with the Grade status type and description
```sql
--select distinct Grade from NeedlesSLF..user_case_data where isnull(grade,'')<>''
select top (1) * from SANeedlesSLF..sma_TRN_Cases
select * from SANeedlesSLF..sma_MST_CaseStatusType
select * from SANeedlesSLF..sma_MST_CaseStatus where cssnStatusTypeID = 24
select * from SANeedlesSLF..sma_TRN_CaseStatus where cssnCaseID = 1
```

##### Investigations
sma_TRN_CaseWitness
- Create witness contact card
- saga_ref = 'witness'
- saga = user_party_data.case_id (which is really case number)

1.33_Witness_Contacts.sql
2.26_General_Investigations_Witness.sql

##### Disbursements
**Key Concepts**
Create Disbursement (`[sma_TRN_Disbursement]`) records from the `value` table. Add user fields to the disbursement record as necessary.

**Script Readme**
- Creates DisbursementTypes that don't exist for mapped value codes.
- Creates helper tables to collate contact information for the Provider ("due to firm") and Plaintiff.
- Creates disbursement records.

**Value Codes**
- 1
- 2
- 3

```sql
select u.case_id,Account_Number, u.Check_Requested, u.Cancel, u.CM_Reviewed, u.Date_Paid, u.For_Dates_From, u.OI_Checked, v.*
from NeedlesSLF..user_tab2_data u
inner join NeedlesSLF..value v
	on v.case_id = u.case_id
	where v.code = 'cpy' and u.case_id =218979
```

##### Negotiation/Settlement
**Value Codes**
- 1
- 2
- 3


#### Other

##### All Contacts
#### Plaintiff
##### Plaintiff Injuries

##### Employment

##### Lost Wages
Value Code `LWG`



##### Special Damages
###### From user_tab_data
`2.47a-Plaintiff_SpDamages-user_tab.sql`
- Create Special Damage records with Loss = Total_Damages

###### From value (generic)
**Value Codes**


##### Lien Tracking
**Value Codes**

##### Medical Providers
code|description|SmartAdvocate Section|	SmartAdvocate Screen|SmartAdvocate Field
---|---|---|---|---
MEDICAL	|Medical Treatment-Doctors, Hospitals, Tests|	Plaintiff	|Medical Provider

- value codes
- MED

- Provider
	- user_tab2_data

> [Note]
> Example: names_id = `45058`

```sql
select d.case_id, d.tab_id, d.Provider, n.user_name, name.names_id, name.first_name, name.last_long_name
from NeedlesSLF..user_tab2_data d
join NeedlesSLF..user_tab2_name n
	on d.tab_id = n.tab_id
join NeedlesSLF..names name
	on name.names_id = n.user_name
join SANeedlesSLF..sma_TRN_Cases c
	on c.cassCaseNumber = d.case_id
where isnull(d.Provider,'') <> ''
```

#### Intake

#### General > Incident

```sql
select synopsis,date_of_incident from NeedlesSLF..case_intake
```

#### General > Retainer/Referral
`referred_by` has field_type = name, so links to a contact card
referred_by_id

#### General > Summary
