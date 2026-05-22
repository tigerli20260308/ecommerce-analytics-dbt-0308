WITH customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

order_summary AS (
    SELECT
        customer_id,
        COUNT(*)                                AS total_orders,
        COUNT(CASE WHEN status = 'completed'
            THEN 1 END)                         AS completed_orders,
        COUNT(CASE WHEN status = 'cancelled'
            THEN 1 END)                         AS cancelled_orders,
        MIN(order_date)                         AS first_order_date,
        MAX(order_date)                         AS last_order_date,
        DATEDIFF('day',
            MIN(order_date),
            MAX(order_date))                    AS days_as_customer,
        SUM(CASE WHEN has_discount
            THEN 1 ELSE 0 END)                  AS discount_order_count
    FROM orders
    GROUP BY customer_id
),

final AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.email,
        c.country_code,
        c.city,
        c.customer_age_days,
        c.created_at,

        -- order metrics
        COALESCE(os.total_orders, 0)            AS total_orders,
        COALESCE(os.completed_orders, 0)        AS completed_orders,
        COALESCE(os.cancelled_orders, 0)        AS cancelled_orders,
        os.first_order_date,
        os.last_order_date,
        COALESCE(os.days_as_customer, 0)        AS days_as_customer,
        COALESCE(os.discount_order_count, 0)    AS discount_order_count,

        -- derived metrics
        CASE
            WHEN COALESCE(os.total_orders, 0) = 0
            THEN 'no_orders'
            WHEN COALESCE(os.total_orders, 0) = 1
            THEN 'new'
            WHEN COALESCE(os.total_orders, 0) <= 3
            THEN 'returning'
            ELSE 'loyal'
        END                                     AS customer_segment
    FROM customers c
    LEFT JOIN order_summary os
        ON c.customer_id = os.customer_id
)

SELECT * FROM final