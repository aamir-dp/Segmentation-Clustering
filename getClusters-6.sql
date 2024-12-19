SELECT
  user_pseudo_id,
  CENTROID_ID AS predicted_cluster  -- Use CENTROID_ID as the predicted cluster
FROM
  ML.PREDICT(MODEL `templix-d8130.dataset.onboarding_clusters`,
    (SELECT * FROM `templix-d8130.dataset.onboarding_features`));
