-- ==============================================================================
-- Supply Chain Fulfillment & Delivery Bottleneck Analysis
-- Dialect: PostgreSQL / SQLite compatible
-- Dataset: Brazilian E-Commerce Public Dataset (Olist)
-- ==============================================================================

-- Stage 1: Clean timestamps, calculate milestone durations, and flag SLA breaches
WITH clean_orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        -- Operational Milestones (Hours & Days)
        ROUND(CAST((julianday(order_delivered_carrier_date) - julianday(order_approved_at)) * 24 AS NUMERIC), 2) AS warehouse_processing_hours,
        ROUND(CAST(julianday(order_delivered_customer_date) - julianday(order_delivered_carrier_date) AS NUMERIC), 2) AS carrier_transit_days,
        ROUND(CAST(julianday(order_delivered_customer_date) - julianday(order_estimated_delivery_date) AS NUMERIC), 2) AS sla_variance_days,
        CASE 
            WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 
            ELSE 0 
        END AS is_late_delivery
    FROM olist_orders
    WHERE order_status = 'delivered'
      AND order_approved_at IS NOT NULL
      AND order_delivered_carrier_date IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
),

-- Stage 2: Join geolocation and order economics for route segmentation
route_metrics AS (
    SELECT
        co.order_id,
        co.warehouse_processing_hours,
        co.carrier_transit_days,
        co.sla_variance_days,
        co.is_late_delivery,
        c.customer_state,
        s.seller_state,
        s.seller_state || ' -> ' || c.customer_state AS fulfillment_route,
        oi.freight_value,
        oi.price AS order_item_value,
        r.review_score
    FROM clean_orders co
    INNER JOIN olist_order_items oi ON co.order_id = oi.order_id
    INNER JOIN olist_customers c ON co.customer_id = c.customer_id
    INNER JOIN olist_sellers s ON oi.seller_id = s.seller_id
    LEFT JOIN olist_order_reviews r ON co.order_id = r.order_id
)

-- Stage 3: Aggregated Route-Level Performance Metrics
SELECT
    fulfillment_route,
    seller_state,
    customer_state,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(warehouse_processing_hours), 1) AS avg_warehouse_hours,
    ROUND(AVG(carrier_transit_days), 1) AS avg_transit_days,
    ROUND(AVG(sla_variance_days), 1) AS avg_delivery_variance_days,
    ROUND(100.0 * SUM(is_late_delivery) / COUNT(DISTINCT order_id), 2) AS sla_breach_rate_pct,
    ROUND(AVG(review_score), 2) AS avg_customer_rating,
    ROUND(AVG(freight_value), 2) AS avg_freight_cost
FROM route_metrics
GROUP BY fulfillment_route, seller_state, customer_state
HAVING COUNT(DISTINCT order_id) >= 150
ORDER BY sla_breach_rate_pct DESC;
