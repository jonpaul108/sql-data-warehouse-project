
/*
========================================
Gold Layer
========================================
*/

--create the customer dimension view
CREATE VIEW gold.dim_customers AS
(
  SELECT
    ROW_NUMBER() over(order by cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr 
    ELSE Upper(COALESCE(ca.gen, 'N/A')) 
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_created_dt AS create_date
  FROM silver.crm_cust_info ci
  LEFT JOIN silver.erp_cust_az12 ca 
  ON ci.cst_key = ca.cid
  LEFT JOIN silver.erp_loc_a101 la
  ON ci.cst_key = la.cid
)
