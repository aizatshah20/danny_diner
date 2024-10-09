# Dannys Diner

## Overview
This case study involves analyzing customer sales data from a restaurant. The provided dataset includes information on sales transactions, the restaurant's menu items, and customers who became members of the restaurant's loyalty program. The goal is to answer several analytical questions using SQL queries, focusing on customer purchasing behavior, most popular items, and the effect of the membership program.

The dataset is spread across three tables: `sales`, `menu`, and `members`.

## Database Schema
### Table: `sales`
Contains the transactions of customers with the restaurant, detailing which items were purchased and when.

| Column       | Type        | Description                             |
|--------------|-------------|-----------------------------------------|
| `customer_id`| VARCHAR(10) | Identifier for the customer             |
| `order_date` | DATE        | Date of the purchase                    |
| `product_id` | INT         | Identifier for the product purchased     |
**Primary Key**: (`customer_id`, `product_id`, `order_date`)

### Table: `menu`
Contains the product details including item names and their prices.

| Column        | Type        | Description                         |
|---------------|-------------|-------------------------------------|
| `product_id`  | INT         | Unique identifier for the product   |
| `product_name`| VARCHAR(20) | Name of the product                 |
| `price`       | INTEGER     | Price of the product (in dollars)   |
**Primary Key**: `product_id`

### Table: `members`
Contains the information of customers who joined the restaurant's loyalty program.

| Column       | Type        | Description                                |
|--------------|-------------|--------------------------------------------|
| `customer_id`| VARCHAR(10) | Unique identifier for the customer          |
| `join_date`  | DATE        | The date the customer joined the program    |
**Primary Key**: `customer_id`

### 1. Total Amount Each Customer Spent
**Query**: Calculate the total spending by each customer based on their purchases from the sales table, joined with the product prices from the menu table.
| Customer ID | Total Spent |
|-------------|-------------|
| B           | 74          |
| C           | 24          |
| A           | 64          |
```sql
SELECT 
  s.customer_id, 
  SUM(m.price) AS total_spent
FROM 
  sales s
JOIN 
  menu m 
ON 
  s.product_id = m.product_id
GROUP BY 
  s.customer_id;
```

### 2. Days Each Customer Visited the Restaurant
**Query**: Count the distinct days each customer visited the restaurant.

| Customer ID | Days Visited |
|-------------|--------------|
| A           | 4            |
| B           | 6            |
| C           | 2            |
```sql
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_visited
FROM
  sales
GROUP BY
  customer_id;
  ```

### 3. First Item Purchased by Each Customer
**Query**: Identify the first item each customer purchased by finding the minimum order date per customer.
## Customer Orders

| Customer ID | Order Date  | Product ID | Product Name |
|-------------|-------------|------------|--------------|
| A           | 2021-01-01  | 1          | sushi        |
| A           | 2021-01-01  | 2          | curry        |
| B           | 2021-01-01  | 2          | curry        |
| C           | 2021-01-01  | 3          | ramen        |
```sql
SELECT s.customer_id, s.order_date, s.product_id, m.product_name
FROM sales s
INNER JOIN (
  SELECT customer_id, MIN(order_date) AS first_order_date
  FROM sales
  GROUP BY customer_id
) AS first_orders
ON s.customer_id = first_orders.customer_id
AND s.order_date = first_orders.first_order_date
JOIN menu m ON s.product_id = m.product_id;
```

### 4. Most Purchased Item on the Menu
**Query**: Find the most purchased item across all customers.
| Product Name | Product ID | Purchase Count |
|--------------|------------|-----------------|
| ramen        | 3          | 6               |
```sql
SELECT m.product_name, s.product_id, COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;
```

### 5. Most Popular Item for Each Customer
**Query**: Identify the item each customer purchased the most.
| Customer ID | Product ID | Product Name | Purchase Count |
|-------------|------------|--------------|-----------------|
| A           | 2          | curry        | 2               |
| B           | 2          | curry        | 2               |
| C           | 3          | ramen        | 2               |
```sql
WITH customer_product_count AS (
  SELECT s.customer_id, s.product_id, p.product_name, COUNT(s.product_id) AS purchase_count
  FROM sales s
  JOIN menu p ON s.product_id = p.product_id
  GROUP BY s.customer_id, s.product_id, p.product_name
)
SELECT customer_id, product_id, product_name, purchase_count
FROM (
  SELECT customer_id, product_id, product_name, purchase_count,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY purchase_count DESC) AS rn
  FROM customer_product_count
) AS ranked_products
WHERE rn = 1;
```

### 6. First Item Purchased After Becoming a Member
**Query**: Find the first item each customer purchased after joining the membership program.
| Customer ID | Order Date  | Product Name |
|--------------|-------------|--------------|
| A            | 2021-01-07  | curry        |
| B            | 2021-01-11  | sushi        |
```sql
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date = (
  SELECT MIN(s2.order_date)
  FROM sales s2
  WHERE s2.customer_id = s.customer_id
    AND s2.order_date >= mb.join_date
)
ORDER BY customer_id;
```

### 7. Item Purchased Just Before Becoming a Member
**Query**: Find the item that each customer purchased right before becoming a member.
| Customer ID | Order Date  | Product Name |
|--------------|-------------|--------------|
| A            | 2021-01-01  | sushi        |
| A            | 2021-01-01  | curry        |
| B            | 2021-01-04  | sushi        |
```sql
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date = (
  SELECT MAX(s2.order_date)
  FROM sales s2
  WHERE s2.customer_id = s.customer_id
  AND s2.order_date < mb.join_date
)
ORDER BY s.customer_id;
```

### 8. Total Items and Amount Spent Before Becoming a Member
**Query**: Calculate the total number of items purchased and the total amount spent by each customer before they became a member.
| Customer ID | Total Items | Total Amount Spent |
|--------------|-------------|---------------------|
| A            | 2           | 25                  |
| B            | 3           | 40                  |
```sql
SELECT 
  s.customer_id,
  COUNT(s.product_id) AS total_items,
  SUM(m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

### 9. Points Calculation
**Query**: Calculate how many points each customer would have, assuming $1 spent equals 10 points, and sushi gives 2x points (20 points per $1).
|customer_id|total_points|
|:----|:----|
|B|940|
|A|740|
|C|240|
```sql
SELECT
  s.customer_id,
  SUM(
    CASE
      WHEN m.product_name = 'sushi' THEN m.price * 20 -- 2x points for sushi
      ELSE m.price * 10 -- 10 points for other items
    END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_points DESC;
```

### 10. Points After Joining Membership (First Week Bonus)
**Query**: Calculate the total points for customers A and B by the end of January, considering 2x points for the first week after joining the program (on all items) and 2x for sushi beyond that period.
|customer_id|total_points|
|:----|:----|
|A|1130|
|B|820|
```sql
SELECT
  s.customer_id,
  SUM(
    CASE
    -- 2x points for all items for the 1st week of join date
    WHEN s.order_date BETWEEN mb.join_date AND mb.join_date + INTERVAL '6 days'
    THEN m.price * 20
    -- 2x for sushi only after the 1st week
    WHEN m.product_name = 'sushi'
    THEN m.price * 20
    -- Normal 10 points per $1 for other items
    ELSE m.price * 10
  END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date <= '2021-01-31'
AND s.customer_id IN ('A', 'B')
GROUP BY s.customer_id
ORDER BY s.customer_id;
```

# Conclusion
This analysis gives valuable insights into customer purchasing behavior, popular menu items, and the impact of the loyalty program. By answering these questions, the restaurant can optimize its offerings, pricing, and promotions to increase sales and customer satisfaction.