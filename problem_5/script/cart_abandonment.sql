-- ================================================================
--  PROBLEM 1: E-Commerce Cart Abandonment Analysis
--
--  REAL-WORLD CONTEXT :
--  Industry average abandonment rate: 70-75%. Every 1% reduction
--  at a $10M/month revenue company = $100K+ recovered monthly.

--  BUSINESS COMPLAINT:
--  "We get thousands of people adding products to cart daily but
--   only ~28% actually checkout. We're losing millions."
--
--  DECISIONS ENABLED:
--  (1) Which step in checkout causes the biggest drop?
--  (2) Which customer segments abandon most?
--  (3) When and what triggers recovery (email, discount)?
-- ================================================================

CREATE DATABASE ecommerce;
-- ── SCHEMA ──────────────────────────────────────────────────────────────────
CREATE TABLE sessions (
    session_id      VARCHAR(30) PRIMARY KEY,
    customer_id     VARCHAR(20),           -- NULL = guest
    session_date    DATE,
    device_type     VARCHAR(20),           -- 'mobile','desktop','tablet'
    traffic_source  VARCHAR(30),           -- 'organic','paid','email','direct','social'
    country         VARCHAR(30),
    session_start   TIMESTAMPTZ,
    session_end     TIMESTAMPTZ
);

CREATE TABLE funnel_events (
    event_id        VARCHAR(30) PRIMARY KEY,
    session_id      VARCHAR(30),
    event_type      VARCHAR(40),           -- 'view_product','add_to_cart','begin_checkout','add_payment_info','purchase_complete'
    event_at        TIMESTAMPTZ,
    product_id      VARCHAR(20),
    cart_value      DECIMAL(10,2)
);

CREATE TABLE carts (
    cart_id         VARCHAR(30) PRIMARY KEY,
    session_id      VARCHAR(30),
    customer_id     VARCHAR(20),
    created_at      TIMESTAMPTZ,
    last_updated    TIMESTAMPTZ,
    cart_value      DECIMAL(10,2),
    item_count      INT,
    status          VARCHAR(20)            -- 'active','converted','abandoned','recovered'
);

CREATE TABLE orders (
    order_id        VARCHAR(20) PRIMARY KEY,
    cart_id         VARCHAR(30),
    customer_id     VARCHAR(20),
    session_id      VARCHAR(30),
    order_date      DATE,
    order_value     DECIMAL(10,2),
    payment_method  VARCHAR(30),
    discount_code   VARCHAR(20)
);

SELECT * FROM carts;
SELECT * FROM funnel_events;
SELECT * FROM orders;
SELECT * FROM sessions;


-- ================================================================
--  SOLUTION A: Full checkout funnel — where do people drop off?
--  Which step loses the most people?"
-- ================================================================
WITH funnel_counts AS (
    SELECT
        event_type,
        COUNT(DISTINCT session_id)  AS sessions,
        ROUND(AVG(cart_value), 2) AS avg_cart_value
    FROM funnel_events
    WHERE event_type IN (
        'view_product','add_to_cart',
        'begin_checkout','add_payment_info','purchase_complete'
    )
    GROUP BY event_type
),
ordered AS (
    SELECT *,
        CASE event_type
            WHEN 'view_product'      THEN 1
            WHEN 'add_to_cart'       THEN 2
            WHEN 'begin_checkout'    THEN 3
            WHEN 'add_payment_info'  THEN 4
            WHEN 'purchase_complete' THEN 5
        END AS order_step
    FROM funnel_counts
)
SELECT
    order_step,
    event_type AS funnel_step,
    sessions,
    LAG(sessions) OVER (ORDER BY order_step)    AS prev_step_sessions,
    ROUND(sessions / NULLIF(LAG(sessions) OVER (ORDER BY order_step), 0) * 100, 1) AS step_conversion_pct,
    ROUND((LAG(sessions) OVER (ORDER BY order_step) - sessions)
        / NULLIF(FIRST_VALUE(sessions) OVER (ORDER BY order_step), 0) * 100, 1) AS pct_lost_from_top,
	ROUND(sessions / FIRST_VALUE(sessions) OVER (ORDER BY order_step) * 100 ,2) AS conversion_pct,
    avg_cart_value
FROM ordered
ORDER BY order_step;

-- ================================================================
--  SOLUTION B: Abandonment by device + traffic source
--  Estimated revenue lost.
-- ================================================================
WITH session_outcomes AS (
    SELECT
        s.session_id,
        s.device_type,
        s.traffic_source,
        s.country,
        MAX(CASE WHEN fe.event_type = 'add_to_cart'      THEN 1 ELSE 0 END) AS added_to_cart,
        MAX(CASE WHEN fe.event_type = 'purchase_complete' THEN 1 ELSE 0 END) AS purchased
    FROM sessions s
    LEFT JOIN funnel_events fe ON s.session_id = fe.session_id
    GROUP BY s.session_id, s.device_type, s.traffic_source, s.country
)
SELECT
    device_type,
    traffic_source,
    COUNT(*)  AS total_sessions,
    SUM(added_to_cart) AS added_to_cart,
    SUM(purchased) AS purchased,
    ROUND(SUM(added_to_cart)/ NULLIF(COUNT(*), 0) * 100, 1)  AS cart_rate_pct,
    ROUND((SUM(added_to_cart) - SUM(purchased)) / NULLIF(SUM(added_to_cart), 0) * 100, 1) AS abandonment_rate_pct,
    ROUND(AVG(c.cart_value), 2)  AS avg_abandoned_cart_value,
    ROUND((SUM(added_to_cart) - SUM(purchased)) * AVG(c.cart_value), 2)   AS est_revenue_lost
FROM session_outcomes so
LEFT JOIN carts c ON so.session_id = c.session_id AND c.status = 'abandoned'
GROUP BY device_type, traffic_source
ORDER BY est_revenue_lost DESC;
