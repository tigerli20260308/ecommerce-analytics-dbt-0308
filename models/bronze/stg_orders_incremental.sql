{{
    config(
        materialized = 'incremental',
        unique_key   = 'order_id',
        on_schema_change = 'sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_orders') }}

    {% if is_incremental() %}
        WHERE created_at::TIMESTAMP > (
            SELECT MAX(created_at)
            FROM {{ this }}
        )
    {% endif %}
),

renamed AS (
    SELECT
        order_id::INTEGER                       AS order_id,
        customer_id::INTEGER                    AS customer_id,
        order_date::DATE                        AS order_date,
        LOWER(status)::VARCHAR                  AS status,
        shipping_address::VARCHAR               AS shipping_address,
        shipping_city::VARCHAR                  AS shipping_city,
        UPPER(shipping_country)::VARCHAR        AS shipping_country_code,
        NULLIF(discount_code, '')::VARCHAR      AS discount_code,
        created_at::TIMESTAMP                   AS created_at,
        updated_at::TIMESTAMP                   AS updated_at,
        DATEDIFF('day',
            order_date::DATE,
            CURRENT_DATE)                       AS order_age_days,
        CASE
            WHEN discount_code IS NOT NULL
            AND  discount_code != ''
            THEN TRUE ELSE FALSE
        END                                     AS has_discount
    FROM source
)

SELECT * FROM renamed