CREATE OR REPLACE TABLE `templix-d8130.dataset.predicted_clusters` AS
SELECT
  user_pseudo_id,
  CENTROID_ID  -- Corrected to reference the correct predicted field
FROM
  ML.PREDICT(MODEL `templix-d8130.dataset.onboarding_clusters`,
             (SELECT
                user_pseudo_id,
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
                ARRAY_LENGTH(categories_selected_ids) AS num_categories_selected,  -- Corrected field name
                reached_dashboard
              FROM `templix-d8130.dataset.onboarding_features`));
