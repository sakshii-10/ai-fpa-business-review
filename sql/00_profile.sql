-- 1. Overview
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT Invoice) AS invoices,
       COUNT(DISTINCT Country) AS countries,
       MIN(InvoiceDate) AS first_date,
       MAX(InvoiceDate) AS last_date
FROM raw.transactions;

-- 2. Rows and revenue per month
SELECT date_trunc('month', InvoiceDate) AS month,
       COUNT(*) AS row_count,
       ROUND(SUM(Quantity * Price)) AS revenue
FROM raw.transactions
GROUP BY 1 ORDER BY 1;

-- 3. Missing Customer ID
SELECT COUNT(*) FILTER (WHERE "Customer ID" IS NULL) AS null_customer_rows,
       ROUND(100.0 * COUNT(*) FILTER (WHERE "Customer ID" IS NULL) / COUNT(*), 1) AS pct_of_rows
FROM raw.transactions;

-- 4. Cancellations
SELECT COUNT(*) FILTER (WHERE Invoice LIKE 'C%') AS cancellation_rows,
       COUNT(*) FILTER (WHERE Quantity < 0) AS negative_qty_rows,
       COUNT(*) FILTER (WHERE Quantity < 0 AND Invoice NOT LIKE 'C%') AS negative_qty_not_cancellation,
       ROUND(SUM(Quantity * Price) FILTER (WHERE Invoice LIKE 'C%')) AS cancellation_value
FROM raw.transactions;

-- 5. Non-product stock codes (anything not starting with 5 digits)
SELECT StockCode,
       COUNT(*) AS row_count,
       ROUND(SUM(Quantity * Price)) AS value
FROM raw.transactions
WHERE NOT regexp_matches(StockCode, '^[0-9]{5}')
GROUP BY 1 ORDER BY 2 DESC LIMIT 25;

-- 6. Price and quantity oddities
SELECT COUNT(*) FILTER (WHERE Price < 0) AS negative_price,
       COUNT(*) FILTER (WHERE Price = 0) AS zero_price,
       MAX(Quantity) AS max_qty,
       MIN(Quantity) AS min_qty,
       MAX(Price) AS max_price
FROM raw.transactions;

-- 7. Rows and revenue per country
SELECT Country,
       COUNT(*) AS row_count,
       ROUND(SUM(Quantity * Price)) AS revenue
FROM raw.transactions
GROUP BY 1 ORDER BY 3 DESC;

-- 8. Extra duplicate rows (the number we will actually drop)
SELECT SUM(n - 1) AS extra_duplicate_rows
FROM (
    SELECT COUNT(*) AS n
    FROM raw.transactions
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country
    HAVING COUNT(*) > 1
);

-- 9. Which months do the duplicate groups fall in?
SELECT date_trunc('month', InvoiceDate) AS month, COUNT(*) AS duplicate_groups
FROM (
    SELECT InvoiceDate
    FROM raw.transactions
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country
    HAVING COUNT(*) > 1
)
GROUP BY 1 ORDER BY 1;

-- 10. Negative quantity but not a cancellation: what are these rows?
SELECT Description, COUNT(*) AS row_count, MIN(Price) AS min_price, MAX(Price) AS max_price
FROM raw.transactions
WHERE Quantity < 0 AND Invoice NOT LIKE 'C%'
GROUP BY 1 ORDER BY 2 DESC LIMIT 10;