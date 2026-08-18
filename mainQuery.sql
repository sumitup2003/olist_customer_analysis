use olist_ecommerce;

SELECT
    o.order_id,
    COUNT(oi.order_id) AS item_count
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi ON o.order_id = oi.order_id
GROUP BY o.order_id
LIMIT 5;

-- total revenue, avg_order_value, total_orders
select 
COUNT(distinct od.order_id) as total_orders,
SUM(oi.price) as Total_revenue,
ROUND(sum(oi.price)/COUNT(DISTINCT od.order_id),2) as avg_ord_value
from 
olist_order_items_dataset oi
JOIN olist_orders_dataset od 
ON oi.order_id = od.order_id
WHERE od.order_status = "delivered";

-- Monthly revenue trend with growth %

with revenue as (
	select 
		date_format(od.order_purchase_timestamp, '%Y-%m') as `month`,
		ROUND(sum(oi.price),2) as revenue
    from olist_order_items_dataset oi
	JOIN olist_orders_dataset od 	
    ON oi.order_id = od.order_id
    WHERE od.order_status = "delivered"
    GROUP BY date_format(od.order_purchase_timestamp, '%Y-%m')
)
select 
	month,
    revenue,
    sum(revenue) OVER(order by month) as running_total,
    LAG(revenue) OVER(order by month) as previous_revenue,
    ROUND((revenue - LAG(revenue) OVER(order by month))/LAG(revenue) OVER(order by month)*100, 2) as mom_growth
from revenue
ORDER BY month;

with customer_orders as (
	select 
		oc.customer_unique_id,
        od.order_id,
        od.order_purchase_timestamp,
        oi.price
    from olist_orders_dataset od 
    JOIN olist_customers_dataset oc ON od.customer_id = oc.customer_id
    JOIN olist_order_items_dataset oi ON od.order_id = oi.order_id
    WHERE od.order_status = "delivered"
),

rfm as (
select 
	customer_unique_id,
    datediff(
		(select max(order_purchase_timestamp) from olist_orders_dataset),
        max(order_purchase_timestamp)
    ) as recency_days,
    COUNT(DISTINCT order_id) as frequency,
    ROUND(SUM(price),2) as monetary
from customer_orders
GROUP BY customer_unique_id
),

rfm_score as (
	select 
		customer_unique_id,
        recency_days,
        frequency,
        monetary,
        ntile(5) OVER (ORDER BY recency_days) as r_score,
        ntile(5) OVER (ORDER BY frequency DESC) as f_score,
        ntile(5) OVER (ORDER BY monetary DESC) as m_score
	from rfm
)

SELECT
    *,
    (6 - r_score) + (6 - f_score) + (6 - m_score) AS rfm_total_score,  
    CASE
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Champions'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'At Risk'
        WHEN r_score >= 4 AND f_score >= 4 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS customer_segment
FROM rfm_score
ORDER BY monetary DESC;

-- seller performance
with seller as (
select 
	oi.seller_id,
	oi.order_id,
	oi.price,
	oi.freight_value,
	od.order_status,
	od.order_delivered_customer_date,
	od.order_estimated_delivery_date
from
olist_order_items_dataset oi
JOIN olist_orders_dataset od ON oi.order_id = od.order_id
),

seller_calculation as (
select
	seller_id,
    COUNT(DISTINCT order_id) as orders_count,
    COUNT(*) as items_sold,
    ROUND(SUM(price),2) as gross_revenue,
    SUM(case when order_status = "delivered" then 1 else 0 end) as delivered_orders,
    sum(case when order_status = "delivered" and order_delivered_customer_date <= order_estimated_delivery_date then 1 else 0 end) as on_time_deliveries
from
seller
GROUP BY seller_id
),

seller_reviews as (
select 
	oi.seller_id,
    ROUND(avg(r.review_score),2) as avg_review_score
from
olist_order_items_dataset oi 
JOIN olist_order_reviews_dataset r ON oi.order_id = r.order_id
GROUP BY oi.seller_id
)
select *
from 
seller_calculation sc 
LEFT JOIN seller_reviews sr ON sc.seller_id = sr.seller_id
order by orders_count desc