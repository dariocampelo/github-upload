--The purpose of this Query is to calcualte Star rating at TIN level
--Hedis are being calcuated by the Quest team but there is no way to excport a file with all the HEDIS measure at TIN level. 
-- This Query is one attempt at calucating the STAR rating at TIN level in SQL to allow future tables from being easily added in future. 
--
SELECT [PROV_TAX_ID],[MEASURE_CAT],
 SUM([ELIGIBLE_CNT]) AS TotalEligibleCount, --Calculate Total Eligible Count by individual TIN and HEDIS measure
 SUM([COMPLIANT_CNT]) AS TotalCompliantCount, --Calculate Total Compliant Count by individual TIN and HEDIS measure
 SUM([ELIGIBLE_CNT]-[COMPLIANT_CNT]) AS TotalNONCompCount, --Calculate Total Non Compliant Count by individual TIN and HEDIS measure
 SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT]) AS GapClosureRate, -- Calculate Percentage Gap closed by individual TIN and HEDIS measure
 CASE 
	WHEN  SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT]) <  AVG([BY21_STAR2]) THEN '1' 
	WHEN AVG([BY21_STAR2]) <= (SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT])) AND (SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT])) < AVG([BY21_STAR3]) THEN '2'
	WHEN AVG([BY21_STAR3]) <= SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT]) AND (SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT])) < AVG([BY21_STAR4]) THEN '3'
	WHEN AVG([BY21_STAR4]) <= SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT]) AND (SUM([COMPLIANT_CNT])/SUM([ELIGIBLE_CNT])) < AVG([BY21_STAR5]) THEN '4'
	ELSE '5'
	 END AS StarRating 
	 into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario] 
  FROM [AdHocData].[FASPRSE].[SER_STARS_20190318V3]
   GROUP BY [PROV_TAX_ID],[MEASURE_CAT] 
   order by [PROV_TAX_ID] asc, [MEASURE_CAT] asc;

/************************Create Table to hold HEDIS Measures Abreviations and individual Weights****************************************************/

CREATE TABLE [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] (
  MEASURECAT VARCHAR (20) NOT NULL, 
  MeasureStarRating INT NULL, 
  PRIMARY KEY (MEASURECAT)
  ); 
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('ABA', '1'); --Adult BMI Assessment
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('ART', '1'); -- Anti-Rheumatic Drug Therapy for Rheumatoid Arthritis
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('BCS', '1'); --Breast Cancer Screening
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('CDC_EYE', '1'); --Comprehensive Diabetes Care
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('CDC_HBACONTROL', '3'); --Comprehensive Diabetes Care
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('CDC_NPH', '1'); --Comprehensive Diabetes Care
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('COA_FSA', '1'); --Care for Older Adults, Functional Status Assessment
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('COA_MDR', '1'); --Care for Older Adults,Medication Review
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('COA_PNS', '3'); -- --Care for Older Adults, Pain Assessment
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('COL', '1'); --Colorectal Cancer Screening
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('MRP', '1'); --Medication Reconciliation Post-Discharge
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('OMW', '1'); --Osteoporosis Management in Women Who Had a Fracture
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('PCR', '3'); --Plan All-Cause Readmissions
  insert into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] values ('SPC_STATIN', '1'); --Statin Therapy for Patients With Cardiovascular Disease

/*********************************Join Tables on Hedis Measure Abreviation*****************************************************************************/
SELECT B.*, A.MeasureStarRating
 into [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1] 
FROM [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] A
INNER JOIN [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario] B
ON  A.[MEASURECAT] = B.[MEASURE_CAT];

/**********************Weighted Avergae Stars for GA and SC (Quest 2.0 BY 2022 is 1.78) versus SQL 1.97 ***************************************/
DROP TABLE  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars]
select --PROV_TAX_ID, 
SUM(cast(MeasureStarRating as float) *CAST (StarRating as float))/SUM(CAST (MeasureStarRating as float)) as TIN_StarWeighted
into  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars]
from [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1];
--GROUP BY PROV_TAX_ID;

/*************************************************************************************************************************/
DROP TABLE  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars]
select PROV_TAX_ID, 
SUM(cast(MeasureStarRating as float) * CAST (StarRating as float))/SUM(CAST (MeasureStarRating as float)) as TIN_StarWeighted
into  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars]
from [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1]
GROUP BY PROV_TAX_ID;

/************************************************************************************************************************************/
SELECT TOP (10000) *   FROM [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario]  --SelectTopNRows Dario
  order by [PROV_TAX_ID] asc, [MEASURE_CAT] asc;
/************************************************************************************************************************************/

SELECT TOP (100000) *   FROM [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1]  --SelectTopNRows Dario1
  order by [PROV_TAX_ID] asc, [MEASURE_CAT] asc;

/************************************************************************************************************************************/

SELECT TOP (100000) *     
  FROM [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1]
   where [PROV_TAX_ID] = '141994804' or [PROV_TAX_ID] = '576000934'
  order by [PROV_TAX_ID] asc, [MEASURE_CAT] asc;
  --group by MEASURE_CAT  --SelectTopNRows Dario1


/************************************************************************************************************************************/
SELECT TOP (10000) *   FROM  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars] --SelectTopNRows Dario
order by TIN_StarWeighted desc, [PROV_TAX_ID] asc;
  
/************************************************************************************************************************************/
DROP TABLE [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario]; -- Drop Table Dario
/************************************************************************************************************************************/
 
DROP TABLE [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario1]; -- Drop Table Dario1

/************************************************************************************************************************************/
DROP TABLE [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_StarRating] -- Drop Table Dario_StarRating
/************************************************************************************************************************************/
DROP TABLE  [AdHocData].[FASPRSE].[SER_STARS_20190318_Dario_Weighted_Stars]