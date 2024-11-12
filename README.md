# U.S. Household Income Dataset: Data Cleaning, Analysis, and Reporting

## Project Overview

This project involves the application of advanced MySQL techniques for data cleaning, analysis, and reporting using the U.S. Household Income dataset. The objective is to create efficient procedures, triggers, and analysis scripts to extract insights, ensure data integrity, and facilitate predictive and geospatial analysis.

### Key Components and Tasks:
- **Data Cleaning**
- **Exploratory Data Analysis (EDA)**
- **Stored Procedures and Automation**
- **Data Integrity with Triggers**
- **Advanced Security Measures**
- **Geospatial Analysis**
- **Statistical Analysis**
- **Resource Allocation Optimization**

---

## Overview of Query Functions

The queries in this project serve various functions to ensure data consistency, integrity, and insightful analysis. Below is a breakdown of the primary objectives:

### Data Consistency Checks
- Ensure uniform data formatting and correct data type representation across the dataset.

### Duplicate Removal
- Identify and remove duplicate entries to maintain data integrity.

### Data Summarization
- Generate average land and water area reports for each state.
- Summarize total land and water area by state with city counts.

### Population Filtering
- List cities based on specific population or area size criteria.

### City Counting
- Count the number of cities in each state and provide a summary report.

### Ranking Using Window Functions
- Rank cities within each state by land area or other metrics.

### Top Area Identification
- Identify top counties or regions based on significant land or water areas.

### Geospatial Proximity Analysis
- Locate cities within a defined latitude and longitude range or radius.

### Anomaly Detection
- Use statistical methods to find outliers in land and water area comparisons.

### Correlation Analysis
- Determine relationships between land and water areas within states.

### Stored Procedure Creation
- Develop reusable procedures for custom reporting or complex calculations.

### Trigger Implementation
- Automate updates to summary tables for data integrity after inserts, updates, or deletions.

### Data Encryption
- Secure sensitive data (e.g., `Zip_Code`, `Area_Code`) using MySQL encryption.

### Recursive CTEs
- Calculate cumulative land areas or perform multi-level hierarchical data analysis.

### Temporary Tables Usage
- Store top results temporarily for further examination and analysis.

### Subquery Utilization
- Create detailed reports that leverage subqueries for calculating averages or specific conditions.

### Hotspot Detection
- Identify areas that significantly deviate from standard metrics using clustering or Z-scores.

### Resource Allocation Modeling
- Develop a model to optimize resource distribution based on city land and water area data.

### Dynamic SQL for Custom Reports
- Enable report generation based on variable input (e.g., state abbreviation).

### Indexing for Performance Optimization
- Enhance query performance by adding indexes and comparing execution times.

---

## Key Tasks and Features

1. **Automated Data Cleaning and Weekly Update**  
   Create a stored procedure and event scheduler to automate data cleaning and update processes weekly.

2. **Custom Report Generation**  
   Develop a stored procedure to generate detailed state reports, providing averages and city-level data.

3. **Geospatial Proximity Detection**  
   Implement logic to calculate distances between cities and a given coordinate.

4. **Hotspot Detection**  
   Use clustering or Z-scores to detect areas that significantly deviate from the standard patterns.

---
