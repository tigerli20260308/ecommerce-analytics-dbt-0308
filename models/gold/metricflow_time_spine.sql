{{
    config(
        materialized = 'table',
        schema = 'gold'
    )
}}

WITH spine AS (
    SELECT
        DATEADD(
            DAY,
            SEQ4(),
            '2023-01-01'::DATE
        ) AS date_day
    FROM TABLE(GENERATOR(ROWCOUNT => 1461))
)

SELECT date_day
FROM spine
WHERE date_day <= '2026-12-31'::DATE