
SELECT 
	Total_Aggregated_Cases.Age_Group
	, Total_Aggregated_Cases.Males_Seen
	, Total_Aggregated_Cases.Females_Seen
	, Total_Aggregated_Cases.Total
FROM(
		(
			SELECT 
				prep_status.Age_Group AS 'Age_Group',
				IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation' AND Gender = 'M', 1, 0))) AS Males_Seen,
				IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation' AND Gender = 'F', 1, 0))) AS Females_Seen,
				IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation', 1, 0))) AS Total,
				prep_status.sort_order

			FROM(
					SELECT Id,patientIdentifier, patientName, Age, Gender, age_group, Program_Status, Location,sort_order
					FROM(
						
						SELECT Id,patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location,sort_order
						FROM(
								SELECT DISTINCT 
									patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
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
							-- group by o.person_id ORDER BY o.obs_datetime desc limit 1			 
						 INNER JOIN person ON person.person_id = patient.patient_id 
						 	AND person.voided = 0
						 INNER JOIN location l ON active_prep.location_id = l.location_id  
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
				)as prep
			)AS prep_status

		GROUP BY prep_status.Age_group
		Order by prep_status.sort_order
		)
	
	
		UNION ALL


		(
			SELECT 
				'Total' AS AgeGroup
				, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation' AND Gender = 'M', 1, 0))) AS 'Males_Seen'
				, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation' AND Gender = 'F', 1, 0))) AS 'Females_Seen'
				, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation', 1, 0))) AS 'Total'
				, 99 AS 'sort_order'
			FROM(
					SELECT  
						Total_prep_status.Id
						, Total_prep_status.Age
						, Total_prep_status.Program_Status
						, Total_prep_status.Gender
						, Total_prep_status.sort_order
					FROM(
							SELECT Id,patientIdentifier, patientName, Age, Gender, age_group, Program_Status, Location,sort_order
							FROM(
									SELECT Id,patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location,sort_order
									FROM(
										
											SELECT DISTINCT 
												patient.patient_id AS Id,
												patient_identifier.identifier AS patientIdentifier,
												concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												person.gender AS Gender,
												observed_age_group.name AS age_group,
												observed_age_group.sort_order AS sort_order,
												l.name AS Location

											FROM obs o
											-- CLIENTS CONTINUING PrEP
											
											INNER JOIN patient ON o.person_id = patient.patient_id 
												AND o.concept_id = 5029
												AND patient.voided = 0 AND o.voided = 0
							
											INNER JOIN obs active_prep ON active_prep.person_id = o.person_id
												AND active_prep.concept_id = 3752
												AND active_prep.obs_datetime < DATE_ADD('#endDate#', INTERVAL 1 DAY)
												AND active_prep.encounter_id = o.encounter_id
												AND active_prep.value_datetime >= '#endDate#'	
												AND active_prep.voided = 0					 
											INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											INNER JOIN location l ON active_prep.location_id = l.location_id  AND l.retired=0
											INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
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
							)as prep
					) AS Total_prep_status
-- Order by Total_prep_status.sort_order
  			) AS Totals
 		)
	) AS Total_Aggregated_Cases
Order by Total_Aggregated_Cases.sort_order

