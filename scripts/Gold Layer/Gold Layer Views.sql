/*
=============================================================================
GOLD LAYER : VIEWS
=============================================================================
*/

--========================================
-- DIM VIEW : gold.dim_customer
--========================================

CREATE VIEW gold.dim_customer AS
SELECT
	ROW_NUMBER() OVER(ORDER BY crm_cust.cust_id ASC) AS customer_key,
	crm_cust.cust_id AS customer_id,
	crm_cust.cst_key AS customer_number,
	crm_cust.cst_firstname AS firstname,
	crm_cust.cst_lastname AS lastname,
	erp_loc.cntry AS country,
	crm_cust.cst_marital_status marital_status,
	CASE 
		WHEN crm_cust.cst_gndr != 'n/a'  THEN cst_gndr
		ELSE Coalesce(erp_cust.gen,'n/a')
    END AS gender,
	erp_cust.bdate AS birth_date,
	crm_cust.cst_create_date AS created_date	
FROM silver.crm_cust_info AS crm_cust
LEFT JOIN silver.erp_cust_az12 AS erp_cust
          ON erp_cust.cid=crm_cust.cst_key
LEFT JOIN silver.erp_loc_a101 AS erp_loc
          ON erp_loc.cid=crm_cust.cst_key;

GO

--========================================
-- DIM VIEW : gold.dim_product
--========================================


CREATE VIEW gold.dim_product AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY crm_prd.prd_id ASC) AS product_key,
	crm_prd.prd_id AS product_id,
	crm_prd.prd_key AS product_number,
	crm_prd.prd_nm AS product_name,
	crm_prd.cat_id AS category_id,
	erp_cat.cat AS category,
	erp_cat.subcat AS subcategory,
	erp_cat.maintenance AS maintenance,
	crm_prd.prd_cost AS product_cost,
	crm_prd.prd_line AS product_line,
	crm_prd.prd_start_dt AS product_start_date   
FROM silver.crm_prd_info AS crm_prd
LEFT JOIN silver.erp_px_cat_g1v2 AS erp_cat
          ON erp_cat.id = crm_prd.cat_id
WHERE prd_end_dt IS NULL;

GO

--========================================
-- FACT VIEW : gold.fact_sales
--========================================

CREATE VIEW gold.fact_sales AS
SELECT 
	crm_sls.sls_ord_num AS order_number,
	dim_prd.product_key,
	dim_cust.customer_key,
	crm_sls.sls_order_dt AS order_date,
	crm_sls.sls_ship_dt AS shipped_date,
	crm_sls.sls_due_dt AS due_date,
	crm_sls.sls_sales AS sales,
	crm_sls.sls_quantity AS quantity,
	crm_sls.sls_price AS price
FROM silver.crm_sales_details AS crm_sls
LEFT JOIN gold.dim_product AS dim_prd
          ON dim_prd.product_number=crm_sls.sls_prd_key
LEFT JOIN gold.dim_customer AS dim_cust
          ON dim_cust.customer_id=crm_sls.sls_cust_id;