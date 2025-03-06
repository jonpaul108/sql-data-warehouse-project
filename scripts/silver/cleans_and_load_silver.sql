CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
  BEGIN TRY
    PRINT '=======================================';
    PRINT 'Loading the Silver Layer...';
    PRINT '=======================================';

    PRINT '---------------------------------------';
    PRINT 'Loading the CRM Layer...';
    PRINT '---------------------------------------';

    DECLARE @initial_start_time DATETIME,@start_time DATETIME, @end_time DATETIME, @final_end_time DATETIME;
    SET @initial_start_time = GETDATE();

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.crm_cust_info';
    TRUNCATE TABLE silver.crm_cust_info;
    PRINT '>> Inserting Data Into Table: silver.crm_cust_info';
    INSERT INTO silver.crm_cust_info (
      cst_id,
      cst_key,
      cst_firstname,
      cst_lastname,
      cst_marital_status,
      cst_gndr,
      cst_created_dt
    )
    SELECT
      cst_id,
      cst_key,
      TRIM(cs_firstname) AS cst_firstname,
      TRIM(cs_lastname) AS cst_lastname,
      cst_marital_status,
      CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'MALE'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'FEMALE'
        ELSE 'N/A'
      END AS cst_gndr,
      cst_created_dt
    FROM 
    (
    SELECT 
      *,
      CASE 
        WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'MARRIED'
        WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'SINGLE'
        ELSE 'N/A'
      END AS cst_marital_status,
      ROW_NUMBER() OVER (partition by cst_id ORDER BY cst_created_dt DESC) AS flag_last
    FROM 
      bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
    ) t WHERE flag_last = 1;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.crm_prd_info';
    TRUNCATE TABLE silver.crm_prd_info;
    PRINT '>> Inserting Data Into Table: silver.crm_prd_info';
    INSERT INTO silver.crm_prd_info (
      prd_id,
      cat_id,
      prd_key,
      prd_nm ,
      prd_cost,
      prd_line,
      prd_start_dt,
      prd_end_dt
    )
    SELECT
      prd_id,
      REPLACE(left(prd_key, 5), '-', '_') as cat_key,
      SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
      prd_nm,
      ISNULL(prd_cost, 0) as prd_cost,
      CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'MOUNTAIN'
        WHEN 'R' THEN 'ROAD'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'other Sales'
        ELSE 'n/a' 
      END as prd_line,
      prd_start_dt,
      DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt_test
    FROM
    bronze.crm_prd_info;
      SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details;
    PRINT '>> Inserting Data Into Table: silver.crm_sales_details';
    INSERT INTO silver.crm_sales_details (
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      sls_order_dt,
      sls_ship_dt,
      sls_due_dt,
      sls_sales,
      sls_quantity,
      sls_price
    )
    SELECT 
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL 
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
      CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL 
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
      CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL 
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
        CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
      END AS sls_sales,
      sls_quantity,
      CASE WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0) 
        ELSE sls_price
      END AS sls_price
    FROM 
    bronze.crm_sales_details;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12;
    PRINT '>> Inserting Data Into Table: silver.erp_cust_az12';
    INSERT INTO silver.erp_cust_az12 (
      CID,
      BDATE,
      Gen
    )
    SELECT
      CASE WHEN cid like 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
      END AS cid,
      CASE WHEN BDATE > GETDATE() 
        THEN NULL
        ELSE BDATE
      END AS BDATE,
      CASE WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('F','FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(REPLACE(gen, CHAR(13), ''))) IN ('M','MALE')  THEN 'Male'
        ELSE 'N/A'
      END AS Gen
    FROM bronze.erp_cust_az12;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';


    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_loc_a101;
    PRINT '>> Inserting Data Into Table: silver.erp_loc_a101';
    INSERT INTO silver.erp_loc_a101 (
      cid,
      cntry
    )
    SELECT 
      REPLACE(cid, '-', '') AS cid,
      CASE WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('US', 'USA', 'UNITED STATES') THEN 'UNITED STATES'
        WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('DE', 'GERMANY') THEN 'GERMANY'
        WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('FRANCE', 'FR') THEN 'FRANCE'
        WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('AUSTRALIA', 'AU') THEN 'AUSTRALIA'
        WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('CANADA', 'CA') THEN 'CANADA'
        WHEN UPPER(TRIM(REPLACE(cntry, CHAR(13), ''))) IN ('UK', 'UNITED KINGDOM') THEN 'UNITED KINGDOM'
        WHEN TRIM(REPLACE(cntry, CHAR(13), '')) = '' OR cntry IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
      END AS cntry
    FROM bronze.erp_loc_a101;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    PRINT '>> Inserting Data Into Table: silver.erp_px_cat_g1v2';
    INSERT INTO silver.erp_px_cat_g1v2 (
      id,
      cat,
      subcat,
      maintenance
    )
    SELECT 
    id,
    cat,
    subcat,
    TRIM(REPLACE(maintenance,CHAR(13),'')) as maintenance
    FROM bronze.erp_px_cat_g1v2;
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @final_end_time = GETDATE();
    PRINT '================================';
    PRINT 'TOTAL LOAD DURATION: ' + CAST(DATEDIFF(SECOND, @initial_start_time, @final_end_time) as NVARCHAR) + ' seconds';
    PRINT '================================';

  END TRY
  BEGIN CATCH
    PRINT '================================';
    PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() as NVARCHAR);
    PRINT 'Error State: ' + CAST(ERROR_STATE() as NVARCHAR);
    PRINT '================================';
    THROW;  
  END CATCH
 END
