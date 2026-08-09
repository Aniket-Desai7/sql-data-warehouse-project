/* 
========================================================
BRONZE LAYER 
========================================================
Store Procedure Load Brnze Layer 

Script Purpose -
	This store procedure load the data into the 'bronze' schema from the external files.
	It prefers following actions
	- Truncate the broze table before loading
	- Uses the 'bulk insert' command to load data from csv files to bronze layers.

Parameters - 
	none
	This store procedure does not accept any parameter or return any value. 

Variables -
	@ start_date , @end_date this variable define the execution time.

Usage Example -
	EXEC bronze.load_bronze

*/

USE DataWarehouse;
GO

-- crm tables value insert
CREATE OR ALTER PROCEDURE bronze.load_bronze AS

BEGIN

-- Error Handling
BEGIN TRY

--Declare Variable
	DECLARE @start_time DATETIME, @end_time DATETIME;

	
	PRINT 'LOADING DATA...'

	--=========================================== CRM TABLES ======================================================

	--=======================================
	-- bronze.crm_cust_info
	--=======================================


	SET  @start_time=GETDATE();

		TRUNCATE TABLE bronze.crm_cust_info
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\CRM\cust_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	SET  @end_time=GETDATE();

	PRINT 'Sussess: bronze.crm_cust_info | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	--=======================================
	-- bronze.crm_prd_info
	--=======================================

	SET  @start_time=GETDATE();

		TRUNCATE TABLE bronze.crm_prd_info
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\CRM\prd_info.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	SET  @end_time=GETDATE();

	PRINT 'Sussess: bronze.bronze.crm_prd_info | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	--=======================================
	-- bronze.crm_sales_details
	--=======================================

	SET @start_time=GETDATE();

		TRUNCATE TABLE bronze.crm_sales_details
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\CRM\sales_details.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	PRINT 'Sussess: bronze.crm_sales_details | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	--================================================== ERP TABLES ==================================================


	--=======================================
	-- bronze.erp_cust_az12
	--=======================================
	SET  @start_time=GETDATE();

		TRUNCATE TABLE bronze.erp_cust_az12
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\ERP\CUST_AZ12.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	SET  @end_time=GETDATE();

	PRINT 'Sussess: bronze.erp_cust_az12 | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	--=======================================
	-- bronze.erp_loc_a101
	--=======================================
	SET  @start_time=GETDATE();

		TRUNCATE TABLE bronze.erp_loc_a101
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\ERP\LOC_A101.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	SET  @end_time=GETDATE();

	PRINT 'Sussess: bronze.erp_loc_a101 | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	--=======================================
	-- bronze.erp_px_cat_g1v2
	--=======================================
	SET  @start_time=GETDATE();

		TRUNCATE TABLE bronze.erp_px_cat_g1v2
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ANKIT\Desktop\Data Warehouse Project\Dataset\ERP\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW=2,
			FIELDTERMINATOR=',',
			TABLOCK
		);

	SET  @end_time=GETDATE();

	PRINT 'Sussess: bronze.crm_sales_details | Duration: '+ CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + 'Seconds';

	 --=============================================== END TABLES =====================================================

	PRINT 'LOADING SUSSESSFULL'

END TRY
BEGIN CATCH
	PRINT 'Error Occured'
	PRINT 'Error is: '+ ERROR_MESSAGE()
	PRINT 'Line Number: '+ CAST(ERROR_LINE() AS NVARCHAR)
	PRINT 'Error State: '+ CAST(ERROR_STATE() AS NVARCHAR)
END CATCH

--******************************************************************************************************************
END;
GO
--************************************************** END ***********************************************************