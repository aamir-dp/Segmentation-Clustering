SELECT *
FROM ML.PREDICT(MODEL `templix-d8130.dataset.onboarding_clusters`,
    (SELECT * FROM `templix-d8130.dataset.onboarding_features`))
LIMIT 100;
