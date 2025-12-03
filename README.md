# Netflix Data Cleaning and Transformation (PostgreSQL)

## Overview

This project presents a complete workflow for cleaning and transforming the Netflix titles dataset using PostgreSQL.

The raw dataset originally came as a CSV file.
It was first imported into **SQLite**, generating the file `netflix.db` included in this repository.
This file serves **only as the original raw dataset**.

All cleaning, transformation, and standardization steps described in this project were performed **entirely inside PostgreSQL**, not in SQLite.

The repository contains both:

* `netflix.db` — original raw SQLite database (for reference)
* PostgreSQL SQL scripts — full ETL pipeline

---

## 1.Extract

The raw CSV was initially imported into SQLite:

```
sqlite3 netflix.db
.import netflix_raw_dataset.csv netflix_raw
```

This generated the file `netflix.db`, which is included in the repository as the **raw data source**.

After inspection, the data was migrated into PostgreSQL using:

```
\copy netflix_raw FROM 'netflix_raw_dataset.csv' CSV HEADER;
```

From this point forward, **all ETL steps were executed exclusively in PostgreSQL**.

### 2. Transform

#### a. Exploration

* Verified dataset size and uniqueness of `show_id`.
* Inspected the volume of missing values using `COUNT(*) FILTER (WHERE ...)`.
* Checked for duplicates and structural inconsistencies.

#### b. Handling Missing Values

* Director: Filled using cast–director relationships; remaining nulls replaced with `"Not Given"`.
* Country: Inferred from known director–country associations; remaining nulls set to `"Not Given"`.
* Rating: FixedFilled using rating-listend_in relationships; remaining nulls replaced with `"Not Given"`
* Duration: Some values belonging to duration were mistakenly stored in the rating column.These values were relocated to the correct column and standardized.Remaining incorrect or missing values were corrected or set to "Not Given" when appropriate.
* Date Added: Rows with missing values had their missing values replaced to `"Not Given "`".

#### c. Structural Adjustments

* Dropped unused columns (`movie_cast`, `description`).
* Standardized country using PostgreSQL string functions.
* Ensured uniform formatting in textual fields.

#### d. Validation

* Confirmed absence of remaining nulls.
* Verified column alignment and row counts.
* Ensured consistency between related fields (e.g., director and country).

---

### 3. Load

Cleaned data was written to a new table (e.g., `netflix_clean`) or exported as:

```
\copy netflix_clean TO 'netflix_clean.csv' CSV HEADER;
```

The dataset is ready for analytical use or BI tools.

---

## SQL Techniques Used

* `COUNT()`, `COUNT(DISTINCT)`
* `FILTER (WHERE ...)` for null profiling
* `UPDATE ... FROM` for conditional updates
* `COALESCE()` for fallback values
* `ALTER TABLE ... DROP COLUMN`
* ``string_to_array()`, `unnest()`
* Common Table Expressions (CTEs)
* Window function (ROW_NUMBER())

---

## Results and Insights

* Director column had over 30% missing values; most were successfully imputed.
* Strong correlation between director and country improved data completeness.
* Final dataset is consistent, clean, and ready for reporting or visualization.

---

## Project Structure

```
├── netflix_raw_dataset.csv      # Original CSV (optional, not included)
├── netflix.db                   # Raw dataset in SQLite format (source only)
├── cleaning_movies_data.sql     # Full PostgreSQL transformation pipeline
├── netflix_clean.csv            # Final cleaned dataset (exported from PostgreSQL)
└── README.md                    # Documentation
```