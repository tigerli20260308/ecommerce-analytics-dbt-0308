{{
    config(
        materialized = 'table',
        tags         = ['gold', 'daily', 'orders']
    )
}}

-- testing CI/CD pipeline
WITH orders_enriched AS (
    SELECT * FROM {{ ref('int_orders_enriched') }}
),

status_config AS (
    SELECT * FROM {{ ref('order_status_config') }}
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
        o.customer_name,
        o.customer_email,
        o.customer_country,

        -- financials
        o.order_total,
        o.order_gross_total,
        o.total_discount,
        o.item_count,
        o.total_quantity,

        -- payment info
        o.total_paid,
        o.payment_count,
        o.has_successful_payment,
        o.latest_payment_status,

        -- status config
        sc.status_label,
        sc.is_terminal,
        sc.sla_days,

        -- derived
        CASE
            WHEN o.order_age_days > sc.sla_days
            AND sc.is_terminal = FALSE
            THEN TRUE ELSE FALSE
        END                                     AS is_overdue
    FROM orders_enriched o
    LEFT JOIN status_config sc
        ON o.status = sc.status
)

SELECT * FROM final