/*
============================================================
Spred Procedure: Load Bronze Layer (Source -> Bronze)
============================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the 'BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
  None.
This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
============================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
  DECLARE @start_time DATETIME, @end_time DATETIME
  BEGIN TRY 
  
    PRINT '================================';
    PRINT 'loading BRONE LAYER';
    PRINT '================================';

    PRINT '--------------------------------';
    PRINT 'Loading CRM Tables'
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    Print '>> Inserting Data Into: crm_cust_info';
    BULK INSERT bronze.crm_cust_info
    FROM '/var/opt/mssql/data/datasets/source_crm/cust_info.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';
   
    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;

    Print '>>Inserting Data Into: crm_prd_info';
    BULK INSERT bronze.crm_prd_info
    FROM '/var/opt/mssql/data/datasets/source_crm/prd_info.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
       SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: _details';
    TRUNCATE TABLE bronze.crm_sales_details;
    Print '>>Inserting Data Into: crm_sales';
    BULK INSERT bronze.crm_sales_details
    FROM '/var/opt/mssql/data/datasets/source_crm/sales_details.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    Print '>>Inserting Data Into: crm_sales_details';
    BULK INSERT bronze.crm_sales_details
    FROM '/var/opt/mssql/data/datasets/source_crm/sales_details.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    PRINT '--------------------------------';
    PRINT 'Loading CRM Tables'
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    Print '>> Inserting Data Into: erp_cust_az12';
    BULK INSERT bronze.erp_cust_az12
    FROM '/var/opt/mssql/data/datasets/source_erp/cust_az12.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';

    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    Print '>> Inserting Data Into: erp_loc_a101';
    BULK INSERT bronze.erp_loc_a101
    FROM '/var/opt/mssql/data/datasets/source_erp/loc_a101.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    PRINT '-----';



    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    Print '>> Inserting Data Into: erp_px_cat_g1v2';
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM '/var/opt/mssql/data/datasets/source_erp/px_cat_g1v2.csv'
    WITH (
      FORMAT = 'CSV',
      FIRSTROW = 2,
      FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n',
      TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) as NVARCHAR) + ' seconds';
    
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
