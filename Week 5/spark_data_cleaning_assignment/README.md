# Week 5 — Spark Fundamentals: Data Cleaning, Transformation & Aggregation

## Objective

Understand Spark fundamentals and perform data cleaning, transformation, and aggregation using DataFrames. The notebook covers the limitations of MapReduce, the advantages of Spark's in-memory model, DataFrame immutability, and a complete end-to-end data processing pipeline built with PySpark.

## Contents

| File | Description |
|------|-------------|
| `Week5_Spark_Fundamentals.ipynb` | A PySpark notebook with code, query results, and insights. |
| `sales_data.csv` | The dataset used throughout the notebook. |
| `README.md` | This file. |

## Dataset — `sales_data.csv`

A synthetic sales and transaction dataset designed for data cleaning practice. The dataset intentionally includes common data quality issues such as duplicate records, missing (`null`) prices, blank or missing status values, missing email addresses, and empty usernames, providing realistic scenarios for performing data preprocessing and transformation tasks.

| Column | Description |
|--------|-------------|
| `user_id` | Customer identifier; repeats across rows. |
| `transaction_date` | Date of the transaction. |
| `region` | One of West, East, North, South. |
| `product_category` | Electronics, Furniture, Office Supplies, Clothing, Groceries, Toys. |
| `sale_amount` | Transaction value used as the revenue measure. |
| `price` | Unit price; contains empty values (read as a string under `inferSchema`). |
| `status` | Active, Inactive, Pending, or blank. |
| `city` | Several cities have more than 100 records (used for HAVING-style filters). |
| `age` | Customer age. |
| `subscription` | Premium, Basic, Standard, Free. |
| `email` | Some rows are blank. |
| `username` | Some rows are empty strings. |
| `raw_timestamp` | `yyyy-MM-dd HH:mm:ss`; cast to TimestampType in the notebook. |
| `store_id` | Store identifier used for revenue aggregation. |

## Notebook structure

The notebook follows the assignment objective step by step:

1. **Limitations of MapReduce and advantages of Spark** — in-memory processing, DAG execution, speed.
2. **Spark DataFrame concepts and immutability** — session setup, data load, and a demo that `df.drop(...)` returns a new DataFrame.
3. **Data cleaning** — inspecting duplicates and null/empty counts, removing duplicates, casting `price`, and handling null values with `na.fill` / filtering out invalid records.
4. **Filtering conditions** — Premium customers aged 18–30, and Electronics sales from the West region.
5. **Aggregation functions** — count, sum, avg, min, max in a single `.agg()`.
6. **Grouping with `groupBy` + conditions** — average sales per category in the West, and cities with more than 100 records (HAVING).
7. **Wide transformations and shuffle operations** — why `groupBy` triggers a shuffle.
8. **Schema modification** — casting `raw_timestamp` to TimestampType and renaming it to `event_time`.
9. **Handling inconsistent data** — the risk of `inferSchema=true` on messy dates and safe parsing with `to_timestamp()`.
10. **Complete data processing pipeline** — dedupe, fill null prices with 0, and total revenue per `store_id`.
11. **Insights** — a summary of the key lessons (see below).

## How to run

### Prerequisites

- Python 3.8 or newer
- Java 8, 11, 17, or 21 (required by Spark)
- PySpark and Jupyter

### Setup

```bash
pip install pyspark notebook
```

### Run

Place `sales_data.csv` in the same folder as the notebook, then launch Jupyter:

```bash
jupyter notebook Week5_Spark_Fundamentals.ipynb
```

Run all cells from top to bottom. Query results appear as output directly below each code cell.

## Brief insights on data processing & transformations

- **In-memory processing improves performance.** Spark keeps frequently used data in memory, reducing repeated disk access and making iterative workloads such as machine learning and multi-stage pipelines far faster than traditional MapReduce.
- **Immutability shapes how DataFrame operations work.** Every transformation creates a new DataFrame instead of modifying the existing one, so steps must be reassigned or chained. This is what lets Spark optimize execution and recover data through lineage if failures occur.
- **Data cleaning should precede analysis.** Removing duplicate records and handling missing values before aggregations such as `sum` or `avg` produces accurate, meaningful results rather than figures distorted by Spark's default null handling.
- **Shuffle operations are the main cost center.** Wide transformations such as `groupBy` and `join` force Spark to redistribute data across partitions; this shuffle involves network transfer and disk I/O, making it one of the most resource-intensive parts of execution.
- **Explicit data types provide greater reliability.** While `inferSchema` is convenient, it read the `price` column as a string because of empty values, so it had to be cast before null handling. Defining schemas manually or converting columns with functions like `to_timestamp()` using a known format gives more consistent processing and makes invalid values easier to spot.

