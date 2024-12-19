SELECT
  CENTROID_ID,
  AVG(intro_1_completed) AS avg_intro_1_completed,
  AVG(intro_2_completed) AS avg_intro_2_completed,
  AVG(intro_3_completed) AS avg_intro_3_completed,
  AVG(question_1_completed) AS avg_question_1_completed,
  AVG(question_2_completed) AS avg_question_2_completed,
  AVG(after_question_video_completed) AS avg_after_question_video_completed,
  AVG(onboarding_paywall_reached) AS avg_onboarding_paywall_reached,
  AVG(onboarding_paywall_paid) AS avg_onboarding_paywall_paid,
  AVG(weekly_paywall_paid) AS avg_weekly_paywall_paid,
  AVG(long_paywall_paid) AS avg_long_paywall_paid,
  AVG(num_categories_selected) AS avg_num_categories_selected,
  AVG(reached_dashboard) AS avg_reached_dashboard
FROM
  `templix-d8130.dataset.predicted_clusters` p
JOIN
  `templix-d8130.dataset.onboarding_features` f
  ON p.user_pseudo_id = f.user_pseudo_id
GROUP BY
  CENTROID_ID
ORDER BY
  CENTROID_ID;
