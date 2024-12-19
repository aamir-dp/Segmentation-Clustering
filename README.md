
# Segmentation & Cluestering using k-means

This documentation provides a detailed explanation of the SQL code for creating and analyzing onboarding features and clusters. The code is implemented in Google BigQuery and includes steps for schema creation, data transformation, clustering, and evaluation.

## Table of Contents

1. [Schema Creation](#1-schema-creation)
2. [Data Transformation](#2-data-transformation)
   - [Flattened Events](#flattened-events)
   - [Onboarding Steps](#onboarding-steps)
   - [Paywall Interaction](#paywall-interaction)
   - [User Category](#user-category)
   - [Final Engagement](#final-engagement)
3. [Feature Table Creation](#3-feature-table-creation)
4. [Clustering Model](#4-clustering-model)
5. [Model Evaluation](#5-model-evaluation)
6. [Cluster Prediction](#6-cluster-prediction)
7. [Cluster Analysis](#7-cluster-analysis)

---

## 1. Schema Creation

```sql
CREATE SCHEMA `project_name.dataset_name`
OPTIONS(
  location = 'US'
);
```

Creates a new schema (dataset) in BigQuery with a specified location.

---

## 2. Data Transformation

### Flattened Events

```sql
WITH flattened_events AS (
  SELECT
    user_pseudo_id,
    event_name,
    param.key AS param_key,
    param.value.string_value AS param_value
  FROM
    `project_name.analytics_dataset.events_*`,
    UNNEST(event_params) AS param
)
```

- Extracts and normalizes event data by unnesting event parameters.

### Onboarding Steps

```sql
onboarding_steps AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'onboarding_screen' AND param_key = 'screen_name' AND param_value = 'intro_1' THEN 1 ELSE 0 END) AS intro_1_completed,
    ...
  FROM flattened_events
  GROUP BY user_pseudo_id
)
```

- Tracks user progress through various onboarding screens.

### Paywall Interaction

```sql
paywall_interaction AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'onboarding_purchase' AND param_key = 'status' AND param_value = 'paid' THEN 1 ELSE 0 END) AS onboarding_paywall_paid,
    ...
  FROM flattened_events
  GROUP BY user_pseudo_id
)
```

- Captures paywall interactions and purchase status.

### User Category

```sql
user_category AS (
  SELECT
    user_pseudo_id,
    ARRAY_AGG(DISTINCT CASE 
                WHEN param_value = 'Personal Use' THEN 1
                ...
              END IGNORE NULLS) AS categories_selected_ids,
    ...
  FROM flattened_events
  WHERE event_name = 'onboarding_interest'
    AND param_key = 'user_category'
    ...
  GROUP BY user_pseudo_id
)
```

- Identifies user-selected categories and counts distinct selections.

### Final Engagement

```sql
final_engagement AS (
  SELECT
    user_pseudo_id,
    MAX(CASE WHEN event_name = 'view_screen' AND param_key = 'screen_name' AND param_value = 'dashboard' THEN 1 ELSE 0 END) AS reached_dashboard
  FROM flattened_events
  GROUP BY user_pseudo_id
)
```

- Determines if a user has reached the dashboard screen.

---

## 3. Feature Table Creation

```sql
CREATE OR REPLACE TABLE `project_name.dataset_name.onboarding_features` AS
SELECT
  ...
FROM onboarding_steps a
LEFT JOIN paywall_interaction b
  ON a.user_pseudo_id = b.user_pseudo_id
...
```

- Combines all transformed data into a comprehensive feature table.

---

## 4. Clustering Model

```sql
CREATE OR REPLACE MODEL `project_name.dataset_name.onboarding_clusters`
OPTIONS(model_type='kmeans', num_clusters=4) AS
SELECT
  ...
FROM `project_name.dataset_name.onboarding_features`;
```

- Creates a k-means clustering model with 4 clusters based on onboarding features.

---

## 5. Model Evaluation

```sql
SELECT
  *
FROM
  ML.EVALUATE(MODEL `project_name.dataset_name.onboarding_clusters`);
```

- Evaluates the performance of the clustering model.

---

## 6. Cluster Prediction

```sql
SELECT
  user_pseudo_id,
  CENTROID_ID AS predicted_cluster
FROM
  ML.PREDICT(MODEL `project_name.dataset_name.onboarding_clusters`,
    (SELECT * FROM `project_name.dataset_name.onboarding_features`));
```

- Predicts clusters for users based on their onboarding features.

---

## 7. Cluster Analysis

### User Distribution per Cluster

```sql
SELECT 
  CENTROID_ID,
  COUNT(*) AS num_users_in_cluster
FROM
  `project_name.dataset_name.predicted_clusters`
GROUP BY
  CENTROID_ID
ORDER BY
  num_users_in_cluster DESC;
```

- Summarizes the number of users in each cluster.

### Feature Averages per Cluster

```sql
SELECT
  CENTROID_ID,
  AVG(intro_1_completed) AS avg_intro_1_completed,
  ...
FROM
  `project_name.dataset_name.predicted_clusters` p
JOIN
  `project_name.dataset_name.onboarding_features` f
  ON p.user_pseudo_id = f.user_pseudo_id
GROUP BY
  CENTROID_ID
ORDER BY
  CENTROID_ID;
```

- Calculates average feature values for each cluster.

---

## Conclusion

This code provides a complete pipeline for analyzing user onboarding data, including data transformation, clustering, and insights into user behavior.
