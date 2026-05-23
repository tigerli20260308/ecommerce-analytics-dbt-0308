{{
    config(
        materialized = 'table',
        tags         = ['gold', 'daily', 'customers']
    )
}}

WITH customer_orders AS (
    SELECT * FROM {{ ref('int_customer_orders') }}
),

final AS (
    SELECT
        customer_id,
        full_name,
        email,
        country_code,
        city,
        customer_age_days,
        created_at,

        -- order metrics
        total_orders,
        completed_orders,
        cancelled_orders,
        first_order_date,
        last_order_date,
        days_as_customer,
        discount_order_count,
        customer_segment,

        -- flags
        CASE WHEN total_orders > 0
            THEN TRUE ELSE FALSE
        END                                     AS is_active_customer,
        CASE WHEN last_order_date >=
            DATEADD('day', -90, CURRENT_DATE)
            THEN TRUE ELSE FALSE
        END                                     AS is_recent_customer
    FROM customer_orders
)

SELECT * FROM final