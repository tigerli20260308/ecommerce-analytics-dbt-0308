-- completed orders must have successful payment
-- returns completed orders with no successful payment

SELECT
    o.order_id,
    o.status,
    o.order_total
FROM {{ ref('fct_orders') }} o
LEFT JOIN {{ ref('fct_payments') }} p
    ON o.order_id = p.order_id
    AND p.is_successful = TRUE
WHERE o.status = 'completed'
AND   p.payment_id IS NULL