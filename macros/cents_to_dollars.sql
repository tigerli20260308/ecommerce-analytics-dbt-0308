-- converts cents to dollars
-- usage: {{ cents_to_dollars('amount_cents') }}

{% macro cents_to_dollars(column_name, scale=2) %}
    ROUND({{ column_name }} / 100, {{ scale }})
{% endmacro %}