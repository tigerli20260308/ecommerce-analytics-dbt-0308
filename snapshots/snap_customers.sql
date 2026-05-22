{% snapshot snap_customers %}

{{
    config(
        target_schema = 'snapshots',
        unique_key    = 'customer_id',
        strategy      = 'timestamp',
        updated_at    = 'updated_at'
    )
}}

SELECT
    customer_id::INTEGER    AS customer_id,
    first_name::VARCHAR     AS first_name,
    last_name::VARCHAR      AS last_name,
    LOWER(email)::VARCHAR   AS email,
    phone::VARCHAR          AS phone,
    UPPER(country)::VARCHAR AS country_code,
    city::VARCHAR           AS city,
    created_at::TIMESTAMP   AS created_at,
    updated_at::TIMESTAMP   AS updated_at
FROM {{ source('raw', 'raw_customers') }}

{% endsnapshot %}