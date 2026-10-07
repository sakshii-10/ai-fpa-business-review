# Data profile: Online Retail II (raw)

- 1,067,371 rows, 53,628 invoices, 43 countries, 2009-12-01 to 2011-12-09 (Dec 2011 partial)
- Revenue: roughly £9.49m in 2010, £8.57m for Jan-Nov 2011
- Missing Customer ID: 243,007 rows (22.8%), kept because the P&L doesn't need customers
- Cancellations: 19,494 rows (invoice starts with C), net -£1.53m, kept as negative revenue
- Non-cancellation negative quantities: 3,457 rows, all price 0 (stock write-offs)
- Non-product stock codes: POST, DOT, M, AMAZONFEE, B, BANK CHARGES, etc., removed
- Price <= 0: 6,207 rows (6,202 zero, 5 negative)
- Exact duplicates: 34,335 extra rows, with a spike in Dec 2010 (22,358 groups) from the sheet overlap
- UK is about 85% of revenue, then EIRE, Netherlands, Germany, France