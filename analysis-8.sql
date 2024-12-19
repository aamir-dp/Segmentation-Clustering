SELECT 
  CENTROID_ID,
  COUNT(*) AS num_users_in_cluster
FROM
  `templix-d8130.dataset.predicted_clusters`
GROUP BY
  CENTROID_ID
ORDER BY
  num_users_in_cluster DESC;
