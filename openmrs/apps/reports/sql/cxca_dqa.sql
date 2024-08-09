
SELECT distinct patientIdentifier AS "Patient Identifier"
        ,patientName AS "Patient Name"
        ,Age
        ,Parity
        ,Previous_Screening
        ,Previous_Management_and_Treatment
        ,Previous_Screening_Results
        ,HIV_Status
        ,HTS_Offered
        ,HIV_Test_Results
        ,Screening_Type
        ,VIA_Results
        ,Pap_Smear_Results
        ,HPV_Results
        ,Breast_Examination
        ,Management_and_Treatment
        ,Next_Visit
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group
									  

                from obs o
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0 and o.concept_id = 4511 -- Cervical Cancer Screening Register
                          AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
				          AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)		 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, o.value_numeric as Parity
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Para
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 1719
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Para
on Para.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, cast(o.value_datetime as date) as Previous_Screening
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_date
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4514
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Screen_date
on Screen_date.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Management and Treatment
                    when o.value_coded = 6073 then "Thermo Coagulation"
                    when o.value_coded = 4533 then "Cryotherapy"
                    when o.value_coded = 4794 then "Colposcopy"
                    when o.value_coded = 4534 then "LLTEZ"
                    when o.value_coded = 4795 then "Conisation"
                    when o.value_coded = 6075 then "Reffered for Treatment"
                    else ""
                end AS Previous_Management_and_Treatment
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as observation
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#startDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4535
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Prev_Management
on Prev_Management.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Screening Results
                    when o.value_coded = 1738 then "Positive"
                    when o.value_coded = 1016 then "Negative"
                    else ""
                end AS Previous_Screening_Results
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_results
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4515
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Screen_results
on Screen_results.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- HIV Results
                    when o.value_coded = 1738 then "Positive"
                    when o.value_coded = 1016 then "Negative"
                    when o.value_coded = 1739 then "Unknown"
                    else ""
                end AS HIV_Status
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Hiv_status
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4521
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) HIV_results
on HIV_results.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- HTS Offered
                    when o.value_coded = 2146 then "Yes"
                    when o.value_coded = 2147 then "No"
                    else ""
                end AS HTS_Offered
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Hiv_offered
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4522
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Hiv_offered
on Hiv_offered.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Screening Results
                    when o.value_coded = 1738 then "Positive"
                    when o.value_coded = 1016 then "Negative"
                    else ""
                end AS HIV_Test_Results
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as test_results
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4523
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) test_results
on test_results.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Screening Type
                    when o.value_coded = 4757 then "Cervical VIA Test"
                    when o.value_coded = 4525 then "Pap Smear"
                    when o.value_coded = 5500 then "VILI Test"
                    when o.value_coded = 6114 then "HPV Test"
                    else ""
                end AS Screening_Type
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screen_type
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4527
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) screen_type
on screen_type.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- VIA Results
                    when o.value_coded = 328 then "VIA +ve"
                    when o.value_coded = 4793 then "VIA +ve suspected cancer"
                    when o.value_coded = 329 then "VIA -ve"
                    else ""
                end AS VIA_Results
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as via_result
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 327
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) via_result
on via_result.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Pap Smear Results
                    when o.value_coded = 324 then "Normal"
                    when o.value_coded = 4748 then "LSIL"
                    when o.value_coded = 4529 then "HSIL"
                    when o.value_coded = 4530 then "ASCUS"
                    when o.value_coded = 4531 then "ASCUS - H AGC AGUS"
                    when o.value_coded = 550 then "	Malignant Cells AIS"
                    else ""
                end AS Pap_Smear_Results
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as smear_result
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4532
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) smear_result
on smear_result.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- HPV Results
                    when o.value_coded = 6116 then "HPV +ve (Type 16)"
                    when o.value_coded = 6117 then "HPV +ve (Type 18)"
                    when o.value_coded = 6118 then "HPV +ve (Type 45)"
                    when o.value_coded = 6119 then "HPV +ve (Other Types)"
                    when o.value_coded = 6120 then "HPV -ve"
                    else ""
                end AS HPV_Results
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as hpv_result
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 6115
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) hpv_result
on hpv_result.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Breast Examination
                    when o.value_coded = 324 then "Normal"
                    when o.value_coded = 4404 then "Abnormal"
                    else ""
                end AS Breast_Examination
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as breast_exam
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4524
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) breast_exam
on breast_exam.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, 
                case
                -- Management and Treatment
                    when o.value_coded = 6073 then "Thermo Coagulation"
                    when o.value_coded = 4533 then "Cryotherapy"
                    when o.value_coded = 4794 then "Colposcopy"
                    when o.value_coded = 4534 then "LLTEZ"
                    when o.value_coded = 4795 then "Conisation"
                    when o.value_coded = 6075 then "Reffered for Treatment"
                    else ""
                end AS Management_and_Treatment
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as observation
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 4535
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) Management
on Management.person_id = Cervical_Cancer_Screened.Id

LEFT OUTER JOIN 
			(
				select distinct
				o.person_id, cast(o.value_datetime as date) as Next_Visit
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as observation
					from obs oss
					where oss.concept_id = 4511 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
                    order by person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 149
				and  cast(o.obs_datetime as date) = cast(max_observation as date)
				and o.voided = 0
			) follow_up
on follow_up.person_id = Cervical_Cancer_Screened.Id

