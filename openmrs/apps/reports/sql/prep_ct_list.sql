SELECT patientIdentifier , patientName, Age, Gender, age_group, PrEP_Option, 'PrEP_Continuation' AS Program_Status, Location
FROM
    (SELECT DISTINCT 
		patient.patient_id AS Id,
		patient_identifier.identifier AS patientIdentifier,
		concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		TIMESTAMPDIFF(YEAR, person.birthdate, CAST('#endDate#' AS DATE)) AS Age,
		person.gender AS Gender,
		observed_age_group.name AS age_group,
		CASE prep_option.value_coded
			WHEN 6096 THEN 'Daily'
			WHEN 6097 THEN 'ED_PreP'
			WHEN 6098 THEN 'Ring'
			WHEN 6099 THEN 'Cab-La'
			WHEN 6597 THEN 'Lenacapavir'
			WHEN 4991 THEN 'Other'
		END AS PrEP_Option,
		observed_age_group.sort_order AS sort_order,
		l.name AS Location

    FROM obs o
	-- CLIENTS CONTINUING PrEP
	INNER JOIN patient ON o.person_id = patient.patient_id 
		AND o.concept_id = 5029	
		AND patient.voided = 0 
		AND o.voided = 0
	INNER JOIN obs active_prep ON active_prep.person_id = o.person_id
		AND active_prep.concept_id = 3752
		AND active_prep.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
		AND active_prep.encounter_id = o.encounter_id
		AND active_prep.value_datetime >= '#endDate#'	
		AND active_prep.voided = 0	
	LEFT JOIN obs prep_option ON prep_option.person_id = o.person_id
   		AND prep_option.encounter_id = o.encounter_id
   		AND prep_option.concept_id = 6100
   		AND prep_option.voided = 0				 
	INNER JOIN person ON person.person_id = patient.patient_id 
		AND person.voided = 0
	INNER JOIN location l on active_prep.location_id = l.location_id
		AND l.retired=0
	INNER JOIN person_name ON person.person_id = person_name.person_id 
		AND person_name.preferred = 1
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id 
		AND patient_identifier.identifier_type = 3 	
		AND patient_identifier.preferred=1
	INNER JOIN reporting_age_group AS observed_age_group ON
		CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
			AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
    WHERE observed_age_group.report_group_name = 'Modified_Ages'
	AND NOT EXISTS (
          SELECT 1
          FROM obs os
          WHERE os.person_id = o.person_id
            AND os.concept_id = 4994
            AND os.obs_datetime >= '#startDate#'
            AND os.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
            AND os.voided = 0
      )
      AND NOT EXISTS (
          SELECT 1
          FROM obs os
          WHERE os.person_id = o.person_id
            AND os.concept_id = 5005
            AND os.obs_datetime >= '#startDate#'
            AND os.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
            AND os.voided = 0
      )
	) AS PrEP_Seen
ORDER BY PrEP_Seen.patientName
