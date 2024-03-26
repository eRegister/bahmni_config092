Select Patient_Identifier, Patient_Name, Age,Gender as "Sex", age_group,HIV_Testing_Initiation,Testing_History,HIV_Status, Location_Name, Mode_Of_Entry
from
(SELECT Id,  Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Testing_Initiation , Testing_History , HIV_Status, observation
FROM (
  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
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
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4227
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

  UNION ALL

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
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
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4227
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
  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
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
                  where os.concept_id = 4228 and os.value_coded = 4227
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

  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
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
                 
                 -- PROVIDER INITIATED TESTING AND COUNSELING
                 Inner Join (
                  select distinct os.person_id, CAST(os.date_created as Date) as current_conc, os.encounter_id as encounter 
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 4228 and os.value_coded = 4227
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
  (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
        , 'Repeat' AS 'Testing_History' , HIV_Status, observation, sort_order
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
                  where os.concept_id = 4228 and os.value_coded = 4227
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
    UNION ALL
     (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group,  'PITC' AS 'HIV_Testing_Initiation'
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
                  where os.concept_id = 4228 and os.value_coded = 4227
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


  )AS HTS_Status_Detailed

ORDER BY HTS_Status_Detailed.HIV_Testing_Initiation
      , HTS_Status_Detailed.Testing_History
	  , HTS_Status_Detailed.HIV_Status desc
      , HTS_Status_Detailed.sort_order
      , HTS_Status_Detailed.Gender
      , HTS_Status_Detailed.Patient_Name) as tested

Left Join 
(
  select distinct o.person_id, l.name as Location_Name, SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as locations 
  from obs o 
  INNER JOIN location l on o.location_id = l.location_id and l.retired=0
  AND o.person_id in (
                  select distinct os.person_id
                  from obs os
                  INNER JOIN patient ON os.person_id = patient.patient_id
                  where os.concept_id = 2386
                  AND patient.voided = 0 AND os.voided = 0
                 )
  AND o.encounter_id not in (
    select distinct os.encounter_id
    from obs os
    INNER JOIN patient ON os.person_id = patient.patient_id
    where os.concept_id = 4663
    AND patient.voided = 0 AND os.voided = 0
    )
    and o.voided = 0
  Group by person_id
) as loc
on tested.Id = loc.person_id

Left Join 

(
  select distinct o.person_id, SUBSTRING((CONCAT(o.obs_datetime, o.encounter_id)), 20) as entry_mode,
       case
           when value_coded = 4234 then "Antiretroviral"
           when value_coded = 4233 then "Anti Natal Care"
           when value_coded = 2191 then "Outpatient"
           when value_coded = 2190 then "Tuberculosis Entry Point"
           when value_coded = 4235 then "VMMC"
           when value_coded = 4236 then "Adolescent"
           when value_coded = 2192 then "Inpatient"
           when value_coded = 3632 then "PEP"
           when value_coded = 2139 then "STI"
           when value_coded = 4788 then "PEADS"
           when value_coded = 4789 then "Malnutrition"
           when value_coded = 4790 then "Subsequent ANC"
           when value_coded = 4791 then "Emergency ward"
           when value_coded = 4792 then "Index Testing"
           when value_coded = 4796 then "Other Cummunity"
           when value_coded = 4237 then "Self Testing"
           when value_coded = 4963 then "PNC"
           when value_coded = 4816 then "PrEP"
           when value_coded = 2143 then "Other"
           else ""
       end AS Mode_of_Entry
     from obs o
     inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as hts_modeofEntry
		 from obs oss
		 where oss.concept_id = 4238 and oss.voided=0
		 AND CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
     AND CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where o.concept_id = 4238
	and o.voided = 0
	and  o.obs_datetime = max_observation
	) modeOfEntry
ON tested.Id = modeOfEntry.person_id

