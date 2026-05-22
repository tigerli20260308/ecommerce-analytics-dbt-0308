{{
    config(materialized='ephemeral')
}}

-- ephemeral = no physical table
-- just a CTE used by other models
-- never stored in Snowflake
-- fastest possible — no storage cost

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price,
    oi.discount_amount,
    oi.gross_amount,
    oi.net_amount,
    p.product_name,
    p.category,
    p.gross_margin_pct
FROM {{ ref('stg_order_items') }} oi
LEFT JOIN {{ ref('stg_products') }} p
    ON oi.product_id = p.product_id