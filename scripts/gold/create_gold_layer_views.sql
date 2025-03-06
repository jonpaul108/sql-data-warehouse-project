
/*
========================================
Gold Layer
========================================
*/

-- create the customer dimension view

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


-- create the product dimension view
  
CREATE VIEW gold.dim_product AS
(
  SELECT 
    ROW_NUMBER() OVER(order by  pi.prd_start_dt, pi.prd_key) AS product_key,
    pi.prd_id AS product_id,
    pi.prd_key AS product_number,
    pi.prd_nm AS product_name,
    pi.cat_id AS category_id,
    px.cat AS category,
    px.subcat AS subcategory,
    px.maintenance AS maintenance,
    pi.prd_cost AS product_cost,
    pi.prd_line AS product_line,
    pi.prd_start_dt AS start_date
  FROM
  silver.crm_prd_info pi
  LEFT JOIN silver.erp_px_cat_g1v2 px ON pi.cat_id = px.id
);


-- create the sales fact view
CREATE VIEW gold.fact_sales AS 
(
SELECT 
  sls_ord_num AS order_number,
  pr.product_key,
  cu.customer_key,
  sls_order_dt AS order_date,
  sls_ship_dt AS shipping_date,
  sls_due_dt AS due_date,
  sls_sales as sales_amount,
  sls_quantity AS quantity,
  sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_product pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
ON sd.sls_cust_id = cu.customer_id
);
