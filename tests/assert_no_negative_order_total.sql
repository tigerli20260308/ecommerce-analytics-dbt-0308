-- this test FAILS if any rows are returned
-- returns rows where order_total is negative

SELECT
    order_id,
    order_total
FROM {{ ref('fct_orders') }}
WHERE order_total < 0