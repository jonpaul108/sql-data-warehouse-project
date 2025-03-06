/*
========================================
Gold Layer Checks
========================================
*/

-- check distinct gender in customer dimension
SELECT DISTINCT
gender
FROM gold.dim_customers;

-- check fact correctly joins with gold.dim_customers and gold.dum_product, expectation: nothing returned
SELECT 
* 
FROM 
gold.fact_sales f 
LEFT JOIN gold.dim_customers cu
ON cu.customer_key = f.customer_key
LEFT JOIN gold.dim_product pr
ON pr.product_key = f.product_key
WHERE cu.customer_key IS NULL;
