-- macros/check_source_freshness.sql
{% macro check_source_freshness(table, timestamp_col, warn_hours=24) %}
    SELECT
        '{{ table }}'                           AS source_table,
        MAX({{ timestamp_col }})                AS last_loaded_at,
        DATEDIFF('hour',
            MAX({{ timestamp_col }}),
            CURRENT_TIMESTAMP)                  AS hours_since_load,
        CASE
            WHEN DATEDIFF('hour',
                MAX({{ timestamp_col }}),
                CURRENT_TIMESTAMP) > {{ warn_hours }}
            THEN 'STALE'
            ELSE 'FRESH'
        END                                     AS freshness_status
    FROM {{ table }}
{% endmacro %}