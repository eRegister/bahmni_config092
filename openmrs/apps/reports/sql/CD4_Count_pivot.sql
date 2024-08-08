SELECT Total_Aggregated_TxCurr.AgeGroup
		, Total_Aggregated_TxCurr.CD4_less_200
		, Total_Aggregated_TxCurr.CD4_200_to_349
		, Total_Aggregated_TxCurr.CD4_350_to_500
		, Total_Aggregated_TxCurr.CD4_greater_500
		, Total_Aggregated_TxCurr.Tx_Curr

FROM

(
	(SELECT TXCURR_DETAILS.age_group AS 'AgeGroup'
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(CD4 < 200, 1, 0))) AS CD4_less_200
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(CD4 >= 200 and CD4 < 350, 1, 0))) AS CD4_200_to_349
            , IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(CD4 >= 350 and CD4 <= 500, 1, 0))) AS CD4_350_to_500
            , IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(CD4 > 500, 1, 0))) AS CD4_greater_500
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(1)) as 'Tx_Curr'
			, TXCURR_DETAILS.sort_order
			
	FROM

(
	Select Id, Patient_Identifier, Patient_Name,age_group, Program_Status, CD4, sort_order
FROM(
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Initiated' AS 'Program_Status', sort_order
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 

						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.patientName)-- AS Tx_New

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Tx_Curr' AS 'Program_Status', sort_order
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

									  
                from obs o
					
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id-- , active_clients.latest_follow_up
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
								where active_clients.latest_follow_up >= cast('#endDate#' as date)
			
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
							)

		and active_clients.person_id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)			
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1
						 )
		and active_clients.person_id not in (
									-- Visitors
								select o.person_id
								from obs o
								inner join
										(
										select oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
										from obs oss
										where oss.concept_id = 3753 
										and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
										)latest
									on latest.person_id = o.person_id
									where concept_id = 5416
									and o.value_coded =1 and o.voided=0
									and  cast(o.obs_datetime as date) = cast(max_observation as date)
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Seen_Previous_ART_Clients
ORDER BY Seen_Previous_ART_Clients.patientName)

UNION

-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Missed' AS 'Program_Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

						
                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (

						  -- Latest followup date from the lastest followup form, exclude voided followup date
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
				
				
		                and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                and active_clients.person_id not in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266 and os.voided = 0
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
                                                
                                                )
			
                            -- DEAD
                        and active_clients.person_id not in (
                                    select person_id 
                                    from person 
                                    where death_date <= cast('#endDate#' as date)
                                    and dead = 1
                                )
						and active_clients.person_id not in (
									-- Visitors
								select o.person_id
								from obs o
								inner join
										(
										select oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
										from obs oss
										where oss.concept_id = 3753 
										and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
										)latest
									on latest.person_id = o.person_id
									where concept_id = 5416
									and o.value_coded =1 and o.voided=0
									and  cast(o.obs_datetime as date) = cast(max_observation as date)
						 )
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters
order by TwentyEightDayDefaulters.patientName)
)as all_patients

left outer join

(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.obs_id)), 20) AS observation_id, o.value_numeric as CD4, obs_datetime, DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
from obs o 
	where o.concept_id = 1187 and o.voided = 0  
    and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
    group by o.person_id
)as cd4
on all_patients.Id = cd4.person_id

) AS TXCURR_DETAILS

GROUP BY TXCURR_DETAILS.age_group
ORDER BY TXCURR_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(CD4 < 200, 1, 0))) AS CD4_less_200
        , IF(Totals.Id IS NULL, 0, SUM(IF(CD4 >= 200 and CD4 < 350, 1, 0))) AS CD4_200_to_349
        , IF(Totals.Id IS NULL, 0, SUM(IF(CD4 >= 350 and CD4 <= 500, 1, 0))) AS CD4_350_to_500
        , IF(Totals.Id IS NULL, 0, SUM(IF(CD4 > 500, 1, 0))) AS CD4_greater_500
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Tx_Curr'
		, 99 AS 'sort_order'
		
FROM

		(Select Id, Patient_Identifier, Patient_Name,age_group, Program_Status, CD4, sort_order
FROM(
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Initiated' AS 'Program_Status', sort_order
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 

						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.patientName)-- AS Tx_New

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Tx_Curr' AS 'Program_Status', sort_order
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

									  
                from obs o
					
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id-- , active_clients.latest_follow_up
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
								where active_clients.latest_follow_up >= cast('#endDate#' as date)
			
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
							)

		and active_clients.person_id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)			
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1
						 )
		and active_clients.person_id not in (
									-- Visitors
								select o.person_id
								from obs o
								inner join
										(
										select oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
										from obs oss
										where oss.concept_id = 3753 
										and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
										)latest
									on latest.person_id = o.person_id
									where concept_id = 5416
									and o.value_coded =1 and o.voided=0
									and  cast(o.obs_datetime as date) = cast(max_observation as date)
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Seen_Previous_ART_Clients
ORDER BY Seen_Previous_ART_Clients.patientName)

UNION

-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Missed' AS 'Program_Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

						
                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (

						  -- Latest followup date from the lastest followup form, exclude voided followup date
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
				
				
		                and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                and active_clients.person_id not in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266 and os.voided = 0
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
                                                
                                                )
			
                            -- DEAD
                        and active_clients.person_id not in (
                                    select person_id 
                                    from person 
                                    where death_date <= cast('#endDate#' as date)
                                    and dead = 1
                                )
						and active_clients.person_id not in (
									-- Visitors
								select o.person_id
								from obs o
								inner join
										(
										select oss.person_id, MAX(oss.obs_datetime) as max_observation,
										SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
										from obs oss
										where oss.concept_id = 3753 
										and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
										group by oss.person_id
										)latest
									on latest.person_id = o.person_id
									where concept_id = 5416
									and o.value_coded =1 and o.voided=0
									and  cast(o.obs_datetime as date) = cast(max_observation as date)
						 )
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters
order by TwentyEightDayDefaulters.patientName)
)as all_patients

left outer join

(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.obs_id)), 20) AS observation_id, o.value_numeric as CD4, obs_datetime, DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
from obs o 
	where o.concept_id = 1187 and o.voided = 0  
    and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
    group by o.person_id
)as cd4
on all_patients.Id = cd4.person_id
  ) AS Totals
 )
) AS Total_Aggregated_TxCurr
ORDER BY Total_Aggregated_TxCurr.sort_order