# SQL Sales Analysis — Sample Superstore

 **CEI Internship · Week 2 Assignment**  
 Exploratory data analysis of a U.S. retail dataset using MySQL — covering schema design, data loading, filtering, aggregations, business insights, and data quality validation.

##  Repository Structure

- sales_analysis.sql            
- Sample - Superstore.csv         
- query_results_and_insights.docx  

##  Dataset Overview

| Property | Details |
|---|---|
| **Source** | Sample Superstore (U.S. Retail) |
| **Rows** | 9,994 orders |
| **Columns** | 21 |
| **Date Range** | January 2014 – December 2017 |
| **Categories** | Furniture, Office Supplies, Technology |
| **Regions** | East, West, Central, South |
| **Customer Segments** | Consumer, Corporate, Home Office |
| **Unique Customers** | 793 |
| **Unique Products** | 1,850 |
| **States Covered** | 49 |


##  SQL Script Sections

### Section 1 - Database Setup & Load Dataset
- Creates the `sales_analysis` database with `utf8mb4` encoding
- Defines the `superstore` table with precise data types (`DECIMAL(10,4)` for financials) and 8 performance indexes
- Loads the CSV using `LOAD DATA LOCAL INFILE` with `STR_TO_DATE()` to convert MM/DD/YYYY dates to MySQL's `DATE` type

### Section 2 - Explore the Table
- `DESCRIBE` to inspect schema and data types
- `SELECT * LIMIT 10` for a sample of raw data
- `SELECT DISTINCT region` to confirm geographic coverage
- Date range query to validate the 4-year time span

### Section 3 - WHERE Filters
- Filter by **region** (`West`)
- Filter by **category** (`Technology`)
- Filter by **date range** (Q4 2017: Oct–Dec)
- Filter by **high discounts** (> 40%) - reveals consistent profit losses at deep discount levels

### Section 4 - GROUP BY Aggregations
- Revenue, units sold, and profit **by Category**
- Revenue, profit, and average order value **by Region**

### Section 5 - Sort and Limit
- **Top 10 products by Revenue** - Technology dominates (7 of 10 are tech products)
- **Top 10 products by Profit** - Canon imageCLASS 2200 Copier leads at $25,200 profit

### Section 6 - Business Use Cases
- **Monthly Revenue & Profit Trend (2017)** - identifies November peak ($118K revenue) and seasonal patterns
- **Top 10 Customers by Lifetime Revenue** - Sean Miller leads at $25,043
- **Duplicate Row Detection** - confirms zero duplicate primary keys

### Section 7 - Validate Results & Data Quality
- Total row count verification
- Zero/negative sales check
- Discount range validation (0–1 scale)
- Overall revenue, profit, margin %, and units sold summary


## Key Findings

| Finding | Detail |
|---|---|
| **Total Revenue** | $2,297,200.86 |
| **Total Profit** | $286,397.02 |
| **Overall Profit Margin** | 12.47% |
| **Most Profitable Category** | Technology ($145,455 profit, 17.4% margin) |
| **Lowest Margin Category** | Furniture ($741K revenue, only 2.5% margin) |
| **Best Performing Region** | West ($725K revenue, $108K profit) |
| **Weakest Region (Margin)** | Central (7.9% profit margin) |
| **Peak Revenue Month (2017)** | November — $118,448 |
| **Top Product (Revenue & Profit)** | Canon imageCLASS 2200 Advanced Copier |
| **Discount Risk** | All orders with discount > 40% result in negative profit |


##  How to Run

**Prerequisites:** MySQL 8.0+, local infile loading enabled

sql
-- Enable local infile (if not already set)
SET GLOBAL local_infile = 1;


```bash
# Run the full script from terminal
mysql --local-infile=1 -u root -p < sales_analysis.sql
```

Or open `sales_analysis.sql` in **MySQL Workbench** and run all sections sequentially.

 **Note:** Update the file path in the `LOAD DATA LOCAL INFILE` statement (Section 1) to match your local directory before running.



##  Tools & Technologies Used

- MySQL
- Excel / CSV

