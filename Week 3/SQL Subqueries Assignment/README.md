# SQL Subqueries, CTEs & Window Functions — Sample Superstore Analysis

A SQL analytical project on the **Sample Superstore** dataset (9,994 rows, 2014–2017) demonstrating subqueries, Common Table Expressions, and window functions on a normalized relational model. For CEI Internship — Week 3 Assignment.

## Objective

Analyze customer sales behaviour on the Sample Superstore dataset using SQL by applying:

- **Subqueries** -- including correlated subqueries -- to filter and compare data
- **Common Table Expressions (CTEs)** to structure multi-step aggregations
- **Window Functions** (`RANK`, `DENSE_RANK`, `ROW_NUMBER` with `PARTITION BY`) for ranking and per-group analysis
- **JOIN + CTE + Window** combined in a single deliverable query
- **Business questions** answered directly from the analytical model

## Tech Stack

- **Database:** MySQL 8.0+ (window functions and CTEs require 8.0)
- **Client:** MySQL Workbench / mysql CLI
- **Dataset:** Sample Superstore (Tableau public dataset, latin1 encoded)

## Setup & Run

### 1. Prerequisites

- MySQL 8.0 or newer installed and running
- `LOAD DATA LOCAL INFILE` enabled (see step 3)

### 2. Configure the CSV Path

Open `superstore_sales_analysis.sql` and update the `LOAD DATA LOCAL INFILE` path to point to your local copy of the CSV:

```sql
LOAD DATA LOCAL INFILE 'D:\\path\\to\\Sample - Superstore.csv'
```

### 3. Enable LOCAL INFILE (one-time setup)

If you hit `ERROR 3948 (42000): Loading local data is disabled`, enable it on both server and client:

```sql
-- On the server, in MySQL:
SET GLOBAL local_infile = 1;
```

Then start the client with the flag:

```bash
mysql --local-infile=1 -u root -p
```

In MySQL Workbench, alternatively use **Server → Data Import → Import from Self-Contained File** for the raw load, then run the rest of the script.

### 4. Execute the Script

```bash
mysql --local-infile=1 -u root -p < superstore_sales_analysis.sql
```

Or open `superstore_sales_analysis.sql` in MySQL Workbench and execute section by section.

---
## Script Sections

The script is organized into 6 logical sections:

| # | Section                              | What it does                                                                       |
|---|--------------------------------------|------------------------------------------------------------------------------------|
| 1 | Database Setup & Load Dataset        | Creates `sales_analysis` DB, defines `superstore_raw`, loads the CSV               |
| 2 | Creating Normalized Tables           | Splits raw into `customers`, `products`, `orders` (with FKs and indexes)           |
| 3 | Insert Data Using SELECT DISTINCT    | Populates normalized tables; uses `GROUP BY` on products to merge duplicates       |
| 4 | Subqueries, CTEs & Window Functions  | Seven analytical queries covering all three techniques                             |
| 5 | Final Combined Query                 | One query using JOIN + CTE + two `RANK()` windows (overall & per-segment)          |
| 6 | Business Queries                     | Top 5, bottom 5, single-order, above-average, and highest order value per customer |

---

## Key Findings

The analysis surfaced seven headline insights from the 9,994-row dataset.

### 1. Revenue is heavily concentrated (Pareto skew)

Only **294 of 793 customers (~37%)** exceed the per-customer average of $2,897. The top customer (Sean Miller) alone contributes **$25,043** — about 1.1% of total revenue and roughly $5,990 ahead of the runner-up. Retention strategy should weight high-value accounts disproportionately.

### 2. Single transactions can dominate lifetime value

Sean Miller's order `CA-2014-145317` (containing a $22,638 Canon imageCLASS copier) is worth **$23,661** — nearly equal to his entire lifetime spend. One high-ticket Technology purchase can outweigh hundreds of small transactions, so "top customer" rankings are sensitive to individual deals.

### 3. Customer retention is genuinely strong

Only **12 of 793 customers (~1.5%)** placed exactly one order. The Superstore's repeat-purchase rate is its clearest competitive advantage. Notable outlier: Jenna Caffey's single order was worth over $1,000 — worth a targeted follow-up.

### 4. Order-value distribution is right-skewed

**2,360 of 9,994 orders (~23.6%)** exceed the per-order average of $229.86. The mean is pulled upward by a long tail of high-value transactions; the median is materially lower and more representative of typical order behaviour.

### 5. Bottom-tier customers are minimal-spend buyers

All five bottom customers spent **under $25 lifetime** — almost certainly one-time purchasers of small accessories. Candidates for a low-cost win-back email, or accepted as incidental traffic with a low spend ceiling.

### 6. Two-dimensional ranking surfaces hidden leaders

The combined query (overall rank + per-segment rank) shows a customer can rank #5 globally but #1 in their segment. The Consumer segment dominates the absolute leaderboard simply because it has the largest customer base; Corporate and Home Office still produce their own top performers worth dedicated retention programs.

### 7. The top 3 alone account for ~2.5% of revenue

| Rank | Customer       | Total Sales  |
|------|----------------|--------------|
| 1    | Sean Miller    | $25,043.05   |
| 2    | Tamara Chand   | $19,052.22   |
| 3    | Raymond Buch   | $15,117.34   |

Three customers together represent **~$59,200** in lifetime revenue. These are VIP-tier accounts — losing any one would materially dent annual revenue.
