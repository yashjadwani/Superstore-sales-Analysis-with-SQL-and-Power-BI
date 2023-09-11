Extra: Update null order_id with pattern identification

UPDATE superstore
SET order_id = CONCAT('CA-',YEAR(order_date),'-', Right(ABS(CHECKSUM(NEWID())),6))
WHERE order_id is null or order_id = '0';

Extra : checking Duplicates

select order_id, count(*) as n_rows from superstore group by Order_ID  HAVING count(*) > 1 order by n_rows desc

Extra : Checking NULL

========================================================================= 

Q. What percentage of total orders were shipped on the same date?

SELECT count(*) AS TotalOrders,
  sum(case when ship_date = order_date then 1 else 0 end) as SameDayShipped,
  round((cast(sum(case when ship_date = order_date then 1 else 0 end) as float) / count(*)) * 100, 2) as '%SameDayShipped'
FROM superstore a
INNER JOIN shipment b on a.order_Id = b.order_id; 

Q. Name top 5 customers with highest total value of orders.

SELECT top 5 Customer_Name,SUM(Sales) AS Total_Sales
FROM superstore
GROUP BY Customer_Name
ORDER BY Total_Sales DESC; 

Q. Find the top 5 items with the highest average sales per day.

SELECT TOP 5 Product_ID, Product_Name ,AVG(Sales) AS Avg_Sales_Per_Day
FROM superstore
GROUP BY Product_ID, Product_Name
ORDER BY Avg_Sales_Per_Day DESC;

Q. Write a query to find the average order value for each customer and rank the customers by their average order value

SELECT Customer_Name,AVG(Sales) AS Avg_Order_Value
FROM superstore
GROUP BY Customer_Name
ORDER BY Avg_Order_Value DESC;

Q. What is the most demanded sub-category in the west region?

SELECT Sub_Category
FROM superstore
WHERE Region = 'West'
GROUP BY Region, Sub_Category
ORDER BY Count(*) DESC;

Q. Which order has the highest number of items? (If there are many sort by most order value) 

SELECT TOP 5 Order_ID,Customer_Name, product_name sum(Quantity) as total_items, sum(sales) as sale_value 
FROM superstore
GROUP BY Order_ID,Customer_Name, product_name
ORDER BY total_items DESC, sale_value desc;

Q. Which order has the highest cumulative value?

SELECT TOP 5 Order_ID, product_name Customer_Name, sum(Sales) as Total_Amount
FROM superstore
GROUP BY Order_ID,Customer_Name ,product_name
ORDER BY Sum(Sales) DESC;

Q. Which segment’s order along with region is more likely to be shipped via first class?

SELECT Category,COUNT(*) as 'No. Of Times',Region
FROM shipment a
INNER JOIN superstore b
ON a.Order_ID = b.Order_ID
INNER JOIN category c
ON b.Sub_Category = c.Sub_Category
WHERE Ship_Mode = 'First Class'
GROUP BY Region,Category
ORDER BY Count(*) desc;

Q. Which city is least contributing to total revenue?

SELECT TOP 1 City, sum(Sales) as 'Total sales'
FROM superstore
GROUP BY City
ORDER BY Sum(Sales) DESC;


Q. What is the average time for orders to get shipped after order is placed?

SELECT Avg(DATEDIFF(day, Order_Date, ship_Date)) AS AVG_SHIPPING_DAYS
FROM superstore a
INNER JOIN shipment b
ON a.Order_ID = b.Order_ID;

Q. Which segment places the highest number of orders from each state? 

WITH cte AS
(
    SELECT state, segment, COUNT(order_id) AS total_orders
    FROM superstore
    GROUP BY state, segment
),
cte2 AS
(
    SELECT state, MAX(total_orders) AS max_orders
    FROM cte
    GROUP BY state
)
SELECT a.state, a.Segment, a.total_orders
FROM cte AS a
JOIN cte2 AS b
ON a.state = b.state AND a.total_orders = b.max_orders
ORDER BY state

Q. which segment places the largest individual orders from each state?

WITH cte AS
(
    SELECT state, segment, round(MAX(sales),2) AS total_sales, Order_ID, Customer_Name
    FROM superstore
    GROUP BY state, segment, Order_ID, Customer_Name
),
cte2 AS
(
    SELECT state, MAX(total_sales) AS max_sales
    FROM cte
    GROUP BY state
)
SELECT a.Order_ID, a.Customer_Name, a.state, a.Segment, a.total_sales
FROM cte AS a
JOIN cte2 AS b
ON a.state = b.state AND a.total_sales = b.max_sales
ORDER BY state

Q. Give the name of customers who ordered highest and lowest orders from each city.

WITH cte AS (
    SELECT city, 
           customer_name, 
           COUNT(order_id) AS num_orders
    FROM superstore
    GROUP BY city, customer_name
),
cte2 AS (
    SELECT city, 
           MIN(num_orders) AS lowest_order, 
           MAX(num_orders) AS highest_order
    FROM cte
    GROUP BY city
)
SELECT a.city,
       STRING_AGG(CASE WHEN a.num_orders = b.lowest_order THEN a.customer_name ELSE NULL END, ',') AS lowest_order_customers,
       min(b.lowest_order) as 'Lowest order count',
       STRING_AGG(CASE WHEN a.num_orders = b.highest_order THEN a.customer_name ELSE NULL END, ',') AS highest_order_customers,
        max(b.highest_order) as 'Highest order Count'
FROM cte a
JOIN cte2 b ON a.city = b.city
WHERE a.num_orders = b.lowest_order OR a.num_orders = b.highest_order
GROUP BY a.city;


Q. Find all the customers who individually ordered on 2 consecutive days where each day’s total order was more than 50 in value.

WITH cte AS (
    SELECT 
        customer_id, 
        customer_name, 
        order_date, 
        ROUND(SUM(sales), 2) as total_sales,
        LEAD(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS next_day,
        LEAD(order_date, 2) OVER (PARTITION BY customer_id ORDER BY order_date) AS n_next_day
    FROM superstore
    GROUP BY customer_id, customer_name, order_date
    HAVING ROUND(SUM(sales), 2) >= 50
)

SELECT DISTINCT 
    a.customer_name, 
    a.order_date, 
    a.next_day
FROM cte AS a
WHERE DATEDIFF(day, a.order_date, a.next_day) = 1 

Q. YoY growth in sales and Profit 

WITH cte AS (
    SELECT
        YEAR(order_date) AS year,
        round(SUM(sales), 3) AS total_sales,
        round(SUM(profit), 3) AS total_profit
    FROM superstore
    GROUP BY YEAR(order_date)
),
yoy_growth AS (
    SELECT
        year,
        total_sales,
        total_profit,
        LAG(total_sales) OVER (ORDER BY year) AS previous_total_sale,
        LAG(total_profit) OVER (ORDER BY year) AS previous_total_profit
    FROM cte
),
yoy_growth_percentage AS (
    SELECT
        year,
        total_sales,
        total_profit,
        previous_total_sale,
        previous_total_profit,
        round((total_sales / previous_total_sale - 1) * 100, 3) AS sales_growth_percentage,
        round((total_profit / previous_total_profit - 1) * 100, 3) AS profit_growth_percentage
    FROM yoy_growth
)
SELECT
    year,
    sales_growth_percentage,
    profit_growth_percentage
FROM yoy_growth_percentage;


Q. Region wise YoY growth

WITH cte AS (
    SELECT
        YEAR(order_date) AS year,
        region,
        round(SUM(sales), 3) AS total_sales,
        round(SUM(profit), 3) AS total_profit
    FROM superstore 
    GROUP BY YEAR(order_date), region
),
yoy_growth AS (
    SELECT
        year,
        region,
        total_sales,
        total_profit,
        LAG(total_sales) OVER (partition by region ORDER BY year) AS previous_total_sale,
        LAG(total_profit) OVER (partition by region  ORDER BY year) AS previous_total_profit
    FROM cte
),
yoy_growth_percentage AS (
    SELECT
        year,
        region,
        total_sales,
        total_profit,
        previous_total_sale,
        previous_total_profit,
        round((total_sales / previous_total_sale - 1) * 100, 3) AS sales_growth_percentage,
        round((total_profit / previous_total_profit - 1) * 100, 3) AS profit_growth_percentage
    FROM yoy_growth
)
SELECT
    year,
    region,
    sales_growth_percentage,
    profit_growth_percentage
FROM yoy_growth_percentage;


Q. Category and region wise YOY growth

WITH cte AS (
    SELECT
        YEAR(order_date) AS year,
        category,
        region,
        round(SUM(sales), 3) AS total_sales,
        round(SUM(profit), 3) AS total_profit
    FROM superstore a inner join category b  on a.sub_category = b.sub_category
    GROUP BY YEAR(order_date), category, region
),
yoy_growth AS (
    SELECT
        year,
        region,
        category,
        total_sales,
        total_profit,
        LAG(total_sales) OVER (partition by region,category ORDER BY year) AS previous_total_sale,
        LAG(total_profit) OVER (partition by region,category  ORDER BY year) AS previous_total_profit
    FROM cte
),
yoy_growth_percentage AS (
    SELECT
        year,
        category,
        region, 
        total_sales,
        total_profit,
        previous_total_sale,
        previous_total_profit,
        round((total_sales / previous_total_sale - 1) * 100, 3) AS sales_growth_percentage,
        round((total_profit / previous_total_profit - 1) * 100, 3) AS profit_growth_percentage
    FROM yoy_growth
)
SELECT
    year,
    category,
    region,
    total_sales,
    total_profit,
    sales_growth_percentage,
    profit_growth_percentage
FROM yoy_growth_percentage;

Q. Top 5 sub category in sales 

select top 5 a.sub_category,category,round(sum(sales),4) as Total_sales from superstore a inner join category b on a.Sub_Category = b.Sub_Category group by a.sub_category,category order by Total_sales desc

Q. Top 5 discount sub_category 

select top 5 a.sub_category,category,Discount from superstore a inner join category b on a.Sub_Category = b.Sub_Category group by a.sub_category,category,discount order by discount desc

Q. Top 10 loss making products

select top 10 Product_Name,a.sub_category,category, sum(profit) as Total_profit from superstore a inner join category b on a.Sub_Category = b.Sub_Category group by Product_Name,a.sub_category,category order by Total_profit

Q. Top 10 revenue generating cities 

select top 10 city, region, round(sum(sales),3) as Total_sales from superstore group by city, region order by Total_sales desc  

Q. Top 10 profit making cities

select top 10 city, region, round(sum(profit),3) as Total_sales from superstore group by city, region order by Total_sales desc  

Q. percentage of orders by shipment TYPE

SELECT 
    ship_mode,
    COUNT(*) AS total_orders,
    round((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM superstore)),3) AS percentage
FROM 
     superstore a inner join shipment b on a.Order_ID = b.Order_ID 
GROUP BY 
    ship_mode
ORDER BY 
    percentage desc;

================================================================================================================================

Extra: Detail Analysis of same day order which got delayed

SELECT 
    a.Order_ID,Customer_Name,state,Product_Name,
    category,Order_Date,ship_date,
    DATEDIFF(day,order_date,ship_date) as 'Delay(Days)', ship_mode
FROM
    shipment a
INNER JOIN
    superstore b ON a.Order_ID = b.Order_ID
INNER JOIN
    category c ON b.Sub_Category = c.Sub_Category
where 
    ship_mode = 'Same Day' and Ship_Date <> order_date;



Q. Find the maximum number of days for which total sales on each day kept rising.








