{{
    config(
        materialized = 'table',
        meta = {
            'time_spine': true
        }
    )
}}

SELECT
    date_day AS date_day
FROM (
    {{
        dbt_utils.date_spine(
            datepart   = "day",
            start_date = "cast('2023-01-01' as date)",
            end_date   = "cast('2026-12-31' as date)"
        )
    }}
)