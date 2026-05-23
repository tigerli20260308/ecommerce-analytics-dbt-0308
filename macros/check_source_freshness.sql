-- custom freshness check macro
-- workaround for dbt Fusion 2.0 missing freshness support
-- usage: dbt run-operation check_source_freshness

{% macro check_source_freshness() %}

    {% set sources = [
        {'table': 'ecommerce_dev.raw.raw_customers',
         'ts_col': 'created_at', 'warn_hours': 24},
        {'table': 'ecommerce_dev.raw.raw_orders',
         'ts_col': 'created_at', 'warn_hours': 24},
        {'table': 'ecommerce_dev.raw.raw_payments',
         'ts_col': 'created_at', 'warn_hours': 24},
        {'table': 'ecommerce_dev.raw.raw_events',
         'ts_col': 'created_at', 'warn_hours': 1}
    ] %}

    {% for source in sources %}
        {% set query %}
            SELECT
                '{{ source.table }}'            AS source_table,
                MAX({{ source.ts_col }})         AS last_loaded_at,
                DATEDIFF('hour',
                    MAX({{ source.ts_col }}),
                    CURRENT_TIMESTAMP)           AS hours_since_load,
                CASE
                    WHEN DATEDIFF('hour',
                        MAX({{ source.ts_col }}),
                        CURRENT_TIMESTAMP)
                        > {{ source.warn_hours }}
                    THEN 'STALE'
                    ELSE 'FRESH'
                END                             AS freshness_status
            FROM {{ source.table }}
        {% endset %}

        {% set results = run_query(query) %}
        {% if execute %}
            {% for row in results %}
                {{ log(
                    row['source_table'] ~ ' | ' ~
                    row['freshness_status'] ~ ' | ' ~
                    'Last loaded: ' ~ row['last_loaded_at'] ~ ' | ' ~
                    row['hours_since_load'] ~ ' hours ago',
                    info=true
                ) }}
            {% endfor %}
        {% endif %}
    {% endfor %}

{% endmacro %}