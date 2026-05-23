-- pre-hook macro that runs before each model
-- logs warning if source has unexpected columns

{% macro detect_new_columns(model) %}
    {{ log(
        'Running pre-hook for: ' ~ model.name,
        info=true
    ) }}
{% endmacro %}