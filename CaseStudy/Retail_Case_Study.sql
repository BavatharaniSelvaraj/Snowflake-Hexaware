--Create Database
CREATE OR REPLACE DATABASE RETAIL; 
USE DATABASE RETAIL; 

--Create Schema
CREATE OR REPLACE SCHEMA RAW_SALES; 
USE SCHEMA RAW_SALES; 

--Create CSV File Format
CREATE OR REPLACE FILE FORMAT MY_CSV_FORMAT
  TYPE = 'CSV'
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  SKIP_HEADER = 1
  FIELD_DELIMITER = ','
  NULL_IF = ('NULL','');

--Create External Stage pointing to Azure Blob
CREATE OR REPLACE STAGE AZURE_SALES_STAGE
  URL='azure://thaaracontainer.blob.core.windows.net/sales'
  CREDENTIALS = (
    AZURE_SAS_TOKEN='sp=rl&st=2025-10-24T03:34:21Z&se=2025-10-24T11:49:21Z&spr=https&sv=2024-11-04&sr=c&sig=Qna2gmElWBLUMO0kJ%2Ftqlxyn4ObDvt%2BCJxxYwIrB0ks%3D'
  )
  FILE_FORMAT = (TYPE='CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1);


--Verify Stage Contents
LIST @AZURE_SALES_STAGE;

--Create Sales Table
CREATE OR REPLACE TABLE SALES (
  OrderID STRING,
  OrderDate STRING,
  MonthOfSale STRING,
  CustomerID STRING,
  CustomerName STRING,
  Country STRING,
  Region STRING,
  City STRING,
  Category STRING,
  Subcategory STRING,
  Quantity INT,
  Discount FLOAT,
  Sales FLOAT,
  Profit FLOAT
);

--Load CSV Data from Stage to Table
COPY INTO SALES
FROM @AZURE_SALES_STAGE/Retail_sales.csv
FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY='"' SKIP_HEADER=1)
ON_ERROR = 'CONTINUE';

-- Preview top 10 rows
SELECT * FROM SALES LIMIT 10;

--Check Current Warehouse
SELECT CURRENT_WAREHOUSE();
