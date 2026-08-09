/*
==========================================================
INSERT DATA INTO BRONZE TO SILVER : TABLES
==========================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS

BEGIN

	BEGIN TRY

	DECLARE @start_time DATETIME , @end_time DATETIME
	--================================================== CRM TABLES =====================================================

	--=================================
	-- silver.crm_cust_info
	--=================================
	SET @start_time = GETDATE()

	TRUNCATE TABLE silver.crm_cust_info
	INSERT INTO silver.crm_cust_info
	(
		cust_id,          
		cst_key,	           
		cst_firstname,       
		cst_lastname,       
		cst_marital_status,
		cst_gndr,           
		cst_create_date
	)
	SELECT 
	cust_id,
	cst_key,
	TRIM(cst_firstname) AS cst_firstname ,
	TRIM(cst_lastname) AS cst_lastname,
	CASE cst_marital_status
		WHEN 'M' THEN 'Married'
		WHEN 'S' THEN 'Single'
		ELSE 'n/a'
	END AS cst_marital_status,
	CASE cst_gndr
		WHEN 'M' THEN 'Male'
		WHEN 'F' THEN 'Female'
		ELSE 'n/a'
	END AS cst_gndr,
	cst_create_date
	FROM
	(SELECT 
	*,
	Row_Number() OVER (PARTITION BY cust_id ORDER BY cst_create_date DESC) as flag_last
	FROM bronze.crm_cust_info
	WHERE cust_id IS NOT NULL
	)t
	Where flag_last=1

	SET @end_time = GETDATE()

	PRINT 'Sussess: silver.crm_cust_info | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';

	--=================================
	-- silver.crm_prd_info
	--=================================
	SET @start_time = GETDATE()

	TRUNCATE TABLE silver.crm_prd_info
	INSERT INTO silver.crm_prd_info
	(
		prd_id,       
		cat_id,       
		prd_key,   
		prd_nm,
		prd_cost,     
		prd_line,     
		prd_start_dt,
		prd_end_dt
	)
	SELECT 
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
		prd_nm,  
		ISNULL(prd_cost,0) AS prd_cost,
		CASE prd_line
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END AS prd_line,
		CAST(prd_start_dt AS DATE) AS prd_start_dt,
		-- CAST(prd_end_dt AS DATE) AS prd_end_dt, Bad Data date
		CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key order by prd_start_dt asc)-1 AS DATE) AS prd_end_dt
	FROM bronze.crm_prd_info

	SET @end_time = GETDATE()

	PRINT 'Sussess: silver.crm_prd_info | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';

	--=================================
	-- silver.crm_sales_details
	--=================================

	SET @start_time = GETDATE()

	TRUNCATE TABLE silver.crm_sales_details
	INSERT INTO silver.crm_sales_details 
	(
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
		CASE
			WHEN sls_order_dt=0 OR LEN(sls_order_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE
			WHEN sls_ship_dt=0 OR LEN(sls_ship_dt)!=8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE
			WHEN sls_due_dt=0 OR LEN(sls_due_dt) !=8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		CASE
			WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity*ABS(sls_price) THEN sls_quantity*ABS(sls_price)
			ELSE sls_sales
		END AS sls_sales,
		sls_quantity, 
		CASE
			WHEN sls_price IS NULL OR sls_price <=0 THEN sls_sales / NULLIF(sls_quantity,0)
			ELSE sls_price
		END AS sls_price
	FROM bronze.crm_sales_details

	SET @start_time = GETDATE()

	PRINT 'Sussess: silver.crm_sales_details | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';


	--================================================== ERP TABLES =====================================================

	--=================================
	-- silver.erp_cust_az12
	--=================================

	SET @start_time = GETDATE()

	TRUNCATE TABLE silver.erp_cust_az12
	INSERT INTO silver.erp_cust_az12
	(
	cid,
	bdate,
	gen
	)
	SELECT
	CASE 
		WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
		ELSE cid
	END AS cid,
	CASE
		WHEN TRY_CONVERT(DATE, bdate, 105) > CAST(GETDATE() AS DATE) THEN NULL
		ELSE TRY_CONVERT(DATE, bdate, 105)
	END AS bdate,
	CASE
		WHEN UPPER(gen) IN ('M','MALE') THEN 'Male'
		WHEN UPPER(gen) IN ('F','FEMALE') THEN 'Female'
		ELSE 'n/a'
	END AS gen 
	FROM bronze.erp_cust_az12

	SET @end_time = GETDATE()

	PRINT 'Sussess: silver.erp_cust_az12 | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';

	--=================================
	-- silver.erp_loc_a101
	--=================================

	SET @start_time = GETDATE()
	TRUNCATE TABLE silver.erp_loc_a101
	INSERT INTO silver.erp_loc_a101
	(
	cid,
	cntry
	)
	Select 
	 REPLACE(cid,'-','') AS cid,
	 CASE
		WHEN UPPER(cntry) IN ('USA','US','United States') THEN 'United State'
		WHEN UPPER(cntry) IN ('DE') THEN 'Germeany'
		WHEN cntry='' OR cntry IS NULL THEN 'n/a'
		ELSE cntry
	 END AS cntry
	from bronze.erp_loc_a101

	SET @end_time = GETDATE()

	PRINT 'Sussess: silver.erp_loc_a101 | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';

	--=================================
	-- silver.erp_px_cat_g1v2
	--=================================

	SET @start_time = GETDATE()

	TRUNCATE TABLE silver.erp_px_cat_g1v2
	INSERT INTO silver.erp_px_cat_g1v2
	(
	id,
	cat,
	subcat,
	maintenance
	)
	SELECT 
	id,
	cat,
	subcat,
	maintenance
	FROM bronze.erp_px_cat_g1v2

	SET @end_time = GETDATE()

	PRINT 'Sussess: silver.erp_px_cat_g1v2 | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' Seconds';

	END TRY

	BEGIN CATCH
	PRINT 'Error Occured'
	PRINT 'Error is: '+ ERROR_MESSAGE()
	PRINT 'Line Number: '+ CAST(ERROR_LINE() AS NVARCHAR)
	PRINT 'Error State: '+ CAST(ERROR_STATE() AS NVARCHAR)
	END CATCH
END

--===================================================== END TABLES ======================================================