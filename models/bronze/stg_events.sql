-- CORRECT ✅
WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_events') }}
    -- no filter in bronze
    -- load ALL events
    -- filter in silver/gold if needed
),

renamed AS (
    SELECT
        event_id::VARCHAR                       AS event_id,
        session_id::VARCHAR                     AS session_id,
        customer_id::INTEGER                    AS customer_id,
        LOWER(event_type)::VARCHAR              AS event_type,
        page_url::VARCHAR                       AS page_url,
        NULLIF(product_id, '')::INTEGER         AS product_id,
        created_at::TIMESTAMP                   AS created_at,
        created_at::DATE                        AS event_date,
        DATE_TRUNC('hour',
            created_at::TIMESTAMP)              AS event_hour
    FROM source
)

SELECT * FROM renamed