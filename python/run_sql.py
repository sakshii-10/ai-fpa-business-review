import sys
import duckdb
import pandas as pd

pd.set_option("display.width", 200)
pd.set_option("display.max_rows", 60)
pd.set_option("display.max_columns", 20)

sql = open(sys.argv[1], encoding="utf-8").read()
con = duckdb.connect("fpa.duckdb")   # read/write

for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
    print("\n" + stmt.splitlines()[0])   # prints the first line (the -- label)
    res = con.execute(stmt)
    if res.description:
        print(res.df().to_string(index=False))