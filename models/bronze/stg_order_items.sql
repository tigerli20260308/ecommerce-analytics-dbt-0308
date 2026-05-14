WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_order_items') }}
),

renamed AS (
    SELECT
        order_item_id::INTEGER                  AS order_item_id,
        order_id::INTEGER                       AS order_id,
        product_id::INTEGER                     AS product_id,
        quantity::INTEGER                       AS quantity,
        unit_price::FLOAT                       AS unit_price,
        discount_amount::FLOAT                  AS discount_amount,
        created_at::TIMESTAMP                   AS created_at,

        -- derived columns
        (unit_price * quantity)                 AS gross_amount,
        (unit_price * quantity)
            - discount_amount                   AS net_amount
    FROM source
)

SELECT * FROM renamed