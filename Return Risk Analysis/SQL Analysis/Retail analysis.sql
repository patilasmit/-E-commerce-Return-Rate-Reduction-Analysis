CREATE DATABASE RETAIL_PROJECT;
USE RETAIL_PROJECT;
SHOW TABLES;
SELECT * FROM ORDERS;
SELECT * FROM PEOPLE;
select * from `returns`;

 -------- Retail Business Performance & Profitability Analysis -----------
------ 1. Data Cleaning & Preparation
----- Create unified view with returns and people ------ 
CREATE VIEW retail_cleans AS
SELECT
o.`Order ID` AS Order_ID,
o.`Order Date` AS Order_Date,
o.`Ship Date` AS Ship_Date,
DATEDIFF(o.`Ship Date`, o.`Order Date`) AS Days_to_Ship,
o.`Customer ID` AS Customer_ID,
o.`Customer Name` AS Customer_Name,
o.Sales,
o.Quantity,
o.Discount,
o.Profit,
o.Region,
o.City,
o.`State/Province`,
o.Category,
o.`Sub-Category` AS Sub_Category,
o.`Product ID` AS Product_ID,
o.`Product Name` AS Product_Name,
o.Segment,
o.`Ship Mode` AS Ship_Mode,
ROUND(o.Profit / NULLIF(o.Sales, 0), 2) AS Profit_Margin,
CASE WHEN r.`Order ID` IS NOT NULL THEN 1 ELSE 0 END AS Is_Returned
FROM orders o
LEFT JOIN `returns` r ON o.`Order ID` = r.`Order ID`
LEFT JOIN people p ON o.Region = p.Region;

SELECT * FROM RETAIL_CLEAN;	

 ----- Insightful Queries --------

-- Q1: Top 10 most returned products by count
SELECT Product_Name, COUNT(*) AS Return_Count
FROM retail_clean
WHERE Is_Returned = 1
GROUP BY Product_Name
ORDER BY Return_Count DESC
LIMIT 10;

-- Q2: Return rate by category
SELECT Category, 
COUNT(CASE WHEN Is_Returned = 1 THEN 1 END)*100.0 / COUNT(*) AS Return_Rate
FROM retail_clean
GROUP BY Category;

-- Q3: Profit margin by shipping mode
SELECT Ship_Mode, ROUND(AVG(Profit_Margin), 2) AS Avg_Profit_Margin
FROM retail_clean
GROUP BY Ship_Mode;

-- Q4: Top 5 loss-making sub-categories
SELECT Sub-Category, SUM(Profit) AS Total_Profit
FROM retail_clean
GROUP BY Sub-Category
ORDER BY Total_Profit ASC
LIMIT 5;

-- Q5: Monthly profit trend
SELECT FORMAT(Order_Date, 'yyyy-MM') AS Month, SUM(Profit) AS Monthly_Profit
FROM retail_clean
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;

-- Q6: Regional sales vs returns
SELECT Region,
SUM(Sales) AS Total_Sales,
COUNT(CASE WHEN Is_Returned = 1 THEN 1 END) AS Total_Returns
FROM retail_clean
GROUP BY Region;

-- Q7: Most profitable managers
SELECT Manager_Name, SUM(Profit) AS Total_Profit
FROM retail_clean
GROUP BY Manager_Name
ORDER BY Total_Profit DESC
LIMIT 5;

-- Q8: Product discount vs return rate
SELECT
ROUND(Discount, 2) AS Discount_Level,
COUNT(*) AS Order_Count,
COUNT(CASE WHEN Is_Returned = 1 THEN 1 END)*100.0 / COUNT(*) AS Return_Rate
FROM retail_clean
GROUP BY ROUND(Discount, 2)
ORDER BY Discount_Level;

-- Q9: Profit by state with return rate
SELECT State,
SUM(Profit) AS Total_Profit,
COUNT(CASE WHEN Is_Returned = 1 THEN 1 END)*100.0 / COUNT(*) AS Return_Rate
FROM retail_clean
GROUP BY State
ORDER BY Total_Profit DESC;

-- Q10: Average shipping time per category
SELECT Category, AVG(Days_to_Ship) AS Avg_Days_To_Ship
FROM retail_clean
GROUP BY Category;