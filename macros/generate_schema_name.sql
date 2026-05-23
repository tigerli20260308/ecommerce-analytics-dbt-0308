{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {{ log("target.name = " ~ target.name, info=true) }}
    {{ log("target.schema = " ~ target.schema, info=true) }}
    {{ log("custom_schema = " ~ custom_schema_name, info=true) }}

    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- elif target.name == 'prod' -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ default_schema }}_{{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}