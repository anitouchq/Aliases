-- MySQL dump-style export for alias_db
-- Compatible with MySQL 8.0.
-- This is a prepared importable SQL export; replace it with the output
-- of mysqldump after running the assignment to obtain the actual server dump.

CREATE DATABASE IF NOT EXISTS alias_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE alias_db;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL,
  city VARCHAR(100) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_customers_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE orders (
  id INT NOT NULL AUTO_INCREMENT,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(30) NOT NULL,
  PRIMARY KEY (id),
  KEY idx_orders_customer_id (customer_id),
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE employees (
  id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  position VARCHAR(100) NOT NULL,
  manager_id INT DEFAULT NULL,
  PRIMARY KEY (id),
  KEY idx_employees_manager_id (manager_id),
  CONSTRAINT fk_employees_manager FOREIGN KEY (manager_id) REFERENCES employees (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO customers (id, name, email, city, created_at) VALUES
(1,'Иван Иванов','ivan@example.com','Москва','2026-09-20 10:00:00'),
(2,'Пётр Петров','petr@example.com','Санкт-Петербург','2026-09-21 11:30:00'),
(3,'Мария Сидорова','maria@example.com','Москва','2026-09-22 09:15:00'),
(4,'Алексей Смирнов','alex@example.com','Казань','2026-09-23 14:45:00'),
(5,'Ольга Кузнецова','olga@example.com','Новосибирск','2026-09-24 16:20:00');

INSERT INTO orders (id, customer_id, order_date, amount, status) VALUES
(1,1,'2026-10-01',1500.00,'completed'),
(2,2,'2026-10-05',2300.50,'completed'),
(3,1,'2026-10-03',750.00,'pending'),
(4,3,'2026-10-07',3200.00,'completed'),
(5,4,'2026-10-10',1200.00,'cancelled'),
(6,5,'2026-10-12',4100.00,'pending');

INSERT INTO employees (id, name, position, manager_id) VALUES
(1,'Андрей Волков','CEO',NULL),
(2,'Елена Морозова','Руководитель отдела продаж',1),
(3,'Дмитрий Соколов','Руководитель разработки',1),
(4,'Анна Белова','Менеджер по продажам',2),
(5,'Игорь Павлов','Менеджер по продажам',2),
(6,'Сергей Фёдоров','Разработчик',3);

SET FOREIGN_KEY_CHECKS = 1;
