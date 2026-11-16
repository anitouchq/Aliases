-- SQL Aliases practice
-- MySQL 8.0
-- Run this file after MySQL container is ready.

CREATE DATABASE IF NOT EXISTS alias_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE alias_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE orders (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(30) NOT NULL,
    CONSTRAINT fk_orders_customer
      FOREIGN KEY (customer_id) REFERENCES customers(id)
) ENGINE=InnoDB;

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    CONSTRAINT fk_employees_manager
      FOREIGN KEY (manager_id) REFERENCES employees(id)
) ENGINE=InnoDB;

INSERT INTO customers (id, name, email, city, created_at) VALUES
(1, 'Иван Иванов', 'ivan@example.com', 'Москва', '2026-09-20 10:00:00'),
(2, 'Пётр Петров', 'petr@example.com', 'Санкт-Петербург', '2026-09-21 11:30:00'),
(3, 'Мария Сидорова', 'maria@example.com', 'Москва', '2026-09-22 09:15:00'),
(4, 'Алексей Смирнов', 'alex@example.com', 'Казань', '2026-09-23 14:45:00'),
(5, 'Ольга Кузнецова', 'olga@example.com', 'Новосибирск', '2026-09-24 16:20:00');

INSERT INTO orders (id, customer_id, order_date, amount, status) VALUES
(1, 1, '2026-10-01', 1500.00, 'completed'),
(2, 2, '2026-10-05', 2300.50, 'completed'),
(3, 1, '2026-10-03', 750.00, 'pending'),
(4, 3, '2026-10-07', 3200.00, 'completed'),
(5, 4, '2026-10-10', 1200.00, 'cancelled'),
(6, 5, '2026-10-12', 4100.00, 'pending');

INSERT INTO employees (id, name, position, manager_id) VALUES
(1, 'Андрей Волков', 'CEO', NULL),
(2, 'Елена Морозова', 'Руководитель отдела продаж', 1),
(3, 'Дмитрий Соколов', 'Руководитель разработки', 1),
(4, 'Анна Белова', 'Менеджер по продажам', 2),
(5, 'Игорь Павлов', 'Менеджер по продажам', 2),
(6, 'Сергей Фёдоров', 'Разработчик', 3);

-- 1. Table aliases
SELECT c.id, c.name, c.city
FROM customers AS c
ORDER BY c.id;

-- 2. Column aliases
SELECT
    c.name AS customer_name,
    c.email AS contact_email,
    c.city AS residence
FROM customers AS c;

-- 3. Table and column aliases together
SELECT
    o.id AS order_number,
    o.order_date AS placed_on,
    o.amount AS order_total
FROM orders AS o
ORDER BY placed_on;

-- 4. JOIN with aliases
SELECT
    c.name AS customer_name,
    o.id AS order_number,
    o.amount AS order_amount,
    o.status AS order_status
FROM customers AS c
INNER JOIN orders AS o ON o.customer_id = c.id
ORDER BY c.name, o.order_date;

-- 5. LEFT JOIN: customers with and without orders
SELECT
    c.name AS customer_name,
    COUNT(o.id) AS orders_count
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY orders_count DESC, customer_name;

-- 6. Self-join: employee and their manager
SELECT
    e.name AS employee_name,
    e.position AS employee_position,
    m.name AS manager_name
FROM employees AS e
LEFT JOIN employees AS m ON e.manager_id = m.id
ORDER BY e.id;

-- 7. Ambiguous column example (intentionally invalid; kept as a comment)
-- SELECT id, name
-- FROM customers AS c
-- JOIN orders AS o ON o.customer_id = c.id;
-- Error: Column 'id' is ambiguous.
-- Correct version:
SELECT
    c.id AS customer_id,
    c.name AS customer_name,
    o.id AS order_id
FROM customers AS c
JOIN orders AS o ON o.customer_id = c.id
ORDER BY c.id, o.id;

-- 8. Derived table alias
SELECT
    customer_totals.customer_id,
    customer_totals.total_spent
FROM (
    SELECT
        o.customer_id,
        SUM(o.amount) AS total_spent
    FROM orders AS o
    GROUP BY o.customer_id
) AS customer_totals
ORDER BY customer_totals.total_spent DESC;

-- 9. Scalar subquery with an alias
SELECT
    c.name AS customer_name,
    (
        SELECT COUNT(*)
        FROM orders AS o
        WHERE o.customer_id = c.id
    ) AS orders_count
FROM customers AS c
ORDER BY orders_count DESC, customer_name;

-- 10. Alias in ORDER BY (valid)
SELECT
    o.customer_id,
    SUM(o.amount) AS total_amount
FROM orders AS o
GROUP BY o.customer_id
ORDER BY total_amount DESC;

-- 11. Alias in GROUP BY (MySQL supports this)
SELECT
    c.city AS customer_city,
    COUNT(*) AS customers_count
FROM customers AS c
GROUP BY customer_city
ORDER BY customers_count DESC, customer_city;

-- 12. Alias in HAVING (MySQL supports this)
SELECT
    o.customer_id,
    SUM(o.amount) AS total_amount
FROM orders AS o
GROUP BY o.customer_id
HAVING total_amount > 2000
ORDER BY total_amount DESC;

-- 13. WHERE cannot use a SELECT-list alias at the same query level.
-- Intentionally invalid example (do not uncomment):
-- SELECT amount * 1.20 AS amount_with_tax
-- FROM orders
-- WHERE amount_with_tax > 2000;
-- Correct version: repeat the expression in WHERE.
SELECT
    o.id,
    o.amount * 1.20 AS amount_with_tax
FROM orders AS o
WHERE o.amount * 1.20 > 2000
ORDER BY amount_with_tax DESC;

-- 14. Correct alternative: use a derived table, then filter its alias.
SELECT calculated_orders.order_id, calculated_orders.amount_with_tax
FROM (
    SELECT
        o.id AS order_id,
        o.amount * 1.20 AS amount_with_tax
    FROM orders AS o
) AS calculated_orders
WHERE calculated_orders.amount_with_tax > 2000
ORDER BY calculated_orders.amount_with_tax DESC;

-- 15. Multiple aliases and aggregate functions
SELECT
    c.city AS city_name,
    COUNT(DISTINCT c.id) AS customers_count,
    COUNT(o.id) AS orders_count,
    COALESCE(SUM(o.amount), 0) AS revenue
FROM customers AS c
LEFT JOIN orders AS o ON o.customer_id = c.id
GROUP BY c.city
ORDER BY revenue DESC;

-- 16. Verify table contents
SELECT * FROM customers ORDER BY id;
SELECT * FROM orders ORDER BY id;
SELECT * FROM employees ORDER BY id;
