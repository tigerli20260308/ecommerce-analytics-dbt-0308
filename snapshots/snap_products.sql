{% snapshot snap_products %}

{{
    config(
        target_schema  = 'snapshots',
        unique_key     = 'product_id',
        strategy       = 'check',
        check_cols     = ['unit_price', 'cost_price',
                          'is_active', 'product_name']
    )
}}

SELECT
    product_id::INTEGER     AS product_id,
    product_name::VARCHAR   AS product_name,
    category::VARCHAR       AS category,
    subcategory::VARCHAR    AS subcategory,
    unit_price::FLOAT       AS unit_price,
    cost_price::FLOAT       AS cost_price,
    sku::VARCHAR            AS sku,
    is_active::BOOLEAN      AS is_active,
    created_at::DATE        AS created_at
FROM {{ source('raw', 'raw_products') }}

{% endsnapshot %}