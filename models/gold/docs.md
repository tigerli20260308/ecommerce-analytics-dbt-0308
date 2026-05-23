{% docs dim_customers %}
Customer dimension table containing one row per customer.
Includes order history metrics and customer segmentation.
Updated daily via dbt scheduled job.

Segments:
- no_orders: registered but never purchased
- new: exactly 1 order
- returning: 2-3 orders
- loyal: 4+ orders
{% enddocs %}

{% docs fct_orders %}
Order fact table containing one row per order.
Joins orders with customer info, payment status and SLA config.
Used by sales dashboard and finance reporting.

Key metrics:
- order_total: net value after discounts
- is_overdue: whether order exceeded SLA days
- has_successful_payment: payment confirmed
{% enddocs %}

{% docs customer_segment %}
Customer segment derived from total order count.

Values:
- no_orders: customer registered but never ordered
- new: exactly 1 completed order
- returning: 2 to 3 orders
- loyal: 4 or more orders

Recalculated on every dbt run.
{% enddocs %}

{% docs fct_payments %}
Payment fact table containing one row per payment transaction.
Includes processing fees and net payment amounts.
{% enddocs %}

{% docs dim_products %}
Product dimension table with sales performance metrics.
Includes revenue tier and sales velocity classifications.
{% enddocs %}