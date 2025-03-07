/*
================================================================================
Quality Checks
================================================================================
Script Purposes:
  This script performs quality schecks to validate the integrity, consistency,
  an accuracy of the Gold Layer. These checks ensure:
  - Uniqueness of surrogate keys in dimension tables.
  - Referential integrity between fact and dimension tables.
  - Validation of relationships in the data model for analytical purposes.

Usage Notes:
  - Run these checks after data loading Silver Layer.
  - Investigate and resolve any discrepancies found during the checks.
================================================================================
*/

-- ================================================================================
-- Check in 'gold.dim_customers'
-- ================================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results
SELECT
    customer_key,
    COUNT(*) AS duplicate_count
  FROM gold.dim_customers
  GROUP BY customer_key
  HAVING COUNT(*) > 1;

-- ================================================================================
-- Check in 'gold.dim_products'
-- ================================================================================
-- Check for Uniqueness of product Key in gold.dim_products
-- Expectation: No results
SELECT
    product_key,
    COUNT(*) AS duplicate_count
  FROM gold.dim_product
  GROUP BY product_key
  HAVING COUNT(*) > 1;

-- ================================================================================
-- Check in 'gold.dim_products'
-- ================================================================================
-- Check for correct joins of Foreign Keys product_key and customer_key 
-- Expectation: No results
SELECT 
  * 
FROM 
gold.fact_sales f 
LEFT JOIN gold.dim_customers cu
ON cu.customer_key = f.customer_key
LEFT JOIN gold.dim_product pr
ON pr.product_key = f.product_key
WHERE cu.customer_key IS NULL;




