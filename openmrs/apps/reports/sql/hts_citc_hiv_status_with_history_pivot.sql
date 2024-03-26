SELECT HTS_TOTALS_COLS_ROWS.AgeGroup
		, HTS_TOTALS_COLS_ROWS.Gender as "Sex"
		, HTS_TOTALS_COLS_ROWS.New_Positives
		, HTS_TOTALS_COLS_ROWS.New_Negatives
    , HTS_TOTALS_COLS_ROWS.New_Indeterminate
		, HTS_TOTALS_COLS_ROWS.Rep_Positives
		, HTS_TOTALS_COLS_ROWS.Rep_Negatives
    , HTS_TOTALS_COLS_ROWS.Rep_Indeterminate
		, HTS_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT HTS_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, HTS_STATUS_DRVD_ROWS.Gender
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc' 
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Positive' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'New', 1, 0))) AS New_Positives
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc'			
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Negative' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'New', 1, 0))) AS New_Negatives
              , IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc'			
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Indeterminate and inconclusive results' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'New', 1, 0))) AS New_Indeterminate
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc' 
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Positive' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'Repeat', 1, 0))) AS Rep_Positives				
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc'
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Negative' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'Repeat', 1, 0))) AS Rep_Negatives
              , IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc'
							AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Indeterminate and inconclusive results' AND HTS_STATUS_DRVD_ROWS.Testing_History = 'Repeat', 1, 0))) AS Rep_Indeterminate
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.HIV_Testing_Initiation = 'citc', 1, 0))) as 'Total'
						, HTS_STATUS_DRVD_ROWS.sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1016
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- NEWER TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1738
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                  AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                  AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL
  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'Repeat' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1016
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                
				-- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'Repeat' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1738
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- REPEATER, HAS HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id				 
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
    UNION ALL
     (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 4220 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 4220
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- NEWER TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
    UNION ALL
     (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 4220 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 4220
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- REPEAT TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

			) AS HTS_STATUS_DRVD_ROWS

			GROUP BY HTS_STATUS_DRVD_ROWS.age_group, HTS_STATUS_DRVD_ROWS.Gender
			ORDER BY HTS_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Sex'
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc' 
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Positive' AND HTS_STATUS_DRVD_COLS.Testing_History = 'New', 1, 0))) AS New_Positives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc'			
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Negative' AND HTS_STATUS_DRVD_COLS.Testing_History = 'New', 1, 0))) AS New_Negatives
              , IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc'			
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Indeterminate and inconclusive results' AND HTS_STATUS_DRVD_COLS.Testing_History = 'New', 1, 0))) AS New_Indeterminate
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc' 
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Positive' AND HTS_STATUS_DRVD_COLS.Testing_History = 'Repeat', 1, 0))) AS Rep_Positives				
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc'
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Negative' AND HTS_STATUS_DRVD_COLS.Testing_History = 'Repeat', 1, 0))) AS Rep_Negatives
              , IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc'
							AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Indeterminate and inconclusive results' AND HTS_STATUS_DRVD_COLS.Testing_History = 'Repeat', 1, 0))) AS Rep_Indeterminate
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.HIV_Testing_Initiation = 'citc', 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1016
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- NEWER TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1738
                 AND patient.voided = 0 AND o.voided = 0
                 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                  AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- NEW TESTER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                  AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
              AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL
  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'Repeat' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1016
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- REPEATER, DOES NOT HAVE HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                
				-- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

  UNION ALL

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'Repeat' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation,
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 1738
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- CLIENT INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter              
                 -- REPEATER, HAS HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id				 
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
    UNION ALL
     (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 4220 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 4220
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- NEWER TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2147
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)
    UNION ALL
     (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'CITC' AS 'HIV_Testing_Initiation'
        , 'New' AS 'Testing_History' , HIV_Status, observation, sort_order
    FROM
            (select distinct patient.patient_id AS Id,
                         patient_identifier.identifier AS patientIdentifier,
                         concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                         floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
                         (select name from concept_name cn where cn.concept_id = 4220 and concept_name_type='FULLY_SPECIFIED') AS HIV_Status,
                         person.gender AS Gender,
                         observed_age_group.name AS age_group,
                         pitc.current_conc,
                         SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as observation, 
                         observed_age_group.sort_order AS sort_order

            from obs o
                -- HTS CLIENTS WITH HIV STATUS BY SEX AND AGE
                 INNER JOIN patient ON o.person_id = patient.patient_id 
                 AND o.concept_id = 2165 and o.value_coded = 4220
                 AND patient.voided = 0 AND o.voided = 0
                  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4226
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as pitc
                 on o.person_id = pitc.person_id
                 AND o.encounter_id = pitc.encounter
                               
                 -- REPEAT TESTER, HAS A HISTORY OF PREVIOUS TESTING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2137 and os.value_coded = 2146
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 ) as repeater
                 on o.person_id = repeater.person_id
                 and pitc.current_conc = repeater.current_conc
                 
				 -- Observation be in HIV Testing form
                 inner join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                   AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                   AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                  AND patient.voided = 0 AND os.voided = 0
                 )as testingform
                 on o.person_id = testingform.person_id
                                 
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                 INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                 INNER JOIN reporting_age_group AS observed_age_group ON
                  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
               WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) AS HTSClients_HIV_Status
    ORDER BY HTSClients_HIV_Status.HIV_Status, HTSClients_HIV_Status.Age)

			) AS HTS_STATUS_DRVD_COLS
		)
		
	) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

