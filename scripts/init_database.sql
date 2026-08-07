/*
==============================================================================
CREATE DATABASE & SCHEMA
==============================================================================

Script Purpose:
	This screate new database named 'DataWarehouse' after checking if exists.
	If database exists, it is dropped and recreated. Additionally, the scripts setup 3 schemas within the database
	'bronze' , 'silver' , 'gold'.

Warnings:
	Running this script will drop the entire 'DataWarehouse' database if it is exists.
	All the data in the database will be deleted permenntly. proceed with caution and ensure you have proper backups before running this scripts.
*/




USE master;
GO

-- Drop and Recreate the 'DataWarehouse' database

/*

IF EXISTS (SELECT 1 FROM sys.databases WHERE name='DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

*/

Create DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
