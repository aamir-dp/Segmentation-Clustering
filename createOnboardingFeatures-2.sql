CREATE OR REPLACE TABLE `templix-d8130.dataset.onboarding_features` AS
WITH flattened_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    param.key AS param_key,
    param.value.string_value AS param_value
  FROM
    `templix-d8130.analytics_427374738.events_*`,
    UNNEST(event_params) AS param
),

onboarding_steps AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'intro_1' THEN 1 ELSE 0 END) AS intro_1_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'intro_2' THEN 1 ELSE 0 END) AS intro_2_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'intro_3' THEN 1 ELSE 0 END) AS intro_3_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'question_1' THEN 1 ELSE 0 END) AS question_1_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'question_2' THEN 1 ELSE 0 END) AS question_2_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'after_question_video' THEN 1 ELSE 0 END) AS after_question_video_completed,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'onboarding_paywall' THEN 1 ELSE 0 END) AS onboarding_paywall_reached
  FROM flattened_events
  GROUP BY user_pseudo_id
),

paywall_interaction AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'onbaording_purchase' AND param_key = 'status' AND param_value = 'paid' THEN 1 ELSE 0 END) AS onboarding_paywall_paid,
    MAX(CASE WHEN event_name = 'paywall_weekly_offer' AND param_key = 'status' AND param_value = 'paid' THEN 1 ELSE 0 END) AS weekly_paywall_paid,
    MAX(CASE WHEN event_name = 'paywall_long' AND param_key = 'status' AND param_value = 'paid' THEN 1 ELSE 0 END) AS long_paywall_paid
  FROM flattened_events
  GROUP BY user_pseudo_id
),

user_category AS (
  SELECT
    user_pseudo_id,
    ARRAY_AGG(DISTINCT CASE 
                WHEN param_value = '🏄 Personal Use' THEN 1
                WHEN param_value = '🏦 Business Owner' THEN 2
                WHEN param_value = '👨‍🎨 Creator' THEN 3
                WHEN param_value = '👨‍💻 Marketing Professional' THEN 4
                WHEN param_value = '🕵 Other' THEN 5
              END IGNORE NULLS) AS categories_selected_ids, -- Ignore NULLs explicitly
    COUNT(DISTINCT CASE 
                     WHEN param_value IN ('🏄 Personal Use', 
                                          '🏦 Business Owner', 
                                          '👨‍🎨 Creator', 
                                          '👨‍💻 Marketing Professional', 
                                          '🕵 Other') 
                     THEN param_value 
                   END) AS num_categories_selected
  FROM flattened_events
  WHERE event_name = 'onboarding_interest'
    AND param_key = 'user_category'
    AND param_value IS NOT NULL
    AND param_value != 'Skipped' -- Exclude Skipped
  GROUP BY user_pseudo_id
),

final_engagement AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'view_screen' AND param_key = 'screen_name' AND param_value = 'dashboard' THEN 1 ELSE 0 END) AS reached_dashboard
  FROM flattened_events
  GROUP BY user_pseudo_id
)

SELECT
  a.user_pseudo_id,
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
  categories_selected_ids, -- IDs for selected categories
  num_categories_selected, -- Total number of distinct categories selected
  reached_dashboard
FROM onboarding_steps a
LEFT JOIN paywall_interaction b
  ON a.user_pseudo_id = b.user_pseudo_id
LEFT JOIN user_category c
  ON a.user_pseudo_id = c.user_pseudo_id
LEFT JOIN final_engagement d
  ON a.user_pseudo_id = d.user_pseudo_id;
