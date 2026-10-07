import duckdb
import pandas as pd

# 1. Read the CSV. Invoice and StockCode must stay as text (they contain letters)
df = pd.read_csv(
    "data/raw/online_retail_II.csv",
    encoding="latin-1",
    dtype={"Invoice": str, "StockCode": str},
    parse_dates=["InvoiceDate"],
)

# 2. Load it into DuckDB exactly as it came, with no cleaning yet
con = duckdb.connect("fpa.duckdb")
con.execute("CREATE SCHEMA IF NOT EXISTS raw")
con.execute("CREATE OR REPLACE TABLE raw.transactions AS SELECT * FROM df")

# 3. Quick sanity checks
print("Rows loaded:", con.execute("SELECT COUNT(*) FROM raw.transactions").fetchone()[0])
print("Date range:", con.execute(
    "SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM raw.transactions").fetchone())
print("Exact duplicate rows:", con.execute("""
    SELECT COUNT(*) FROM (
        SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country, COUNT(*) AS n
        FROM raw.transactions
        GROUP BY ALL
        HAVING COUNT(*) > 1
    )""").fetchone()[0])

con.close()