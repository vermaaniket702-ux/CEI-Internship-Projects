# Delta Lake assignment— Incremental Data Processing with SCD Type 1 & Type 2

## Brief summary

This project implements an incremental data-processing pipeline on a customer dimension using **Delta Lake** on **Databricks**. A master customer dataset is loaded into a Delta table and cleaned, then an incremental batch of new and changed records is merged in using the Delta `MERGE` operation. Two Slowly Changing Dimension strategies are demonstrated: **SCD Type 1**, which overwrites changed values in place and keeps no history, and **SCD Type 2**, which preserves the full history of changes by expiring old rows and inserting new versioned rows. The pipeline finishes by validating the results and displaying the final dimension.

## Objective

Perform incremental data processing on a customer dimension using Delta Lake, implementing both Slowly Changing Dimension (SCD) Type 1 and Type 2 strategies via the `MERGE` operation.

## Project structure

```
delta-lake-assignment/
│
├── data/
│   ├── customer_master.csv          # existing customer dimension
│   └── customer_incremental.csv     # new + changed records (incremental batch)
│
├── notebooks/
│   └── delta_scd_assignment.ipynb   # main Databricks notebook
│
├── screenshots/
│   ├── data_loading/                # loading the Delta table
│   ├── data_cleaning/               # null handling + de-duplication
│   ├── scd1/                        # SCD Type 1 merge (before/after)
│   ├── scd2/                        # SCD Type 2 merge (history preserved)
│   ├── validation/                  # row counts, duplicate checks
│   └── final_output/                # final dimension + Delta history
│
└── README.md
```

## Datasets

### `customer_master.csv`
The existing customer dimension. It deliberately contains missing `segment` values and duplicate `customer_id` rows so the cleaning step has visible effect.

### `customer_incremental.csv`
The incremental batch: existing customers whose attributes were **changed** (city and segment updated) to exercise the update path, plus **brand-new** customers to exercise the insert path.

## Notebook contents

The notebook `delta_scd_assignment.ipynb` is organized into the following steps:

**Step 1 - Setup and load the master dataset into a Delta table.** Imports the Spark functions and Delta APIs, defines the input paths, reads the master CSV with header and schema inference, and writes it into a Delta table.

**Step 2 - Basic data cleaning (nulls + duplicates).** Counts nulls per column, fills the missing `segment` values with `Unknown`, and removes duplicate `customer_id` rows, showing the before/after row counts.

**Step 3 - Load the incremental (new / changed) data.** Reads the incremental CSV, applies the same cleaning, and prepares the batch of updates and new customers.

**Step 4 - SCD Type 1 (overwrite in place, no history).** Initializes the SCD1 Delta table, shows a customer before the merge, runs a `MERGE` that overwrites changed attributes and inserts new customers, and shows the same customer afterward with its values overwritten.

**Step 5 - SCD Type 2 (preserve history).** Initializes the SCD2 Delta table with tracking columns (`is_current`, `start_date`, `end_date`), detects which incoming records represent real changes, expires the old current rows for changed customers, and appends new current versions plus brand-new customers.

**Step 6 - Validate results.** Reports total, current, and historical row counts, checks that no customer has more than one current row, and displays the full version history for a changed customer.

**Step 7 - Final dimension & summary.** Shows the SCD1 latest-only view, the SCD2 current view, and the Delta table history, followed by a written summary.

## How to run (Databricks)

1. Import `notebooks/delta_scd_assignment.ipynb` into your Databricks workspace.
2. Upload both CSVs from `data/` to a location the notebook can read. The notebook's input paths are:
   - `master_csv = "/Workspace/delta-lake-assignment/data/customer_master.csv"`
   - `incremental_csv = "/Workspace/delta-lake-assignment/data/customer_incremental.csv"`
   Adjust these paths if your files are stored elsewhere 
3. Attach the notebook to a running cluster (Delta Lake is built into the Databricks Runtime - no extra installation is needed).

## SCD Type 1 vs Type 2 — quick reference

| Aspect | SCD Type 1 | SCD Type 2 |
|--------|------------|------------|
| On change | Overwrites the old value | Expires the old row, adds a new versioned row |
| History | Not kept | Fully preserved |
| Extra columns | None | `is_current`, `start_date`, `end_date` |
| Use when | Past values do not matter | Point-in-time history is needed |
| Storage | Compact | Grows with each change |

## Key insights

- **Delta Lake enables upserts** that plain CSV or Parquet cannot support. Its transaction log adds ACID `MERGE`, which is the foundation of incremental processing.
- **`MERGE` performs update-existing and insert-new logic in a single atomic transaction**, matched on the customer key.
- **SCD Type 1 is simple and compact but loses history**, while **SCD Type 2 preserves a complete, queryable record** of how each row changed over time, at the cost of extra storage.
- **Delta's version history** records every `MERGE` and append as a versioned commit, providing an auditable trail and supporting time travel.

## Environment

Developed for the Databricks Runtime (PySpark + Delta Lake). The notebook uses the pre-existing `spark` session and the built-in `delta.tables.DeltaTable` API.
