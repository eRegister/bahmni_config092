SELECT 
    pi.identifier AS Patient_Identifier,
    CONCAT(pn.given_name, ' ', pn.family_name) AS Names,
    FLOOR(DATEDIFF(cast('#endDate#' as Date), p.birthdate)/365) AS Age,
    p.gender AS Sex,
    ag.name AS age_group,
    MAX(CASE WHEN o.concept_id = 4228 THEN IF(o.value_coded = 4227, 'PITC', 'CITC') END) AS HIV_Testing_Initiation,
    MAX(CASE WHEN o.concept_id = 4798 THEN IF(o.value_coded = 2146, 'New', 'Repeat') END) AS Testing_History,
    CASE tr.value_coded
        WHEN 1738 THEN 'Positive'
        WHEN 1016 THEN 'Negative'
        WHEN 4220 THEN 'Indeterminate'
        ELSE '' 
    END AS HIV_Status,
    loc.name AS Location,
    MAX(CASE WHEN o.concept_id = 4238 THEN 
        CASE o.value_coded
            WHEN 4234 THEN 'Antiretroviral'
            WHEN 4233 THEN 'Anti Natal Care'
            WHEN 2191 THEN 'Outpatient'
            WHEN 2190 THEN 'Tuberculosis Entry Point'
            WHEN 4235 THEN 'VMMC'
            WHEN 4236 THEN 'Adolescent'
            WHEN 2192 THEN 'Inpatient'
            WHEN 3632 THEN 'PEP'
            WHEN 2139 THEN 'STI'
            WHEN 4788 THEN 'PEADS'
            WHEN 4789 THEN 'Malnutrition'
            WHEN 4790 THEN 'Subsequent ANC'
            WHEN 4791 THEN 'Emergency ward'
            WHEN 4792 THEN 'Index Testing'
            WHEN 4796 THEN 'Other Community'
            WHEN 4237 THEN 'Self Testing'
            WHEN 4963 THEN 'PNC'
            WHEN 4816 THEN 'PrEP'
            WHEN 2143 THEN 'Other'
            ELSE '' END END) AS Mode_of_Entry
FROM patient_identifier pi
JOIN person_name pn ON pn.person_id = pi.patient_id
JOIN person p ON p.person_id = pi.patient_id
JOIN obs tr 
     ON tr.person_id = pi.patient_id
    AND tr.concept_id = 2165
    AND tr.obs_datetime BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
JOIN location loc ON loc.location_id = tr.location_id AND loc.retired = 0
JOIN obs o ON o.person_id = pi.patient_id
           AND o.obs_datetime BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
JOIN reporting_age_group ag 
  ON cast('#endDate#' as Date) BETWEEN DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.min_years YEAR), INTERVAL ag.min_days DAY)
                   AND DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.max_years YEAR), INTERVAL ag.max_days DAY)
                 AND ag.report_group_name = 'Modified_Ages'
WHERE pi.identifier_type = 3 
  AND pi.preferred = 1 
  AND pi.voided = 0
GROUP BY 
    pi.identifier, Names, Age, Sex, ag.name, loc.name, HIV_Status
ORDER BY HIV_Status, Age;
