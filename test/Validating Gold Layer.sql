SELECT
DISTINCT 
crm_cust.cst_gndr,
erp_cust.gen,
CASE 
	WHEN crm_cust.cst_gndr != 'n/a'  THEN cst_gndr
	ELSE Coalesce(erp_cust.gen,'n/a')
END AS new_gen
FROM silver.crm_cust_info AS crm_cust
LEFT JOIN silver.erp_cust_az12 AS erp_cust
ON erp_cust.cid=crm_cust.cst_key
LEFT JOIN silver.erp_loc_a101 AS erp_loc
ON erp_loc.cid=crm_cust.cst_key
ORDER BY 1,2

select * from silver.crm_prd_info
order by prd_id ASC

select * from gold.fact_sales