-- ============================================================

use olist_ecommerce;
-- 1. ORDER ITEMS
-- ============================================================
ALTER TABLE olist_order_items_dataset
MODIFY COLUMN order_id VARCHAR(32) NOT NULL,
MODIFY COLUMN order_item_id INT NOT NULL,
MODIFY COLUMN product_id VARCHAR(32) NOT NULL,
MODIFY COLUMN seller_id VARCHAR(32) NOT NULL,
MODIFY COLUMN shipping_limit_date DATETIME,
MODIFY COLUMN price DECIMAL(10,2),
MODIFY COLUMN freight_value DECIMAL(10,2);

ALTER TABLE olist_order_items_dataset
ADD PRIMARY KEY (order_id, order_item_id);

-- ============================================================
-- 2. ORDER PAYMENTS
-- ============================================================
ALTER TABLE olist_order_payments_dataset
MODIFY COLUMN order_id VARCHAR(32) NOT NULL,
MODIFY COLUMN payment_sequential INT NOT NULL,
MODIFY COLUMN payment_type VARCHAR(20),
MODIFY COLUMN payment_installments INT,
MODIFY COLUMN payment_value DECIMAL(10,2);

ALTER TABLE olist_order_payments_dataset
ADD PRIMARY KEY (order_id, payment_sequential);

-- ============================================================
-- 3. ORDER REVIEWS
-- ============================================================
ALTER TABLE olist_order_reviews_dataset
MODIFY COLUMN review_id VARCHAR(32) NOT NULL,
MODIFY COLUMN order_id VARCHAR(32) NOT NULL,
MODIFY COLUMN review_score INT,
MODIFY COLUMN review_comment_title VARCHAR(255),
MODIFY COLUMN review_comment_message TEXT,          -- genuinely free text, TEXT is correct here
MODIFY COLUMN review_creation_date DATETIME,
MODIFY COLUMN review_answer_timestamp DATETIME;

-- NOTE: review_id is NOT unique in this dataset (a few duplicates exist),
-- so we do NOT make it a primary key alone. Composite key instead:
ALTER TABLE olist_order_reviews_dataset
ADD PRIMARY KEY (review_id, order_id);

-- ============================================================
-- 4. PRODUCTS
-- ============================================================
ALTER TABLE olist_products_dataset
MODIFY COLUMN product_id VARCHAR(32) NOT NULL,
MODIFY COLUMN product_category_name VARCHAR(100),
MODIFY COLUMN product_name_lenght INT,
MODIFY COLUMN product_description_lenght INT,
MODIFY COLUMN product_photos_qty INT,
MODIFY COLUMN product_weight_g INT,
MODIFY COLUMN product_length_cm INT,
MODIFY COLUMN product_height_cm INT,
MODIFY COLUMN product_width_cm INT;

ALTER TABLE olist_products_dataset
ADD PRIMARY KEY (product_id);

-- ============================================================
-- 5. SELLERS
-- ============================================================
ALTER TABLE olist_sellers_dataset
MODIFY COLUMN seller_id VARCHAR(32) NOT NULL,
MODIFY COLUMN seller_zip_code_prefix VARCHAR(10),
MODIFY COLUMN seller_city VARCHAR(100),
MODIFY COLUMN seller_state VARCHAR(2);

ALTER TABLE olist_sellers_dataset
ADD PRIMARY KEY (seller_id);

-- ============================================================
-- 6. CUSTOMERS
-- ============================================================
ALTER TABLE olist_customers_dataset
MODIFY COLUMN customer_id VARCHAR(32) NOT NULL,
MODIFY COLUMN customer_unique_id VARCHAR(32),
MODIFY COLUMN customer_zip_code_prefix VARCHAR(10),
MODIFY COLUMN customer_city VARCHAR(100),
MODIFY COLUMN customer_state VARCHAR(2);

ALTER TABLE olist_customers_dataset
ADD PRIMARY KEY (customer_id);

-- ============================================================
-- 7. GEOLOCATION  (no primary key — zip codes repeat many times,
-- this table is just a lookup, not an entity table)
-- ============================================================
ALTER TABLE olist_geolocation_dataset
MODIFY COLUMN geolocation_zip_code_prefix VARCHAR(10),
MODIFY COLUMN geolocation_lat DECIMAL(10,7),
MODIFY COLUMN geolocation_lng DECIMAL(10,7),
MODIFY COLUMN geolocation_city VARCHAR(100),
MODIFY COLUMN geolocation_state VARCHAR(2);

-- ============================================================
-- 8. CATEGORY TRANSLATION
-- ============================================================
ALTER TABLE product_category_name_translation
MODIFY COLUMN product_category_name VARCHAR(100) NOT NULL,
MODIFY COLUMN product_category_name_english VARCHAR(100);

ALTER TABLE product_category_name_translation
ADD PRIMARY KEY (product_category_name);

-- ============================================================
-- 9. FOREIGN KEYS — run LAST, after every primary key above exists
-- ============================================================
ALTER TABLE olist_orders_dataset
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset(customer_id);

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_items_order
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id),
ADD CONSTRAINT fk_items_product
FOREIGN KEY (product_id) REFERENCES olist_products_dataset(product_id),
ADD CONSTRAINT fk_items_seller
FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset(seller_id);

ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);