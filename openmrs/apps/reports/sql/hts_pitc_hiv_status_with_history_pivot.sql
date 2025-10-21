-- Aggregated data by AgeGroup and Sex
SELECT
    ag.name AS AgeGroup,
    p.gender AS Sex,
    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Indeterminate,
    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Indeterminate,
    COUNT(DISTINCT pi.identifier) AS Total
FROM patient_identifier pi
JOIN person_name pn ON pn.person_id = pi.patient_id
JOIN person p ON p.person_id = pi.patient_id
JOIN obs tr 
     ON tr.person_id = pi.patient_id
    AND tr.concept_id = 2165
    AND cast(tr.obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
JOIN location loc ON loc.location_id = tr.location_id AND loc.retired = 0
JOIN (
    SELECT person_id, IF(value_coded = 2146, 'New', 'Repeat') AS Testing_History
    FROM obs
    WHERE concept_id = 4798
      AND cast(obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
) th ON th.person_id = pi.patient_id
JOIN (
    SELECT person_id
    FROM obs
    WHERE concept_id = 4228
      AND value_coded = 4227 -- PITC clients only
      AND cast(obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
) pitc ON pitc.person_id = pi.patient_id
JOIN reporting_age_group ag 
  ON cast('#endDate#' as Date) BETWEEN DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.min_years YEAR), INTERVAL ag.min_days DAY)
                   AND DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.max_years YEAR), INTERVAL ag.max_days DAY)
                 AND ag.report_group_name = 'Modified_Ages'
WHERE pi.identifier_type = 3
  AND pi.preferred = 1
  AND pi.voided = 0
GROUP BY ag.name, p.gender

UNION ALL

-- Grand total row
SELECT
    'Total' AS AgeGroup,
    'All' AS Sex,
    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Indeterminate,
    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Indeterminate,
    COUNT(DISTINCT pi.identifier) AS Total
FROM patient_identifier pi
JOIN obs tr 
     ON tr.person_id = pi.patient_id
    AND tr.concept_id = 2165
    AND cast(tr.obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
JOIN (
    SELECT person_id, IF(value_coded = 2146, 'New', 'Repeat') AS Testing_History
    FROM obs
    WHERE concept_id = 4798
      AND cast(obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
) th ON th.person_id = pi.patient_id
JOIN (
    SELECT person_id
    FROM obs
    WHERE concept_id = 4228
      AND value_coded = 4227 -- PITC Clients only
      AND cast(obs_datetime as date) BETWEEN cast('#startDate#' as Date) AND cast('#endDate#' as Date)
) pitc ON pitc.person_id = pi.patient_id
WHERE pi.identifier_type = 3
  AND pi.preferred = 1
  AND pi.voided = 0
ORDER BY AgeGroup, Sex;
