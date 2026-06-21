# Azure Data Factory — CSV Copy Pipeline

An end-to-end Azure Data Factory project that reads a CSV file from Azure Blob Storage, validates its structure with a metadata check, and copies it to a destination container. Built as part of the CEI Internship Azure assignment.

---

## Objective

Demonstrate practical fluency in Azure's core data engineering primitives by building a complete pipeline from scratch:

- **Resource Group** for logical grouping and cleanup
- **Azure Blob Storage** as source and destination
- **Azure Data Factory** for the orchestration and data movement
- **Linked Services + Datasets + Activities** — ADF's three-layer abstraction
- **Get Metadata + Copy Data** activities chained via an On Success dependency
- **Role-based access control (RBAC)** to grant ADF the right data-plane permissions

---

## Resources Created

| Resource Type      | Name                          |
|--------------------|-------------------------------|
| Resource Group     | `rg-adf-assignment-week4`     |
| Storage Account    | `storageadfweek4`             |
| Source Container   | `source-data`                 |
| Destination Container | `destination-data`         |
| Data Factory       | `adf-assignment-week4`        |
| Linked Service     | `LS_AzureBlobStorage1`        |
| Pipeline           | `PL_CopyCSV_WithMetadata`     |

---

## Task Summary

### Task 1 — Resource Group

Created a single Resource Group `rg-adf-assignment-week4` in the Central India region to act as a logical container for every resource in the assignment. This makes cleanup a one-click operation: deleting the resource group removes the storage account, data factory, and any associated metadata together.

### Task 2 — Storage Setup

Created a Storage Account (`storageadfweek4`) with Standard performance, LRS redundancy, and Hot access tier — the cheapest viable combination for an assignment workload. Inside it, created two private blob containers — `source-data` and `destination-data` . 
Uploaded `Sample - Superstore.csv` into `source-data`.

### Task 3 — ADF Basics

Created the Data Factory `adf-assignment-week4`, launched ADF Studio, and built three foundational objects:

- **Linked Service** `LS_AzureBlobStorage1` (Azure Blob Storage, account key authentication) — verified with "Test connection"
- **Source Dataset** `DS_Source_CSV` — DelimitedText format pointing at `source-data/Sample - Superstore.csv`, with quote character `"` and escape character `"` to correctly parse fields containing embedded commas
- **Sink Dataset** `DS_Destination_CSV` — same format, pointing at `destination-data/output.csv`

Added a **Get Metadata** activity to the pipeline canvas, configured against the source dataset with the field list set to `Item name`, `Item type`, `Size`, `Last modified`, `Column count`, and `Structure`.

### Task 4 — Pipeline Development

Added a **Copy Data** activity to the right of Get Metadata, then chained the two with an **On Success** dependency (green arrow). Configured Copy Data with:

- **Source:** `DS_Source_CSV`
- **Sink:** `DS_Destination_CSV` (Copy behavior: None)
- **Mapping:** schemas imported from both datasets — 21 source columns mapped 1:1 to 21 sink columns

Validated the full pipeline (no errors) and published all four objects (Linked Service, two Datasets, Pipeline) to the ADF service.

### Task 5 — Pipeline Execution

Ran the pipeline using **Debug** mode. Both activities turned green:

- **Get Metadata:** Succeeded in 13 s — returned `itemType="File"`, `columnCount=21`, and the full structure
- **Copy Data:** Succeeded — returned `rowsRead=9994`, `rowsWritten=9994`, with matching `dataRead` and `dataWritten` of ~2.3 MB

Verified the output file `output.csv` landed in `destination-data` at the expected size.

### Task 6 — IAM Roles

Configured three role assignments on the storage account via **Access control (IAM)**:

1. **Reader** — assigned to a user (read-only management access)
2. **Contributor** — assigned to a user (full management, no permission grants)
3. **Storage Blob Data Contributor** — assigned to the ADF managed identity `adf-assignment-week4`

The third assignment is the critical one — without it, ADF can manage the storage account but cannot actually read or write blob contents, and the pipeline would fail with 403 errors at runtime.

### Mini Project — End-to-End Pipeline

The mini project consolidates Tasks 3–5 into a single deliverable demonstrating the complete data flow: source CSV in Blob → metadata validation → copy to destination. All requirements were met:

- ✅ Source: CSV file in Blob (`source-data/Sample - Superstore.csv`)
- ✅ Linked Service + Dataset + Pipeline: all three layers configured
- ✅ Copy Data + Metadata check: both activities chained with On Success
- ✅ Destination: new file in `destination-data` container
- ✅ Pipeline executed successfully
- ✅ Data copied correctly (9,994 rows read, 9,994 rows written, lossless)
- ✅ Metadata validated (21 columns, file type and size confirmed)

---
