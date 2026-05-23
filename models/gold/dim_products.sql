{{
    config(
        materialized = 'table',
        tags         = ['gold', 'daily', 'products']
    )
}}

WITH product_performance AS (
    SELECT * FROM {{ ref('int_product_performance') }}
),

final AS (
    SELECT
        product_id,
        product_name,
        category,
        subcategory,
        unit_price,
        cost_price,
        gross_margin,
        gross_margin_pct,
        is_active,

        -- performance metrics
        orders_count,
        total_units_sold,
        total_revenue,
        total_discounts,
        avg_selling_price,
        view_count,
        add_to_cart_count,
        cart_rate_pct,

        -- derived flags
        CASE
            WHEN total_revenue > 200
            THEN 'high'
            WHEN total_revenue > 100
            THEN 'medium'
            ELSE 'low'
        END                                     AS revenue_tier,
        CASE
            WHEN orders_count = 0
            THEN 'no_sales'
            WHEN orders_count <= 2
            THEN 'slow_mover'
            ELSE 'fast_mover'
        END                                     AS sales_velocity
    FROM product_performance
)

SELECT * FROM final