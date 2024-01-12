USE tiendas;

/*Evaluation of missing values*/ 
SELECT 'Invoice ID' FROM supermarket WHERE ('Invoice ID' IS NULL) OR ('Invoice ID' = ' ');
SELECT Branch FROM supermarket WHERE (Branch IS NULL) OR (Branch = ' ');
SELECT City FROM supermarket WHERE (City IS NULL) OR (City = ' ');
SELECT 'Customer type' FROM supermarket WHERE ('Customer type' IS NULL) OR ('Customer type' = ' ');
SELECT Gender FROM supermarket WHERE (Gender IS NULL) OR (Gender = ' ');
SELECT 'Product line' FROM supermarket WHERE ('Product line' IS NULL) OR ('Product line' = ' ');
SELECT 'Unit price' FROM supermarket WHERE ('Unit price' IS NULL) OR ('Unit price' = ' ');
SELECT Quantity FROM supermarket WHERE (Quantity IS NULL) OR (Quantity = ' ');
SELECT 'Tax 5%' FROM supermarket WHERE ('Tax 5%' IS NULL) OR ('Tax 5%' = ' ');
SELECT Total FROM supermarket WHERE (Total IS NULL) OR (Total = ' ');
SELECT Date FROM supermarket WHERE (Date IS NULL) OR (Date = ' ');
SELECT Time FROM supermarket WHERE (Time IS NULL) OR (Time = ' ');
SELECT Payment FROM supermarket WHERE (Payment IS NULL) OR (Payment = ' ');
SELECT cogs FROM supermarket WHERE (cogs IS NULL) OR (cogs = ' ');
SELECT 'gross margin' FROM supermarket WHERE ('gross margin' IS NULL) OR ('gross margin' = ' ');
SELECT percentage FROM supermarket WHERE (percentage IS NULL) OR (percentage = ' ');
SELECT 'gross income' FROM supermarket WHERE ('gross income' IS NULL) OR ('gross income' = ' ');
SELECT Rating FROM supermarket WHERE (Rating IS NULL) OR (Rating = ' ');

/*Normalization of titles and variables*/
ALTER TABLE supermarket CHANGE `Invoice ID` `Invoice_ID` VARCHAR(20) NOT NULL;
ALTER TABLE supermarket CHANGE `Branch` `Branch` VARCHAR(5) NOT NULL; 
ALTER TABLE supermarket CHANGE `City` `City` VARCHAR(30) NOT NULL;
ALTER TABLE supermarket CHANGE `Customer type` `Customer_type` VARCHAR(10) NOT NULL;
ALTER TABLE supermarket CHANGE `Gender` `Gender` VARCHAR(10) NOT NULL;
ALTER TABLE supermarket CHANGE `Product line` `Product_line` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL;
ALTER TABLE supermarket CHANGE `Unit price` `Unit_price` DECIMAL(6,2) NOT NULL;
ALTER TABLE supermarket CHANGE `Quantity` `Quantity` INT(100) NOT NULL;
ALTER TABLE supermarket CHANGE `Tax 5%` `Tax_5per` DECIMAL(8,4) NOT NULL;
ALTER TABLE supermarket CHANGE `Total` `Total`  DECIMAL(8,4) NOT NULL;
ALTER TABLE supermarket CHANGE `Time` `Time` TIME;
ALTER TABLE supermarket CHANGE `Payment` `Payment` VARCHAR(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_spanish_ci NOT NULL;
ALTER TABLE supermarket CHANGE `cogs` `Cogs` DECIMAL(6,2) NOT NULL;
ALTER TABLE supermarket CHANGE `gross margin percentage` `Gross_margin_per` DECIMAL(11,9) NOT NULL;
ALTER TABLE supermarket CHANGE `gross income` `Gross_income`  DECIMAL(7,4) NOT NULL;
ALTER TABLE supermarket CHANGE `Rating` `Rating`  DECIMAL(3,1) NOT NULL;


/* QUERIES */
-- 1. Cities where supermarket are located
SELECT Branch, City 
FROM supermarket 
GROUP BY Branch, City 
ORDER BY Branch;

-- 2. Total of transactions and sales by Branch
SELECT Branch, count(Invoice_ID) AS Sales, round(sum(Total),2) AS Total_sales
FROM supermarket
GROUP BY Branch
ORDER BY Branch;

-- 3. Proportion of women and men who buy in branches
SELECT Branch, Gender,count(Gender) AS Total_gender, round(sum(Total),2) AS Total_sales 
FROM supermarket
GROUP BY Branch, Gender 
ORDER BY Branch, sum(Total) DESC;

 -- 4. Product_line preferences according to Gender discriminating by branch
SELECT Branch, Product_line, Gender ,round(sum(Total),2) AS Total_sales
FROM supermarket
GROUP BY Branch, Product_line, Gender
ORDER BY Branch, Product_line, round(sum(Total),2) DESC;

-- 5. Total sales by Customer_type and branch
SELECT Branch, Customer_type, round(sum(Total),2) AS Total_sales
FROM supermarket
GROUP BY Branch, Customer_type 
ORDER BY Branch, sum(Total) DESC;

-- 6. Total sales by Customer_type and Gender
SELECT Branch, Customer_type, Gender, round(sum(Total),2) AS Total_sales
FROM supermarket
GROUP BY Branch, Customer_type, Gender 
ORDER BY Branch, sum(Total) DESC;

-- 7. Popular payment method for each of the branches (Percentage)
SELECT Branch, SUM(Total) AS Total_Price,
round((SUM(CASE WHEN Payment = 'Credit card' THEN Total ELSE NULL END))/SUM(Total)*100,2) AS 'Credit card',
round((SUM(CASE WHEN Payment = 'Ewallet' THEN Total ELSE NULL END))/SUM(Total)*100,2) AS 'Ewallet',
round((SUM(CASE WHEN Payment = 'Cash' THEN Total ELSE NULL END))/SUM(Total)*100,2) AS 'Cash'
FROM supermarket
GROUP BY Branch
ORDER BY Total_Price DESC;

-- 8. Popular payment method for each of the branches according Customer_type
SELECT Branch, Customer_type,
COUNT(CASE WHEN Payment = 'Credit card' THEN Total ELSE NULL END) AS 'Credit card',
COUNT(CASE WHEN Payment = 'Ewallet' THEN Total ELSE NULL END) AS 'Ewallet',
COUNT(CASE WHEN Payment = 'Cash' THEN Total ELSE NULL END) AS 'Cash'
FROM supermarket
GROUP BY Branch, Customer_type
ORDER BY Branch;

-- 9. Degree of customer satisfation according to Product_line
SELECT Product_line, Branch, round(SUM(Rating),1) AS Rating_total, round(sum(total),2) AS total_sales
FROM supermarket
GROUP BY Product_line, Branch
ORDER BY 3 DESC;

-- 10. Total sales and transactions made by Product_line  
SELECT Product_line, count(Quantity)  AS Units_sold, round(sum(total),2) AS Total_sales 
FROM supermarket
GROUP BY Product_line
ORDER BY count(Quantity) DESC;

 -- 11. Transactions and total sales by Product_line and Branch
SELECT Branch, Product_line, count(Quantity)  AS Units_sold, round(sum(Total),2) AS Total_sales
FROM supermarket
GROUP BY Branch, Product_line
ORDER BY Branch, count(Quantity) DESC;

-- 12. Best selling items
SELECT DISTINCT Branch, Product_line, SUM(Quantity)
FROM supermarket
GROUP BY Branch, Product_line
ORDER BY SUM(Quantity) desc;
  
 -- 13. Statistical analysis of total units sold monthly
 SELECT 
	STR_TO_DATE(Date, '%m/%d/%Y') as Monthly, 
	SUM(Quantity) AS Total_us, 
	ROUND(AVG(Quantity), 2) AS Average_us,
	round(STDDEV_POP(Quantity),3) AS Std_us,
	round(VAR_POP(Quantity),3) AS Variance_us
FROM supermarket
GROUP BY EXTRACT(MONTH FROM Monthly);

-- 14. Profits and Revenues of Branches
SELECT Branch, round(sum(Cogs),2) as Cost_of_goods, round(sum(Gross_income),2) as Profit, round((sum(Cogs) + sum(Gross_income)),2) as Revenue
FROM supermarket
GROUP BY Branch
ORDER BY Branch;

-- 15. Total monthly Gross_income of each Branch
WITH Branch AS ( SELECT Branch, STR_TO_DATE(Date, '%m/%d/%Y') AS 'Month', Gross_income
                 FROM supermarket
                 WHERE Branch ='A'), 
GI AS (SELECT 
	CASE
        WHEN (Month BETWEEN '2019-01-01' AND '2019-01-31')
		THEN Gross_income
        ELSE 0
        END AS 'January',
    CASE 
        WHEN(Month BETWEEN '2019-02-01' AND '2019-02-28') 
        THEN Gross_income
        ELSE 0
        END AS 'February',
    CASE 
        WHEN(Month BETWEEN '2019-03-01' AND '2019-03-31') 
        THEN Gross_income
        ELSE 0
        END AS 'March'
    FROM Branch)
SELECT SUM(January) AS 'Jan_gross_income', SUM(February) AS 'Feb_gross_income', SUM(March) AS 'Mar_gross_income' 
FROM GI;


WITH branch AS (SELECT Branch, STR_TO_DATE(Date, '%m/%d/%Y') AS 'Month', Gross_income
				FROM supermarket
				WHERE Branch ='B'), 
GI AS (SELECT 
	CASE
        WHEN (Month BETWEEN '2019-01-01' AND '2019-01-31')
		THEN Gross_income
        ELSE 0
        END AS 'January',
    CASE 
        WHEN(Month BETWEEN '2019-02-01' AND '2019-02-28') 
        THEN Gross_income
        ELSE 0
        END AS 'February',
    CASE 
        WHEN(Month BETWEEN '2019-03-01' AND '2019-03-31') 
        THEN Gross_income
        ELSE 0
        END AS 'March'
    FROM branch)
SELECT SUM(January) AS 'Jan_gross_income', SUM(February) AS 'Feb_gross_income', SUM(March) AS 'Mar_gross_income' 
FROM GI;


WITH Branch AS (SELECT Branch, STR_TO_DATE(Date, '%m/%d/%Y') AS 'Month', Gross_income
				FROM supermarket
				WHERE Branch ='C'), 
GI AS (SELECT 
	CASE
        WHEN (Month BETWEEN '2019-01-01' AND '2019-01-31')
		THEN Gross_income
        ELSE 0
        END AS 'January',
    CASE 
        WHEN(Month BETWEEN '2019-02-01' AND '2019-02-28') 
        THEN Gross_income
        ELSE 0
        END AS 'Febraury',
    CASE 
        WHEN(Month BETWEEN '2019-03-01' AND '2019-03-31') 
        THEN Gross_income
        ELSE 0
        END AS 'March'
    FROM Branch)
SELECT SUM(January) AS 'Jan_gross_income', SUM(Febraury) AS 'Feb_gross_income', SUM(March) AS 'Mar_gross_income' 
FROM GI;
