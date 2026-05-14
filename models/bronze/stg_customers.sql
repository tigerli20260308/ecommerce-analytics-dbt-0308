WITH source AS (
    SELECT * FROM {{ source('raw', 'raw_customers') }}
),

renamed AS (
    SELECT
        customer_id::INTEGER                    AS customer_id,
        first_name::VARCHAR                     AS first_name,
        last_name::VARCHAR                      AS last_name,
        LOWER(email)::VARCHAR                   AS email,
        phone::VARCHAR                          AS phone,
        UPPER(country)::VARCHAR                 AS country_code,
        city::VARCHAR                           AS city,
        created_at::TIMESTAMP                   AS created_at,
        updated_at::TIMESTAMP                   AS updated_at,

        -- derived columns
        first_name || ' ' || last_name          AS full_name,
        DATEDIFF('day',
            created_at::DATE,
            CURRENT_DATE)                       AS customer_age_days
    FROM source
)

SELECT * FROM renamed