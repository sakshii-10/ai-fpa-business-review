# Methodology

## Cleaning rules (raw.transactions → clean.sales)

Each raw row is assigned to the first rule that applies. Raw revenue = kept + removed (reconciled).

| # | Rule | Rows removed | Revenue removed |
|---|---|---|---|
| 1 | Exact duplicate rows (keep one copy) | 34,335 | £431,717 |
| 2 | Non-product stock codes (anything not starting with 5 digits: POST, DOT, M, AMAZONFEE, B, BANK CHARGES, etc.) | 5,980 | -£70,732 |
| 3 | Price ≤ 0 (includes zero-price stock write-offs) | 5,928 | £0 |

Kept deliberately: cancellations (negative revenue, real returns) and rows with no Customer ID (not needed for the P&L).

Reconciliation: raw £19,287,250.57 = kept £18,926,266.18 + removed £360,984.39.

Note: the Dec 2010 duplicate spike (22,358 duplicate groups vs ~200-500 in other months) comes from the overlap between the two source sheets. Cleaning reduces Dec 2010 revenue from £1.13m to £0.76m.