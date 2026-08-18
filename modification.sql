create database olist_ecommerce;
use olist_ecommerce;

SELECT COUNT(*) FROM olist_customers_dataset;

SELECT * FROM olist_customers_dataset LIMIT 5;

SELECT 'customers' AS tbl, COUNT(*) FROM olist_customers_dataset
UNION ALL SELECT 'orders', COUNT(*) FROM olist_orders_dataset
UNION ALL SELECT 'order_items', COUNT(*) FROM olist_order_items_dataset
UNION ALL SELECT 'order_payments', COUNT(*) FROM olist_order_payments_dataset
UNION ALL SELECT 'order_reviews', COUNT(*) FROM olist_order_reviews_dataset
UNION ALL SELECT 'products', COUNT(*) FROM olist_products_dataset
UNION ALL SELECT 'sellers', COUNT(*) FROM olist_sellers_dataset
UNION ALL SELECT 'geolocation', COUNT(*) FROM olist_geolocation_dataset
UNION ALL SELECT 'category_translation', COUNT(*) FROM product_category_name_translation;

DESCRIBE olist_orders_dataset;

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_estimated_delivery_date DATETIME;

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_id VARCHAR(32) NOT NULL,
MODIFY COLUMN customer_id VARCHAR(32) NOT NULL;

ALTER TABLE olist_orders_dataset
ADD PRIMARY KEY (order_id);

ALTER TABLE olist_orders_dataset
MODIFY COLUMN order_status VARCHAR(20) NOT NULL;