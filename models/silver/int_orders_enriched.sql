WITH orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

payments AS (
    SELECT
        order_id,
        SUM(amount)                             AS total_paid,
        COUNT(*)                                AS payment_count,
        MAX(CASE WHEN is_successful
            THEN 1 ELSE 0 END)                  AS has_successful_payment,
        MAX(payment_status)                     AS latest_payment_status
    FROM {{ ref('stg_payments') }}
    GROUP BY order_id
),

order_items AS (
    SELECT
        order_id,
        SUM(net_amount)                         AS order_total,
        SUM(gross_amount)                       AS order_gross_total,
        SUM(discount_amount)                    AS total_discount,
        COUNT(*)                                AS item_count,
        SUM(quantity)                           AS total_quantity
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
),

final AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.status,
        o.shipping_city,
        o.shipping_country_code,
        o.discount_code,
        o.has_discount,
        o.order_age_days,

        -- customer info
        c.full_name                             AS customer_name,
        c.email                                 AS customer_email,
        c.country_code                          AS customer_country,

        -- order financials
        COALESCE(oi.order_total, 0)             AS order_total,
        COALESCE(oi.order_gross_total, 0)       AS order_gross_total,
        COALESCE(oi.total_discount, 0)          AS total_discount,
        COALESCE(oi.item_count, 0)              AS item_count,
        COALESCE(oi.total_quantity, 0)          AS total_quantity,

        -- payment info ← COALESCE added
        COALESCE(p.total_paid, 0)               AS total_paid,
        COALESCE(p.payment_count, 0)            AS payment_count,
        COALESCE(p.has_successful_payment, 0)   AS has_successful_payment,
        p.latest_payment_status                 AS latest_payment_status

    FROM orders o
    LEFT JOIN customers c
        ON o.customer_id = c.customer_id
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    LEFT JOIN payments p
        ON o.order_id = p.order_id
)

SELECT * FROM final