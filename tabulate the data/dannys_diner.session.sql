-- Table sales
CREATE TABLE sales (
  customer_id VARCHAR(10),  -- Increased size for customer_id
  order_date DATE,
  product_id INT,
  PRIMARY KEY (customer_id, product_id, order_date)  -- Composite primary key
);

-- Insert into sales
INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', 1),
  ('A', '2021-01-01', 2),
  ('A', '2021-01-07', 2),
  ('A', '2021-01-10', 3),
  ('A', '2021-01-11', 3),
  ('B', '2021-01-01', 2),
  ('B', '2021-01-02', 2),
  ('B', '2021-01-04', 1),
  ('B', '2021-01-11', 1),
  ('B', '2021-01-16', 3),
  ('B', '2021-02-01', 3),
  ('C', '2021-01-01', 3),
  ('C', '2021-01-07', 3);

-- Table menu
CREATE TABLE menu (
  product_id INT,
  product_name VARCHAR(20),  -- Increased size for product_name
  price INTEGER,
  PRIMARY KEY (product_id)  -- No foreign key constraint
);

-- Insert into menu
INSERT INTO menu
  (product_id, product_name, price)
VALUES
  (1, 'sushi', 10),   -- Removed quotes from integers
  (2, 'curry', 15),
  (3, 'ramen', 12);

-- Table members
CREATE TABLE members (
  customer_id VARCHAR(10),  -- Increased size for customer_id
  join_date DATE,
  PRIMARY KEY (customer_id)  -- No foreign key constraint
);

-- Insert into members
INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');