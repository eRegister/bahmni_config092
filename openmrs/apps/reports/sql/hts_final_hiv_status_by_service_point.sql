
SELECT DISTINCT
    pd.identifier AS Patient_Identifier,
    CONCAT(pn.given_name, ' ', pn.family_name) AS Patient_Name,
    FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) AS Age,
    p.gender AS Sex,
    CASE
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 1 AND 4 THEN '1-4yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 5 AND 9 THEN '5-9yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 10 AND 14 THEN '10-14yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 15 AND 19 THEN '15-19yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 20 AND 24 THEN '20-24yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 25 AND 29 THEN '25-29yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 30 AND 34 THEN '30-34yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 35 AND 39 THEN '35-39yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 40 AND 44 THEN '40-44yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) BETWEEN 45 AND 49 THEN '45-49yrs'
        WHEN FLOOR(DATEDIFF('#endDate#', p.birthdate) / 365) >= 50 THEN '50+yrs'
        ELSE 'Unknown'
        END AS age_group,
    CASE
        WHEN repeater.value_coded = 4227 THEN 'PITC'
        WHEN repeater.value_coded = 4226 THEN 'CITC'
        WHEN repeater.value_coded = 4237 THEN 'HIVST'
        ELSE 'Unknown'
        END AS HIV_Testing_Initiation,
    CASE
        WHEN history.value_coded = 2147 THEN 'New'
        WHEN history.value_coded = 2146 THEN 'Repeat'
        ELSE 'New'
        END AS Testing_History,
    CASE
        WHEN outcome.value_coded = 1738 THEN 'Positive'
        WHEN outcome.value_coded = 1016 THEN 'Negative'
        WHEN outcome.value_coded = 4220 THEN 'Inconclusive'
        ELSE 'Unknown'
        END AS HIV_Status,
    location.name AS Location_Name,
    CASE
        WHEN modeOfEntry.value_coded = 4234 THEN 'Antiretroviral'
        WHEN modeOfEntry.value_coded = 4233 THEN 'Anti Natal Care'
        WHEN modeOfEntry.value_coded = 2191 THEN 'Outpatient'
        WHEN modeOfEntry.value_coded = 2190 THEN 'Tuberculosis Entry Point'
        WHEN modeOfEntry.value_coded = 4235 THEN 'VMMC'
        WHEN modeOfEntry.value_coded = 4236 THEN 'Adolescent'
        WHEN modeOfEntry.value_coded = 2192 THEN 'Inpatient'
        WHEN modeOfEntry.value_coded = 3632 THEN 'PEP'
        WHEN modeOfEntry.value_coded = 2139 THEN 'STI'
        WHEN modeOfEntry.value_coded = 4788 THEN 'PEADS'
        WHEN modeOfEntry.value_coded = 4789 THEN 'Malnutrition'
        WHEN modeOfEntry.value_coded = 4790 THEN 'Subsequent ANC'
        WHEN modeOfEntry.value_coded = 4791 THEN 'Emergency ward'
        WHEN modeOfEntry.value_coded = 4792 THEN 'Index Testing'
        WHEN modeOfEntry.value_coded = 4796 THEN 'Other Cummunity'
        WHEN modeOfEntry.value_coded = 4237 THEN 'Self Testing'
        WHEN modeOfEntry.value_coded = 4963 THEN 'PNC'
        WHEN modeOfEntry.value_coded = 4816 THEN 'PrEP'
        WHEN modeOfEntry.value_coded = 2143 THEN 'Other'
        ELSE 'Unknown'
        END AS Mode_Of_Entry

FROM obs repeater
         INNER JOIN person p ON p.person_id = repeater.person_id AND p.voided = 0
         INNER JOIN person_name pn ON pn.person_id = p.person_id AND pn.preferred = 1
         INNER JOIN patient_identifier pd ON pd.patient_id = p.person_id AND pd.preferred = 1 AND pd.identifier_type = 3
         INNER JOIN location ON location.location_id = repeater.location_id AND location.retired = 0
         LEFT JOIN obs history ON history.encounter_id = repeater.encounter_id AND history.concept_id = 2137 AND history.voided = 0
         LEFT JOIN obs outcome ON outcome.encounter_id = repeater.encounter_id AND outcome.concept_id = 2165 AND outcome.voided = 0
         LEFT JOIN (
    SELECT person_id, MAX(obs_datetime) AS max_obs_datetime
    FROM obs
    WHERE concept_id = 4238 AND voided = 0
    GROUP BY person_id
) latestEntry ON latestEntry.person_id = repeater.person_id
         LEFT JOIN obs modeOfEntry ON modeOfEntry.person_id = latestEntry.person_id
    AND modeOfEntry.obs_datetime = latestEntry.max_obs_datetime
    AND modeOfEntry.concept_id = 4238
    AND modeOfEntry.voided = 0

WHERE repeater.concept_id = 4228
  AND DATE(repeater.obs_datetime) BETWEEN '#startDate#' AND '#endDate#'
  AND repeater.voided = 0

ORDER BY Patient_Name;
