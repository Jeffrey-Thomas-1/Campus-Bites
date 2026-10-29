CREATE DATABASE IF NOT EXISTS `campusBites`;
USE `campusBites`;

CREATE TABLE IF NOT EXISTS `Users` (
  `user_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `full_name` VARCHAR(120) NOT NULL,
  `student_id` VARCHAR(50) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `role` ENUM('student', 'staff') NOT NULL DEFAULT 'student',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_users_student_id` (`student_id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS `MENU` (
  `Food Name` VARCHAR(150) NOT NULL,
  `Food type` VARCHAR(80) NOT NULL,
  `Price` DECIMAL(10,2) NOT NULL,
  `rating` DECIMAL(2,1) NOT NULL DEFAULT 0.0,
  `Prep time` INT UNSIGNED NOT NULL COMMENT 'Preparation time in minutes',
  `in stock` BOOLEAN NOT NULL DEFAULT TRUE,
  `stock_number` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`Food Name`),
  CONSTRAINT `chk_menu_rating` CHECK (`rating` BETWEEN 0.0 AND 5.0)
) ENGINE=InnoDB;

INSERT IGNORE INTO `MENU`
  (`Food Name`, `Food type`, `Price`, `rating`, `Prep time`, `in stock`, `stock_number`)
VALUES
  ('Masala chai', 'Beverage', 45.00, 4.7, 7, TRUE, 40),
  ('Cappuccino', 'Beverage', 90.00, 4.6, 8, TRUE, 25),
  ('Ginger lemon tea', 'Beverage', 55.00, 4.5, 6, TRUE, 30),
  ('Iced latte', 'Beverage', 105.00, 4.4, 7, TRUE, 20),
  ('Hot chocolate', 'Beverage', 115.00, 4.8, 9, TRUE, 18),
  ('Fresh lime soda', 'Beverage', 65.00, 4.3, 4, TRUE, 35),
  ('Filter coffee', 'Beverage', 60.00, 4.8, 8, TRUE, 45),
  ('Mango lassi', 'Beverage', 100.00, 4.6, 6, TRUE, 20),
  ('Avocado toast', 'Breakfast', 140.00, 4.5, 8, TRUE, 15),
  ('Masala dosa', 'Breakfast', 110.00, 4.7, 12, TRUE, 20),
  ('Chicken burger', 'Fast food', 180.00, 4.6, 15, TRUE, 12),
  ('Paneer tikka bowl', 'Lunch', 165.00, 4.5, 18, TRUE, 14),
  ('Loaded fries', 'Snacks', 130.00, 4.2, 10, TRUE, 16),
  ('Chicken rice bowl', 'Lunch', 190.00, 4.4, 20, TRUE, 10),
  ('Idli sambar', 'Breakfast', 85.00, 4.6, 10, TRUE, 20),
  ('Egg breakfast wrap', 'Breakfast', 125.00, 4.3, 11, TRUE, 15),
  ('Peanut butter banana toast', 'Breakfast', 100.00, 4.2, 6, TRUE, 15),
  ('Samosa chaat', 'Snacks', 90.00, 4.5, 9, TRUE, 25),
  ('Veg spring rolls', 'Snacks', 115.00, 4.2, 12, TRUE, 18),
  ('Chicken popcorn', 'Snacks', 150.00, 4.4, 14, TRUE, 14),
  ('Veggie grilled sandwich', 'Fast food', 130.00, 4.3, 10, TRUE, 16),
  ('Margherita pizza', 'Fast food', 170.00, 4.5, 18, TRUE, 10),
  ('Chicken tikka roll', 'Fast food', 160.00, 4.4, 16, TRUE, 12);
