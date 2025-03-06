/*
========================================
Gold Layer Checks
========================================
*/

-- check distinct gender in customer dimension
SELECT DISTINCT
gender
FROM gold.dim_customers;
