CREATE OR REPLACE MODEL `templix-d8130.dataset.onboarding_clusters`
OPTIONS(model_type='kmeans', num_clusters=4) AS
SELECT
  intro_1_completed,
  intro_2_completed,
  intro_3_completed,
  question_1_completed,
  question_2_completed,
  after_question_video_completed,
  onboarding_paywall_reached,
  onboarding_paywall_paid,
  weekly_paywall_paid,
  long_paywall_paid,
  ARRAY_LENGTH(categories_selected_ids) AS num_categories_selected,
  reached_dashboard
FROM
  `templix-d8130.dataset.onboarding_features`;
