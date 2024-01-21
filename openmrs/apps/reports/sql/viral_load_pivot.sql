-- updated
SELECT TOTALS_COLS_ROWS.AgeGroup 
		, TOTALS_COLS_ROWS.Received 
		, TOTALS_COLS_ROWS.Pending 	
        , TOTALS_COLS_ROWS.Total

FROM (
 
(SELECT viral_load_clients_DRVD_rows.age_group AS 'AgeGroup'                  
						, IF(viral_load_clients_DRVD_rows.Id IS NULL, 0, SUM(IF(viral_load_clients_DRVD_rows.VL_Results_Status = 'Received' , 1, 0))) AS Received                      
						, IF(viral_load_clients_DRVD_rows.Id IS NULL, 0, SUM(IF(viral_load_clients_DRVD_rows.VL_Results_Status = 'Pending' , 1, 0))) AS Pending						
						, IF(viral_load_clients_DRVD_rows.Id IS NULL, 0,  SUM(1)) as 'Total' 
						, viral_load_clients_DRVD_rows.sort_order
			FROM (  
				

-- CLIENTS WITH DETECTABLE VL
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, "Received" AS 'VL_Results_Status','High VL Routine' as 'Client Enrollment Status', sort_order
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   o.value_numeric AS vl_result,
											   observed_age_group.sort_order AS sort_order

						from obs o

						     INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5494 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
															Select pId
														From
														(
															 Select pId, date_received
																From
																	(
																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5485
																			and oss.voided=0
																			and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
																			group by oss.person_id

																		UNION

																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5489
																			and oss.voided=0
																			and cast(oss.obs_datetime as date)  <= cast('#endDate#' as date)
																			group by oss.person_id

																	) As received_date
																where datediff(cast(date_received as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
														) As Clients_results
								 )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'

								 ) AS VL_CLIENTS
		ORDER BY VL_CLIENTS.Age)  

UNION

(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, "Pending" AS 'VL_Results_Status','High VL Routine' as 'Client Enrollment Status', sort_order
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   o.value_numeric AS vl_result,
											   observed_age_group.sort_order AS sort_order

							from obs o
								
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5494 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0
                                            
                        AND o.person_id not in (
													Select pId
														From
														(
															 Select pId, date_received
																From
																	(
																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5485
																			and oss.voided=0
																			and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
																			group by oss.person_id

																		UNION

																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5489
																			and oss.voided=0
																			and cast(oss.obs_datetime as date)  <= cast('#endDate#' as date)
																			group by oss.person_id

																	) As received_date
																where datediff(cast(date_received as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
														) As Clients_results
                                              
                                            )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS VL_CLIENTS
		ORDER BY VL_CLIENTS.Age)  



) AS viral_load_clients_DRVD_rows

GROUP by viral_load_clients_DRVD_rows.age_group
ORDER BY viral_load_clients_DRVD_rows.sort_order)

UNION ALL

(SELECT 'Total Blood Draws' AS 'AgeGroup'                                  
						, IF(viral_load_clients.Id IS NULL, 0, SUM(IF(viral_load_clients.VL_Results_Status = 'Received' , 1, 0))) AS Received                      
						, IF(viral_load_clients.Id IS NULL, 0, SUM(IF(viral_load_clients.VL_Results_Status = 'Pending' , 1, 0))) AS Pending							
						, IF(viral_load_clients.Id IS NULL, 0,  SUM(1)) as 'Total'  
						, 99 AS sort_order
			FROM (				

-- CLIENTS WITH DETECTABLE VL
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, "Received" AS 'VL_Results_Status','High VL Routine' as 'Client Enrollment Status'
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   o.value_numeric AS vl_result 

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5494 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
															Select pId
														From
														(
															 Select pId, date_received
																From
																	(
																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5485
																			and oss.voided=0
																			and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
																			group by oss.person_id

																		UNION

																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5489
																			and oss.voided=0
																			and cast(oss.obs_datetime as date)  <= cast('#endDate#' as date)
																			group by oss.person_id

																	) As received_date
																where datediff(cast(date_received as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
														) As Clients_results
								 )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'

								) AS viral_load_clients_cols )  

UNION

(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, "Pending" AS 'VL_Results_Status','High VL Routine' as 'Client Enrollment Status'
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   o.value_numeric AS vl_result 

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5494 AND datediff(cast(o.value_datetime as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
                                 AND patient.voided = 0 AND o.voided = 0
                                            
                        AND o.person_id not in (
													Select pId
														From
														(
															 Select pId, date_received
																From
																	(
																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5485
																			and oss.voided=0
																			and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
																			group by oss.person_id

																		UNION

																		select oss.person_id as pId, cast(oss.obs_datetime as date) as date_received
																			from obs oss
																			where oss.concept_id = 5489
																			and oss.voided=0
																			and cast(oss.obs_datetime as date)  <= cast('#endDate#' as date)
																			group by oss.person_id

																	) As received_date
																where datediff(cast(date_received as date), DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))) between 0 and 90
														) As Clients_results
                                              
                                            )
								 
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'

								) AS viral_load_clients_cols ) 
				
        ) AS viral_load_clients
    )

) AS TOTALS_COLS_ROWS

ORDER BY TOTALS_COLS_ROWS.sort_order
