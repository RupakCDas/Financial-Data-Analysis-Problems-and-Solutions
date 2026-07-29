CREATE TABLE IF NOT EXISTS customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    signup_date VARCHAR(20),
    city_tier INT,            -- 1=metro, 2=mid, 3=small
    preferred_device  VARCHAR(30),    -- 'Mobile','Desktop','Tablet'
    preferred_payment VARCHAR(30),    -- 'Credit Card','Debit Card','UPI','Wallet'
    gender VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    order_date DATE,
    category VARCHAR(60),
    order_value VARCHAR(20), -- DECIMAL(10,2),
    is_returned VARCHAR(20),  -- BOOLEAN DEFAULT FALSE,
    satisfaction_score INT             -- 1-5
);

CREATE TABLE IF NOT EXISTS churn_labels (
    customer_id VARCHAR(20) PRIMARY KEY,
    churned  VARCHAR(20), -- BOOLEAN,        -- TRUE = churned in last 90 days
    churn_date DATE
);

SELECT * FROM customers ;
SELECT * FROM orders ;
SELECT * FROM churn_labels ;

-- ================================================================
--  SOLUTION A: Confirm churn rate & segment by profile
--  "Which customer types are churning most?"
-- ================================================================
SELECT
    c.city_tier,
    c.preferred_device,
    c.preferred_payment,
    COUNT(*)   AS total_customers,
    SUM(CASE WHEN cl.churned= 'True' THEN 1 ELSE 0 END)  AS churned_count,
	ROUND (SUM(CASE WHEN cl.churned= 'True' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2)  AS churn_rate_pct,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(AVG(o.satisfaction_score), 2)  AS avg_satisfaction
FROM customers c
JOIN churn_labels cl ON c.customer_id = cl.customer_id
LEFT JOIN orders o   ON c.customer_id = o.customer_id
GROUP BY c.city_tier, c.preferred_device, c.preferred_payment
ORDER BY churn_rate_pct DESC
LIMIT 20; -- FINISH

-- ================================================================
--  SOLUTION B: RFM (Recency, Frequency, and Monetary value).Segmentation to find at-risk customers
--  Recency + Frequency + Monetary — the classic retention model
-- ================================================================
WITH rfm_raw AS (
    SELECT
        customer_id,
        STR_TO_DATE(CURRENT_DATE, '%Y-%m-%d') - MAX(STR_TO_DATE(order_date, '%Y-%m-%d')) AS recency_days,
        COUNT(order_id) AS frequency,
        SUM(order_value)  AS monetary
    FROM orders
    GROUP BY customer_id
),
rfm_scored AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY recency_days ASC) AS r_score,  -- 5=most recent
        NTILE(5) OVER (ORDER BY frequency DESC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC) AS m_score
    FROM rfm_raw 
),
rfm_segments AS (
    SELECT *,
        (r_score + f_score + m_score)  AS rfm_total,
        CASE
            WHEN r_score = 1 AND f_score = 1 THEN 'best'
            WHEN r_score = 2 AND f_score = 2 THEN 'better'
            WHEN r_score = 3 AND f_score = 3 THEN 'good'
            WHEN r_score = 4 AND f_score = 4 THEN 'At Risk'
            WHEN r_score = 5 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scored
)
SELECT
    rfm_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(recency_days),2) AS avg_recency_days,
    ROUND(AVG(frequency), 1) AS avg_orders,
    ROUND(AVG(monetary), 2) AS avg_ltv,
    ROUND(AVG(monetary) * COUNT(*), 2) AS segment_revenue
FROM rfm_segments
GROUP BY rfm_segment
ORDER BY segment_revenue DESC;
