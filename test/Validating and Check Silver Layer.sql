
--- Select

Select DISTINCT prd_line from bronze.crm_prd_info
Select * from bronze.crm_sales_details
Select * from bronze.erp_px_cat_g1v2

-- Duplicate Find 
SELECT prd_id, Rank_Number FROM
(SELECT 
prd_id,
Row_Number() OVER (PARTITION BY prd_id ORDER BY prd_id DESC) as Rank_Number
FROM bronze.crm_prd_info)t
Where Rank_Number=2

Select * from silver.crm_cust_info
where cst_key='AW00029433'

--- Trim Check

Select prd_key from bronze.crm_prd_info
where prd_key != Trim(prd_key)

-- Distinct Cases 
Select DISTINCT cst_gndr from silver.crm_cust_info

-- Check Any Null
Select * from silver.crm_cust_info
Where cst_create_date IS NULL

Select * from silver.crm_cust_info

-- Check Dates
Select prd_id,prd_key,prd_nm,prd_cost,prd_line,CAST(prd_start_dt AS DATE),CAST(prd_end_dt AS DATE) from bronze.crm_prd_info
where CAST(prd_start_dt AS DATE) > CAST(prd_end_dt AS DATE) --AND prd_id IN (212,213,213,215,216,217)

Select * from (
Select sls_ord_num,Count(sls_ord_num) Over(Partition by sls_ord_num) as no_data  from bronze.crm_sales_details)t
where no_data=2

Select * from silver.crm_cust_info

Select CONVERT(DATE, bdate, 105) from bronze.erp_cust_az12
WHERE CONVERT(DATE,bdate,105) > GETDATE()

Select DISTINCT gen FROM bronze.erp_cust_az12


select bdate from silver.erp_cust_az12
where bdate > GETDATE()

Select * from bronze.crm_cust_info

Select * from bronze.erp_loc_a101
Select DISTINCT cntry from bronze.erp_loc_a101


Select DISTINCT cntry from silver.erp_loc_a101

EXEC silver.load_silver


