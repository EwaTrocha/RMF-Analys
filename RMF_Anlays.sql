WITH LatestCountry AS (
  SELECT
    CustomerID,
    MAX(InvoiceDate) AS latest_country_date,
    FIRST_VALUE(Country) OVER (PARTITION BY CustomerID ORDER BY InvoiceDate DESC) AS latest_country
  FROM `tc-da-1.turing_data_analytics.rfm` 
  WHERE CustomerID IS NOT NULL
    AND DATE_TRUNC(InvoiceDate, DAY) <= '2011-12-01'
  GROUP BY CustomerID,Country,InvoiceDate
),

table_1 AS (
SELECT
  main_table.CustomerID,
  LatestCountry.latest_country AS country,
  MAX(DATE_TRUNC(InvoiceDate, DAY)) AS last_purchase_date,
  COUNT(DISTINCT InvoiceNo) AS frequency,
  SUM(Quantity * UnitPrice) AS monetary
FROM `tc-da-1.turing_data_analytics.rfm` AS main_table
JOIN LatestCountry 
  ON main_table.CustomerID = LatestCountry.CustomerID
    AND main_table.InvoiceDate = LatestCountry.latest_country_date
WHERE main_table.CustomerID IS NOT NULL
  AND DATE_TRUNC(main_table.InvoiceDate, DAY) <= '2011-12-01'
  AND main_table.Quantity > 0
  AND main_table.UnitPrice > 0
GROUP BY main_table.CustomerID, LatestCountry.latest_country
),

table_2 AS (
  SELECT *,
    DATE_DIFF(referance_date, last_purchase_date, DAY) AS recency
  FROM(
    SELECT *,
      MAX(last_purchase_date) OVER () AS referance_date
    FROM table_1)
),

table_3 AS (
  SELECT
    a.*
    EXCEPT(last_purchase_date,referance_date),
  --percentiles for Recency
    b.percentiles[offset(25)] AS r25, 
    b.percentiles[offset(50)] AS r50,
    b.percentiles[offset(75)] AS r75,
  --percentiles for Frequency
    c.percentiles[offset(25)] AS f25, 
    c.percentiles[offset(50)] AS f50,
    c.percentiles[offset(75)] AS f75, 
  --percentiles for Monetary
    d.percentiles[offset(25)] AS m25, 
    d.percentiles[offset(50)] AS m50,
    d.percentiles[offset(75)] AS m75

  FROM
    table_2 AS a,
    (SELECT 
      APPROX_QUANTILES(recency, 100) AS percentiles
    FROM table_2) AS b,
    (SELECT 
      APPROX_QUANTILES(frequency, 100) AS percentiles
    FROM table_2) AS c,
    (SELECT 
      APPROX_QUANTILES(monetary, 100) AS percentiles
    FROM table_2) AS d
),

table_4 AS (
  SELECT *,
    CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm_score
  FROM(
    SELECT *,
      CASE WHEN recency <=r25 THEN 4
          WHEN recency <= r50 AND recency > r25 THEN 3
          WHEN recency <= r75 AND recency > r50 THEN 2
          WHEN recency > r75 THEN 1
      END AS r_score,

      CASE WHEN frequency <= f25 THEN 1
          WHEN frequency <= f50 AND frequency > f25 THEN 2
          WHEN frequency <= f75 AND frequency > f50 THEN 3
          WHEN frequency > f75 THEN 4
      END AS f_score,

      CASE WHEN monetary <= m25 THEN 1
          WHEN monetary <= m50 AND monetary > m25 THEN 2
          WHEN monetary <= m75 AND monetary > m50 THEN 3
          WHEN monetary > m75 THEN 4

      END AS m_score

    FROM table_3)
),

table_5 AS (
SELECT *,
  CASE WHEN (r_score = 4 AND f_score = 4 AND m_score = 4) 
       THEN 'Champions'

       WHEN (r_score = 4 AND f_score >= 3  AND m_score >= 1) 
       THEN 'Loyal Customers'

       WHEN (r_score >= 3 AND f_score >= 3  AND m_score >= 1) 
       THEN 'Potential Loyalist'

       WHEN (r_score >= 3 AND f_score = 1  AND m_score >= 1) 
       THEN 'Recent Customers'

       WHEN (r_score >= 3 AND f_score = 2  AND m_score >= 1) 
       THEN 'Promising'

       WHEN (r_score = 2 AND f_score >= 1  AND m_score >= 1) 
       THEN 'Customers Needing Attention'

       WHEN (r_score = 1 AND f_score >= 1  AND m_score >= 1) 
       THEN 'Lost'

  END AS rfm_segment

FROM table_4
)

SELECT 
  CustomerID,
  country,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  rfm_segment

FROM table_5;
