/*

Each of the following case study questions can be answered using a single SQL statement:

- What is the total amount each customer spent at the restaurant?
- How many days has each customer visited the restaurant?
- What was the first item from the menu purchased by each customer?
- What is the most purchased item on the menu and how many times was it purchased by all customers?
- Which item was the most popular for each customer?
- Which item was purchased first by the customer after they became a member?
- Which item was purchased just before the customer became a member?
- What is the total items and amount spent for each member before they became a member?
- If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
  - how many points would each customer have?
- In the first week after a customer joins the program (including their join date) 
  they earn 2x points on all items, not just sushi 
  - how many points do customer A and B have at the end of January?

*/

--total_sales_by_each_customer
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

--days_each_customer_visited
SELECT
  customer_id,
  COUNT(DISTINCT order_date) AS days_visited
FROM
  sales
GROUP BY
  customer_id;

--1st_item_purchased_by_each_customer
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

--the_most_purchased_item_&_total(count)_purchase_of_each_item
SELECT m.product_name, s.product_id, COUNT(s.product_id) AS purchase_count
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name
ORDER BY purchase_count DESC
LIMIT 1;

--most_popular_item_by_each_customer
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

--least_popular_item_by_each_customer
WITH customer_product_count AS (
  SELECT
    s.customer_id,
    m.product_name,
    COUNT(s.product_id) AS purchase_count
  FROM
    sales s
  JOIN 
    menu m ON s.product_id = m.product_id
  GROUP BY
    s.customer_id,
    m.product_name
)
SELECT
  customer_id,
  product_name,
  purchase_count
FROM (
  SELECT
    customer_id, product_name, purchase_count,
    ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY purchase_count ASC) AS rn
  FROM customer_product_count
)
AS ranked_products
WHERE rn = 1

--item_purchased_1st_after_become_member
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

--items_purchased_before_becoming_member
SELECT s.customer_id, s.order_date, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date = (
  SELECT MAX (s2.order_date)
  FROM sales s2
  WHERE s2.customer_id = s.customer_id
  AND s2.order_date < mb.join_date
)

ORDER BY s.customer_id;

-- What is the total items and amount spent for each member before they became a member?
-- total_items_amount_spent_for_each_member_before_become_member

SELECT 
  s.customer_id,
  COUNT (s.product_id) AS total_items,
  SUM (m.price) AS total_amount_spent
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date < mb.join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

/*
If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
  - how many points would each customer have?
*/

-- how_many_points_each_customer_has_meeting_said_conditions

SELECT
  s.customer_id,
  SUM(
    case
      WHEN m.product_name = 'sushi' THEN m.price * 20 -- 2x multiplier for sushi (20 points per $1)
      ELSE m.price * 10 -- 10 points per $1
    END
  ) AS total_points
FROM sales s
JOIN menu m ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY total_points DESC;

/*
In the first week after a customer joins the program (including their join date) 
  they earn 2x points on all items, not just sushi 
  - how many points do customer A and B have at the end of January?
*/
-- total_points_for_customer_AB_meeting_criteria_before_endjan
SELECT
  s.customer_id,
  SUM(
    case
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
WHERE s.order_date <= '2021-01-31' -- limit to purchase date made before the end of Jan
AND s.customer_id IN ('A', 'B') -- return result for only customer A and B
GROUP BY s.customer_id
ORDER BY s.customer_id;