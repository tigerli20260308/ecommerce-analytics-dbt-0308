WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_products') }}
),

renamed AS (
    SELECT
        product_id::INTEGER                     AS product_id,
        product_name::VARCHAR                   AS product_name,
        category::VARCHAR                       AS category,
        subcategory::VARCHAR                    AS subcategory,
        unit_price::FLOAT                       AS unit_price,
        cost_price::FLOAT                       AS cost_price,
        sku::VARCHAR                            AS sku,
        is_active::BOOLEAN                      AS is_active,
        created_at::DATE                        AS created_at,

        -- derived columns
        unit_price - cost_price                 AS gross_margin,
        ROUND(
            (unit_price - cost_price)
            / NULLIF(unit_price, 0) * 100
        , 2)                                    AS gross_margin_pct
    FROM source
)

SELECT * FROM renamed