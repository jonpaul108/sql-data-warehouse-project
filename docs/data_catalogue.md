# Data Dictionary for Gold Layer
## Overview
The Gold Layer is the business -level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.
<hr style="border:2px solid gray">
### 1. gold.dim_customers 
  
- **Purposes:** Stores customer details enriched with demographic and geographic data
- **Columns:**
    
|Column Name|DataType|Description|
|--------|--------|--------|
|customer_key|INT|Surrogate key uniquely identifying each customer record in the diension table.|
|customer_id|INT|Unique numberical identifier assigned to each customer.|
|customer_number|NVARCHAR(50)|Alphanumeric identifier representing the customer, used for tracking and referencing.|
|first_name|NVARCHAR(50)|Surrogate key uniquely identifying each customer record in the diension table.|
|last_name|NVARCHAR(50)|Surrogate key uniquely identifying each customer record in the diension table.|
|country|NVARCHAR(50)|Surrogate key uniquely identifying each customer record in the diension table.|
|marital_status|NVARCHAR(50)|Surrogate key uniquely identifying each customer record in the diension table.|
|gender|NVARCHAR(50)|Surrogate key uniquely identifying each customer record in the diension table.|
|birthdate|DATE|The datre of birth of the customer, formatted as YYY-MM-DD (e.g., 1971-10-06).|
|create_date|DATE|The date and time when the customer record was created in the system.|
<hr style="border:2px solid gray">

### 2. gold.dim_product  

- **Purposes:** Stores product details, including categorization, cost, and product lifecycle data.  
- **Columns:**  

| Column Name     | DataType      | Description |
|---------------|--------------|------------|
| product_key   | INT          | Surrogate key uniquely identifying each product record in the dimension table. |
| product_id    | INT          | Unique numerical identifier assigned to each product. |
| product_number | NVARCHAR(50) | Alphanumeric identifier representing the product, used for tracking and referencing. |
| product_name  | NVARCHAR(255) | Name of the product. |
| category_id   | INT          | Identifier linking the product to its associated category. |
| category      | NVARCHAR(100) | Broad classification of the product. |
| subcategory   | NVARCHAR(100) | More specific classification under the category. |
| maintenance   | NVARCHAR(50)  | Indicates if the product is under maintenance or requires special handling. |
| product_cost  | DECIMAL(18,2) | The cost price of the product. |
| product_line  | NVARCHAR(100) | The product line under which this product falls. |
| start_date    | DATE         | The date when the product was introduced into the system. |

<hr style="border:2px solid gray">

### 3. gold.fact_sales  

- **Purposes:** Stores transactional sales data, linking products and customers for revenue analysis.  
- **Columns:**  

| Column Name   | DataType      | Description |
|--------------|--------------|------------|
| order_number | NVARCHAR(50) | Unique identifier for each sales order. |
| product_key  | INT          | Foreign key linking to `gold.dim_product`, identifying the sold product. |
| customer_key | INT          | Foreign key linking to `gold.dim_customers`, identifying the purchasing customer. |
| order_date   | DATE         | The date when the order was placed. |
| shipping_date | DATE        | The date when the order was shipped. |
| due_date     | DATE         | The expected delivery date of the order. |
| sales_amount | DECIMAL(18,2) | Total revenue generated from the sale. |
| quantity     | INT          | The number of units sold. |
| price        | DECIMAL(18,2) | Unit price of the product at the time of sale. |

<hr style="border:2px solid gray">

