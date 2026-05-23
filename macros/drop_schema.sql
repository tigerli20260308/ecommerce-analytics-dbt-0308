-- macros/drop_schema.sql
-- drops CI schema after PR closes
-- called by dbt-pr-cleanup.yml

{% macro drop_schema(schema_name) %}

    {% set drop_query %}
        DROP SCHEMA IF EXISTS
        {{ target.database }}.{{ schema_name }}
        CASCADE
    {% endset %}

    {% if execute %}
        {% do run_query(drop_query) %}
        {{ log(
            "✅ Dropped schema: " ~
            target.database ~ "." ~ schema_name,
            info=true
        ) }}
    {% endif %}

{% endmacro %}
