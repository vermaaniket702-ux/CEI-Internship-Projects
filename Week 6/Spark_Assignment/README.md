# Week 6 — Spark Architecture & Efficient Data Processing

## Objective

Understand Spark architecture and perform efficient data processing using transformations, filtering, schema handling, and optimized file formats. The notebook explains how Spark is organized internally (Driver, Cluster Manager, Executors), how lazy evaluation and the DAG drive execution, and how to read, transform, filter, and write data efficiently using both CSV and Parquet.

## Contents

| File | Description |
|------|-------------|
| `Week6_Spark_Architecture.ipynb` | Main deliverable — a PySpark notebook with code, execution results, and insights. |
| `orders_data.csv` | The dataset used throughout the notebook. |
| `README.md` | This file. |

## Dataset — `orders_data.csv`

A synthetic orders/transactions dataset of about 10,000 rows. 

| Column | Description |
|--------|-------------|
| `order_id` | Unique order identifier. |
| `product_id` | Product identifier. |
| `category` | Product category (Electronics, Furniture, Clothing, etc.). |
| `price` | Unit price; stored with empty values, cast to double in the notebook. |
| `base_price` | Base price, used to compute a taxed `final_price`. |
| `amount` | Order amount, used in filtering conditions. |
| `status` | Order status (Completed, Pending, Cancelled, etc.). |
| `user_id` | Customer identifier; contains nulls that are filtered out. |
| `region` | Order region (North, South, East, West, Central). |
| `priority` | Order priority (High, Medium, Low). |
| `order_date` | Date the order was placed. |
| `quantity` | Quantity ordered. |
| `payment_method` | Payment method used. |
| `old_name` | A column renamed to `new_name` to demonstrate schema changes. |

## Notebook structure

The notebook works through each step of the objective:

1. **Spark architecture (Driver, Cluster Manager, Executors) and execution modes** — the role of each component, plus client vs cluster mode, with a live inspection of the running session.
2. **Lazy evaluation and the DAG / lineage graph** — how transformations are deferred and optimized before execution.
3. **Reading files with proper schema handling** — CSV with header and `inferSchema`, and an explicit `StructType` schema.
4. **Filtering and selecting columns** — selecting specific columns and applying single and multi-condition filters.
5. **Modifying DataFrames** — renaming columns, casting data types, and adding a computed column.
6. **Transformations vs actions** — the difference between deferred transformations and result-triggering actions, with examples.
7. **Wide transformations and performance** — shuffle, fault tolerance through lineage, and predicate pushdown.
8. **CSV vs Parquet** — row-based vs columnar storage and the resulting performance difference.
9. **Handling null values and efficient filtering** — quantifying and removing missing values.
10 and 11. **Building and saving a pipeline** — a complete read → transform → filter → write flow, saved to both Parquet and CSV.
12. **Best practices for large datasets** — using `show()` and `take()` instead of `collect()`.

Each section pairs PySpark code with its execution result and a short takeaway.

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

Place `orders_data.csv` in the location referenced by the notebook (the read path in the notebook points to the dataset), then launch Jupyter:

```bash
jupyter notebook Week6_Spark_Architecture.ipynb
```

Run the cells from top to bottom. Execution results appear directly below each code cell.

### Note for Windows users

On Windows, Spark's native file-writing (`.write`) requires the Hadoop helper files `winutils.exe` and `hadoop.dll`. If you hit a `HADOOP_HOME and hadoop.home.dir are unset` error when writing:

1. Download `winutils.exe` and `hadoop.dll` matching your bundled Hadoop version.
2. Place both in a folder such as `C:\hadoop\bin`.
3. Set `HADOOP_HOME` to `C:\hadoop` and add `C:\hadoop\bin` to `PATH`.
4. Restart the kernel and run from the top.

Reading and `show()` work without this; only writing to disk requires it.

## Brief insights on performance and architecture

- **Spark follows a distributed architecture.** The Driver creates the execution plan and schedules tasks, the Cluster Manager provides resources, and the Executors process data in parallel across the cluster.
- **Lazy evaluation improves efficiency.** Transformations are recorded instead of executed immediately, allowing Spark to optimize the complete execution plan before running it.
- **Lineage provides fault tolerance.** Spark tracks the sequence of transformations, enabling it to recompute only the lost partitions if an executor fails rather than restarting the entire job.
- **Parquet is more efficient than CSV for analytics.** Its columnar storage, built-in schema, compression, and predicate pushdown reduce disk I/O and improve query performance.
- **Shuffles are expensive operations.** Wide transformations such as `groupBy()` and `join()` require data movement across partitions, making them one of the primary factors affecting Spark job performance.
- **Manage driver memory carefully.** Use `show()`, `take()`, or `limit()` to inspect data, and avoid `collect()` on large datasets unless the result is guaranteed to fit in the driver's memory.

## Environment

Developed and run on PySpark 3.5.1 (Hadoop 3.3.4). The notebook runs locally in `local[*]` mode, using all available cores on a single machine.
