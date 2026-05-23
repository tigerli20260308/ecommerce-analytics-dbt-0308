-- detects new columns in source tables
-- compares actual Snowflake columns
-- against expected columns defined here
-- run with: dbt run-operation detect_schema_drift

{% macro detect_schema_drift() %}

    {% set expected_columns = {
        'raw_customers': [
            'customer_id','first_name','last_name',
            'email','phone','country','city',
            'created_at','updated_at'
        ],
        'raw_orders': [
            'order_id','customer_id','order_date',
            'status','shipping_address','shipping_city',
            'shipping_country','discount_code',
            'created_at','updated_at'
        ],
        'raw_products': [
            'product_id','product_name','category',
            'subcategory','unit_price','cost_price',
            'sku','is_active','created_at'
        ],
        'raw_payments': [
            'payment_id','order_id','payment_method',
            'amount','currency','status',
            'transaction_id','created_at'
        ],
        'raw_events': [
            'event_id','session_id','customer_id',
            'event_type','page_url','product_id',
            'created_at'
        ]
    } %}

    {% for table_name, expected_cols in expected_columns.items() %}

        {% set query %}
            SELECT
                LOWER(column_name) AS column_name
            FROM ecommerce_dev.information_schema.columns
            WHERE LOWER(table_schema) = 'raw'
            AND   LOWER(table_name)   = '{{ table_name }}'
            ORDER BY ordinal_position
        {% endset %}

        {% set results = run_query(query) %}

        {% if execute %}
            {% set actual_cols = [] %}
            {% for row in results %}
                {% do actual_cols.append(row['column_name']) %}
            {% endfor %}

            {% set new_cols = [] %}
            {% for col in actual_cols %}
                {% if col not in expected_cols %}
                    {% do new_cols.append(col) %}
                {% endif %}
            {% endfor %}

            {% set missing_cols = [] %}
            {% for col in expected_cols %}
                {% if col not in actual_cols %}
                    {% do missing_cols.append(col) %}
                {% endif %}
            {% endfor %}

            {% if new_cols | length > 0 %}
                {{ log(
                    '⚠️  SCHEMA DRIFT DETECTED in ' ~
                    table_name ~ ': NEW columns: ' ~
                    new_cols | join(', '),
                    info=true
                ) }}
            {% endif %}

            {% if missing_cols | length > 0 %}
                {{ log(
                    '❌  SCHEMA DRIFT DETECTED in ' ~
                    table_name ~ ': MISSING columns: ' ~
                    missing_cols | join(', '),
                    info=true
                ) }}
            {% endif %}

            {% if new_cols | length == 0
               and missing_cols | length == 0 %}
                {{ log(
                    '✅  ' ~ table_name ~
                    ': schema matches expected',
                    info=true
                ) }}
            {% endif %}

        {% endif %}

    {% endfor %}

{% endmacro %}