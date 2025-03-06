/*
======================================================================
Quality Checks
======================================================================
Script Purpose:
  This script performs various quality checls for data consistency, accuracy,
  standardization across the 'silver' schema. It includes checls for:
  - Null or duplicate primary keys.
  - Unwanted spaces in string fields.
  - Data standardization and consistency.
  - Invalid date ranges and orders.
  - Data consistency between related fields.

Usage Notes:
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepencies found during the checks.
======================================================================
*/

-- ======================================================================
-- Checking 'silver.crm_cust_info'
-- ======================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results


SELECT cst_id, count_pk
FROM
(SELECT cst_id, COUNT(*) OVER(partition by cst_id order by cst_id) AS count_pk
FROM silver.crm_cust_info) AS subquery
WHERE count_pk > 1;

SELECT cst_id, COUNT(*) AS cnt
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

SELECT
cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
SELECT
cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;


-- ======================================================================
-- Checking 'silver.silver.crm_prd_info'
-- ======================================================================
-- Check for NULL values and Duplicates; Correct assignment of gender
-- Expectation: no values for Null; 'Male' or 'Female' for Gender

SELECT prd_id, COUNT(*) AS cnt
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

SELECT DISTINCT cst_gndr FROM silver.crm_prd_info;


-- ======================================================================
-- Checking 'silver.crm_sales_details'
-- ======================================================================
-- Check for Errant Dates, incorrect Sales, negative values
-- Expectation: No results for errant dates; Sales to match quantity * price



SELECT * 
FROM silver.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt 
OR sls_ship_dt > sls_due_dt;

SELECT
sls_sales AS old_sls_sales,
sls_quantity,
sls_price AS old_sls_price,
CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
  THEN sls_quantity * ABS(sls_price)
  ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0 
  THEN sls_sales / NULLIF(sls_quantity, 0) 
  ELSE sls_price
END AS sls_price
FROM 
silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales < 0
OR sls_quantity < 0
OR sls_price < 0;

-- ======================================================================
-- Checking 'silver.erp_cust_az12'
-- ======================================================================
-- Check for BDATES older than current date, matching ID with crm_cust,
  -- Correct Gender
-- Expectation: No dates older than current date; IDs match crm_cust, Male or Female


SELECT DISTINCT 
BDATE
FROM silver.erp_cust_az12
WHERE BDATE < '1924-01-01' OR BDATE > GETDATE();

SELECT 
gen,
UPPER(TRIM(gen)) AS gen_trim,
LEN(UPPER(TRIM(gen))) AS gen_trim_len,
CASE WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('F','FEMALE') THEN 'Female'
  WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('M','MALE')  THEN 'Male'
  ELSE 'N/A'
END AS Gen
FROM silver.erp_cust_az12;

SELECT DISTINCT
CASE WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('F','FEMALE') THEN 'Female'
  WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('M','MALE')  THEN 'Male'
  ELSE 'N/A'
  END
FROM silver.erp_cust_az12;


-- ======================================================================
-- Checking 'silver.erp_loc_a101'
-- ======================================================================
-- Check country formatting, correctly formatted 
-- Expectation: Full names of countries, no NULL values for country, no cid having '-'
SELECT DISTINCT 
  cntry 
  FROM silver.erp_loc_a101;
SELECT  
  *
  FROM silver.erp_loc_a101;

SELECT cid 
FROM silver.erp_loc_a101 
WHERE SUBSTRING(cid, 3, 1) = '-';

-- ======================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ======================================================================
-- Check NULL and duplicate values, consistent id length, distinct cat and subcat
-- Expectation: NO NULL values, all ids having length of 5, no repeat cat or subcat values
SELECT id 
FROM silver.erp_px_cat_g1v2 
WHERE id IS NULL;

SELECT DISTINCT cat 
from silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

SELECT 
id,
len(id)
FROM bronze.erp_px_cat_g1v2
WHERE len(id) > 5;



