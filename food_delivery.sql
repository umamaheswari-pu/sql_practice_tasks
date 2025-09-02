create database food_delivery;
USE food_delivery;

-- Tables
CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(15)
) ENGINE=InnoDB;

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    CONSTRAINT fk_menu_restaurant
      FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
      ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
      ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_orders_item
      FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Prevent future duplicates (same customer, same item, same day)
ALTER TABLE orders
ADD CONSTRAINT uq_orders_unique_per_day UNIQUE (customer_id, item_id, order_date);

-- Seed data
INSERT INTO restaurants (name, location) VALUES
  ('Pizza Hub', 'Hyderabad'),
  ('Biryani Palace', 'Delhi'),
  ('Chicken with Rotti', 'Kadapa'),
  ('Dosa House', 'Kadapa');
update restaurants
  set name='andhara spice'
  where restaurant_id=3;
update restaurants
  set name='green park'
  where restaurant_id=4;
  select*from restaurants;

INSERT INTO customers (name, phone) VALUES
  ('Uma', '9999999999'),
  ('Ravi', '8888888888'),
  ('Lavanya', '6405064565'),
  ('Thulasi', '6305064565');

INSERT INTO menu_items (restaurant_id, item_name, price) VALUES
  (1, 'Cheese Pizza', 299.00),
  (1, 'Veg Burger', 149.00),
  (2, 'Chicken Biryani', 399.00),
  (3, 'Dosa', 100.00),
  (3, 'Chicken with Rotti', 150.00),
  (4, 'Butter Rotti with Mushroom', 220.00);

-- Correct orders (every item_id exists; no duplicates)
-- Uma -> Cheese Pizza
INSERT INTO orders (customer_id, item_id, order_date) VALUES (1, 1, '2025-09-01');
-- Ravi -> Chicken Biryani
INSERT INTO orders (customer_id, item_id, order_date) VALUES (2, 3, '2025-09-01');
-- Thulasi -> Chicken Biryani
INSERT INTO orders (customer_id, item_id, order_date) VALUES (4, 3, '2025-09-15');
-- Lavanya -> Dosa   (item_id = 4; NOT 7)
INSERT INTO orders (customer_id, item_id, order_date) VALUES (3, 4, '2025-09-15');
insert into orders (customer_id,item_id,order_date)values(2,4,'2025-09-19');
-- Reports
-- 1) All orders with customer & restaurant
SELECT o.order_id, c.name AS customer, m.item_name, r.name AS restaurant, o.order_date
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN menu_items m ON o.item_id = m.item_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
ORDER BY o.order_id;

-- 2) Top restaurants by orders
SELECT r.name AS restaurant, COUNT(*) AS total_orders
FROM orders o
JOIN menu_items m ON o.item_id = m.item_id
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
GROUP BY r.name
ORDER BY total_orders DESC, r.name;

-- 3) Customers who ordered more than 1 item
SELECT c.name AS customer, COUNT(*) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.name
HAVING COUNT(*) > 1
ORDER BY total_orders DESC, c.name;

-- 4) Sanity check: show any duplicates (should return 0 rows)
SELECT customer_id, item_id, order_date, COUNT(*) AS duplicate_cou
FROM orders
GROUP BY customer_id, item_id, order_date
HAVING COUNT(*) > 1;
