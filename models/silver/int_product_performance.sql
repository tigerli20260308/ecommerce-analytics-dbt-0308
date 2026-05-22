WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_order_items') }}
),

events AS (
    SELECT * FROM {{ ref('stg_events') }}
),

product_sales AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id)                AS orders_count,
        SUM(quantity)                           AS total_units_sold,
        SUM(net_amount)                         AS total_revenue,
        SUM(gross_amount)                       AS total_gross_revenue,
        SUM(discount_amount)                    AS total_discounts,
        AVG(unit_price)                         AS avg_selling_price
    FROM order_items
    GROUP BY product_id
),

product_views AS (
    SELECT
        product_id,
        COUNT(CASE WHEN event_type = 'page_view'
            THEN 1 END)                         AS view_count,
        COUNT(CASE WHEN event_type = 'add_to_cart'
            THEN 1 END)                         AS add_to_cart_count,
        COUNT(CASE WHEN event_type = 'purchase'
            THEN 1 END)                         AS purchase_count
    FROM events
    WHERE product_id IS NOT NULL
    GROUP BY product_id
),

final AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.unit_price,
        p.cost_price,
        p.gross_margin,
        p.gross_margin_pct,
        p.is_active,

        -- sales metrics
        COALESCE(ps.orders_count, 0)            AS orders_count,
        COALESCE(ps.total_units_sold, 0)        AS total_units_sold,
        COALESCE(ps.total_revenue, 0)           AS total_revenue,
        COALESCE(ps.total_discounts, 0)         AS total_discounts,
        COALESCE(ps.avg_selling_price, 0)       AS avg_selling_price,

        -- engagement metrics
        COALESCE(pv.view_count, 0)              AS view_count,
        COALESCE(pv.add_to_cart_count, 0)       AS add_to_cart_count,

        -- derived metrics
        CASE
            WHEN COALESCE(pv.view_count, 0) = 0
            THEN 0
            ELSE ROUND(
                COALESCE(pv.add_to_cart_count, 0)
                / pv.view_count * 100
            , 2)
        END                                     AS cart_rate_pct
    FROM products p
    LEFT JOIN product_sales ps
        ON p.product_id = ps.product_id
    LEFT JOIN product_views pv
        ON p.product_id = pv.product_id
)

SELECT * FROM final