CREATE DATABASE My_project;
USE My_project;

SELECT * FROM customers;
SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;


ALTER TABLE customers
ADD PRIMARY KEY (customer_ID);

ALTER TABLE products
ADD PRIMARY KEY(Product_ID);

ALTER TABLE stores
ADD PRIMARY KEY(Store_ID);

ALTER TABLE sales
ADD PRIMARY KEY(Sale_ID);

ALTER TABLE sales
ADD CONSTRAINT sales_product
FOREIGN KEY (product_ID) REFERENCES products(Product_ID);

ALTER TABLE sales
ADD CONSTRAINT sales_customer
FOREIGN KEY (customer_ID) REFERENCES customers(customer_ID);

ALTER TABLE sales
ADD CONSTRAINT sales_store
FOREIGN KEY (store_ID) REFERENCES stores(store_ID);


-- Total revenue
SELECT round(sum(Total_sales),2) AS Total_revenue FROM sales;


-- Top 10 Products by revenue.
SELECT Product_Name, round(sum(total_sales),0) AS Revenue
 FROM sales 
 INNER JOIN products USING (product_ID)
 GROUP BY Product_ID,Product_Name
 ORDER BY Revenue DESC
 LIMIT 10;
 
-- Monthly Sales Trend (aggregate by month). 
 SELECT Month, round(sum(Total_sales),0) AS Revenue FROM sales
 GROUP BY Month
 ORDER BY revenue DESC;
 
 --  Revenue by Region and City.
 SELECT Region,City, round(sum(Total_sales)) AS Revenue FROM sales
 INNER JOIN stores USING (Store_ID)
 GROUP BY Region,City
 ORDER BY revenue DESC;
 
 
 -- Revenue by Age Group & Loyalty Status 
 SELECT count(Customer_ID) AS customer_count,Loyalty_Status,Age_Group,round((sum(Total_sales))) AS Revenue
 FROM customers
 INNER JOIN sales USING(Customer_ID)
 GROUP BY Customer_id, Age_Group,Loyalty_Status
 ORDER BY Revenue DESC;
 
 -- Store Ranking: Top 5 stores by sales. 
SELECT Store_ID,Store_Name, sum(Quantity) AS Qty_sold FROM stores
JOIN sales USING(store_id)
GROUP BY Store_ID, Store_Name
ORDER BY Qty_sold DESC
LIMIT 5;

-- Customers with more than 5 purchase
SELECT count(Customer_ID)AS customer_count,Customer_Name,Quantity FROM sales
JOIN customers USING(customer_ID)
GROUP BY Customer_Name, Quantity
HAVING Quantity >=5;


-- Region with most sales= North
SELECT Region, round(sum(total_sales)) AS Sale FROM stores
JOIN sales USING(Store_id)
GROUP BY Region
ORDER BY Sale DESC
LIMIT 1;

-- Do loyalty program members (Silver, Gold, Platinum) spend more than Regular customers?
SELECT c.Customer_id, Loyalty_Status,round(sum(Total_sales)) AS Total_spent
FROM customers c
INNER JOIN sales s 
ON c.Customer_id = s.Customer_ID
GROUP BY Customer_ID, Loyalty_Status
ORDER BY Total_spent DESC;

SELECT c.Customer_Id,
					CASE WHEN Loyalty_Status IN ("silver", "gold", "platinum") THEN "Loyalty_member"
					ELSE "Regular"
					END AS Loyalty_members,
round(sum(Total_sales)) AS Total_spent
FROM customers c
INNER JOIN sales s 
ON c.Customer_id = s.Customer_ID
GROUP BY Customer_ID,Loyalty_members
ORDER BY Total_spent DESC;
 

 
-- Which 3 products should the company promote more, based on sales revenue?
 SELECT Product_ID,Product_Name, round(sum(Total_sales)) AS Total_revenue 
 FROM products
 JOIN sales USING(product_ID)
 GROUP BY Product_ID,Product_Name
 ORDER BY Total_revenue DESC
 LIMIT 3;














DESCRIBE access_logs_large;
SELECT * FROM access_logs_large;
SELECT * FROM call_records_large;
SELECT * FROM forensic_events_large;
SELECT * FROM suspects_large;


-- checkin for missing or invalid data
SELECT count(name) FROM suspects_large
WHERE  name IS NULL;

-- To find who accessed the vault room at the time of incident
SELECT suspect_id, door_accessed, access_time, success_flag
FROM access_logs_large
WHERE door_accessed = "vault room" AND success_flag = "true"
AND access_time BETWEEN '2025-06-01 19:50:00' AND '2025-06-01 20:03:00'; 

-- who called the victim around the time of incident
SELECT call_id,s.suspect_id,name,call_time,recipient_relation  FROM call_records_large c
JOIN suspects_large s ON c.suspect_id = s.suspect_id
WHERE call_time BETWEEN '2025-06-01 19:50:00' AND '2025-06-01 20:03:00'
AND recipient_relation = "Victim" 
GROUP BY call_id, suspect_id,name,call_time 
ORDER BY call_time;
-- Susan Knight


-- checking Alibi
SELECT s.suspect_id, name,alibi,access_time,door_accessed, success_flag FROM suspects_large s
JOIN access_logs_large a ON s.suspect_id = a.suspect_id
WHERE access_time BETWEEN  '2025-06-01 19:50:00' AND '2025-06-01 20:03:00'
AND success_flag = "true";

SELECT s.suspect_id, name,alibi,access_time,door_accessed,relation_to_victim, success_flag 
FROM suspects_large s
JOIN access_logs_large a ON s.suspect_id = a.suspect_id
WHERE access_time BETWEEN  '2025-06-01 19:45:00' AND '2025-06-01 20:03:00'
AND success_flag = "true" AND door_accessed = "vault room";


SELECT * FROM suspects_large;


SELECT DISTINCT *
FROM access_logs_large
WHERE access_time BETWEEN '2025-06-01 20:00:00' AND '2025-06-01 20:03:00'
 AND success_flag = "true";
 
-- who killed Ronald Greene 
SELECT s.suspect_id, name,access_time,door_accessed,alibi, success_flag from suspects_large s
JOIN access_logs_large a ON s.suspect_id = a.suspect_id
WHERE door_accessed = "vault room"AND success_flag = "true"
AND access_time BETWEEN '2025-06-01 19:50:00' AND '2025-06-01 20:03:00' ;
-- Jamie Bennett


-- top 3 suspects
SELECT suspect_id, Count(*) AS access_count
FROM access_logs_large
WHERE door_accessed = "vault room" AND success_flag = "true"
AND access_time BETWEEN '2025-06-01 19:50:00' AND '2025-06-01 20:03:00'
GROUP BY suspect_id
ORDER BY access_count DESC
LIMIT 3;
-- Robin Ahmed, Jamie Bennett and Samira Shaw


-- suspects whose alibi doesn't match forensic timeline 
SELECT a.suspect_id, name, alibi,access_time, door_accessed,success_flag 
FROM suspects_large s
JOIN access_logs_large a ON s.suspect_id = a.suspect_id
WHERE alibi != door_accessed;
-- All


-- was anyone in the vault shortly before and after 8pm
SELECT s.suspect_id,name, access_time, door_accessed, success_flag
FROM suspects_large s
JOIN access_logs_large a ON s.suspect_id = a.suspect_id
WHERE door_accessed = "vault room" AND success_flag = "true"
AND access_time BETWEEN '2025-06-01 19:55:00' AND '2025-06-01 20:03:00';
-- Robin Ahmed and Jamie Bennett

-- what does the call log reveal after the final call
SELECT call_id,s.suspect_id,name,call_time,recipient_relation  FROM call_records_large c
JOIN suspects_large s ON c.suspect_id = s.suspect_id
WHERE call_time BETWEEN '2025-06-01 19:50:00' AND '2025-06-01 20:03:00'
AND recipient_relation = "Victim" 
GROUP BY call_id, suspect_id,name,call_time 
ORDER BY call_time;
-- Susan Knight

-- what does the forensic timeline says about time and manner of death
SELECT * FROM forensic_events_large
-- 



