-- 1. Very large orders (check the 80,995 pair)
SELECT Invoice, InvoiceDate, StockCode, Description, Quantity, Price, revenue
FROM clean.sales
WHERE abs(Quantity) > 10000
ORDER BY InvoiceDate;

-- 2. Top 60 products by revenue
SELECT StockCode, any_value(Description) AS Description, ROUND(SUM(revenue)) AS revenue
FROM clean.sales
GROUP BY StockCode
ORDER BY 3 DESC
LIMIT 60;

-- 3. Top 60 words in descriptions by revenue
SELECT word, COUNT(DISTINCT StockCode) AS products, ROUND(SUM(revenue)) AS revenue
FROM (
    SELECT StockCode, revenue, unnest(string_split(upper(Description), ' ')) AS word
    FROM clean.sales
)
WHERE length(word) > 2
GROUP BY word
ORDER BY 3 DESC
LIMIT 60;