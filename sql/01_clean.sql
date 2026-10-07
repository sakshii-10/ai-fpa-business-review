-- Clean schema
CREATE SCHEMA IF NOT EXISTS clean;

-- Classify every raw row by the first rule that removes it
CREATE OR REPLACE TABLE clean.classified AS
WITH ranked AS (
    SELECT *,
           Quantity * Price AS revenue,
           row_number() OVER (
               PARTITION BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country
           ) AS rn
    FROM raw.transactions
)
SELECT *,
       CASE
           WHEN rn > 1 THEN '1_duplicate'
           WHEN NOT regexp_matches(StockCode, '^[0-9]{5}') THEN '2_non_product_code'
           WHEN Price <= 0 THEN '3_price_zero_or_negative'
           ELSE 'kept'
       END AS reason
FROM ranked;

-- The clean sales table
CREATE OR REPLACE TABLE clean.sales AS
SELECT Invoice,
       StockCode,
       Description,
       Quantity,
       InvoiceDate,
       Price,
       "Customer ID" AS CustomerID,
       Country,
       revenue,
       date_trunc('month', InvoiceDate) AS month,
       Invoice LIKE 'C%' AS is_cancellation
FROM clean.classified
WHERE reason = 'kept';

-- Removal log: rows and revenue removed by each rule
SELECT reason, COUNT(*) AS row_count, ROUND(SUM(revenue), 2) AS revenue
FROM clean.classified
GROUP BY reason ORDER BY reason;

-- Reconciliation: kept + removed must equal raw
SELECT (SELECT ROUND(SUM(Quantity * Price), 2) FROM raw.transactions) AS raw_revenue,
       (SELECT ROUND(SUM(revenue), 2) FROM clean.classified) AS classified_revenue,
       (SELECT ROUND(SUM(revenue), 2) FROM clean.sales) AS clean_revenue,
       (SELECT ROUND(SUM(revenue), 2) FROM clean.classified WHERE reason <> 'kept') AS removed_revenue,
       (SELECT COUNT(*) FROM raw.transactions) AS raw_rows,
       (SELECT COUNT(*) FROM clean.sales) AS clean_rows;

-- Monthly revenue after cleaning (compare Dec 2010 with the raw figure)
SELECT month, COUNT(*) AS row_count, ROUND(SUM(revenue)) AS revenue
FROM clean.sales
GROUP BY 1 ORDER BY 1;

-- Sample of 15 clean rows
SELECT Invoice, StockCode, Description, Quantity, Price, Country, revenue
FROM clean.sales
USING SAMPLE 15 ROWS;