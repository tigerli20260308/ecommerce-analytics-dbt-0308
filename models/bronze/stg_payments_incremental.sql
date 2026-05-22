{{
    config(
        materialized = 'incremental',
        unique_key   = 'payment_id',
        on_schema_change = 'sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_payments') }}

    {% if is_incremental() %}
        WHERE created_at::TIMESTAMP > (
            SELECT MAX(created_at)
            FROM {{ this }}
        )
    {% endif %}
),

renamed AS (
    SELECT
        payment_id::INTEGER                     AS payment_id,
        order_id::INTEGER                       AS order_id,
        LOWER(payment_method)::VARCHAR          AS payment_method,
        amount::FLOAT                           AS amount,
        UPPER(currency)::VARCHAR                AS currency,
        LOWER(status)::VARCHAR                  AS payment_status,
        transaction_id::VARCHAR                 AS transaction_id,
        created_at::TIMESTAMP                   AS created_at,
        CASE
            WHEN LOWER(status) = 'success'
            THEN TRUE ELSE FALSE
        END                                     AS is_successful
    FROM source
)

SELECT * FROM renamed