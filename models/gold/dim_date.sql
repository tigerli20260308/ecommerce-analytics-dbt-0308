{{
    config(
        materialized = 'table',
        tags         = ['gold', 'daily']
    )
}}

-- uses dbt_utils.date_spine to generate a date table
-- very useful for BI tools that need a date dimension

WITH date_spine AS (
    {{
        dbt_utils.date_spine(
            datepart   = "day",
            start_date = "cast('2023-01-01' as date)",
            end_date   = "cast('2025-12-31' as date)"
        )
    }}
),

final AS (
    SELECT
        date_day                                AS date_id,
        date_day                                AS full_date,
        EXTRACT(year  FROM date_day)::INTEGER   AS year,
        EXTRACT(month FROM date_day)::INTEGER   AS month,
        EXTRACT(day   FROM date_day)::INTEGER   AS day,
        EXTRACT(dow   FROM date_day)::INTEGER   AS day_of_week,
        DAYNAME(date_day)                       AS day_name,
        MONTHNAME(date_day)                     AS month_name,
        DATE_TRUNC('quarter', date_day)         AS quarter_start,
        EXTRACT(quarter FROM date_day)::INTEGER AS quarter,
        CASE WHEN EXTRACT(dow FROM date_day)
            IN (0, 6)
            THEN FALSE ELSE TRUE
        END                                     AS is_weekday,
        DATE_TRUNC('week', date_day)            AS week_start,
        DATE_TRUNC('month', date_day)           AS month_start,
        DATE_TRUNC('year', date_day)            AS year_start
    FROM date_spine
)

SELECT * FROM final