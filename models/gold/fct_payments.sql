{{
    config(
        materialized = 'table',
        tags         = ['gold', 'daily', 'payments']
    )
}}

WITH payments AS (
    SELECT * FROM {{ ref('stg_payments') }}
),

orders AS (
    SELECT
        order_id,
        customer_id,
        order_date,
        shipping_country_code
    FROM {{ ref('stg_orders') }}
),

payment_methods AS (
    SELECT * FROM {{ ref('payment_method_types') }}
),

final AS (
    SELECT
        p.payment_id,
        p.order_id,
        p.payment_method,
        p.amount,
        p.currency,
        p.payment_status,
        p.transaction_id,
        p.created_at,
        p.is_successful,

        -- order context
        o.customer_id,
        o.order_date,
        o.shipping_country_code,

        -- payment method context
        pm.payment_category,
        pm.is_digital,
        pm.processing_fee_pct,
        ROUND(
            p.amount * pm.processing_fee_pct
        , 2)                                    AS processing_fee_amount,
        ROUND(
            p.amount - (p.amount * pm.processing_fee_pct)
        , 2)                                    AS net_payment_amount
    FROM payments p
    LEFT JOIN orders o
        ON p.order_id = o.order_id
    LEFT JOIN payment_methods pm
        ON p.payment_method = pm.payment_method
)

SELECT * FROM final