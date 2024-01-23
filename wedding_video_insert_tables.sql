USE wedding_video_company_db;

CREATE TABLE customers (
customer_id INT,
first_name VARCHAR(255),
last_name VARCHAR(255),
home_state VARCHAR(255),
phone_number VARCHAR(255),
email VARCHAR(255),
PRIMARY KEY (customer_id)
);

CREATE TABLE team (
videographer_id INT,
first_name VARCHAR(255),
last_name VARCHAR(255),
PRIMARY KEY (videographer_id)
);

CREATE TABLE orders (
order_id INT,
customer_id INT,
package_type INT,
wedding_date VARCHAR(255),
booked_date VARCHAR(255),
order_amount FLOAT,
venue_state VARCHAR(255),
videographer_id INT,
videographer_amount FLOAT,
hours_of_coverage FLOAT,
PRIMARY KEY (order_id),
FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
FOREIGN KEY (videographer_id) REFERENCES team(videographer_id)
);

LOAD DATA LOCAL INFILE '/Users/austinshirk/Documents/cs/Projects/wedding_video_project/wedding_customer_table.csv'
INTO TABLE customers
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6)
SET
customer_id = IF(@col1 = '', NULL, @col1),
first_name = IF(@col2 = '', NULL, @col2),
last_name = IF(@col3 = '', NULL, @col3),
home_state = IF(@col4 = '', NULL, @col4),
phone_number = IF(@col5 = '', NULL, @col5),
email = IF(@col6 = '', NULL, @col6);

select *
from customers

LOAD DATA LOCAL INFILE '/Users/austinshirk/Documents/cs/Projects/wedding_video_project/wedding_team_table.csv'
INTO TABLE team
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @col2, @col3)
SET
videographer_id = IF(@col1 = '', NULL, @col1),
first_name = IF(@col2 = '', NULL, @col2),
last_name = IF(@col3 = '', NULL, @col3)

select *
from team

LOAD DATA LOCAL INFILE '/Users/austinshirk/Documents/cs/Projects/wedding_video_project/wedding_order_table.csv'
INTO TABLE orders
FIELDS TERMINATED BY ","
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@col1, @col2, @col3, @col4, @col5, @col6, @col7, @col8, @col9, @col10)
SET
order_id = IF(@col1 = '', NULL, @col1),
customer_id = IF(@col2 = '', NULL, @col2),
package_type  = IF(@col3 = '', NULL, @col3),
wedding_date = IF(@col4 = '', NULL, @col4),
booked_date = IF(@col5 = '', NULL, @col5),
order_amount = IF(@col6 = '', NULL, @col6),
venue_state = IF(@col7 = '', NULL, @col7),
videographer_id = IF(@col8 = '', NULL, @col8),
videographer_amount  = IF(@col9 = '', NULL, @col9),
hours_of_coverage = IF(@col10 = '', NULL, @col10)

SELECT *
FROM orders

-- convert dates to date data type
ALTER TABLE orders
ADD COLUMN new_wedding_date DATE;

UPDATE orders
SET new_wedding_date = STR_TO_DATE(wedding_date, '%m/%d/%y');

ALTER TABLE orders
DROP COLUMN wedding_date;

ALTER TABLE orders
RENAME COLUMN new_wedding_date TO wedding_date;

ALTER TABLE orders
ADD COLUMN new_booked_date DATE;

UPDATE orders
SET new_booked_date = STR_TO_DATE(booked_date, '%m/%d/%y');

ALTER TABLE orders
DROP COLUMN booked_date;

ALTER TABLE orders
RENAME COLUMN new_booked_date TO booked_date;










