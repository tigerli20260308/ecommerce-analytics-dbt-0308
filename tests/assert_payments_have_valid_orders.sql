-- every payment must have a valid order
-- returns orphaned payments (no matching order)

SELECT
    p.payment_id,
    p.order_id
FROM {{ ref('fct_payments') }} p
LEFT JOIN {{ ref('fct_orders') }} o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL